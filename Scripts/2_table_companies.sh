#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username="$POSTGRES_USER" --dbname="$POSTGRES_DB" <<-EOSQL

	/*
		Companies Table
	*/

  CREATE TABLE IF NOT EXISTS companies.companies
  (
    id bigint GENERATED ALWAYS AS IDENTITY,
    name text COLLATE pg_catalog.default,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT companies_pkey PRIMARY KEY (id)
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS companies.companies
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON companies.companies
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();

	/*
		Company Brands Table
	*/

	CREATE TABLE IF NOT EXISTS companies.brands
  (
    id bigint GENERATED ALWAYS AS IDENTITY,
    name text COLLATE pg_catalog.default,
    company_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT brands_pkey PRIMARY KEY (id),
    CONSTRAINT brands_company_fkey FOREIGN KEY (company_id)
        REFERENCES companies.companies (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS companies.brands
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON companies.brands
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();

	/*
		Company Relationships Table
	*/

	CREATE TABLE IF NOT EXISTS companies.company_relationships
  (
    parent_company_id bigint NOT NULL,
    child_company_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT company_relationships_pkey PRIMARY KEY (parent_company_id, child_company_id),
    CONSTRAINT company_relationships_parent_fkey FOREIGN KEY (parent_company_id)
        REFERENCES companies.companies (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT company_relationships_child_fkey FOREIGN KEY (child_company_id)
        REFERENCES companies.companies (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT check_no_self_relationship CHECK (parent_company_id != child_company_id)
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS companies.company_relationships
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON companies.company_relationships
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();

	/*
		Company Locations Table
	*/

	CREATE TABLE IF NOT EXISTS companies.company_addresses
  (
    company_id bigint NOT NULL,
    address_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT company_addresses_pkey PRIMARY KEY (company_id, address_id),
    CONSTRAINT company_addresses_company_fkey FOREIGN KEY (company_id)
        REFERENCES companies.companies (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT company_addresses_address_fkey FOREIGN KEY (address_id)
        REFERENCES public.addresses (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS companies.company_addresses
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON companies.company_addresses
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();

	/*
		Company Websites Table
	*/

	CREATE TABLE IF NOT EXISTS companies.company_websites
  (
    company_id bigint NOT NULL,
    website_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT company_websites_pkey PRIMARY KEY (company_id, website_id),
    CONSTRAINT company_websites_company_fkey FOREIGN KEY (company_id)
        REFERENCES companies.companies (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT company_websites_website_fkey FOREIGN KEY (website_id)
        REFERENCES public.websites (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS companies.company_websites
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON companies.company_websites
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();
EOSQL