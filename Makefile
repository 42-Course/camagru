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
	-${DOCKER_EXEC} compose run \
		-it \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		rake doc:export

create:
	-${DOCKER_EXEC} compose run --rm \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		rake db:create

migrate:
	-${DOCKER_EXEC} compose run --rm \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		rake db:migrate

seed: create migrate
	-${DOCKER_EXEC} compose run --rm \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		rake db:seed

drop:
	-${DOCKER_EXEC} compose run --rm \
		--remove-orphans \
		${DOCKER_CONTAINER_NAME} \
		rake db:drop

test:
	-${DOCKER_EXEC} compose run --rm \
		${DOCKER_CONTAINER_NAME} \
		sh -c "RACK_ENV=test bundle exec rspec $(filter-out $@,$(MAKECMDGOALS))"

console:
	${DOCKER_EXEC} compose run \
		${DOCKER_CONTAINER_NAME} \
		irb -r ./app

re: down build re_db lint

re_db: drop create migrate

lint:
	-@rubocop -a

help:
	@echo
	@echo "🚀 Camagru Makefile Commands"
	@echo "────────────────────────────────────────────"
	@echo " up            🟢 Start all containers"
	@echo " build         🔨 Build and start containers"
	@echo " down          🔻 Stop and remove containers"
	@echo " logs          📜 Tail container logs"
	@echo " run           🐚 Bash shell into backend container"
	@echo " console       🧪 Launch IRB with app preloaded"
	@echo " docs          📘 Generate API docs (markdown + JSON)"
	@echo
	@echo " DB Commands"
	@echo "────────────────────────────────────────────"
	@echo " create        🏗️  Create both dev and test databases"
	@echo " migrate       🧬 Run all migrations (on both DBs)"
	@echo " drop          💣 Drop both dev and test databases"
	@echo " seed          🌱 Seed the database (calls create + migrate first)"
	@echo " re_db         🔁 Drop + Create + Migrate database"
	@echo
	@echo " Dev Tools"
	@echo "────────────────────────────────────────────"
	@echo " lint          🎯 Run RuboCop with auto-correct"
	@echo " test          ✅ Run RSpec tests (e.g. make test spec/foo_spec.rb)"
	@echo " re            ♻️  Full reset (down, build, re_db, lint)"
	@echo

.PHONY: docs test migrate
