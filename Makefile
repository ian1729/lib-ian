.PHONY: dev check tsan all format hooks build run watch gen-ostream

dev:
	cmake --workflow --preset dev

check:
	cmake --workflow --preset check

tsan:
	cmake --workflow --preset tsan

all:
	@cmake --workflow --preset check & p1=$$!; \
	cmake --workflow --preset tsan & p2=$$!; \
	fail=0; \
	wait $$p1 || fail=1; \
	wait $$p2 || fail=1; \
	exit $$fail

format:
	cmake --build --preset format

hooks:
	bash scripts/install-hooks.sh

build:
	cmake --preset dev && cmake --build --preset dev

run:
	cmake --preset dev && cmake --build --preset dev && ./build/dev/ian_socket_app

watch:
	find app -name '*.cpp' | entr -c sh -c 'cmake --build --preset dev && ./build/dev/ian_socket_app'

gen-ostream:
	python3 scripts/gen-ostream.py
