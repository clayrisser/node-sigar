PLATFORM := $(shell node -e "process.stdout.write(process.platform)")
ifeq ($(PLATFORM), win32)
	SHELL = cmd.exe
	NULL := nul
	GREP := shx grep
	RM := shx rm
	MV := shx mv
	MKDIR := shx mkdir
	TRUE := shx true
else
	NULL := /dev/null
	GREP := shx grep
	RM := rm
	MV := mv
	MKDIR := mkdir
	TRUE := true
endif

GIT := $(shell git --version >$(NULL) 2>&1 && echo git|| echo $(TRUE))
GREP := $(shell where grep)
NPM := $(shell pnpm --version >$(NULL) 2>&1 && echo pnpm|| (yarn --version >$(NULL) 2>&1 && echo yarn|| echo npm))


.EXPORT_ALL_VARIABLES:

.PHONY: all
all: build

.PHONY: install
install: node_modules
node_modules: package.json
	@$(NPM) install

.PHONY: format
format:
	-@eslint --fix --ext .ts,.tsx . >$(NULL) || $(TRUE)
	@prettier --write ./**/*.{json,md,scss,yaml,yml,js,jsx,ts,tsx} --ignore-path .gitignore
	@$(MKDIR) -p node_modules/.make && touch -m node_modules/.make/format
node_modules/.make/format: $(shell $(GIT) ls-files | $(GREP) "\.(j|t)sx?$$")
	@$(MAKE) -s format

.PHONY: spellcheck
spellcheck: node_modules/.make/format
	-@cspell --config .cspellrc src/**/*.ts
	@$(MKDIR) -p node_modules/.make && touch -m node_modules/.make/spellcheck
node_modules/.make/spellcheck: $(shell $(GIT) ls-files | $(GREP) "\.(j|t)sx?$$")
	-@$(MAKE) -s spellcheck

.PHONY: lint
lint: node_modules/.make/spellcheck
	# -@tsc --allowJs --noEmit
	# -@eslint --ext .ts,.tsx .
	# @eslint -f json -o node_modules/.tmp/eslintReport.json --ext .ts,.tsx ./
node_modules/.tmp/eslintReport.json: $(shell $(GIT) ls-files | $(GREP) "\.(j|t)sx?$$")
	-@$(MAKE) -s lint

.PHONY: test
test: node_modules/.tmp/eslintReport.json
	# @jest --json --outputFile=node_modules/.tmp/jestTestResults.json --coverage --coverageDirectory=node_modules/.tmp/coverage --testResultsProcessor=jest-sonar-reporter --collectCoverageFrom='["src/**/*.{js,jsx,ts,tsx}","!src/**/*.story.{js,jsx,ts,tsx}"]' $(ARGS)
node_modules/.tmp/coverage/lcov.info: $(shell $(GIT) ls-files | $(GREP) "\.(j|t)sx?$$")
	-@$(MAKE) -s test

.PHONY: coverage
coverage: node_modules/.tmp/eslintReport.json
	# @jest --coverage --coverageDirectory=node_modules/.tmp/coverage --collectCoverageFrom='["src/**/*.{js,jsx,ts,tsx}","!src/**/*.story.{js,jsx,ts,tsx}"]' $(ARGS)

.PHONY: test-watch
test-watch: src/generated/apollo.tsx node_modules
	@jest --watch --collectCoverageFrom='["src/**/*.{js,jsx,ts,tsx}","!src/**/*.story.{js,jsx,ts,tsx}"]' $(ARGS)

.PHONY: test-ui
test-ui: src/generated/apollo.tsx node_modules
	@majestic $(ARGS)

.PHONY: build
build: lib build/Release/sigar.node
	@echo building
lib: node_modules/.tmp/coverage/lcov.info $(shell $(GIT) ls-files)
	@echo lib
	-@$(RM) -rf lib node_modules/.tmp/lib 2>$(NULL) || $(TRUE)
	@babel src -d lib --extensions '.ts,.tsx' --source-maps inline
	@tsc -d --emitDeclarationOnly
	@$(RM) -rf lib/tests
	@$(MKDIR) -p node_modules/.tmp/lib
	@$(MV) lib/src node_modules/.tmp/lib/src
	@$(CP) -r node_modules/.tmp/lib/src/* lib 2>$(NULL) || $(TRUE)
	@$(CP) -r node_modules/.tmp/lib/src/.* lib 2>$(NULL) || $(TRUE)
build/config.gypi: binding.gyp src/lib/*.cpp
	@echo buuu
	@node-pre-gyp clean configure
build/Release/sigar.node: build/config.gypi
	@echo hiii
	@node-pre-gyp build package
	@cd deps && $(MAKE) -s -f Makefile.sigar clean

.PHONY: clean
clean:
	-@jest --clearCache
	-@node-pre-gyp clean
	-@$(RM) -rf node_modules/.cache || true
	-@$(RM) -rf node_modules/.make || true
	-@$(RM) -rf node_modules/.tmp || true
	@cd deps && $(MAKE) -s -f Makefile.sigar clean
	@git clean -fXd \
		-e \!/node_modules \
		-e \!/node_modules/**/* \
		-e \!/package-lock.json \
		-e \!/pnpm-lock.yaml \
		-e \!/yarn.lock

.PHONY: start
start: node_modules/.tmp/eslintReport.json
	@babel-node --extensions '.ts,.tsx' example $(ARGS)

.PHONY: prepublish-only
prepublish-only:
	-@rm -rf build || true
	@$(MAKE) -s build
	@node-pre-gyp-github publish --release

.PHONY: purge
purge: clean
	@git clean -fXd

.PHONY: report
report: spellcheck lint test
	@

%:
	@
