all: setup generate_data/all run

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
	@rm -rf venv vendor Gemfile.lock

generate_data/all: generate_data/setup generate_data

generate_data/setup:
	@bundle install

generate_data:
	@ruby generate_data.rb

run:
	@venv/bin/python main.py
