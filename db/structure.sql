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
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: anonymous_students; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE anonymous_students (
    id integer NOT NULL,
    org_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: anonymous_students_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE anonymous_students_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anonymous_students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE anonymous_students_id_seq OWNED BY anonymous_students.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    commentable_id integer NOT NULL,
    commentable_type character varying(255) NOT NULL,
    user_id integer,
    parent_id integer,
    lft integer,
    rgt integer,
    comment_subject text,
    comment_body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: content_page_elements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_page_elements (
    id integer NOT NULL,
    "position" integer,
    content_page_id integer,
    element_id integer,
    element_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_page_elements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_page_elements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_page_elements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_page_elements_id_seq OWNED BY content_page_elements.id;


--
-- Name: content_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_pages (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying(255)
);


--
-- Name: content_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_pages_id_seq OWNED BY content_pages.id;


--
-- Name: content_pages_lessons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_pages_lessons (
    id integer NOT NULL,
    "position" integer,
    content_page_id integer,
    lesson_id integer
);


--
-- Name: content_pages_lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_pages_lessons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_pages_lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_pages_lessons_id_seq OWNED BY content_pages_lessons.id;


--
-- Name: content_storages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_storages (
    id integer NOT NULL,
    content_hash character varying(255),
    content_data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_storages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_storages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_storages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_storages_id_seq OWNED BY content_storages.id;


--
-- Name: course_mails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_mails (
    id integer NOT NULL,
    email_type_cd integer,
    email_subject character varying(255),
    email_message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mail_object_type character varying(255),
    mail_object_id integer
);


--
-- Name: course_mails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_mails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_mails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_mails_id_seq OWNED BY course_mails.id;


--
-- Name: course_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_pages (
    id integer NOT NULL,
    course_id integer,
    page_id integer,
    page_type character varying(255),
    page_num integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_page_num integer,
    learning_module_id integer,
    lesson_id integer,
    content_page_id integer,
    quiz_ids_str text,
    question_ids_str text,
    learning_module_page_num integer,
    lesson_page_num integer,
    content_page_num integer
);


--
-- Name: course_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_pages_id_seq OWNED BY course_pages.id;


--
-- Name: course_variants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_variants (
    id integer NOT NULL,
    course_id integer,
    course_structure text,
    course_structure_cache text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: course_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_variants_id_seq OWNED BY course_variants.id;


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE courses (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    course_pages_changed boolean,
    title character varying(255)
);


--
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE courses_id_seq OWNED BY courses.id;


--
-- Name: courses_learning_modules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE courses_learning_modules (
    course_id integer,
    learning_module_id integer,
    "position" integer
);


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invitations (
    id integer NOT NULL,
    orgs_course_id integer,
    user_id integer,
    invitation_email character varying(255),
    invitation_state character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    invitation_token character varying(255),
    sent_at timestamp without time zone,
    sent_count integer DEFAULT 0
);


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invitations_id_seq OWNED BY invitations.id;


--
-- Name: learning_modules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE learning_modules (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying(255),
    description text,
    description_image character varying(255)
);


--
-- Name: learning_modules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE learning_modules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: learning_modules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE learning_modules_id_seq OWNED BY learning_modules.id;


--
-- Name: learning_modules_lessons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE learning_modules_lessons (
    learning_module_id integer,
    lesson_id integer,
    "position" integer
);


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lessons (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying(255),
    rate_lesson boolean
);


--
-- Name: lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lessons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lessons_id_seq OWNED BY lessons.id;


--
-- Name: morphed_photos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE morphed_photos (
    id integer NOT NULL,
    photo character varying(255),
    user_detail_id integer,
    tags character varying(255),
    data_f integer,
    data_t integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    race_mask character varying(255)
);


--
-- Name: morphed_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE morphed_photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: morphed_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE morphed_photos_id_seq OWNED BY morphed_photos.id;


--
-- Name: org_resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE org_resources (
    id integer NOT NULL,
    org_id integer,
    course_id integer,
    org_key character varying(255) NOT NULL,
    org_value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: org_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE org_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE org_resources_id_seq OWNED BY org_resources.id;


--
-- Name: orgs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orgs (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    is_active boolean,
    contact text,
    notes text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    signup_key character varying(255),
    org_details text,
    domain character varying(255)
);


--
-- Name: orgs_courses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orgs_courses (
    id integer NOT NULL,
    org_id integer,
    course_id integer,
    enrollment_code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: orgs_courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orgs_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orgs_courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orgs_courses_id_seq OWNED BY orgs_courses.id;


--
-- Name: orgs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orgs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orgs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orgs_id_seq OWNED BY orgs.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_search_documents (
    id integer NOT NULL,
    content text,
    searchable_id integer,
    searchable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pg_search_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pg_search_documents_id_seq OWNED BY pg_search_documents.id;


--
-- Name: pgbench_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pgbench_accounts (
    aid integer NOT NULL,
    bid integer,
    abalance integer,
    filler character(84)
)
WITH (fillfactor=100);


--
-- Name: pgbench_branches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pgbench_branches (
    bid integer NOT NULL,
    bbalance integer,
    filler character(88)
)
WITH (fillfactor=100);


--
-- Name: pgbench_history; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pgbench_history (
    tid integer,
    bid integer,
    aid integer,
    delta integer,
    mtime timestamp without time zone,
    filler character(22)
);


--
-- Name: pgbench_tellers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pgbench_tellers (
    tid integer NOT NULL,
    bid integer,
    tbalance integer,
    filler character(84)
)
WITH (fillfactor=100);


--
-- Name: question_privacies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE question_privacies (
    id integer NOT NULL,
    course_id integer,
    org_id integer,
    question_id integer,
    question_privacy_cd integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: question_privacies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_privacies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_privacies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE question_privacies_id_seq OWNED BY question_privacies.id;


--
-- Name: question_response_bases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE question_response_bases (
    id integer NOT NULL,
    type character varying(255),
    user_id integer,
    question_id integer,
    content_hash character varying(255),
    given_answer text,
    quiz_result_id integer,
    score double precision,
    correct_answer text,
    details text,
    question_privacy_cd integer DEFAULT 0,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    anonymous_student_id integer
);


--
-- Name: question_response_bases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_response_bases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_response_bases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE question_response_bases_id_seq OWNED BY question_response_bases.id;


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE questions (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    retired boolean,
    question_type character varying(255),
    name character varying(255),
    content_hash character varying(255),
    question_privacy_cd integer DEFAULT 0
);


--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE questions_id_seq OWNED BY questions.id;


--
-- Name: quiz_results; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_results (
    id integer NOT NULL,
    user_id integer,
    quiz_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    score double precision DEFAULT 0
);


--
-- Name: quiz_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quiz_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quiz_results_id_seq OWNED BY quiz_results.id;


--
-- Name: quizzes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quizzes (
    id integer NOT NULL,
    name text,
    instructions text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying(255)
);


--
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: quizzes_questions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quizzes_questions (
    quiz_id integer,
    question_id integer,
    "position" integer
);


--
-- Name: redactor_assets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE redactor_assets (
    id integer NOT NULL,
    user_id integer,
    data_file_name character varying(255) NOT NULL,
    data_content_type character varying(255),
    data_file_size integer,
    assetable_id integer,
    assetable_type character varying(30),
    type character varying(30),
    width integer,
    height integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: redactor_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE redactor_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: redactor_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE redactor_assets_id_seq OWNED BY redactor_assets.id;


--
-- Name: reminders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reminders (
    id integer NOT NULL,
    orgs_course_id integer,
    user_id integer,
    reminder_state character varying(255),
    sent_at timestamp without time zone,
    sent_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reminder_token character varying(255)
);


--
-- Name: reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reminders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reminders_id_seq OWNED BY reminders.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: surveys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE surveys (
    id integer NOT NULL,
    question_id integer,
    question_response_id integer,
    orgs_course_id integer,
    user_id integer,
    survey_email character varying(255),
    survey_token character varying(255),
    survey_state character varying(255),
    sent_at timestamp without time zone,
    sent_count integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: surveys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE surveys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: surveys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE surveys_id_seq OWNED BY surveys.id;


--
-- Name: text_blocks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE text_blocks (
    id integer NOT NULL,
    private_title text,
    raw_content text,
    rendered_content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    course_id integer,
    learning_module_id integer,
    lesson_id integer
);


--
-- Name: text_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE text_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE text_blocks_id_seq OWNED BY text_blocks.id;


--
-- Name: user_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_details (
    id integer NOT NULL,
    user_photo character varying(255),
    user_id integer,
    user_data hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    main_photo_status_cd integer DEFAULT 0,
    detected_user_photo character varying(255),
    registration_state character varying(255),
    cropped_user_photo character varying(255),
    mask_photo character varying(255)
);


--
-- Name: user_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_details_id_seq OWNED BY user_details.id;


--
-- Name: user_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_events (
    id integer NOT NULL,
    user_id integer,
    course_id integer,
    learning_module_id integer,
    lesson_id integer,
    content_page_id integer,
    event_type character varying(255),
    event_time timestamp without time zone,
    event_data hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying(255),
    deleted_at timestamp without time zone
);


--
-- Name: user_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_events_id_seq OWNED BY user_events.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    org_id integer,
    roles_mask integer,
    provider character varying(255),
    uid character varying(255),
    authentication_token character varying(255),
    anonid character varying(255)
);


--
-- Name: users_courses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users_courses (
    id integer NOT NULL,
    user_id integer,
    course_id integer,
    created_at timestamp without time zone,
    authentication_token character varying(255)
);


--
-- Name: users_courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_courses_id_seq OWNED BY users_courses.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: word_definitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE word_definitions (
    id integer NOT NULL,
    word character varying(255),
    word_definition text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: word_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE word_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: word_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE word_definitions_id_seq OWNED BY word_definitions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY anonymous_students ALTER COLUMN id SET DEFAULT nextval('anonymous_students_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_page_elements ALTER COLUMN id SET DEFAULT nextval('content_page_elements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_pages ALTER COLUMN id SET DEFAULT nextval('content_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_pages_lessons ALTER COLUMN id SET DEFAULT nextval('content_pages_lessons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_storages ALTER COLUMN id SET DEFAULT nextval('content_storages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_mails ALTER COLUMN id SET DEFAULT nextval('course_mails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_pages ALTER COLUMN id SET DEFAULT nextval('course_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_variants ALTER COLUMN id SET DEFAULT nextval('course_variants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses ALTER COLUMN id SET DEFAULT nextval('courses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invitations ALTER COLUMN id SET DEFAULT nextval('invitations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_modules ALTER COLUMN id SET DEFAULT nextval('learning_modules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lessons ALTER COLUMN id SET DEFAULT nextval('lessons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY morphed_photos ALTER COLUMN id SET DEFAULT nextval('morphed_photos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY org_resources ALTER COLUMN id SET DEFAULT nextval('org_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY orgs ALTER COLUMN id SET DEFAULT nextval('orgs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY orgs_courses ALTER COLUMN id SET DEFAULT nextval('orgs_courses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pg_search_documents ALTER COLUMN id SET DEFAULT nextval('pg_search_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_privacies ALTER COLUMN id SET DEFAULT nextval('question_privacies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_response_bases ALTER COLUMN id SET DEFAULT nextval('question_response_bases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions ALTER COLUMN id SET DEFAULT nextval('questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_results ALTER COLUMN id SET DEFAULT nextval('quiz_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY redactor_assets ALTER COLUMN id SET DEFAULT nextval('redactor_assets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reminders ALTER COLUMN id SET DEFAULT nextval('reminders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY surveys ALTER COLUMN id SET DEFAULT nextval('surveys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_blocks ALTER COLUMN id SET DEFAULT nextval('text_blocks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_details ALTER COLUMN id SET DEFAULT nextval('user_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_events ALTER COLUMN id SET DEFAULT nextval('user_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_courses ALTER COLUMN id SET DEFAULT nextval('users_courses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY word_definitions ALTER COLUMN id SET DEFAULT nextval('word_definitions_id_seq'::regclass);


--
-- Name: courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: user_events_materalized_view; Type: MATERIALIZED VIEW; Schema: public; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW user_events_materalized_view AS
 SELECT user_events_view.email,
    user_events_view.id,
    user_events_view.registered,
    user_events_view.first_name,
    user_events_view.last_name,
    user_events_view.org_id,
    user_events_view.status,
    user_events_view.course_id,
    user_events_view.title,
    user_events_view.pages_completed,
    user_events_view.days_since_last_activity,
    user_events_view.last_activity_timestamp_est,
    t_course_pages.courses_id,
    t_course_pages.course_title,
    t_course_pages.course_page_count,
    LEAST(round((((user_events_view.pages_completed)::numeric * 100.0) / (t_course_pages.course_page_count)::numeric), 0), (100)::numeric) AS percent_completed
   FROM (( SELECT users.email,
            users.id,
            'Yes'::text AS registered,
            initcap((users.first_name)::text) AS first_name,
            initcap((users.last_name)::text) AS last_name,
            users.org_id,
            'Enrolled'::text AS status,
            courses.id AS course_id,
            courses.title,
            ( SELECT count(*) AS count
                   FROM user_events user_events_1
                  WHERE (((user_events_1.user_id = users.id) AND (user_events_1.course_id = courses.id)) AND ((user_events_1.event_type)::text = 'content_page_end'::text))) AS pages_completed,
            (to_char(age(users.updated_at), 'FMDDD'::text))::integer AS days_since_last_activity,
            timezone('EST'::text, timezone('UTC'::text, users.updated_at)) AS last_activity_timestamp_est
           FROM ((((users
             LEFT JOIN user_events ON ((users.id = user_events.user_id)))
             LEFT JOIN users_courses ON ((users_courses.user_id = users.id)))
             LEFT JOIN courses ON ((courses.id = users_courses.course_id)))
             JOIN orgs ON (((users.org_id = orgs.id) AND (orgs.is_active = true))))
          GROUP BY users.email, users.id, users.first_name, users.last_name, users.org_id, courses.id, courses.title, (to_char(age(users.updated_at), 'FMDDD'::text))::integer, users.updated_at
        UNION
        ( SELECT invitations.invitation_email AS email,
            invitations.id,
            'No'::text AS registered,
            NULL::text AS first_name,
            NULL::text AS last_name,
            orgs_courses.org_id,
            ((((invitations.invitation_state)::text || ' '::text) || invitations.sent_count) || 'x'::text) AS status,
            courses.id AS course_id,
            courses.title,
            0 AS pages_completed,
            (to_char(age(invitations.created_at), 'FMDDD'::text))::integer AS days_since_last_activity,
            invitations.updated_at AS last_activity_timestamp_est
           FROM (((invitations
             LEFT JOIN orgs_courses ON ((invitations.orgs_course_id = orgs_courses.id)))
             LEFT JOIN courses ON ((courses.id = orgs_courses.course_id)))
             LEFT JOIN orgs ON ((orgs.id = orgs_courses.org_id)))
          WHERE ((invitations.invitation_state)::text <> ALL (ARRAY[('invitation_accepted'::character varying)::text, ('invitation_deactivated'::character varying)::text]))
          ORDER BY invitations.invitation_email)) user_events_view
     LEFT JOIN ( SELECT courses.id AS courses_id,
            courses.title AS course_title,
            count(*) AS course_page_count
           FROM course_pages,
            courses
          WHERE (((course_pages.page_type)::text = 'ContentPage'::text) AND (courses.id = course_pages.course_id))
          GROUP BY courses.id) t_course_pages ON ((user_events_view.course_id = t_course_pages.courses_id)))
  WITH NO DATA;


--
-- Name: anonymous_students_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY anonymous_students
    ADD CONSTRAINT anonymous_students_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: content_page_elements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_page_elements
    ADD CONSTRAINT content_page_elements_pkey PRIMARY KEY (id);


--
-- Name: content_pages_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_pages_lessons
    ADD CONSTRAINT content_pages_lessons_pkey PRIMARY KEY (id);


--
-- Name: content_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_pages
    ADD CONSTRAINT content_pages_pkey PRIMARY KEY (id);


--
-- Name: content_storages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_storages
    ADD CONSTRAINT content_storages_pkey PRIMARY KEY (id);


--
-- Name: course_mails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_mails
    ADD CONSTRAINT course_mails_pkey PRIMARY KEY (id);


--
-- Name: course_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_pages
    ADD CONSTRAINT course_pages_pkey PRIMARY KEY (id);


--
-- Name: course_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_variants
    ADD CONSTRAINT course_variants_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: learning_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY learning_modules
    ADD CONSTRAINT learning_modules_pkey PRIMARY KEY (id);


--
-- Name: lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- Name: morphed_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY morphed_photos
    ADD CONSTRAINT morphed_photos_pkey PRIMARY KEY (id);


--
-- Name: org_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY org_resources
    ADD CONSTRAINT org_resources_pkey PRIMARY KEY (id);


--
-- Name: orgs_courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orgs_courses
    ADD CONSTRAINT orgs_courses_pkey PRIMARY KEY (id);


--
-- Name: orgs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orgs
    ADD CONSTRAINT orgs_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: pgbench_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pgbench_accounts
    ADD CONSTRAINT pgbench_accounts_pkey PRIMARY KEY (aid);


--
-- Name: pgbench_branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pgbench_branches
    ADD CONSTRAINT pgbench_branches_pkey PRIMARY KEY (bid);


--
-- Name: pgbench_tellers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pgbench_tellers
    ADD CONSTRAINT pgbench_tellers_pkey PRIMARY KEY (tid);


--
-- Name: question_privacies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_privacies
    ADD CONSTRAINT question_privacies_pkey PRIMARY KEY (id);


--
-- Name: question_response_bases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_response_bases
    ADD CONSTRAINT question_response_bases_pkey PRIMARY KEY (id);


--
-- Name: questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: quiz_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_results
    ADD CONSTRAINT quiz_results_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: redactor_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY redactor_assets
    ADD CONSTRAINT redactor_assets_pkey PRIMARY KEY (id);


--
-- Name: reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY surveys
    ADD CONSTRAINT surveys_pkey PRIMARY KEY (id);


--
-- Name: text_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY text_blocks
    ADD CONSTRAINT text_blocks_pkey PRIMARY KEY (id);


--
-- Name: user_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_details
    ADD CONSTRAINT user_details_pkey PRIMARY KEY (id);


--
-- Name: user_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_events
    ADD CONSTRAINT user_events_pkey PRIMARY KEY (id);


--
-- Name: users_courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users_courses
    ADD CONSTRAINT users_courses_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: word_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY word_definitions
    ADD CONSTRAINT word_definitions_pkey PRIMARY KEY (id);


--
-- Name: course_module_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX course_module_index ON courses_learning_modules USING btree (course_id, learning_module_id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: idx_redactor_assetable; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_redactor_assetable ON redactor_assets USING btree (assetable_type, assetable_id);


--
-- Name: idx_redactor_assetable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_redactor_assetable_type ON redactor_assets USING btree (assetable_type, type, assetable_id);


--
-- Name: index_anonymous_students_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_anonymous_students_on_org_id ON anonymous_students USING btree (org_id);


--
-- Name: index_comments_on_commentable_id_and_commentable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_id_and_commentable_type ON comments USING btree (commentable_id, commentable_type);


--
-- Name: index_comments_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_created_at ON comments USING btree (created_at);


--
-- Name: index_comments_on_lft; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_lft ON comments USING btree (lft);


--
-- Name: index_comments_on_rgt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_rgt ON comments USING btree (rgt);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_content_page_elements_on_content_page_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_page_elements_on_content_page_id ON content_page_elements USING btree (content_page_id);


--
-- Name: index_content_page_elements_on_element_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_page_elements_on_element_id ON content_page_elements USING btree (element_id);


--
-- Name: index_content_page_elements_on_element_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_page_elements_on_element_type ON content_page_elements USING btree (element_type);


--
-- Name: index_content_page_elements_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_page_elements_on_position ON content_page_elements USING btree ("position");


--
-- Name: index_content_pages_lessons_on_content_page_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_pages_lessons_on_content_page_id ON content_pages_lessons USING btree (content_page_id);


--
-- Name: index_content_pages_lessons_on_lesson_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_pages_lessons_on_lesson_id ON content_pages_lessons USING btree (lesson_id);


--
-- Name: index_content_storages_on_content_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_storages_on_content_hash ON content_storages USING btree (content_hash);


--
-- Name: index_course_mails_on_email_type_cd; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_mails_on_email_type_cd ON course_mails USING btree (email_type_cd);


--
-- Name: index_course_mails_on_mail_object_type_and_mail_object_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_mails_on_mail_object_type_and_mail_object_id ON course_mails USING btree (mail_object_type, mail_object_id);


--
-- Name: index_course_pages_on_content_page_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_content_page_id ON course_pages USING btree (content_page_id);


--
-- Name: index_course_pages_on_content_page_num; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_content_page_num ON course_pages USING btree (content_page_num);


--
-- Name: index_course_pages_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_course_id ON course_pages USING btree (course_id);


--
-- Name: index_course_pages_on_learning_module_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_learning_module_id ON course_pages USING btree (learning_module_id);


--
-- Name: index_course_pages_on_learning_module_page_num; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_learning_module_page_num ON course_pages USING btree (learning_module_page_num);


--
-- Name: index_course_pages_on_lesson_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_lesson_id ON course_pages USING btree (lesson_id);


--
-- Name: index_course_pages_on_lesson_page_num; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_lesson_page_num ON course_pages USING btree (lesson_page_num);


--
-- Name: index_course_pages_on_page_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_page_id ON course_pages USING btree (page_id);


--
-- Name: index_course_pages_on_page_num; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_page_num ON course_pages USING btree (page_num);


--
-- Name: index_course_pages_on_page_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_page_type ON course_pages USING btree (page_type);


--
-- Name: index_course_pages_on_parent_page_num; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_pages_on_parent_page_num ON course_pages USING btree (parent_page_num);


--
-- Name: index_course_variants_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_variants_on_course_id ON course_variants USING btree (course_id);


--
-- Name: index_courses_learning_modules_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_learning_modules_on_course_id ON courses_learning_modules USING btree (course_id);


--
-- Name: index_courses_learning_modules_on_learning_module_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_learning_modules_on_learning_module_id ON courses_learning_modules USING btree (learning_module_id);


--
-- Name: index_courses_on_course_pages_changed; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_on_course_pages_changed ON courses USING btree (course_pages_changed);


--
-- Name: index_invitations_on_invitation_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invitations_on_invitation_email ON invitations USING btree (invitation_email);


--
-- Name: index_invitations_on_invitation_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invitations_on_invitation_state ON invitations USING btree (invitation_state);


--
-- Name: index_invitations_on_invitation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invitations_on_invitation_token ON invitations USING btree (invitation_token);


--
-- Name: index_invitations_on_orgs_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invitations_on_orgs_course_id ON invitations USING btree (orgs_course_id);


--
-- Name: index_invitations_on_sent_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invitations_on_sent_at ON invitations USING btree (sent_at);


--
-- Name: index_invitations_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invitations_on_user_id ON invitations USING btree (user_id);


--
-- Name: index_learning_modules_lessons_on_lesson_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_learning_modules_lessons_on_lesson_id ON learning_modules_lessons USING btree (lesson_id);


--
-- Name: index_matview_on_course_id_percent_completed; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_matview_on_course_id_percent_completed ON user_events_materalized_view USING btree (course_id, percent_completed);


--
-- Name: index_matview_on_id_email_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_matview_on_id_email_course_id ON user_events_materalized_view USING btree (id, email, course_id);


--
-- Name: index_morphed_photos_on_race_mask; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_morphed_photos_on_race_mask ON morphed_photos USING btree (race_mask);


--
-- Name: index_morphed_photos_on_tags; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_morphed_photos_on_tags ON morphed_photos USING btree (tags);


--
-- Name: index_morphed_photos_on_user_detail_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_morphed_photos_on_user_detail_id ON morphed_photos USING btree (user_detail_id);


--
-- Name: index_org_resources_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_org_resources_on_course_id ON org_resources USING btree (course_id);


--
-- Name: index_org_resources_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_org_resources_on_org_id ON org_resources USING btree (org_id);


--
-- Name: index_org_resources_on_org_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_org_resources_on_org_key ON org_resources USING btree (org_key);


--
-- Name: index_orgs_courses_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orgs_courses_on_course_id ON orgs_courses USING btree (course_id);


--
-- Name: index_orgs_courses_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orgs_courses_on_org_id ON orgs_courses USING btree (org_id);


--
-- Name: index_orgs_on_domain; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orgs_on_domain ON orgs USING btree (domain);


--
-- Name: index_orgs_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orgs_on_name ON orgs USING btree (name);


--
-- Name: index_orgs_on_signup_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orgs_on_signup_key ON orgs USING btree (signup_key);


--
-- Name: index_orgs_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orgs_on_user_id ON orgs USING btree (user_id);


--
-- Name: index_question_privacies_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_privacies_on_course_id ON question_privacies USING btree (course_id);


--
-- Name: index_question_privacies_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_privacies_on_org_id ON question_privacies USING btree (org_id);


--
-- Name: index_question_privacies_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_privacies_on_question_id ON question_privacies USING btree (question_id);


--
-- Name: index_question_response_bases_on_anonymous_student_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_response_bases_on_anonymous_student_id ON question_response_bases USING btree (anonymous_student_id);


--
-- Name: index_question_response_bases_on_content_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_response_bases_on_content_hash ON question_response_bases USING btree (content_hash);


--
-- Name: index_question_response_bases_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_response_bases_on_question_id ON question_response_bases USING btree (question_id);


--
-- Name: index_question_response_bases_on_question_privacy_cd; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_response_bases_on_question_privacy_cd ON question_response_bases USING btree (question_privacy_cd);


--
-- Name: index_question_response_bases_on_quiz_result_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_response_bases_on_quiz_result_id ON question_response_bases USING btree (quiz_result_id);


--
-- Name: index_question_response_bases_on_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_response_bases_on_title ON question_response_bases USING btree (title);


--
-- Name: index_question_response_bases_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_response_bases_on_type ON question_response_bases USING btree (type);


--
-- Name: index_question_response_bases_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_response_bases_on_user_id ON question_response_bases USING btree (user_id);


--
-- Name: index_questions_on_content_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questions_on_content_hash ON questions USING btree (content_hash);


--
-- Name: index_questions_on_question_privacy_cd; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questions_on_question_privacy_cd ON questions USING btree (question_privacy_cd);


--
-- Name: index_quiz_results_on_quiz_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quiz_results_on_quiz_id ON quiz_results USING btree (quiz_id);


--
-- Name: index_quiz_results_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quiz_results_on_user_id ON quiz_results USING btree (user_id);


--
-- Name: index_quizzes_questions_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quizzes_questions_on_question_id ON quizzes_questions USING btree (question_id);


--
-- Name: index_quizzes_questions_on_quiz_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quizzes_questions_on_quiz_id ON quizzes_questions USING btree (quiz_id);


--
-- Name: index_quizzes_questions_on_quiz_id_and_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quizzes_questions_on_quiz_id_and_question_id ON quizzes_questions USING btree (quiz_id, question_id);


--
-- Name: index_redactor_assets_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_redactor_assets_on_user_id ON redactor_assets USING btree (user_id);


--
-- Name: index_reminders_on_orgs_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reminders_on_orgs_course_id ON reminders USING btree (orgs_course_id);


--
-- Name: index_reminders_on_reminder_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reminders_on_reminder_state ON reminders USING btree (reminder_state);


--
-- Name: index_reminders_on_reminder_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reminders_on_reminder_token ON reminders USING btree (reminder_token);


--
-- Name: index_reminders_on_sent_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reminders_on_sent_at ON reminders USING btree (sent_at);


--
-- Name: index_reminders_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reminders_on_user_id ON reminders USING btree (user_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_surveys_on_orgs_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_surveys_on_orgs_course_id ON surveys USING btree (orgs_course_id);


--
-- Name: index_surveys_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_surveys_on_question_id ON surveys USING btree (question_id);


--
-- Name: index_surveys_on_question_response_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_surveys_on_question_response_id ON surveys USING btree (question_response_id);


--
-- Name: index_surveys_on_survey_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_surveys_on_survey_email ON surveys USING btree (survey_email);


--
-- Name: index_surveys_on_survey_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_surveys_on_survey_state ON surveys USING btree (survey_state);


--
-- Name: index_surveys_on_survey_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_surveys_on_survey_token ON surveys USING btree (survey_token);


--
-- Name: index_surveys_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_surveys_on_user_id ON surveys USING btree (user_id);


--
-- Name: index_text_blocks_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_text_blocks_on_course_id ON text_blocks USING btree (course_id);


--
-- Name: index_text_blocks_on_learning_module_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_text_blocks_on_learning_module_id ON text_blocks USING btree (learning_module_id);


--
-- Name: index_text_blocks_on_lesson_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_text_blocks_on_lesson_id ON text_blocks USING btree (lesson_id);


--
-- Name: index_user_details_on_registration_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_details_on_registration_state ON user_details USING btree (registration_state);


--
-- Name: index_user_details_on_user_data; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_details_on_user_data ON user_details USING gist (user_data);


--
-- Name: index_user_details_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_details_on_user_id ON user_details USING btree (user_id);


--
-- Name: index_user_events_materalized_view_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_materalized_view_on_course_id ON user_events_materalized_view USING btree (course_id);


--
-- Name: index_user_events_materalized_view_on_course_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_materalized_view_on_course_title ON user_events_materalized_view USING btree (course_title);


--
-- Name: index_user_events_materalized_view_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_materalized_view_on_email ON user_events_materalized_view USING btree (email);


--
-- Name: index_user_events_materalized_view_on_email_and_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_materalized_view_on_email_and_course_id ON user_events_materalized_view USING btree (email, course_id);


--
-- Name: index_user_events_materalized_view_on_first_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_materalized_view_on_first_name ON user_events_materalized_view USING btree (first_name);


--
-- Name: index_user_events_materalized_view_on_last_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_materalized_view_on_last_name ON user_events_materalized_view USING btree (last_name);


--
-- Name: index_user_events_materalized_view_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_materalized_view_on_org_id ON user_events_materalized_view USING btree (org_id);


--
-- Name: index_user_events_materalized_view_on_org_id_and_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_materalized_view_on_org_id_and_course_id ON user_events_materalized_view USING btree (org_id, course_id);


--
-- Name: index_user_events_materalized_view_on_percent_completed; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_materalized_view_on_percent_completed ON user_events_materalized_view USING btree (percent_completed);


--
-- Name: index_user_events_materalized_view_on_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_materalized_view_on_status ON user_events_materalized_view USING btree (status);


--
-- Name: index_user_events_on_content_page_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_content_page_id ON user_events USING btree (content_page_id);


--
-- Name: index_user_events_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_course_id ON user_events USING btree (course_id);


--
-- Name: index_user_events_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_deleted_at ON user_events USING btree (deleted_at);


--
-- Name: index_user_events_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_email ON user_events USING btree (email);


--
-- Name: index_user_events_on_event_time; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_event_time ON user_events USING btree (event_time);


--
-- Name: index_user_events_on_event_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_event_type ON user_events USING btree (event_type);


--
-- Name: index_user_events_on_learning_module_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_learning_module_id ON user_events USING btree (learning_module_id);


--
-- Name: index_user_events_on_lesson_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_lesson_id ON user_events USING btree (lesson_id);


--
-- Name: index_user_events_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_user_id ON user_events USING btree (user_id);


--
-- Name: index_user_events_on_user_id_and_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_user_id_and_course_id ON user_events USING btree (user_id, course_id);


--
-- Name: index_user_events_on_user_id_and_course_id_and_event_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_events_on_user_id_and_course_id_and_event_type ON user_events USING btree (user_id, course_id, event_type);


--
-- Name: index_users_courses_on_authentication_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_courses_on_authentication_token ON users_courses USING btree (authentication_token);


--
-- Name: index_users_courses_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_courses_on_course_id ON users_courses USING btree (course_id);


--
-- Name: index_users_courses_on_course_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_courses_on_course_id_and_user_id ON users_courses USING btree (course_id, user_id);


--
-- Name: index_users_courses_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_courses_on_user_id ON users_courses USING btree (user_id);


--
-- Name: index_users_on_anonid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_anonid ON users USING btree (anonid);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_org_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_org_id ON users USING btree (org_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_roles_mask; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_roles_mask ON users USING btree (roles_mask);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: index_word_definitions_on_word; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_word_definitions_on_word ON word_definitions USING btree (word);


--
-- Name: learning_module_lesson_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX learning_module_lesson_index ON learning_modules_lessons USING btree (learning_module_id);


--
-- Name: page_lesson_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX page_lesson_index ON content_pages_lessons USING btree (content_page_id, lesson_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: content_page_elements_content_page_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_page_elements
    ADD CONSTRAINT content_page_elements_content_page_id_fk FOREIGN KEY (content_page_id) REFERENCES content_pages(id);


--
-- Name: content_pages_lessons_content_page_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_pages_lessons
    ADD CONSTRAINT content_pages_lessons_content_page_id_fk FOREIGN KEY (content_page_id) REFERENCES content_pages(id);


--
-- Name: content_pages_lessons_lesson_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_pages_lessons
    ADD CONSTRAINT content_pages_lessons_lesson_id_fk FOREIGN KEY (lesson_id) REFERENCES lessons(id);


--
-- Name: courses_learning_modules_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses_learning_modules
    ADD CONSTRAINT courses_learning_modules_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: courses_learning_modules_learning_module_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses_learning_modules
    ADD CONSTRAINT courses_learning_modules_learning_module_id_fk FOREIGN KEY (learning_module_id) REFERENCES learning_modules(id);


--
-- Name: learning_modules_lessons_learning_module_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_modules_lessons
    ADD CONSTRAINT learning_modules_lessons_learning_module_id_fk FOREIGN KEY (learning_module_id) REFERENCES learning_modules(id);


--
-- Name: learning_modules_lessons_lesson_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_modules_lessons
    ADD CONSTRAINT learning_modules_lessons_lesson_id_fk FOREIGN KEY (lesson_id) REFERENCES lessons(id);


--
-- Name: morphed_photos_user_detail_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY morphed_photos
    ADD CONSTRAINT morphed_photos_user_detail_id_fk FOREIGN KEY (user_detail_id) REFERENCES user_details(id);


--
-- Name: orgs_courses_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orgs_courses
    ADD CONSTRAINT orgs_courses_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: orgs_courses_org_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orgs_courses
    ADD CONSTRAINT orgs_courses_org_id_fk FOREIGN KEY (org_id) REFERENCES orgs(id);


--
-- Name: quiz_results_quiz_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_results
    ADD CONSTRAINT quiz_results_quiz_id_fk FOREIGN KEY (quiz_id) REFERENCES quizzes(id);


--
-- Name: quiz_results_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_results
    ADD CONSTRAINT quiz_results_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: quizzes_questions_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quizzes_questions
    ADD CONSTRAINT quizzes_questions_question_id_fk FOREIGN KEY (question_id) REFERENCES questions(id);


--
-- Name: quizzes_questions_quiz_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quizzes_questions
    ADD CONSTRAINT quizzes_questions_quiz_id_fk FOREIGN KEY (quiz_id) REFERENCES quizzes(id);


--
-- Name: redactor_assets_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY redactor_assets
    ADD CONSTRAINT redactor_assets_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: text_blocks_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_blocks
    ADD CONSTRAINT text_blocks_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: text_blocks_learning_module_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_blocks
    ADD CONSTRAINT text_blocks_learning_module_id_fk FOREIGN KEY (learning_module_id) REFERENCES learning_modules(id);


--
-- Name: text_blocks_lesson_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_blocks
    ADD CONSTRAINT text_blocks_lesson_id_fk FOREIGN KEY (lesson_id) REFERENCES lessons(id);


--
-- Name: user_details_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_details
    ADD CONSTRAINT user_details_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: users_courses_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_courses
    ADD CONSTRAINT users_courses_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: users_courses_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_courses
    ADD CONSTRAINT users_courses_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: users_org_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_org_id_fk FOREIGN KEY (org_id) REFERENCES orgs(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130611145616');

INSERT INTO schema_migrations (version) VALUES ('20130611145617');

INSERT INTO schema_migrations (version) VALUES ('20130611151422');

INSERT INTO schema_migrations (version) VALUES ('20130611153551');

INSERT INTO schema_migrations (version) VALUES ('20130611205223');

INSERT INTO schema_migrations (version) VALUES ('20130612030953');

INSERT INTO schema_migrations (version) VALUES ('20130613191356');

INSERT INTO schema_migrations (version) VALUES ('20130614020151');

INSERT INTO schema_migrations (version) VALUES ('20130614020212');

INSERT INTO schema_migrations (version) VALUES ('20130614020512');

INSERT INTO schema_migrations (version) VALUES ('20130614194716');

INSERT INTO schema_migrations (version) VALUES ('20130614200831');

INSERT INTO schema_migrations (version) VALUES ('20130614201321');

INSERT INTO schema_migrations (version) VALUES ('20130614223758');

INSERT INTO schema_migrations (version) VALUES ('20130614224039');

INSERT INTO schema_migrations (version) VALUES ('20130614224304');

INSERT INTO schema_migrations (version) VALUES ('20130614225132');

INSERT INTO schema_migrations (version) VALUES ('20130615031619');

INSERT INTO schema_migrations (version) VALUES ('20130615174304');

INSERT INTO schema_migrations (version) VALUES ('20130617035017');

INSERT INTO schema_migrations (version) VALUES ('20130617040304');

INSERT INTO schema_migrations (version) VALUES ('20130617145217');

INSERT INTO schema_migrations (version) VALUES ('20130619230615');

INSERT INTO schema_migrations (version) VALUES ('20130621055156');

INSERT INTO schema_migrations (version) VALUES ('20130621132201');

INSERT INTO schema_migrations (version) VALUES ('20130621133207');

INSERT INTO schema_migrations (version) VALUES ('20130621203008');

INSERT INTO schema_migrations (version) VALUES ('20130621203041');

INSERT INTO schema_migrations (version) VALUES ('20130621203115');

INSERT INTO schema_migrations (version) VALUES ('20130621203158');

INSERT INTO schema_migrations (version) VALUES ('20130621203221');

INSERT INTO schema_migrations (version) VALUES ('20130621204252');

INSERT INTO schema_migrations (version) VALUES ('20130621204940');

INSERT INTO schema_migrations (version) VALUES ('20130621221527');

INSERT INTO schema_migrations (version) VALUES ('20130621221719');

INSERT INTO schema_migrations (version) VALUES ('20130622032754');

INSERT INTO schema_migrations (version) VALUES ('20130622150753');

INSERT INTO schema_migrations (version) VALUES ('20130627004230');

INSERT INTO schema_migrations (version) VALUES ('20130627142510');

INSERT INTO schema_migrations (version) VALUES ('20130627142511');

INSERT INTO schema_migrations (version) VALUES ('20130627185544');

INSERT INTO schema_migrations (version) VALUES ('20130628150322');

INSERT INTO schema_migrations (version) VALUES ('20130628150508');

INSERT INTO schema_migrations (version) VALUES ('20130628150552');

INSERT INTO schema_migrations (version) VALUES ('20130628150746');

INSERT INTO schema_migrations (version) VALUES ('20130628153943');

INSERT INTO schema_migrations (version) VALUES ('20130628174010');

INSERT INTO schema_migrations (version) VALUES ('20130630115208');

INSERT INTO schema_migrations (version) VALUES ('20130630160530');

INSERT INTO schema_migrations (version) VALUES ('20130703212147');

INSERT INTO schema_migrations (version) VALUES ('20130705064456');

INSERT INTO schema_migrations (version) VALUES ('20130705091922');

INSERT INTO schema_migrations (version) VALUES ('20130707084439');

INSERT INTO schema_migrations (version) VALUES ('20130707084844');

INSERT INTO schema_migrations (version) VALUES ('20130707181947');

INSERT INTO schema_migrations (version) VALUES ('20130707182254');

INSERT INTO schema_migrations (version) VALUES ('20130708003144');

INSERT INTO schema_migrations (version) VALUES ('20130709194148');

INSERT INTO schema_migrations (version) VALUES ('20130710025657');

INSERT INTO schema_migrations (version) VALUES ('20130712132624');

INSERT INTO schema_migrations (version) VALUES ('20130713170716');

INSERT INTO schema_migrations (version) VALUES ('20130714012240');

INSERT INTO schema_migrations (version) VALUES ('20130716205111');

INSERT INTO schema_migrations (version) VALUES ('20130717094909');

INSERT INTO schema_migrations (version) VALUES ('20130717095241');

INSERT INTO schema_migrations (version) VALUES ('20130717221933');

INSERT INTO schema_migrations (version) VALUES ('20130724045220');

INSERT INTO schema_migrations (version) VALUES ('20130724211345');

INSERT INTO schema_migrations (version) VALUES ('20130729095228');

INSERT INTO schema_migrations (version) VALUES ('20130729221524');

INSERT INTO schema_migrations (version) VALUES ('20130808185155');

INSERT INTO schema_migrations (version) VALUES ('20130808185451');

INSERT INTO schema_migrations (version) VALUES ('20130808185710');

INSERT INTO schema_migrations (version) VALUES ('20130808191545');

INSERT INTO schema_migrations (version) VALUES ('20130808193128');

INSERT INTO schema_migrations (version) VALUES ('20130808200712');

INSERT INTO schema_migrations (version) VALUES ('20130808215132');

INSERT INTO schema_migrations (version) VALUES ('20130808215133');

INSERT INTO schema_migrations (version) VALUES ('20130809052339');

INSERT INTO schema_migrations (version) VALUES ('20130809052802');

INSERT INTO schema_migrations (version) VALUES ('20130809193056');

INSERT INTO schema_migrations (version) VALUES ('20130809202325');

INSERT INTO schema_migrations (version) VALUES ('20130810173532');

INSERT INTO schema_migrations (version) VALUES ('20130810202621');

INSERT INTO schema_migrations (version) VALUES ('20130812141503');

INSERT INTO schema_migrations (version) VALUES ('20130823054543');

INSERT INTO schema_migrations (version) VALUES ('20130825202748');

INSERT INTO schema_migrations (version) VALUES ('20130828200604');

INSERT INTO schema_migrations (version) VALUES ('20130830201834');

INSERT INTO schema_migrations (version) VALUES ('20130831203656');

INSERT INTO schema_migrations (version) VALUES ('20130908211850');

INSERT INTO schema_migrations (version) VALUES ('20130909105742');

INSERT INTO schema_migrations (version) VALUES ('20130921195851');

INSERT INTO schema_migrations (version) VALUES ('20131003221817');

INSERT INTO schema_migrations (version) VALUES ('20131016231711');

INSERT INTO schema_migrations (version) VALUES ('20131215181458');

INSERT INTO schema_migrations (version) VALUES ('20131217193320');

INSERT INTO schema_migrations (version) VALUES ('20140306190030');

INSERT INTO schema_migrations (version) VALUES ('20140312054956');

INSERT INTO schema_migrations (version) VALUES ('20140419180751');

INSERT INTO schema_migrations (version) VALUES ('20140427201629');

INSERT INTO schema_migrations (version) VALUES ('20140518210015');

INSERT INTO schema_migrations (version) VALUES ('20140522211441');

INSERT INTO schema_migrations (version) VALUES ('20140529200346');

INSERT INTO schema_migrations (version) VALUES ('20140601213935');

INSERT INTO schema_migrations (version) VALUES ('20140609213601');

INSERT INTO schema_migrations (version) VALUES ('20140615214531');

INSERT INTO schema_migrations (version) VALUES ('20140618220558');

INSERT INTO schema_migrations (version) VALUES ('20140701195836');

INSERT INTO schema_migrations (version) VALUES ('20140708220845');

INSERT INTO schema_migrations (version) VALUES ('20140709210617');

INSERT INTO schema_migrations (version) VALUES ('20140710213841');

INSERT INTO schema_migrations (version) VALUES ('20140822155043');

INSERT INTO schema_migrations (version) VALUES ('20140908020620');

INSERT INTO schema_migrations (version) VALUES ('20140920161735');

INSERT INTO schema_migrations (version) VALUES ('20140923003948');

INSERT INTO schema_migrations (version) VALUES ('20141005163202');

INSERT INTO schema_migrations (version) VALUES ('20141028043456');

INSERT INTO schema_migrations (version) VALUES ('20141212153502');

INSERT INTO schema_migrations (version) VALUES ('20141222092934');

