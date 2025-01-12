#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username="$POSTGRES_USER" --dbname="$POSTGRES_DB" <<-EOSQL
  SET standard_conforming_strings = ON;

  \COPY public.cities(name, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/public_cities.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY public.countries(name, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/public_countries.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY public.addresses(street_name, street_number, postal, country_id, city_id, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/public_addresses.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY public.websites(url, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/public_websites.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY public.units(name, symbol, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/public_units.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');

  \COPY companies.companies(name, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/companies_companies.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY companies.brands(name, company_id, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/companies_brands.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY companies.company_relationships(parent_company_id, child_company_id, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/companies_company_relationships.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY companies.company_addresses(company_id, address_id, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/companies_company_addresses.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY companies.company_websites(company_id, website_id, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/companies_company_websites.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');

  \COPY groceries.groceries(name, content, unit, brand_id, manufacturer_id, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/groceries_groceries.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY groceries.categories(name, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/groceries_categories.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY groceries.grocery_categories(grocery_id, category_id, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/groceries_grocery_categories.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
  \COPY groceries.grocery_purchases(article_id, price, price_per_unit, unit_id, offer, purchase_date, purchase_place_physical, purchase_place_online, created_at, updated_at) FROM '/docker-entrypoint-initdb.d/DummyData/groceries_grocery_purchases.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '');
EOSQL