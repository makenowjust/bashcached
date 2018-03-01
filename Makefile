BIN ?= bashcached
PREFIX ?= /usr/local

install:
	cp bashcached $(PREFIX)/bin/$(BIN)

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)
