DOCKER_IMAGE := texlive/texlive
IMAGE_TAG := latest
IMAGE_SHA := sha256:b09360744230661858dc48526b9f20aa1269dba37d4e5310e3150b8f93584e58

.PHONY: help

help: ## Display this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

TEX_FILE := resume.tex
build: $(TEX_FILE) ## Build the PDF from the LaTeX source
	docker run --rm \
		-v $(shell pwd):/data \
		-w /data \
		$(DOCKER_IMAGE):$(IMAGE_TAG)@$(IMAGE_SHA) \
		pdflatex $(TEX_FILE)
	@echo "PDF created at $(TEX_FILE).pdf"
