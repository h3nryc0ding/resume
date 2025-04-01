TEX_IMAGE 		:= texlive/texlive
TEX_IMAGE_TAG 	:= latest
TEX_IMAGE_SHA 	:= sha256:b09360744230661858dc48526b9f20aa1269dba37d4e5310e3150b8f93584e58
POPPLER_IMAGE 		:= minidocks/poppler
POPPLER_IMAGE_TAG 	:= latest
POPPLER_IMAGE_SHA  	:= sha256:45b53aae7fce0a5e712e8b85e78387269915a400f521b11b7306a9f1f216c747

.PHONY: help

help: ## Display this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

pdf: resume.tex ## Build the PDF from the LaTeX source
	set -e; \
	TMP_DIR=$$(mktemp -d); \
	trap 'rm -rf $$TMP_DIR; echo "Cleaning up temporary directory"' EXIT; \
	echo "Creating temporary directory: $$TMP_DIR"; \
	mkdir -p $$TMP_DIR; \
	docker run --rm \
		-v $(shell pwd):/data:ro \
		-v $$TMP_DIR:/tmp:rw \
		$(TEX_IMAGE):$(TEX_IMAGE_TAG)@$(TEX_IMAGE_SHA) \
		pdflatex -output-directory=/tmp /data/resume.tex; \
	cp $$TMP_DIR/resume.pdf generated/; \
	echo "Creating PDF at $(shell pwd)/generated/resume.pdf"

png: pdf ## Convert the PDF to PNG using pdftoppm
	set -e; \
	TMP_DIR=$$(mktemp -d); \
	trap 'rm -rf $$TMP_DIR; echo "Cleaning up temporary directory"' EXIT; \
	echo "Creating temporary directory: $$TMP_DIR"; \
	mkdir -p $$TMP_DIR; \
	docker run --rm \
		-v $(shell pwd):/data:ro \
		-v $$TMP_DIR:/tmp:rw \
		$(POPPLER_IMAGE):$(POPPLER_IMAGE_TAG)@$(POPPLER_IMAGE_SHA) \
		pdftoppm -png -r 300 data/generated/resume.pdf /tmp/resume; \
	cp $$TMP_DIR/resume-*.png generated/; \
	echo "Creating PNG at $(shell pwd)/generated/resume-*.png"
