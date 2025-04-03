#!/bin/bash


docker run -d \
  --name db \
  --network my_network \
  -e POSTGRES_USER=webuser \
  -e POSTGRES_PASSWORD=webpass \
  -e POSTGRES_DB=webdb \
  postgres:latest