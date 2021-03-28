-- Table: public.reads_books

-- DROP TABLE public.reads_books;

CREATE TABLE public.reads_books
(
    id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    updated_at timestamp without time zone,
    author character varying COLLATE pg_catalog."default",
    description character varying COLLATE pg_catalog."default",
    img_storage character varying COLLATE pg_catalog."default",
    page_number integer,
    qr_code character varying COLLATE pg_catalog."default",
    rating double precision,
    title character varying COLLATE pg_catalog."default",
    category character varying COLLATE pg_catalog."default",
    left_ratings integer,
    rating_sum double precision,
    deadline integer,
    creator character varying(256)[] COLLATE pg_catalog."default",
    editor character varying(256)[] COLLATE pg_catalog."default",
    CONSTRAINT reads_books_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.reads_books
    OWNER to postgres;
-- Table: public.reads_contact_us

-- DROP TABLE public.reads_contact_us;

CREATE TABLE public.reads_contact_us
(
    id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    updated_at timestamp without time zone,
    description character varying(255) COLLATE pg_catalog."default",
    user_id uuid,
    creator character varying(256)[] COLLATE pg_catalog."default",
    editor character varying(256)[] COLLATE pg_catalog."default",
    CONSTRAINT reads_contact_us_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.reads_contact_us
    OWNER to postgres;
-- Table: public.reads_group

-- DROP TABLE public.reads_group;

CREATE TABLE public.reads_group
(
    id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    updated_at timestamp without time zone,
    mentor_id uuid,
    title character varying(255) COLLATE pg_catalog."default",
    creator character varying(256)[] COLLATE pg_catalog."default",
    editor character varying(256)[] COLLATE pg_catalog."default",
    CONSTRAINT reads_group_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.reads_group
    OWNER to postgres;
-- Table: public.reads_rules

-- DROP TABLE public.reads_rules;

CREATE TABLE public.reads_rules
(
    id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    updated_at timestamp without time zone,
    description character varying(255) COLLATE pg_catalog."default",
    title character varying(255) COLLATE pg_catalog."default",
    creator character varying(256)[] COLLATE pg_catalog."default",
    editor character varying(256)[] COLLATE pg_catalog."default",
    CONSTRAINT mds_reads_rules_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.reads_rules
    OWNER to postgres;
-- Table: public.reads_user_book

-- DROP TABLE public.reads_user_book;

CREATE TABLE public.reads_user_book
(
    id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    updated_at timestamp without time zone,
    book_id uuid,
    book_rating double precision,
    book_review text COLLATE pg_catalog."default",
    end_date timestamp without time zone,
    got_point integer,
    profile_id uuid,
    start_date timestamp without time zone,
    chance_number integer,
    verified boolean,
    check_rated boolean,
    last_notification timestamp without time zone,
    creator character varying(256)[] COLLATE pg_catalog."default",
    editor character varying(256)[] COLLATE pg_catalog."default",
    quiz_acl boolean,
    CONSTRAINT reads_user_book_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.reads_user_book
    OWNER to postgres;
-- Table: public.profiles

-- DROP TABLE public.profiles;

CREATE TABLE public.profiles
(
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    first_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    last_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    middle_name character varying(50) COLLATE pg_catalog."default",
    birthday date,
    gender smallint NOT NULL DEFAULT 1,
    grants boolean NOT NULL DEFAULT false,
    avatar character varying COLLATE pg_catalog."default",
    address character varying COLLATE pg_catalog."default",
    social character varying COLLATE pg_catalog."default",
    phone character varying COLLATE pg_catalog."default",
    skills character varying COLLATE pg_catalog."default",
    description text COLLATE pg_catalog."default",
    english_type integer,
    english_value character varying COLLATE pg_catalog."default",
    created_at timestamp without time zone DEFAULT (now())::timestamp without time zone,
    updated_at timestamp without time zone DEFAULT (now())::timestamp without time zone,
    deleted_at timestamp without time zone,
    email character varying(255) COLLATE pg_catalog."default",
    enabled boolean,
    password character varying(255) COLLATE pg_catalog."default",
    username character varying(255) COLLATE pg_catalog."default",
    group_id uuid,
    email_verified boolean,
    is_blocked timestamp without time zone,
    login_attempts integer,
    is_active boolean,
    path character varying COLLATE pg_catalog."default",
    reads_point integer,
    reads_recommendation character varying COLLATE pg_catalog."default",
    reads_finished_books integer,
    reads_reviews_number integer,
    language character varying(255) COLLATE pg_catalog."default",
    reads_group_id uuid,
    creator character varying(256)[] COLLATE pg_catalog."default",
    editor character varying(256)[] COLLATE pg_catalog."default",
    CONSTRAINT profile_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.profiles
    OWNER to postgres;