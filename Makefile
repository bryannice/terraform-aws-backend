# -----------------------------------------------------------------------------
# Senzing Terraform AWS Backend
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Internal Variables
# -----------------------------------------------------------------------------

BOLD :=$(shell tput bold)
RED :=$(shell tput setaf 1)
GREEN :=$(shell tput setaf 2)
YELLOW :=$(shell tput setaf 3)
RESET :=$(shell tput sgr0)

# -----------------------------------------------------------------------------
# Checking If Required Environment Variables Were Set
# -----------------------------------------------------------------------------

TARGETS_TO_CHECK := "cli fetch-statefile init plan destroy apply backend"

ifeq ($(findstring $(MAKECMDGOALS),$(TARGETS_TO_CHECK)),$(MAKECMDGOALS))
ifndef AWS_ACCESS_KEY_ID
$(error $(BOLD)$(RED)AWS_ACCESS_KEY_ID is not defined, please set this environment variable before proceeding$(RESET))
endif

ifndef AWS_SECRET_ACCESS_KEY
$(error $(BOLD)$(RED)AWS_SECRET_ACCESS_KEY is not defined, please set this environment variable before proceeding$(RESET))
endif

ifndef AWS_DEFAULT_REGION
$(error $(BOLD)$(RED)AWS_DEFAULT_REGION is not defined, please set this environment variable before proceeding$(RESET))
endif
endif

# -----------------------------------------------------------------------------
# Git Variables
# -----------------------------------------------------------------------------

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GIT_REPOSITORY_NAME := $(shell git config --get remote.origin.url | cut -d'/' -f5 | cut -d'.' -f1)
GIT_ACCOUNT_NAME := $(shell git config --get remote.origin.url | cut -d'/' -f4)
GIT_SHA := $(shell git log --pretty=format:'%H' -n 1)
GIT_TAG ?= $(shell git describe --always --tags | awk -F "-" '{print $$1}')
GIT_TAG_END ?= HEAD
GIT_VERSION := $(shell git describe --always --tags --long --dirty | sed -e 's/\-0//' -e 's/\-g.......//')
GIT_VERSION_LONG := $(shell git describe --always --tags --long --dirty)

# -----------------------------------------------------------------------------
# Docker Variables
# -----------------------------------------------------------------------------

BASE_IMAGE ?= golang:1.14.1-alpine3.11
DOCKER_IMAGE_PACKAGE := $(GIT_REPOSITORY_NAME)-package:$(GIT_VERSION)
DOCKER_IMAGE_TAG ?= $(GIT_REPOSITORY_NAME):$(GIT_VERSION)
DOCKER_IMAGE_NAME := $(GIT_REPOSITORY_NAME)

# -----------------------------------------------------------------------------
# Go Lang Variables
# -----------------------------------------------------------------------------

GOLANG_VERSION ?= 1.13.8
GOLANG_SHA ?= 0567734d558aef19112f2b2873caa0c600f1b4a5827930eb5a7f35235219e9d8

# -----------------------------------------------------------------------------
# Terraform Varibles
# -----------------------------------------------------------------------------

TERRAFORM_VERSION ?= 0.12.20

.EXPORT_ALL_VARIABLES:
TF_VAR_access_key := $(AWS_ACCESS_KEY_ID)
TF_VAR_secret_key := $(AWS_SECRET_ACCESS_KEY)
TF_VAR_bucket := $(GIT_ACCOUNT_NAME)-$(GIT_REPOSITORY_NAME)
TF_VAR_region := $(AWS_DEFAULT_REGION)
TF_VAR_key := backend/$(GIT_REPOSITORY_NAME).tfstate #Terraform Statefile Name

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# Docker-based builds
# -----------------------------------------------------------------------------

.PHONY: docker-build
docker-build: docker-rmi-for-build
	docker build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg GOLANG_VERSION=$(GOLANG_VERSION) \
		--build-arg GOLANG_SHA=$(GOLANG_SHA) \
		--build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
		--tag $(DOCKER_IMAGE_NAME) \
		--tag $(DOCKER_IMAGE_NAME):$(GIT_VERSION) \
		.

.PHONY: docker-build-development-cache
docker-build-development-cache: docker-rmi-for-build-development-cache
	docker build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg GOLANG_VERSION=$(GOLANG_VERSION) \
		--build-arg GOLANG_SHA=$(GOLANG_SHA) \
		--build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
		--tag $(DOCKER_IMAGE_TAG) \
		.

# -----------------------------------------------------------------------------
# Clean up targets
# -----------------------------------------------------------------------------

.PHONY: docker-rmi-for-build
docker-rmi-for-build:
	-docker rmi --force \
		$(DOCKER_IMAGE_NAME):$(GIT_VERSION) \
		$(DOCKER_IMAGE_NAME)

