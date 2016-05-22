--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: bold_english; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION bold_english (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR word WITH unaccent, english_stem;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR hword_part WITH unaccent, english_stem;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR hword WITH unaccent, english_stem;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION bold_english
    ADD MAPPING FOR file WITH simple;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: assets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assets (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    file character varying(500) NOT NULL,
    content_type character varying(100),
    meta hstore DEFAULT ''::hstore NOT NULL,
    site_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying(500) NOT NULL,
    file_size integer NOT NULL,
    disk_directory character varying,
    creator_id uuid
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(100),
    slug character varying(100),
    description text,
    site_id uuid,
    asset_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contact_messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_messages (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    subject character varying NOT NULL,
    body text NOT NULL,
    sender_name character varying NOT NULL,
    sender_email character varying NOT NULL,
    receiver_email character varying,
    site_id uuid NOT NULL,
    user_id uuid,
    content_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contents (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    type character varying,
    title character varying(500),
    slug character varying(500),
    template character varying(100),
    body text,
    teaser text,
    post_date timestamp without time zone,
    last_update timestamp without time zone,
    comments_allowed boolean,
    status integer,
    site_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    author_id uuid,
    meta hstore DEFAULT ''::hstore NOT NULL,
    template_field_values hstore DEFAULT ''::hstore NOT NULL,
    category_id uuid,
    deleted_at timestamp without time zone
);


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: drafts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE drafts (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    content_id uuid,
    drafted_changes hstore DEFAULT ''::hstore NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: extension_configs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE extension_configs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(100),
    type character varying(100),
    config hstore DEFAULT ''::hstore NOT NULL,
    site_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: fulltext_indices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fulltext_indices (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    config character varying,
    published boolean DEFAULT false NOT NULL,
    searchable_type character varying,
    searchable_id uuid,
    tsv tsvector,
    site_id uuid NOT NULL
);


--
-- Name: memento_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE memento_sessions (
    id integer NOT NULL,
    user_id uuid,
    undo_info character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: memento_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE memento_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memento_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE memento_sessions_id_seq OWNED BY memento_sessions.id;


--
-- Name: memento_states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE memento_states (
    id integer NOT NULL,
    action_type character varying,
    record_data bytea,
    record_type character varying,
    record_id uuid,
    session_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: memento_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE memento_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memento_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE memento_states_id_seq OWNED BY memento_states.id;


--
-- Name: navigations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE navigations (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    url character varying NOT NULL,
    "position" integer,
    site_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: permalinks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permalinks (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    path character varying NOT NULL,
    destination_type character varying NOT NULL,
    destination_id uuid NOT NULL,
    site_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: redirects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE redirects (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    location character varying NOT NULL,
    permanent boolean,
    site_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: request_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE request_logs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    status smallint NOT NULL,
    secure boolean NOT NULL,
    hostname character varying NOT NULL,
    path character varying NOT NULL,
    request hstore DEFAULT ''::hstore NOT NULL,
    response hstore DEFAULT ''::hstore NOT NULL,
    site_id uuid NOT NULL,
    resource_id uuid,
    resource_type character varying(50),
    created_at timestamp without time zone NOT NULL,
    device_class smallint,
    visitor_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    permalink_id uuid,
    processed boolean DEFAULT false NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: site_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE site_users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    site_id uuid NOT NULL,
    user_id uuid NOT NULL,
    manager boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sites (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying,
    hostname character varying,
    aliases character varying[] DEFAULT '{}'::character varying[],
    config hstore DEFAULT ''::hstore NOT NULL,
    homepage_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stats_pageviews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stats_pageviews (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    site_id uuid NOT NULL,
    stats_visit_id uuid NOT NULL,
    date date NOT NULL,
    content_id uuid NOT NULL,
    request_log_id uuid NOT NULL
);


--
-- Name: stats_visits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stats_visits (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    site_id uuid NOT NULL,
    visitor_id uuid NOT NULL,
    country_code character varying(5),
    country_name character varying,
    mobile boolean DEFAULT false NOT NULL,
    date date NOT NULL,
    started_at timestamp without time zone NOT NULL,
    ended_at timestamp without time zone NOT NULL,
    length integer
);


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    tag_id uuid NOT NULL,
    taggable_id uuid NOT NULL,
    taggable_type character varying(20) NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    site_id uuid NOT NULL,
    taggings_count integer DEFAULT 0
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    admin boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    invitation_token character varying,
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_id uuid,
    prefs hstore DEFAULT ''::hstore NOT NULL
);


--
-- Name: visitor_postings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE visitor_postings (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    type character varying(30) NOT NULL,
    data hstore DEFAULT ''::hstore NOT NULL,
    request hstore DEFAULT ''::hstore NOT NULL,
    author_ip inet NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    content_id uuid NOT NULL,
    site_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY memento_sessions ALTER COLUMN id SET DEFAULT nextval('memento_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY memento_states ALTER COLUMN id SET DEFAULT nextval('memento_states_id_seq'::regclass);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: contact_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contact_messages
    ADD CONSTRAINT contact_messages_pkey PRIMARY KEY (id);


--
-- Name: contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contents
    ADD CONSTRAINT contents_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: drafts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY drafts
    ADD CONSTRAINT drafts_pkey PRIMARY KEY (id);


--
-- Name: extension_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY extension_configs
    ADD CONSTRAINT extension_configs_pkey PRIMARY KEY (id);


--
-- Name: fulltext_indices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fulltext_indices
    ADD CONSTRAINT fulltext_indices_pkey PRIMARY KEY (id);


--
-- Name: memento_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY memento_sessions
    ADD CONSTRAINT memento_sessions_pkey PRIMARY KEY (id);


--
-- Name: memento_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY memento_states
    ADD CONSTRAINT memento_states_pkey PRIMARY KEY (id);


--
-- Name: navigations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY navigations
    ADD CONSTRAINT navigations_pkey PRIMARY KEY (id);


--
-- Name: permalinks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permalinks
    ADD CONSTRAINT permalinks_pkey PRIMARY KEY (id);


--
-- Name: redirects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY redirects
    ADD CONSTRAINT redirects_pkey PRIMARY KEY (id);


--
-- Name: request_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY request_logs
    ADD CONSTRAINT request_logs_pkey PRIMARY KEY (id);


--
-- Name: site_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY site_users
    ADD CONSTRAINT site_users_pkey PRIMARY KEY (id);


--
-- Name: sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: stats_pageviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stats_pageviews
    ADD CONSTRAINT stats_pageviews_pkey PRIMARY KEY (id);


--
-- Name: stats_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stats_visits
    ADD CONSTRAINT stats_visits_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: visitor_postings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visitor_postings
    ADD CONSTRAINT visitor_postings_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: fulltext_indices_searchable_unique_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX fulltext_indices_searchable_unique_idx ON fulltext_indices USING btree (searchable_id, published);


--
-- Name: fulltext_tsv_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fulltext_tsv_idx ON fulltext_indices USING gin (tsv);


--
-- Name: idx_assets_slugs; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_assets_slugs ON assets USING btree (site_id, slug);


--
-- Name: idx_sites_on_aliases; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_sites_on_aliases ON sites USING gin (aliases);


--
-- Name: idx_stats_pageviews_visit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_stats_pageviews_visit_id ON stats_pageviews USING btree (stats_visit_id);


--
-- Name: index_assets_on_site_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assets_on_site_id ON assets USING btree (site_id);


--
-- Name: index_assets_on_site_id_and_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assets_on_site_id_and_creator_id ON assets USING btree (site_id, creator_id);


--
-- Name: index_categories_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_site_id_and_slug ON categories USING btree (site_id, slug);


--
-- Name: index_contents_on_site_id_and_type_and_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contents_on_site_id_and_type_and_status ON contents USING btree (site_id, type, status);


--
-- Name: index_drafts_on_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_drafts_on_content_id ON drafts USING btree (content_id);


--
-- Name: index_extension_configs_on_name_and_site_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_extension_configs_on_name_and_site_id ON extension_configs USING btree (name, site_id);


--
-- Name: index_extension_configs_on_site_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_extension_configs_on_site_id ON extension_configs USING btree (site_id);


--
-- Name: index_fulltext_indices_on_published; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fulltext_indices_on_published ON fulltext_indices USING btree (published);


--
-- Name: index_fulltext_indices_on_site_id_and_searchable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fulltext_indices_on_site_id_and_searchable_type ON fulltext_indices USING btree (site_id, searchable_type);


--
-- Name: index_permalinks_on_site_and_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_permalinks_on_site_and_path ON permalinks USING btree (site_id, path);


--
-- Name: index_request_logs_on_processed_and_resource_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_request_logs_on_processed_and_resource_type ON request_logs USING btree (processed, resource_type);


--
-- Name: index_site_users_on_site_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_site_users_on_site_id_and_user_id ON site_users USING btree (site_id, user_id);


--
-- Name: index_sites_hostname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_sites_hostname ON sites USING btree (lower((hostname)::text));


--
-- Name: index_stats_pageviews_on_site_id_and_date_and_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stats_pageviews_on_site_id_and_date_and_content_id ON stats_pageviews USING btree (site_id, date, content_id);


--
-- Name: index_stats_visits_on_site_id_and_date_and_mobile; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stats_visits_on_site_id_and_date_and_mobile ON stats_visits USING btree (site_id, date, mobile);


--
-- Name: index_taggings_on_tag_id_and_taggable_type_and_taggable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_taggings_on_tag_id_and_taggable_type_and_taggable_id ON taggings USING btree (tag_id, taggable_type, taggable_id);


--
-- Name: index_taggings_on_taggable_type_and_taggable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_type_and_taggable_id ON taggings USING btree (taggable_type, taggable_id);


--
-- Name: index_tags_on_site_and_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_site_and_slug ON tags USING btree (site_id, slug);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON users USING btree (invitation_token);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);


--
-- Name: index_visitor_postings_on_site_id_and_type_and_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_visitor_postings_on_site_id_and_type_and_content_id ON visitor_postings USING btree (site_id, type, content_id);


--
-- Name: index_visitor_postings_on_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_visitor_postings_on_status ON visitor_postings USING btree (status);


--
-- Name: request_logs_device_class_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX request_logs_device_class_idx ON request_logs USING btree (device_class);


--
-- Name: request_logs_site_id_resource_type_resource_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX request_logs_site_id_resource_type_resource_id_idx ON request_logs USING btree (site_id, resource_type, resource_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: contents_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contents
    ADD CONSTRAINT contents_author_id_fkey FOREIGN KEY (author_id) REFERENCES users(id);


--
-- Name: fk_rails_1408168d23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT fk_rails_1408168d23 FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_1666ae479c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permalinks
    ADD CONSTRAINT fk_rails_1666ae479c FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_1cc3cf129c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT fk_rails_1cc3cf129c FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE SET NULL;


--
-- Name: fk_rails_1f36e32858; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stats_visits
    ADD CONSTRAINT fk_rails_1f36e32858 FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_2ad1e69bd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stats_pageviews
    ADD CONSTRAINT fk_rails_2ad1e69bd6 FOREIGN KEY (stats_visit_id) REFERENCES stats_visits(id) ON DELETE CASCADE;


--
-- Name: fk_rails_2ae538a59a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY site_users
    ADD CONSTRAINT fk_rails_2ae538a59a FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_32b0bfe7a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_messages
    ADD CONSTRAINT fk_rails_32b0bfe7a4 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: fk_rails_3333770a38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memento_sessions
    ADD CONSTRAINT fk_rails_3333770a38 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_4e9b2dd00f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stats_pageviews
    ADD CONSTRAINT fk_rails_4e9b2dd00f FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_5ed975d240; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY drafts
    ADD CONSTRAINT fk_rails_5ed975d240 FOREIGN KEY (content_id) REFERENCES contents(id);


--
-- Name: fk_rails_766455a4ea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY site_users
    ADD CONSTRAINT fk_rails_766455a4ea FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_7a427a9ec2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_logs
    ADD CONSTRAINT fk_rails_7a427a9ec2 FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE SET NULL;


--
-- Name: fk_rails_930fb84a6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memento_states
    ADD CONSTRAINT fk_rails_930fb84a6a FOREIGN KEY (session_id) REFERENCES memento_sessions(id) ON DELETE CASCADE;


--
-- Name: fk_rails_9823f4fec7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY redirects
    ADD CONSTRAINT fk_rails_9823f4fec7 FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_9fcd2e236b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT fk_rails_9fcd2e236b FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE;


--
-- Name: fk_rails_ae14a5013f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_ae14a5013f FOREIGN KEY (invited_by_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: fk_rails_b71ee631cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY extension_configs
    ADD CONSTRAINT fk_rails_b71ee631cc FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_bfb87a3769; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assets
    ADD CONSTRAINT fk_rails_bfb87a3769 FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: fk_rails_c2b6a4c44c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assets
    ADD CONSTRAINT fk_rails_c2b6a4c44c FOREIGN KEY (site_id) REFERENCES sites(id);


--
-- Name: fk_rails_c4b5e91b6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_messages
    ADD CONSTRAINT fk_rails_c4b5e91b6c FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_c807fba884; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stats_pageviews
    ADD CONSTRAINT fk_rails_c807fba884 FOREIGN KEY (request_log_id) REFERENCES request_logs(id) ON DELETE SET NULL;


--
-- Name: fk_rails_d35a92da04; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contents
    ADD CONSTRAINT fk_rails_d35a92da04 FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_d914bbe5f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contents
    ADD CONSTRAINT fk_rails_d914bbe5f3 FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;


--
-- Name: fk_rails_dc798e5c6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY navigations
    ADD CONSTRAINT fk_rails_dc798e5c6b FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_dcb22a1057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sites
    ADD CONSTRAINT fk_rails_dcb22a1057 FOREIGN KEY (homepage_id) REFERENCES contents(id) ON DELETE SET NULL;


--
-- Name: fk_rails_de3626ae7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stats_pageviews
    ADD CONSTRAINT fk_rails_de3626ae7b FOREIGN KEY (content_id) REFERENCES contents(id) ON DELETE CASCADE;


--
-- Name: fk_rails_df37ad1903; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT fk_rails_df37ad1903 FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;


--
-- Name: fk_rails_e8a1825fa5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_messages
    ADD CONSTRAINT fk_rails_e8a1825fa5 FOREIGN KEY (content_id) REFERENCES contents(id) ON DELETE SET NULL;


--
-- Name: request_logs_permalink_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_logs
    ADD CONSTRAINT request_logs_permalink_id_fkey FOREIGN KEY (permalink_id) REFERENCES permalinks(id) ON DELETE SET NULL;


--
-- Name: site_id_references_sites; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fulltext_indices
    ADD CONSTRAINT site_id_references_sites FOREIGN KEY (site_id) REFERENCES sites(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140718191443'), ('20140722185008'), ('20140723074109'), ('20140723185956'), ('20140724152311'), ('20140724214204'), ('20140728195811'), ('20140730142844'), ('20140804080313'), ('20140807085247'), ('20140814074455'), ('20150219021551'), ('20150404054400'), ('20150421043312'), ('20150502111245'), ('20150503065121'), ('20150607050856'), ('20150607091857'), ('20150702102543'), ('20150807080050'), ('20150815095401'), ('20150816062234'), ('20150819094334'), ('20150830102633'), ('20150831065039'), ('20151006041322'), ('20151006044738'), ('20151006051929'), ('20151011074758'), ('20151024100100'), ('20160116081325'), ('20160213090357'), ('20160216110944'), ('20160219060400'), ('20160219085205'), ('20160219091840'), ('20160522082635');


