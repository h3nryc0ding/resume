IMAGE 		:= texlive/texlive
IMAGE_TAG 	:= latest
IMAGE_SHA 	:= sha256:b09360744230661858dc48526b9f20aa1269dba37d4e5310e3150b8f93584e58

.PHONY: help

help: ## Display this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

INPUT_FILE := resume.tex
OUTPUT_FILE := resume.pdf

build: $(INPUT_FILE) ## Build the PDF from the LaTeX source
	@(\
		set -e; \
		TMP_DIR=$$(mktemp -d); \
		trap 'rm -rf $$TMP_DIR; echo "Cleaning up temporary directory"' EXIT; \
		echo "Creating temporary directory: $$TMP_DIR"; \
		mkdir -p $$TMP_DIR; \
		docker run --rm \
			-v $(shell pwd):/data:ro \
			-v $$TMP_DIR:/tmp:rw \
			$(IMAGE):$(IMAGE_TAG)@$(IMAGE_SHA) \
			pdflatex -output-directory=/tmp /data/$(INPUT_FILE); \
		cp $$TMP_DIR/$(OUTPUT_FILE) .; \
		echo "Creating PDF at $(OUTPUT_FILE)"; \
	)
