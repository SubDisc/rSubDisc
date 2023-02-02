# h/t to @jimhester and @yihui for this parse block:
# https://github.com/yihui/knitr/blob/dc5ead7bcfc0ebd2789fe99c527c7d91afb3de4a/Makefile#L1-L4
# Note the portability change as suggested in the manual:
# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-portable-packages
PKGNAME = `sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION`
PKGVERS = `sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION`
SUBDISCDIR = inst/java/SubDisc
GITHUB = https://github.com/SubDisc/SubDisc.git
VERSION = $(shell curl -s -I -k "https://api.github.com/repos/SubDisc/SubDisc/commits?per_page=1" | sed -n '/^[Ll]ink:/ s/.*"next".*page=\([0-9]*\).*"last".*/\1/p')
LIBNAME = subdisc-lib-2.$(VERSION).jar
JAVALIB = inst/java/$(LIBNAME)
all: check

build: install_deps $(JAVALIB)
	R CMD build .

check: build
	R CMD check --no-manual $(PKGNAME)_$(PKGVERS).tar.gz

install_deps:
	Rscript \
	-e 'if (!requireNamespace("remotes")) install.packages("remotes", repos = "http://cran.us.r-project.org")' \
	-e 'remotes::install_deps(dependencies = TRUE)'

install: build
	R CMD INSTALL $(PKGNAME)_$(PKGVERS).tar.gz

clean:
	@rm -rf $(PKGNAME)_$(PKGVERS).tar.gz $(PKGNAME).Rcheck
	@rm -rf inst/java/*

$(JAVALIB):
	[ -d "$(SUBDISCDIR)" ] && cd $(SUBDISCDIR) && git pull || git clone --branch main --single-branch $(GITHUB) $(SUBDISCDIR)
	cd $(SUBDISCDIR) && mvn package -Plib
	cp $(SUBDISCDIR)/target/$(LIBNAME) inst/java
	sed -i's/^SUBDISCLIB <- .*/SUBDISCLIB <- \"$(LIBNAME)\"/' R/zzz.R
	sed -i's/^Version: .*/Version: 0.0.3.$(VERSION)/' DESCRIPTION
