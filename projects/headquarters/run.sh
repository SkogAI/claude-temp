#!/usr/bin/env bash

echo "password1" >bootstrap/pat.password.example
docker compose build
docker compose down
docker compose up -d
docker exec soft-serve bash -c "git clone https://github.com/SkogAI/bootstrap.git ~/bootstrap && cd ~/bootstrap && ./bootstrap.sh"
