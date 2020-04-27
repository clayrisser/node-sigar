include node_modules/gnumake/gnumake.mk

.PHONY: all
all: build

.PHONY: install
install: node_modules
node_modules: package.json
	@$(NPM) install

.PHONY: prepare
prepare: deps/sigar/.git
deps/sigar/.git:
	@$(GIT) submodule update --init --recursive
	@$(CD) deps/sigar && $(GIT) pull origin master

.PHONY: format
format:
	-@eslint --fix --ext .ts,.tsx . >$(NULL) || $(TRUE)
	@prettier --write ./**/*.{json,md,scss,yaml,yml,js,jsx,ts,tsx} --ignore-path .gitignore
	-@$(MKDIRP) "node_modules/.make" && $(TOUCH) -m node_modules/.make/format
node_modules/.make/format: $(shell $(GIT) ls-files | $(GREP) "\.(j|t)sx?$$")
	@$(MAKE) -s format

.PHONY: spellcheck
spellcheck: node_modules/.make/format
	-@cspell --config .cspellrc src/**/*.ts
	-@$(MKDIRP) "node_modules/.make" && $(TOUCH) -m node_modules/.make/spellcheck
node_modules/.make/spellcheck: $(shell $(GIT) ls-files | $(GREP) "\.(j|t)sx?$$")
	-@$(MAKE) -s spellcheck

.PHONY: lint
lint: node_modules/.make/spellcheck
	-@tsc --allowJs --noEmit
	-@eslint --ext .ts,.tsx .
	@eslint -f json -o node_modules/.tmp/eslintReport.json --ext .ts,.tsx ./
node_modules/.tmp/eslintReport.json: $(shell $(GIT) ls-files | $(GREP) "\.(j|t)sx?$$")
	-@$(MAKE) -s lint

.PHONY: test
test: node_modules/.tmp/eslintReport.json
	-@jest --json --outputFile=node_modules/.tmp/jestTestResults.json --coverage --coverageDirectory=node_modules/.tmp/coverage --testResultsProcessor=jest-sonar-reporter --collectCoverageFrom='["src/**/*.{js,jsx,ts,tsx}","!src/**/*.story.{js,jsx,ts,tsx}"]' $(ARGS)
node_modules/.tmp/coverage/lcov.info: $(shell $(GIT) ls-files | $(GREP) "\.(j|t)sx?$$")
	-@$(MAKE) -s test

.PHONY: coverage
coverage: node_modules/.tmp/eslintReport.json
	@jest --coverage --coverageDirectory=node_modules/.tmp/coverage --collectCoverageFrom='["src/**/*.{js,jsx,ts,tsx}","!src/**/*.story.{js,jsx,ts,tsx}"]' $(ARGS)

.PHONY: test-watch
test-watch: src/generated/apollo.tsx node_modules
	@jest --watch --collectCoverageFrom='["src/**/*.{js,jsx,ts,tsx}","!src/**/*.story.{js,jsx,ts,tsx}"]' $(ARGS)

.PHONY: test-ui
test-ui: src/generated/apollo.tsx node_modules
	@majestic $(ARGS)

.PHONY: patch
patch:
	@$(SED) -i "s/#define snprintf _snprintf/\/\/ #define  snprintf _snprintf/" deps/sigar/src/os/win32/sigar_os.h 1>$(NULL)

.PHONY: compile
compile: build/Release/sigar.node
build-tmp-napi-v3/config.gypi: deps/sigar/.git binding.gyp src/lib/*.cpp
	@$(MAKE) -s patch
	@node-pre-gyp clean configure
build/Release/sigar.node: build-tmp-napi-v3/config.gypi
	@$(MAKE) -s patch
	@node-pre-gyp build package
	@$(CD) deps && $(MAKE) -s -f Makefile.sigar clean
	@$(CP) -r build-tmp-napi-v3/* build

.PHONY: build
build: lib build/Release/sigar.node
lib: node_modules/.tmp/coverage/lcov.info $(shell $(GIT) ls-files)
	-@$(RM) -rf lib node_modules/.tmp/lib 2>$(NULL) || $(TRUE)
	@babel src -d lib --extensions ".ts,.tsx" --source-maps inline
	@tsc -d --emitDeclarationOnly
	@$(RM) -rf lib/tests
	@$(MKDIRP) "node_modules/.tmp/lib"
	@$(MV) lib/src node_modules/.tmp/lib/src
	@$(CP) -r node_modules/.tmp/lib/src/* lib 2>$(NULL) || $(TRUE)
	@$(CP) -r node_modules/.tmp/lib/src/.* lib 2>$(NULL) || $(TRUE)

.PHONY: clean
clean:
	-@jest --clearCache
	-@node-pre-gyp clean
	-@$(RM) -rf node_modules/.cache || $(TRUE)
	-@$(RM) -rf node_modules/.make || $(TRUE)
	-@$(RM) -rf node_modules/.tmp || $(TRUE)
	-@$(CD) deps && $(MAKE) -s -f Makefile.sigar clean
ifeq ($(PLATFORM), win32)
	@$(GIT) clean -fXd -e !/node_modules -e !/node_modules/**/* -e !/package-lock.json -e !/pnpm-lock.yaml -e !/yarn.lock
else
	@$(GIT) clean -fXd \
	  -e \!/node_modules \
		-e \!/node_modules/**/* \
		-e \!/package-lock.json \
		-e \!/pnpm-lock.yaml \
		-e \!/yarn.lock
endif
	@$(MAKE) -s prepare

.PHONY: start
start: node_modules build/Release/sigar.node
	@babel-node --extensions ".ts,.tsx" example $(ARGS)

.PHONY: prepublish-only
prepublish-only: publish-binaries
.PHONY: publish-binaries
publish-binaries:
	-@$(RM) -rf build || $(TRUE)
	@$(MAKE) -s build
	@node-pre-gyp-github publish --release

.PHONY: purge
purge: clean
	@$(GIT) clean -fXd

.PHONY: report
report: spellcheck lint test
	@

%:
	@
port: spellcheck lint test
	@

%:
	@