.PHONY: docker-rmi-for-build-development-cache
docker-rmi-for-build-development-cache:
	-docker rmi --force $(DOCKER_IMAGE_TAG)

.PHONY: docker-rmi-for-package
docker-rmi-for-packagae:
	-docker rmi --force $(DOCKER_IMAGE_PACKAGE)

# -----------------------------------------------------------------------------
# Terraform Targets
# -----------------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "$(BOLD)$(YELLOW)Cleaning up working directory.$(RESET)"
	@rm -rf beconf.tfvarse
	@rm -rf beconf.tfvars
	@rm -rf .terraform
	@rm -rf .terraform.d
	@rm -rf *.tfstate
	@rm -rf crash.log
	@rm -rf backend.tf
	@rm -rf *.tfstate.backup
	@echo "$(BOLD)$(GREEN)Completed cleaning up working directory.$(RESET)"

.PHONY: cli
cli:
	@docker run \
		-it \
		--rm \
		-v $(PWD):/root/$(DOCKER_IMAGE_NAME) \
		--env AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		--env AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		--env AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		--workdir /root/$(GIT_REPOSITORY_NAME) \
		$(DOCKER_IMAGE_NAME) \
		bash

.PHONY: fmt
fmt:
	@echo "$(BOLD)$(YELLOW)Formatting terraform files.$(RESET)"
	@terraform fmt
	@echo "$(BOLD)$(GREEN)Completed formatting files.$(RESET)"

.PHONY: change-to-local
change-to-local:
	@echo "$(BOLD)$(YELLOW)Creating backend.tf with local configuration.$(RESET)"
	@export BACKEND_TYPE=local; \
	export BUCKET=""; \
	export KEY=""; \
	export REGION=""; \
	export DYNAMODB_TABLE=""; \
	export ENCRYPT=""; \
	envsubst < templates/template.backend.tf > backend.tf
	@echo "$(BOLD)$(GREEN)Completed generating backend.tf.$(RESET)"

.PHONY: change-to-s3
change-to-s3:
	@echo "$(BOLD)$(YELLOW)Creating backend.tf with s3 configuration.$(RESET)"
	@export BACKEND_TYPE=s3; \
	export BUCKET="bucket = \"$(TF_VAR_bucket)\""; \
	export KEY="key = \"$(TF_VAR_key)\""; \
	export REGION="region = \"$(TF_VAR_region)\""; \
	export DYNAMODB_TABLE="dynamodb_table = \"$(TF_VAR_bucket)\""; \
	export ENCRYPT="encrypt = \"true\""; \
	envsubst < templates/template.backend.tf > backend.tf
	@echo "$(BOLD)$(GREEN)Completed generating backend.tf.$(RESET)"

.PHONY: fetch-statefile
fetch-statefile:
	@echo "$(BOLD)$(YELLOW)Fetching statefile from s3 bucket.$(RESET)"
	@aws s3 cp s3://$(TF_VAR_bucket)/$(TF_VAR_key) . --recursive
	@echo "$(BOLD)$(GREEN)Completed fetching statefile.$(RESET)"

.PHONY: init
init:
	@echo "$(BOLD)$(YELLOW)Initializing terraform project.$(RESET)"
	@terraform init \
		-force-copy \
		-input=false \
		-upgrade
	@echo "$(BOLD)$(GREEN)Completed initialization.$(RESET)"

.PHONY: plan
plan:
	@echo "$(BOLD)$(YELLOW)Create terraform plan.$(RESET)"
	@terraform plan \
		-input=false \
		-refresh=true
	@echo "$(BOLD)$(GREEN)Completed plan generation.$(RESET)"

.PHONY: destroy
destroy: change-to-local fetch-statefile init plan
	@echo "$(BOLD)$(YELLOW)Destroying backend infrastructure in aws.$(RESET)"
	@sleep 10
	@terraform destroy \
		-auto-approve \
		-input=false \
		-refresh=true
	@echo "$(BOLD)$(GREEN)Completed infrastructure destroy.$(RESET)"

.PHONY: apply
apply: change-to-local clean init plan
	@echo "$(BOLD)$(YELLOW)Creating backend infrastructure in aws.$(RESET)"
	@sleep 10
	@terraform apply \
		-input=false \
    	-auto-approve
	@echo "$(BOLD)$(GREEN)Completed creating backend infrastructure.$(RESET)"

.PHONY: backend
backend: apply change-to-s3
	@echo "$(BOLD)$(YELLOW)Initializing terraform to sync statefile with s3 bucket.$(RESET)"
	@sleep 10
	@terraform init \
		-force-copy \
		-input=false
	@echo "$(BOLD)$(GREEN)Completed syncing statefile with s3.$(RESET)"

