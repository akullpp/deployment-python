#!/bin/bash

export AWS_ECR_URL=<REPLACE_WITH_AWS_ACCOUNT_ID>.dkr.ecr.<REPLACE_WIHT_AWS_REGION>.amazonaws.com
export AWS_REGION=<REPLACE_WIHT_AWS_REGION>

export STAGE=PRODUCTION
export HOST=<REPLACE_WITH_API_URL_NAME>
export PORT=8000
export CONTEXT=$SLUG
export MEMORY_LIMIT=512Mi
export MEMORY_REQUESTS=256Mi

printenv
