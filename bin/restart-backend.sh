#!/usr/bin/env bash

set -euo pipefail

update_crontab() {
    local file=$1
    local url=$2
    if ! grep -q "$file" /etc/crontab; then
        echo "0 1 * * *	root	curl -o $(pwd)/$file $url" | sudo tee -a /etc/crontab
    fi
}

update_crontab supply.csv https://etherscan.io/chart/ethersupplygrowth?output=csv
update_crontab price.csv https://etherscan.io/chart/etherprice?output=csv

curl -o supply.csv https://etherscan.io/chart/ethersupplygrowth?output=csv
curl -o price.csv https://etherscan.io/chart/etherprice?output=csv

pkill -f uvicorn
sleep 1
poetry run -- uvicorn --host 0.0.0.0 --port 8080 backend.main:app 1>backend.log 2>&1 &