#!/bin/bash

service_name="$1"
new_tag="$2"
yaml_file="./charts/values.yaml"

# Check if service name is provided
if [ -z "$service_name" ]; then
  echo "Service name not provided. Exiting..."
  exit 1
fi

# Check if tag is provided
if [ -z "$new_tag" ]; then
  echo "New tag not provided. Exiting..."
  exit 1
fi

# Update the tag for the specified service in the YAML file
sed -i.bak -e "/$service_name:/,/tag:/ s/tag:.*/tag: $new_tag/" $yaml_file

# Remove the backup file
rm "${yaml_file}.bak"

echo "Tag updated successfully for $service_name."
