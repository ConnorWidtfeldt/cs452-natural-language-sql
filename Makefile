setup: venv requirements docker

reset: clean setup

venv:
	@python3 -m venv venv

requirements:
	@venv/bin/pip install -r requirements.txt

docker:
	@docker compose up -d --build --remove-orphans --renew-anon-volumes

docker/attach:
	@docker compose up --build --remove-orphans --renew-anon-volumes --force-recreate

clean:
	@docker compose down --remove-orphans

setup-generator:
	@cd generator && bundle install

generator:
	@generator/generate_data.rb

run:
	@python3 src/main.py
