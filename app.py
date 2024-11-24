#!/usr/bin/env python3
import asyncio
import logging
import os
import uuid
from contextlib import asynccontextmanager
from typing import Annotated

import blibs
import httpx
from asgi_logger.middleware import AccessLoggerMiddleware
from fastapi import FastAPI
from fastapi import Header
from fastapi import HTTPException
from fastapi.middleware import Middleware
from fastapi.responses import RedirectResponse

import webhook
from config import DefaultConfig
from db import database
from gitlab_model import MergeRequestPayload
from gitlab_model import PipelinePayload
from periodic_cleanup import periodic_cleanup

# from fastapi.middleware.cors import CORSMiddleware

config = DefaultConfig()

# Configure logging
blibs.init_root_logger()
logger = logging.getLogger(__name__)
logging.getLogger("urllib3").setLevel(logging.ERROR)
logging.getLogger("msrest").setLevel(logging.ERROR)
logging.getLogger("msal").setLevel(logging.ERROR)


@asynccontextmanager
async def lifespan(app: FastAPI):
    await database.connect()
    task = asyncio.create_task(periodic_cleanup(config, database))

    yield

    task.cancel()
    await database.disconnect()


app: FastAPI = FastAPI(
    title="Teams Notifier gitlab-mr-api",
    version=os.environ.get("VERSION", "v0.0.0-dev"),
    lifespan=lifespan,
    middleware=[
        Middleware(
            AccessLoggerMiddleware,  # type: ignore
            format='%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(L)ss',  # noqa # type: ignore
        )
    ],
)

# Configure CORS
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # Allows all origins
#     allow_credentials=True,
#     allow_methods=["*"],  # Allows all methods
#     allow_headers=["*"],  # Allows all headers
# )


@app.get("/", response_class=RedirectResponse, status_code=302)
async def root():
    return "/docs"


def validate_gitlab_token(token: str) -> None:
    if not config.is_valid_token(token):
        raise HTTPException(status_code=403, detail=f"Invalid gitlab token {token}")


def validate_uuid(val: str) -> str | None:
    try:
        return str(uuid.UUID(str(val)))
    except ValueError:
        return None


@app.post("/api/v1/gitlab-webhook")
async def handle_webhook(
    payload: MergeRequestPayload | PipelinePayload,
    x_conversation_token: Annotated[str, Header()],
    x_gitlab_token: Annotated[str, Header()],
):
    validate_gitlab_token(x_gitlab_token)
    conversation_tokens = list(
        filter(
            None,
            [validate_uuid(ct.strip()) for ct in x_conversation_token.split(",")],
        )
    )
    try:
        if isinstance(payload, MergeRequestPayload):
            await webhook.merge_request(payload, conversation_tokens)
        if isinstance(payload, PipelinePayload):
            await webhook.pipeline(payload, conversation_tokens)
        return {"status": "ok"}
    except httpx.HTTPStatusError as exc:
        raise HTTPException(
            status_code=exc.response.status_code,
            detail=exc.response.json(),
        )


if __name__ == "__main__":
    # fmt: off
    print(
        "use fastapi cli to run this app\n"
        "- fastapi run # for prod\n"
        "- fastapi dev # for dev :)\n"
    )
    # fmt: on

    # for debug entry point
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)