#!/bin/bash

# If SLUG is not set, build it from the repository name
if [[ -z ${SLUG} ]]; then
  SLUG=$(echo "$<REPLACE_WITH_REPOSITORY_NAME_ENV_VAR>" | cut -f1 -d"-" | head -c 15)
fi

export SLUG=$SLUG
echo "SLUG: $SLUG"
