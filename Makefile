.DEFAULT_GOAL = build

bootstrap:
	@git submodule update --init --recursive

# The .git directory is not accessible by actions on GitHub, so we need a workaround for it.
# GitHub's actions set a CI environment variable (to true) so we can use it to check if we're running inside an action
# or not and initiate the workaround.
ifdef CI
# GitHub Actions also set the environment variables GITHUB_REF for the branch and GITHUB_SHA for the current commit
# hash. We can use that instead of git rev-parse.
	@echo Running build in CI mode.
BRANCH := $(shell echo $$GITHUB_REF)
BRANCH := $(patsubst refs/heads/%,%,$(BRANCH))
HASH := $(shell echo $$GITHUB_SHA | cut -c1-7)
# This will only be executed if we are outside the CI.
else
	@echo Running build in user mode.
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
HASH := $(shell git rev-parse --short HEAD)
endif

build: bootstrap
	@docker build -t osdev:$(BRANCH) .
