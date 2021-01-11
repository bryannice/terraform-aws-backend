# -----------------------------------------------------------------------------
# Terraform AWS Backend
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
# FUNCTIONS
# -----------------------------------------------------------------------------

if_def_any_of = $(filter-out undefined,$(foreach v,$(1),$(origin $(v))))

# -----------------------------------------------------------------------------
# Checking If Required Environment Variables Were Set
# -----------------------------------------------------------------------------

TARGETS_TO_CHECK := "fetch-statefile init plan destroy apply backend"
AWS_CREDENTIAL_CONTEXT := $(shell [[ ! -d ".aws" ]] && echo 0 || echo 1)

ifeq ($(findstring $(MAKECMDGOALS),$(TARGETS_TO_CHECK)),$(MAKECMDGOALS))
$(info $(BOLD)$(YELLOW)Checking required AWS credential context is set.$(RESET))
ifeq ($(AWS_CREDENTIAL_CONTEXT),0)
ifeq ($(AWS_ACCESS_KEY_ID), )
$(info $(BOLD)$(RED)Required Envirornment AWS_ACCESS_KEY_ID is not set.$(RESET))
$(shell read -p "AWS_ACCESS_KEY_ID=" AWS_ACCESS_KEY_ID)
endif
ifeq ($(AWS_SECRET_ACCESS_KEY), )
$(info $(BOLD)$(RED)Required Envirornment AWS_SECRET_ACCESS_KEY is not set.$(RESET))
$(shell read -p "AWS_SECRET_ACCESS_KEY=" AWS_SECRET_ACCESS_KEY)
endif
ifeq ($(AWS_DEFAULT_REGION), )
$(info $(BOLD)$(RED)Required Envirornment AWS_DEFAULT_REGION is not set.$(RESET))
$(shell read -p "AWS_DEFAULT_REGION=" AWS_DEFAULT_REGION)
endif
ifeq ($(AWS_DEFAULT_OUTPUT), )
$(info $(BOLD)$(RED)Required Envirornment AWS_DEFAULT_OUTPUT is not set.$(RESET))
$(shell read -p "AWS_DEFAULT_OUTPUT=" AWS_DEFAULT_OUTPUT)
endif

.EXPORT_ALL_VARIABLES:
AWS_ACCESS_KEY_ID := $(AWS_ACCESS_KEY_ID)
AWS_SECRET_ACCESS_KEY := $(AWS_SECRET_ACCESS_KEY)
AWS_DEFAULT_REGION := $(AWS_DEFAULT_REGION)
AWS_DEFAULT_OUTPUT := $(AWS_DEFAULT_OUTPUT)

$(info $(BOLD)$(GREEN)Completed setting required aws environment variables.$(RESET))
$(info $(BOLD)$(GREEN)AWS credential context verified.$(RESET))
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

DOCKER_IMAGE_NAME ?= bryannice/alpine-terraform-aws
DOCKER_IMAGE_TAG ?= 1.3.2

# -----------------------------------------------------------------------------
# Terraform Varibles
# -----------------------------------------------------------------------------

.EXPORT_ALL_VARIABLES:
TF_VAR_access_key ?= $(AWS_ACCESS_KEY_ID)
TF_VAR_secret_key ?= $(AWS_SECRET_ACCESS_KEY)
TF_VAR_bucket := $(GIT_ACCOUNT_NAME)-$(GIT_REPOSITORY_NAME)
TF_VAR_region ?= $(AWS_DEFAULT_REGION)
TF_VAR_key := backend/$(GIT_REPOSITORY_NAME).tfstate #Terraform Statefile Name

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
	@rm -rf .aws
	@echo "$(BOLD)$(GREEN)Completed cleaning up working directory.$(RESET)"

.PHONY: cli
cli:
	@docker run \
		-it \
		--rm \
		-v ${PWD}:/home/terraform \
		--env AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		--env AWS_DEFAULT_OUTPUT=$(AWS_DEFAULT_OUTPUT) \
		--env AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		--env AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) \
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

.PHONY: build
build:
	@echo "$(BOLD)$(YELLOW)Instantiate alpine-terraform-aws container.$(RESET)"
	@docker run \
		-it \
		--rm \
		-v $(PWD):/home/terraform \
		--env AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		--env AWS_DEFAULT_OUTPUT=$(AWS_DEFAULT_OUTPUT) \
		--env AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		--env AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) \
		make backend
	@echo "$(BOLD)$(GREEN)Completed backend provisioning process.$(RESET)"
