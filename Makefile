NAME	= appsoa/docker-alpine-harbor
ALIAS	= harbor
VERSION	= 0.0.1

DATA_DIR		= /workspace/.docker/volumes/$(ALIAS)
HARBOR_VERSION 	= 1.1.2
HARBOR_FILE 	= harbor-online-installer-v1.1.2.tgz

.PHONY:	all build test tag_latest release ssh

all:	clean build

build:

	@echo "Building an image with the current tag $(NAME):$(VERSION).."
	@docker build -t $(NAME):$(VERSION) --rm .

clean: docker-current-clean-images docker-current-clean-volumes docker-global-clean-images
clean:
	
	@echo Deleting source files
	@rm -rf harbor
	@rm -rf $(HARBOR_FILE)

src:

	git clone https://github.com/vmware/harbor

prepare:

	@wget https://github.com/vmware/harbor/releases/download/v$(HARBOR_VERSION)/$(HARBOR_FILE) -O $(HARBOR_FILE)
	@tar -xvf $(HARBOR_FILE)
	
	@cp harbor.cfg harbor/harbor.cfg
	@cd harbor && ./install.sh

run:

	docker run --rm -p 9389:3389 -p 922:22 -it $(NAME):$(VERSION) /bin/sh

tag_latest:

	docker tag $(NAME):$(VERSION) $(NAME):latest

release:

	docker push $(NAME)

test:

	./test.sh $(NAME):$(VERSION)


docker-current-clean-containers:

	@echo "Deleting container(s) with the current tag $(NAME):$(VERSION).."
	@docker ps -a | grep $(ALIAS) | xargs --no-run-if-empty docker rm -f

docker-current-clean-images:

	@echo "Deleting image(s) with the current tag $(NAME):$(VERSION).."
	@docker images -a | grep $(NAME):$(VERSION) | xargs --no-run-if-empty docker rmi -f

docker-current-clean-volumes:

	@echo "Deleting volumes(s) with the current tag $(NAME):$(VERSION).."
	@docker volume ls -q | grep $(NAME):$(VERSION) | xargs -r docker volume rm || true

docker-global-clean-images:

	@echo "Deleting images that are not tagged.."
	@docker images | grep \<none\> | awk -F " " '{print $3}' | xargs --no-run-if-empty docker rmi

docker-images-list:

	@echo "Listing image(s) matching the current repo \"$(NAME)\" and the tag \"$(VERSION)\".."
	@docker images -a | grep $(NAME) | grep $(VERSION) || true

	@echo "Listing any other images matching current repo \"$(NAME)\":"
	@docker images -a | grep $(NAME) | grep -v $(VERSION) || true