SRC_DIRS := 'src' $(shell test -d 'vendor' && echo 'vendor') $(shell test -d 'external' && echo 'external') 'database'
ALL_VFILES := $(shell find $(SRC_DIRS) -name "*.v")
TEST_VFILES := $(shell find 'src' -name "*Tests.v")
PROJ_VFILES := $(shell find 'src' -name "*.v")
VFILES := $(filter-out $(TEST_VFILES),$(PROJ_VFILES))
TEST_VO := $(TEST_VFILES:.v=.vo)

default: src/ShouldBuild.vo

all: $(VFILES:.v=.vo)
test: $(TEST_VO) $(VFILES:.v=.vo)

_CoqProject: _CoqExt libname $(wildcard vendor/*) $(wildcard external/*)
	@echo "-R src $$(cat libname)" > $@
	@cat _CoqExt >> $@
	@for libdir in $(wildcard vendor/*); do \
	libname=$$(cat $$libdir/libname); \
	if [ $$? -ne 0 ]; then \
	  echo "Do you need to run git submodule update --init --recursive?" 1>&2; \
		exit 1; \
	fi; \
	echo "-R $$libdir/src $$(cat $$libdir/libname)" >> $@; \
	done
	@echo "_CoqProject:"
	@cat $@

.coqdeps.d: $(ALL_VFILES) _CoqProject
	@echo "COQDEP $@"
	@coqdep -f _CoqProject $(ALL_VFILES) > $@

ifneq ($(MAKECMDGOALS), clean)
-include .coqdeps.d
endif

%.vo: %.v _CoqProject
	@echo "COQC $<"
	@coqc -w -notation-overridden,-redundant-canonical-projection,-several-object-files,-implicit-core-hint-db,-undeclared-scope,-solve_obligation_error,-auto-template \
     $(shell cat '_CoqProject') $< -o $@

.PHONY: extract
extract: database/src/Coq/ExtractionExamples.hs

database/src/Coq/ExtractionExamples.hs: database/Extract.vo
	./scripts/add-preprocess.sh database/src/Coq/*.hs

.PHONY: build-extract
build-extract: extract
	@echo "stack build"
	@cd database && stack build

.PHONY: ci
ci: src/ShouldBuild.vo $(TEST_VO) extract

clean:
	@echo "CLEAN vo glob aux"
	@rm -f $(ALL_VFILES:.v=.vo) $(ALL_VFILES:.v=.glob)
	@find $(SRC_DIRS) -name ".*.aux" -exec rm {} \;
	@echo "CLEAN extraction"
	@rm -rf database/src/Coq/*.hs
	rm -f _CoqProject .coqdeps.d

.PHONY: default test clean
.DELETE_ON_ERROR:
