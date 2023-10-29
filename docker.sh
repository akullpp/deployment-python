#!/bin/bash

[[ -z $SLUG ]] && echo "Missing SLUG" && exit 1
[[ -z $<REPLACE_WITH_BRANCH_NAME_ENV_VAR> ]] && echo "Missing BRANCH_NAME" && exit 1
[[ -z $<REPLACE_WITH_COMMIT_HASH_ENV_VAR> ]] && echo "Missing COMMIT_HASH" && exit 1
[[ -z $AWS_ECR_URL ]] && echo "Missing AWS_ECR_URL" && exit 1
[[ -z $AWS_REGION ]] && echo "Missing AWS_REGION" && exit 1
[[ -z $AWS_ACCESS_KEY_ID ]] && echo "Missing AWS_ACCESS_KEY_ID" && exit 1
[[ -z $AWS_SECRET_ACCESS_KEY ]] && echo "Missing AWS_SECRET_ACCESS_KEY" && exit 1

# Create Dockerfile
cat >Dockerfile <<EOF
FROM python:3.12-slim as build

ENV PIP_DEFAULT_TIMEOUT=100 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY requirements.in ./

RUN pip install pip-tools \
    && pip-compile --strip-extras -q -o requirements.txt requirements.in


FROM python:3.12-slim as runtime

ENV CONTEXT=$CONTEXT

WORKDIR /app

COPY --from=build /app/requirements.txt .

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install build-essential -y \
    && pip install -r requirements.txt \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

COPY ./app app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--root-path", "/$CONTEXT"]
EOF

# Create vars
IMAGE="${AWS_ECR_URL}/${SLUG}"
TAG="${BRANCH_NAME}-${COMMIT_HASH::7}"

echo -e "\n--- docker ---"
echo "IMAGE=$IMAGE"
echo "TAGS=$TAG,latest"
echo -e "--- docker ---\n"

aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ECR_URL}" &&
  # Build and push
  docker build -t "$IMAGE":"$TAG" -t "$IMAGE":latest . &&
  docker push "$IMAGE":latest &&
  docker push "$IMAGE":"$TAG"
