VERSION = master
UID = $(shell id -u)
GID = $(shell id -g)
SSH_AUTH_SOCK = $(shell echo $$SSH_AUTH_SOCK)
DOCKER_IMAGE = pim-docs:$(VERSION)
DOCKER_RUN = docker run -it --rm -u $(UID):$(GID)

.DEFAULT_GOAL := build
.PHONY: build, deploy, docker-build

build:
	@echo "\nBuilding Docker image..."
	make docker-build
	@echo "\nChecking documentation errors..."
	make lint
	@echo "\nBuilding documentation..."
	rm -rf pim-docs-build && mkdir pim-docs-build
	$(DOCKER_RUN) -v $(PWD):/home/akeneo/pim-docs/data $(DOCKER_IMAGE) data/build.sh $(VERSION)
	@echo "\n\nYou are now ready to check the documentation locally in the directory \"pim-docs-build/\" and to deploy it with \"HOSTNAME=foo.com PORT=1985 make deploy\"."

deploy:
	docker run -it --rm -v $(SSH_AUTH_SOCK):/ssh-auth.sock:ro -e SSH_AUTH_SOCK=/ssh-auth.sock -v $(PWD):/home/akeneo/pim-docs/data $(DOCKER_IMAGE) rsync -e "ssh -p ${PORT}" -arvz /home/akeneo/pim-docs/data/pim-docs-build/ akeneo@${HOSTNAME}:/var/www/${VERSION}

lint:
	rm -rf pim-docs-lint && mkdir pim-docs-lint
	$(DOCKER_RUN) -v $(PWD):/home/akeneo/pim-docs/data $(DOCKER_IMAGE) sphinx-build -nWT -b linkcheck /home/akeneo/pim-docs/data /home/akeneo/pim-docs/data/pim-docs-lint

docker-build:
	docker build . --tag $(DOCKER_IMAGE)
