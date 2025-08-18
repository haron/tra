.DEFAULT_GOAL := build
SHELL := /usr/bin/env -S bash -O globstar # makes work globs like **/*.py

sync:
	uv sync

build: linter sync test
	uv build

publish: build
	UV_PUBLISH_TOKEN=$$(cat .pypi_token) uv publish

test: linter
	PYTHONWARNINGS=ignore PYTHONPATH=. uv -q run pytest -q

init: clean githook
	uv venv -q
	make sync

githook:
	echo -e "#!/bin/sh\nexec uv run -q pre-commit" > .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit

clean:
	rm -rf .venv **/__pycache__ .python-version dist **/*.egg* *.lock build

linter: format
	uv sync --no-dev -q
	uv run ty check --respect-ignore-files **/*.py
	uv run ruff check -q --ignore F401 **/*.py

format: sync
	uv run isort -q **/*.py
	uv run ruff format **/*.py

safety:
	uv run safety scan -o bare
