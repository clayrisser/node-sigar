PLATFORM := $(shell node -e "process.stdout.write(process.platform)")
ifeq ($(PLATFORM), win32)
	SHELL = cmd
endif

NPM := npm
ifeq ($(shell pnpm --version >/dev/null 2>&1 && echo true || echo false), true)
	NPM = pnpm
else
ifeq ($(shell yarn --version >/dev/null 2>&1 && echo true || echo false), true)
	NPM = yarn
endif
endif

.EXPORT_ALL_VARIABLES:

.PHONY: all
all: build

.PHONY: install
install: .make/install
.make/install: package.json node_modules
	@[ "$(NPM)" = "yarn" ] && yarn || $(NPM) install

.PHONY: prepare
prepare:
	@mkdir -p .make && touch -m .make/install

.PHONY: install-continue
install-continue:
	# -@node-pre-gyp install --fallback-to-build

.PHONY: format
format:
	-@eslint --fix --ext .ts,.tsx . >/dev/null || true
	@prettier --write ./**/*.{json,md,scss,yaml,yml,js,jsx,ts,tsx} --ignore-path .gitignore
	@mkdir -p .make && touch -m .make/format
.make/format: .make/install $(shell git ls-files 2>/dev/null || true)
	@$(MAKE) -s format

.PHONY: spellcheck
spellcheck:
	-@cspell --config .cspellrc src/**/*.ts prisma/schema.prisma.tmpl
	@mkdir -p .make && touch -m .make/spellcheck
.make/spellcheck: .make/format $(shell git ls-files 2>/dev/null || true)
	@$(MAKE) -s spellcheck

.PHONY: lint
lint:
	-@tsc --allowJs --noEmit
	-@eslint --ext .ts,.tsx .
	-@eslint -f json -o node_modules/.tmp/eslintReport.json --ext .ts,.tsx ./
	@mkdir -p .make && touch -m .make/lint
.make/lint: .make/spellcheck $(shell git ls-files 2>/dev/null || true)
	@$(MAKE) -s lint

.PHONY: test
test:
	@jest --coverage
	@mkdir -p .make && touch -m .make/test
.make/test: .make/lint $(shell git ls-files 2>/dev/null || true)
	@$(MAKE) -s test

.PHONY: build
build: .make/build
build/config.gypi: binding.gyp clib
	@node-pre-gyp clean configure
build/Release/sigar.node: build/config.gypi
	@node-pre-gyp build package
.make/build: .make/test package.json lib build/Release/sigar.node $(shell git ls-files 2>/dev/null || true)
	@echo hi
	-@rm -rf lib || true
	@babel src -d lib --extensions '.ts,.tsx' --source-maps inline
	@mkdir -p .make && touch -m .make/build

.PHONY: clean
clean:
	-@jest --clearCache
	@git clean -fXd -e \!node_modules -e \!node_modules/**/* -e \!yarn.lock
	-@rm -rf node_modules/.cache || true
	-@rm -rf node_modules/.tmp || true

.PHONY: purge
purge: clean
	@git clean -fXd

.PHONY: start
start: node_modules/.tmp/eslintReport.json
	@babel-node --extensions '.ts,.tsx' example










# .PHONY: build
# build: lib build/Release/gtop.node
# build/config.gypi:
# 	@node-pre-gyp clean configure
# build/Release/gtop.node: build/config.gypi
# 	@cd deps && $(MAKE) -s -f Makefile.glib build
# 	@cd deps && $(MAKE) -s -f Makefile.libgtop build
# 	@node-pre-gyp build package
# lib: node_modules/.tmp/eslintReport.json
# 	@rm -rf lib
# 	@babel src -d lib --extensions ".ts,.tsx" --source-maps inline


# .PHONY: clean
# clean:
# 	-@jest --clearCache
# 	-@node-pre-gyp clean
# 	-@rm -rf node_modules/.cache || true
# 	-@rm -rf node_modules/.tmp || true
# 	@cd deps && $(MAKE) -s -f Makefile.glib clean
# 	@cd deps && $(MAKE) -s -f Makefile.libgtop clean
# 	@git clean -fXd -e \!node_modules -e \!node_modules/**/* -e \!yarn.lock

# .PHONY: purge
# purge: clean
# 	@git clean -fXd

# .PHONY: prepublish
# prepublish: deps/libgtop/.git deps/glib/.git
# 	@$(MAKE) -s _modified MODIFIED=install
# 	@$(MAKE) -s build
# deps/libgtop/.git:
# 	$(MAKE) -s _submodules
# deps/glib/.git:
# 	$(MAKE) -s _submodules
# .PHONY: _submodules
# _submodules:
# 	@git submodule update --init --recursive

# .PHONY: prepublish-only
# prepublish-only:
# 	@rm -rf build
# 	@$(MAKE) -s build
# 	@node-pre-gyp-github publish --release

%:
	@
