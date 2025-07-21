#!/bin/bash
mongoimport --host localhost \
  --port 27017 \
  -u root \
  -p root \
  --authenticationDatabase admin \
  --db smartify \
  --collection universities \
  --file /docker-entrypoint-initdb.d/universities.json \
  --jsonArray

mongoimport --host localhost \
  --port 27017 \
  -u root \
  -p root \
  --authenticationDatabase admin \
  --db smartify \
  --collection professions \
  --file /docker-entrypoint-initdb.d/professions.json \
  --jsonArray

mongoimport --host localhost \
  --port 27017 \
  -u root \
  -p root \
  --authenticationDatabase admin \
  --db smartify \
  --collection dataset_career_test \
  --file /docker-entrypoint-initdb.d/dataset_career_test.json \
  --jsonArray
