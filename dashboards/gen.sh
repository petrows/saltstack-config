#!/bin/bash -e

# export GRAFANA_URL=http://admin:admin@localhost:3000

for file in dashboard_*jsonnet; do
    echo "Processing: $file"

    JSONNET_PATH=grafonnet-lib \
    jsonnet $file > ../tmp/$file.json

    payload="{\"dashboard\": $(jq . ../tmp/$file.json), \"overwrite\": true}"

    curl -X POST $BASIC_AUTH \
    -H 'Content-Type: application/json' \
    -d "${payload}" \
    "$GRAFANA_URL/api/dashboards/db"
done
