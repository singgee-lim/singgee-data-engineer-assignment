.PHONY: help
help:
	@echo "Here are the commands to get started:\n"
	@echo "\tsetup:\t\tBuilds container image using Docker\n"
	@echo "\trun:\t\tRuns container image using Docker\n"

DOCKER				= docker
CONTAINER_NAME		= sg-assignment

.PHONY: setup
setup:
	$(DOCKER) build -t $(CONTAINER_NAME) .

.PHONY: run
run:
	$(DOCKER) run -v $GOOGLE_APPLICATION_CREDENTIALS:/root/.config/gcloud/application_default_credentials.json:ro $(CONTAINER_NAME)
