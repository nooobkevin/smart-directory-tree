PREFIX ?= $(HOME)/.local
ifneq ($(PREFIX),/)
PREFIX := $(patsubst %/,%,$(PREFIX))
endif
BIN_DIR := $(PREFIX)/bin
SCRIPT := myrepo
TARGET := $(BIN_DIR)/$(SCRIPT)

.PHONY: all install uninstall help

all: help

help:
	@echo "Targets:"
	@echo "  make install        Create symlink $(TARGET) -> $(CURDIR)/$(SCRIPT) (if absent)"
	@echo "  make uninstall      Remove symlink"
	@echo "Variables:"
	@echo "  PREFIX (default: $(PREFIX))"

install:
	@mkdir -p "$(BIN_DIR)"
	@if [ -L "$(TARGET)" ]; then \
	  echo "Symlink already exists: $(TARGET) -> $$(readlink -f $(TARGET))"; \
	  echo "Proceed to update it."; \
	  rm "$(TARGET)"; \
	  ln -s "$(CURDIR)/$(SCRIPT)" "$(TARGET)"; \
	  echo "Updated symlink: $(TARGET) -> $(CURDIR)/$(SCRIPT)"; \
	elif [ -e "$(TARGET)" ]; then \
	  echo "Error: $(TARGET) exists and is not a symlink. Remove it manually if you want to replace it." >&2; \
	  exit 1; \
	else \
	  ln -s "$(CURDIR)/$(SCRIPT)" "$(TARGET)"; \
	  echo "Created symlink: $(TARGET) -> $(CURDIR)/$(SCRIPT)"; \
	fi
	@echo 'If $(BIN_DIR) is not in your PATH, add it, e.g.: export PATH="$(BIN_DIR):$$PATH"'

uninstall:
	@if [ -L "$(TARGET)" ]; then \
	  rm "$(TARGET)"; \
	  echo "Removed symlink: $(TARGET)"; \
	elif [ -e "$(TARGET)" ]; then \
	  echo "Refusing to remove non-symlink file: $(TARGET)"; \
	  exit 1; \
	else \
	  echo "No symlink to remove at $(TARGET)"; \
	fi
