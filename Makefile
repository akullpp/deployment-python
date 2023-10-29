.ONESHELL:

.DEFAULT_GOAL := install

BIN = .venv/bin

.PHONY: clean
clean:
	rm -f requirements.txt
	rm -rf .venv

.PHONY: install
install: requirements.in
	python3 -m venv .venv
	chmod +x .venv/bin/activate
	. .venv/bin/activate
	$(BIN)/pip install pip-tools
	$(BIN)/pip-compile --strip-extras -q -o requirements.txt requirements.in
	$(BIN)/pip-sync requirements.txt

.PHONY: lint
lint: .venv/bin/ruff
	$(BIN)/ruff check .

.PHONY: test
test: .venv/bin/pytest
	$(BIN)/pytest app/
