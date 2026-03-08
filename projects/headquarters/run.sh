#!/usr/bin/env bash

echo "password1" >bootstrap/pat.password.example
docker compose build
docker compose down
docker compose up -d
docker exec soft-serve bash -c "cd /bootstrap && git pull && ./bootstrap.sh"
