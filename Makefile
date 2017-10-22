
all: lint test
.PHONY: all

test:
	@./test.sh
.PHONY: test

lint:
	@shellcheck rbu
.PHONY: lint

