#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username="$POSTGRES_USER" --dbname="$POSTGRES_DB" <<-EOSQL

	/*
		Cities Table
	*/

  CREATE TABLE IF NOT EXISTS public.cities
  (
    id bigint GENERATED ALWAYS AS IDENTITY,
    name text COLLATE pg_catalog.default,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT cities_pkey PRIMARY KEY (id)
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS public.cities
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON public.cities
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();

	/*
		Countries Table
	*/

  CREATE TABLE IF NOT EXISTS public.countries
  (
    id bigint GENERATED ALWAYS AS IDENTITY,
    name text COLLATE pg_catalog.default,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT countries_pkey PRIMARY KEY (id)
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS public.countries
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON public.countries
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();

	/*
		Addresses Table
	*/

  CREATE TABLE IF NOT EXISTS public.addresses
  (
    id bigint GENERATED ALWAYS AS IDENTITY,
    street_name text COLLATE pg_catalog.default,
    street_number text COLLATE pg_catalog.default,
    postal text COLLATE pg_catalog.default,
    country_id bigint NOT NULL,
    city_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT addresses_pkey PRIMARY KEY (id),
    CONSTRAINT addresses_country_fkey FOREIGN KEY (country_id)
        REFERENCES public.countries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT addresses_city_fkey FOREIGN KEY (city_id)
        REFERENCES public.cities (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS public.addresses
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON public.addresses
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();

	/*
		Websites Table
	*/

  CREATE TABLE IF NOT EXISTS public.websites
  (
    id bigint GENERATED ALWAYS AS IDENTITY,
    url text COLLATE pg_catalog.default,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT websites_pkey PRIMARY KEY (id)
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS public.websites
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON public.websites
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();

	/*
		Units Table
	*/

  CREATE TABLE IF NOT EXISTS public.units
  (
    id bigint GENERATED ALWAYS AS IDENTITY,
    name text COLLATE pg_catalog.default,
    symbol text COLLATE pg_catalog.default,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT units_pkey PRIMARY KEY (id)
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS public.units
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON public.units
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();
EOSQL