# Deployment for Python

Opinionated shell scripts for deployment, a lot is based on the repository name and thus the `SLUG` environment variable.

Assume we have a repository named `foobar-service` and we didn't set `SLUG` by hand.

Here's the explanation in order of recommended execution:

## Requirements

- 3.12 <= [Python](https://docs.python.org) < 3.13

- [Docker](https://docs.docker.com/)

- [Kubernetes](https://kubernetes.io/docs/home/)

- [AWS](https://docs.aws.amazon.com/)

- [pip-tools](https://github.com/jazzband/pip-tools)

- [ruff](https://docs.astral.sh/ruff/)

## slug.sh

A lot of things are derived from the repository's name, i.e. you either set the `SLUG` environment variable manually or you replace `<REPLACE_WITH_REPOSITORY_NAME_ENV_VAR>` with something provided by your CI/CD like `GITHUB_REPOSITORY_NAME`, `BITBUCKET_REPO_SLUG`, ...

Example: `BITBUCKET_REPO_SLUG=foobar-service` will result in `SLUG=foobar`

## master.sh

Sets up all the environment variables for a specific branch/environment, i.e. rename this file to `production.sh` or duplicate it for whatever environment you build for. It requires some replacements:

- `<REPLACE_WITH_AWS_ACCOUNT_ID>`, e.g. 123456789012 or environment variable

- `<REPLACE_WIHT_AWS_REGION>`, e.g. us-east-1 or environment variable

- `<REPLACE_WITH_API_URL_NAME>`, e.g. api.foobar.com or environment variable

Then we have the `CONTEXT` for our API which I like to base on the `SLUG`, e.g. `api.company.com/foobar` but you can also set it manually.

## build.sh

Triggers `make`, see `Makefile`.

## lint.sh

Triggers `make lint`, see `Makefile`.

## docker.sh

Here we build the docker image and push it to the ECR repository.

It also requires some environment_variables to be set:

- `SLUG`, set by `slug.sh` or manually, e.g. in `master.sh`

- `<REPLACE_WITH_BRANCH_NAME_ENV_VAR>`, e.g. `GITHUB_REF##*/`, `BITBUCKET_BRANCH`, ...

- `<REPLACE_WITH_COMMIT_HASH_ENV_VAR>`, e.g. `GITHUB_SHA`, `BITBUCKET_COMMIT`, ...

- `AWS_ECR_URL`

- `AWS_REGION`

- `AWS_ACCESS_KEY_ID`

- `AWS_SECRET_ACCESS_KEY`

A multi-staged build follows that can use a specific `CONTEXT` (set in `master.sh`) environment variable for the server.

The images pushed assume an existing repository with `SLUG` as it's name, e.g. `foobar`.

It will push the image with the tags `latest` and branch name with shortened commit hash, e.g. `master-1234567`.

## k8s.sh

So one assumption here is that `STAGE` is basically also your k8s namespace, e.g. `(STAGE=PRODUCTION) == (NAMESPACE=production)`.

Yet another assumption is that you've created a secret in the secrets-manager with name `$SLUG-secrets`, e.g. `foobar-secrets`.

I use [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html) to replace variables in the `*.yml` files with environment variables.

Have a look at the YAML files yourself, they provide a basic skeleton.
