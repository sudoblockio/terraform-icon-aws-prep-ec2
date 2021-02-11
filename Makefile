SHELL := /bin/bash -euo pipefail
.PHONY: all test clean

help: 								## Show help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

clear-cache:						## Clear the terragrunt and terraform caches
	find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \; && \
	find . -type d -name ".terraform" -prune -exec rm -rf {} \; && \
	find . -type f -name "*.tfstate*" -prune -exec rm -rf {} \;

# Currently tests don't work in CI except for the citizen
# This is due to a bug in the registration module re-running on destroy which breaks the
# destroy in automation.
#test:								## Run tests
#	go test ./test -v -timeout 120m
#
#test-init:							## Initialize the repo for tests
#	go mod init test && go mod tidy
test:								## Run tests
	go test ./test/terraform_citizen_test.go ./test/options.go -v -timeout 120m
