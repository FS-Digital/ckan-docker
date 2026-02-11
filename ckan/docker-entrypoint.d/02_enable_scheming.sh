#!/bin/bash
echo "Configuring Scheming..."
ckan config-tool $CKAN_INI "scheming.dataset_schemas = file:///srv/app/schemas/stockton_schema.json"