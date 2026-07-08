.DEFAULT_GOAL := help
TF_DIR := terraform
.PHONY: help init fmt validate lint plan clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform (no backend)
	terraform -chdir=$(TF_DIR) init -backend=false

fmt: ## Check Terraform formatting recursively
	terraform fmt -recursive -check

validate: ## Initialize (no backend) and validate the Terraform config
	terraform -chdir=$(TF_DIR) init -backend=false
	terraform -chdir=$(TF_DIR) validate

lint: ## Lint YAML and Terraform (yamllint + tflint if installed)
	yamllint helm multi-cluster observability
	@command -v tflint >/dev/null 2>&1 && tflint --chdir=$(TF_DIR) || \
		echo "tflint not installed; skipping"

plan: ## Show a Terraform plan (requires cluster access + tfvars)
	terraform -chdir=$(TF_DIR) plan

clean: ## Remove local Terraform state and cache artifacts
	find . -type d -name ".terraform" -prune -exec rm -rf {} +
	find . -type f -name "*.tfplan" -delete
	rm -f crash.log crash.*.log
