# Build the report PDF from report.tex and Content/.
# Use: make | make clean | make distclean | make view
# Intermediate logs and auxiliary files are stored in logs/.
# The PDF is written to report.pdf in the project root.

MAIN = report
LOGS_DIR = logs

PDFLATEX = pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 -output-directory=$(LOGS_DIR)

TEX_FILES := $(MAIN).tex $(shell find Content -type f -name '*.tex' 2>/dev/null | tr ' ' '?') hcmut-report.cls
GRAPHICS_FILES := $(shell find graphics -type f \( -name '*.png' -o -name '*.jpeg' -o -name '*.jpg' \) 2>/dev/null | tr ' ' '?')

.PHONY: all clean distclean view

all: $(MAIN).pdf

$(MAIN).pdf: $(TEX_FILES) $(GRAPHICS_FILES)
	@mkdir -p $(LOGS_DIR)
	@find Content -type d -exec mkdir -p $(LOGS_DIR)/{} \;
	$(PDFLATEX) $(MAIN).tex
	@if [ -f $(LOGS_DIR)/$(MAIN).aux ] && grep -q '\\citation' $(LOGS_DIR)/$(MAIN).aux; then \
		bibtex $(LOGS_DIR)/$(MAIN); \
		$(PDFLATEX) $(MAIN).tex; \
	fi
	$(PDFLATEX) $(MAIN).tex
	$(PDFLATEX) $(MAIN).tex
	@mv -f $(LOGS_DIR)/$(MAIN).pdf $(MAIN).pdf
	@echo "Build successful: $(MAIN).pdf"

view: $(MAIN).pdf
	open $(MAIN).pdf

clean:
	rm -rf $(LOGS_DIR)
	rm -f $(MAIN).aux $(MAIN).log $(MAIN).out $(MAIN).toc $(MAIN).lof $(MAIN).lot \
		$(MAIN).bbl $(MAIN).blg $(MAIN).synctex.gz $(MAIN).pdf
	rm -f Content/*.aux

distclean: clean
