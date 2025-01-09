#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username="$POSTGRES_USER" --dbname="$POSTGRES_DB" <<-EOSQL

	/*
		Groceries Table
	*/

  CREATE TABLE IF NOT EXISTS groceries.groceries
  (
    id bigint GENERATED ALWAYS AS IDENTITY,
    name text COLLATE pg_catalog.default,
    content numeric(1000,2),
    unit bigint,
    brand_id bigint NOT NULL,
    manufacturer_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT groceries_pkey PRIMARY KEY (id),
    CONSTRAINT groceries_brand_fkey FOREIGN KEY (brand_id)
        REFERENCES companies.brands (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT groceries_manufacturer_fkey FOREIGN KEY (manufacturer_id)
        REFERENCES companies.companies (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS groceries.groceries
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON groceries.groceries
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();

	/*
		Categories Table
	*/

  CREATE TABLE IF NOT EXISTS groceries.categories
  (
    id bigint GENERATED ALWAYS AS IDENTITY,
    name text COLLATE pg_catalog.default,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT categories_pkey PRIMARY KEY (id)
  )

	TABLESPACE pg_default;

	ALTER TABLE IF EXISTS groceries.categories
		OWNER to "$POSTGRES_USER";

	CREATE TRIGGER trigger_onUpdate
		BEFORE UPDATE
		ON groceries.categories
		FOR EACH ROW
		EXECUTE FUNCTION public.onUpdate_timestamp();

  /*
    Grocery Categories Table
  */

  CREATE TABLE IF NOT EXISTS groceries.grocery_categories
  (
    grocery_id bigint NOT NULL,
    category_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT grocery_categories_pkey PRIMARY KEY (grocery_id, category_id),
    CONSTRAINT grocery_categories_category_fkey FOREIGN KEY (category_id)
        REFERENCES groceries.categories (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT grocery_categories_grocery_fkey FOREIGN KEY (grocery_id)
        REFERENCES groceries.groceries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
  )

  TABLESPACE pg_default;

  ALTER TABLE IF EXISTS groceries.grocery_categories
    OWNER to "$POSTGRES_USER";

  CREATE TRIGGER trigger_onUpdate
    BEFORE UPDATE
    ON groceries.grocery_categories
    FOR EACH ROW
    EXECUTE FUNCTION public.onUpdate_timestamp();

  /*
    Grocery Purchases Table
  */

  CREATE TABLE IF NOT EXISTS groceries.grocery_purchases
  (
    id bigint GENERATED ALWAYS AS IDENTITY,
    article_id bigint NOT NULL,
    price numeric(1000,2),
    price_per_unit numeric(1000,2),
    unit_id bigint,
    offer boolean,
    purchase_date timestamp with time zone,
    purchase_place_physical bigint,
    purchase_place_online bigint,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT grocery_purchases_pkey PRIMARY KEY (id),
    CONSTRAINT grocery_purchases_article_fkey FOREIGN KEY (article_id)
        REFERENCES groceries.groceries (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT grocery_purchases_purchase_place_online_fkey FOREIGN KEY (purchase_place_online)
        REFERENCES public.websites (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT grocery_purchases_purchase_place_physical_fkey FOREIGN KEY (purchase_place_physical)
        REFERENCES public.addresses (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT grocery_purchases_unit_fkey FOREIGN KEY (unit_id)
        REFERENCES public.units (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT grocery_purchases_check CHECK (((purchase_place_physical IS NOT NULL)::integer + (purchase_place_online IS NOT NULL)::integer) = 1)
  )

  TABLESPACE pg_default;

  ALTER TABLE IF EXISTS groceries.grocery_purchases
    OWNER to "$POSTGRES_USER";

  DROP INDEX IF EXISTS groceries.grocery_purchases_purchase_place_online_idx;
  CREATE UNIQUE INDEX IF NOT EXISTS grocery_purchases_purchase_place_online_idx
    ON groceries.grocery_purchases USING btree
    (purchase_place_online ASC NULLS LAST)
    TABLESPACE pg_default
    WHERE purchase_place_online IS NOT NULL;

  DROP INDEX IF EXISTS groceries.grocery_purchases_purchase_place_physical_idx;
  CREATE UNIQUE INDEX IF NOT EXISTS grocery_purchases_purchase_place_physical_idx
    ON groceries.grocery_purchases USING btree
    (purchase_place_physical ASC NULLS LAST)
    TABLESPACE pg_default
    WHERE purchase_place_physical IS NOT NULL;

  CREATE TRIGGER trigger_onUpdate
    BEFORE UPDATE
    ON groceries.grocery_purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.onUpdate_timestamp();
EOSQL