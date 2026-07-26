# context-repository — universal command interface (ADR-0050 standard §3).
# This repo is shape=contract: a published spec + conformance bundle. It has no
# build/deploy/run surface. The Makefile is a thin delegator to real scripts;
# no business logic lives here.

.DEFAULT_GOAL := help
PY := python3
CONF := spec/discovery-framework/conformance

.PHONY: help check test lint setup build eval \
        check-repo-toml check-schemas check-conformance check-index check-version

help: ## Show this help
	@echo "context-repository — shape=contract (published canon spec + conformance)."
	@echo
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
	  | sed 's/:.*## /\t/' | sort | awk -F'\t' '{printf "  %-18s %s\n", $$1, $$2}'
	@echo
	@echo "Not applicable to this shape (contract repo, no deployable service):"
	@echo "  make run           no runtime entrypoint — the artifact is the spec itself"
	@echo "  make build         'build' = regenerate index.md; run: scripts/build-index.sh"
	@echo "  make deploy-check  nothing is deployed; downstream repos consume the spec by path/digest"
	@echo "  make eval          no governed prompt/agent surface here (see docs/architecture.md)"

setup: ## Install the pinned dependency (jsonschema) used by the conformance checker
	$(PY) -m pip install --quiet -r requirements.txt

check: check-repo-toml check-version check-schemas check-conformance check-index ## Full hermetic pre-merge gate (no masked failures)
	@echo "OK: make check passed"

test: check-conformance ## Deterministic test suite (canon conformance fixtures)

lint: check-version check-index ## Spec-hygiene checks (version consistency, index freshness, frontmatter)

check-repo-toml: ## Validate repo.toml against the standard
	$(PY) scripts/validate_repo.py

check-version: ## Assert one canon spec version across schemas, prose, and CHANGELOG
	$(PY) scripts/check_spec_version.py

check-schemas: ## Assert every canon schema is parseable JSON
	@for f in spec/discovery-framework/schemas/*.schema.json; do \
	  $(PY) -c "import json,sys; json.load(open(sys.argv[1]))" "$$f" || exit 1; \
	done
	@echo "schemas OK (all parse)"

check-conformance: ## Run the canon conformance fixtures (must be all-pass)
	cd $(CONF) && $(PY) run.py

check-index: ## Verify tracked index.md is current and all Markdown has frontmatter
	@scripts/check_index.sh

build: ## Regenerate the tracked index.md from frontmatter
	scripts/build-index.sh
