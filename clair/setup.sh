#!/bin/bash

echo "*** Starting PostgreSQL"
docker-compose up -d postgres

if [ -f "clair.sql" ]; then
  echo "*** Seems sample DB dump has been already downloaded"
else
  echo "*** Downloading sample database"
  curl -LO https://gist.githubusercontent.com/BenHall/34ae4e6129d81f871e353c63b6a869a7/raw/5818fba954b0b00352d07771fabab6b9daba5510/clair.sql
fi

echo "*** Waiting to PostgreSQL to bootup"
sleep 5

# Note: Clair would do this by default, but can take 10/15 minutes to download.
echo "*** Starting to import database"
docker run -it -v $(pwd):/sql/ --network "clair_default" --link clair_postgres:clair_postgres postgres:latest \
  bash -c "PGPASSWORD=password psql -h clair_postgres -U postgres < /sql/clair.sql"

echo "*** Booting up Clair"
docker-compose up -d clair


if [ -x "./klar" ]; then
  echo "*** Seems klar has been already downloaded"
else
  dist=$(uname)

  case $dist in
    "Linux")
      echo "*** Downloading klar for Linux"
      curl -L https://github.com/optiopay/klar/releases/download/v1.5/klar-1.5-linux-amd64 -o klar && chmod +x $_
      ;;
    "Darwin")
      echo "*** Downloading klar for OSX"
      curl -L https://github.com/optiopay/klar/releases/download/v1.5/klar-1.5-osx-amd64 -o klar && chmod +x $_
      ;;
    *)
      ;;
  esac
fi

echo "*** Clair and klar setup ***"
echo "*** Usage:"
echo "CLAIR_ADDR=http://localhost:6060 CLAIR_OUTPUT=Medium CLAIR_THRESHOLD=0 ./klar quay.io/coreos/clair:v2.0.1"
