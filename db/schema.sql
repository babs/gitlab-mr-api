SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: gitlab_mr_api; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA gitlab_mr_api;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: gitlab_instance; Type: TABLE; Schema: gitlab_mr_api; Owner: -
--

CREATE TABLE gitlab_mr_api.gitlab_instance (
    gitlab_instance_id bigint NOT NULL,
    hostname character varying NOT NULL
);


--
-- Name: gitlab_instance_gitlab_instance_id_seq; Type: SEQUENCE; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE gitlab_mr_api.gitlab_instance ALTER COLUMN gitlab_instance_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME gitlab_mr_api.gitlab_instance_gitlab_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: merge_request_message_ref; Type: TABLE; Schema: gitlab_mr_api; Owner: -
--

CREATE TABLE gitlab_mr_api.merge_request_message_ref (
    merge_request_message_ref_id bigint NOT NULL,
    merge_request_ref_id bigint NOT NULL,
    conversation_token uuid NOT NULL,
    message_id uuid,
    failure jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: merge_request_message_ref_merge_request_message_ref_seq; Type: SEQUENCE; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE gitlab_mr_api.merge_request_message_ref ALTER COLUMN merge_request_message_ref_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME gitlab_mr_api.merge_request_message_ref_merge_request_message_ref_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: merge_request_ref; Type: TABLE; Schema: gitlab_mr_api; Owner: -
--

CREATE TABLE gitlab_mr_api.merge_request_ref (
    merge_request_ref_id bigint NOT NULL,
    gitlab_instance_id bigint NOT NULL,
    gitlab_project_id bigint NOT NULL,
    gitlab_merge_request_id bigint NOT NULL,
    gitlab_merge_request_iid bigint NOT NULL,
    merge_request_payload jsonb DEFAULT '{}'::jsonb,
    merge_request_extra_state jsonb DEFAULT '{}'::jsonb,
    head_pipeline_id bigint
);


--
-- Name: COLUMN merge_request_ref.gitlab_merge_request_id; Type: COMMENT; Schema: gitlab_mr_api; Owner: -
--

COMMENT ON COLUMN gitlab_mr_api.merge_request_ref.gitlab_merge_request_id IS 'merge request id instance wide';


--
-- Name: COLUMN merge_request_ref.gitlab_merge_request_iid; Type: COMMENT; Schema: gitlab_mr_api; Owner: -
--

COMMENT ON COLUMN gitlab_mr_api.merge_request_ref.gitlab_merge_request_iid IS 'merge request id project scoped (used for links etc)';


--
-- Name: merge_request_ref_merge_request_ref_id_seq; Type: SEQUENCE; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE gitlab_mr_api.merge_request_ref ALTER COLUMN merge_request_ref_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME gitlab_mr_api.merge_request_ref_merge_request_ref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: msg_to_delete; Type: TABLE; Schema: gitlab_mr_api; Owner: -
--

CREATE TABLE gitlab_mr_api.msg_to_delete (
    msg_to_delete_id bigint NOT NULL,
    message_id character varying NOT NULL,
    expire_at timestamp with time zone DEFAULT (now() + '00:05:00'::interval) NOT NULL
);


--
-- Name: msg_to_delete_msg_to_delete_id_seq; Type: SEQUENCE; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE gitlab_mr_api.msg_to_delete ALTER COLUMN msg_to_delete_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME gitlab_mr_api.msg_to_delete_msg_to_delete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: schema_migrations; Type: TABLE; Schema: gitlab_mr_api; Owner: -
--

CREATE TABLE gitlab_mr_api.schema_migrations (
    version character varying(128) NOT NULL
);


--
-- Name: gitlab_instance gitlab_instance_pkey; Type: CONSTRAINT; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE ONLY gitlab_mr_api.gitlab_instance
    ADD CONSTRAINT gitlab_instance_pkey PRIMARY KEY (gitlab_instance_id);


--
-- Name: merge_request_message_ref merge_request_message_ref_pkey; Type: CONSTRAINT; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE ONLY gitlab_mr_api.merge_request_message_ref
    ADD CONSTRAINT merge_request_message_ref_pkey PRIMARY KEY (merge_request_message_ref_id);


--
-- Name: merge_request_ref merge_request_ref_mr_identity_uniq; Type: CONSTRAINT; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE ONLY gitlab_mr_api.merge_request_ref
    ADD CONSTRAINT merge_request_ref_mr_identity_uniq UNIQUE (gitlab_instance_id, gitlab_project_id, gitlab_merge_request_iid);


--
-- Name: merge_request_ref merge_request_ref_pkey; Type: CONSTRAINT; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE ONLY gitlab_mr_api.merge_request_ref
    ADD CONSTRAINT merge_request_ref_pkey PRIMARY KEY (merge_request_ref_id);


--
-- Name: merge_request_message_ref mr_ref_conv_token_uniq; Type: CONSTRAINT; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE ONLY gitlab_mr_api.merge_request_message_ref
    ADD CONSTRAINT mr_ref_conv_token_uniq UNIQUE (merge_request_ref_id, conversation_token);


--
-- Name: msg_to_delete msg_to_delete_pkey; Type: CONSTRAINT; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE ONLY gitlab_mr_api.msg_to_delete
    ADD CONSTRAINT msg_to_delete_pkey PRIMARY KEY (msg_to_delete_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: gitlab_mr_api; Owner: -
--

ALTER TABLE ONLY gitlab_mr_api.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: gitlab_instance_hostname_lower_uniq; Type: INDEX; Schema: gitlab_mr_api; Owner: -
--

CREATE UNIQUE INDEX gitlab_instance_hostname_lower_uniq ON gitlab_mr_api.gitlab_instance USING btree (lower((hostname)::text));


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--
