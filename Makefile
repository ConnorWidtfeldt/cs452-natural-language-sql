all: setup run

setup: venv requirements docker

reset: clean setup

venv:
	@python3 -m venv venv

requirements:
	@venv/bin/pip install -r requirements.txt

.PHONY: docker
docker:
	@docker compose up -d --build --remove-orphans --renew-anon-volumes

docker/attach:
	@docker compose up --build --remove-orphans --renew-anon-volumes --force-recreate

clean:
	@docker compose down --remove-orphans
	@rm -rf venv
	@rm -rf generator/vendor
	@rm -rf generator/Gemfile.lock

setup-generator:
	@cd generator && bundle install

generate:
	@generator/generate_data.rb

run:
	@venv/bin/python main.py
