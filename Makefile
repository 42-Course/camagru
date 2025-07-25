DOCKER_CONTAINER_NAME = backend
DOCKER_EXEC = /usr/bin/docker

up:
	${DOCKER_EXEC} compose up -d
	
build:
	${DOCKER_EXEC} compose up --build -d

down:
	${DOCKER_EXEC} compose down --remove-orphans

logs:
	${DOCKER_EXEC} compose logs -f

run:
	${DOCKER_EXEC} compose run \
    -it \
    --remove-orphans \
    ${DOCKER_CONTAINER_NAME} \
    /bin/bash

docs:
	${DOCKER_EXEC} compose run \
		-it \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		rake doc:export

create:
	-${DOCKER_EXEC} compose run \
		-it \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		rake db:create

migrate:
	-${DOCKER_EXEC} compose run \
		-it \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		rake db:migrate

seed: create migrate
	-${DOCKER_EXEC} compose run \
		-it \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		rake db:seed

drop:
	-${DOCKER_EXEC} compose run \
		-it \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		rake db:drop

test:
	-${DOCKER_EXEC} compose run \
		-it \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		bundle exec rspec $(filter-out $@,$(MAKECMDGOALS))

console:
	${DOCKER_EXEC} compose run \
		${DOCKER_CONTAINER_NAME} \
		irb -r ./app

re: down build re_db

re_db: drop create migrate

lint:
	@rubocop -a

.PHONY: docs test migrate
