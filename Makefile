
SHELL = /bin/sh

# ------------------------------------------------
#   DEFINITIONS
# ------------------------------------------------

LOCAL_PATH  = .

EXCLUDE		=	'README,TODO,version.pl,utils/*,test/*,Makefile,shtool,CVS,\.cvsignore,ChangeLog,doc/*'

#   installation tools
SHTOOL          = /home/child/opt/bin/shtool
MKDIR           = $(SHTOOL) mkdir -p -f -m 755
VERSION_TOOL    = $(SHTOOL) version
TAR_TOOL		= $(SHTOOL) tarball

# ------------------------------------------------
#   THE CONFIGURATION SUPPORT
# ------------------------------------------------

shtool:
	@shtoolize echo version install mkdir path

# ------------------------------------------------
#   THE RELEASE STUFF
# ------------------------------------------------

TAR    = tar       # where to find GNU Tar
FIND   = find      # where to find a good Find tool
GZIP   = gzip      # where to find GNU Zip
RM			=	/bin/rm

NEWVERS = \
    $(VERSION_TOOL) -l perl -n phpmode -p PhpMode $$OPT version.pl; \
    V=`$(VERSION_TOOL) -l perl -d long version.pl`;\
    sed -e "s/^%.*version.*/%   version $$V/g" php.sl > php.n && mv php.n php.sl

UPDATEVERS = \
    V=`$(VERSION_TOOL) -l perl -d short version.pl`; \
    $(VERSION_TOOL) -l perl -n phpmode -p PhpMode -s $$V version.pl; \
    V=`$(VERSION_TOOL) -l perl -d long version.pl`; \
    sed -e "s/^%.*version.*/%   version $$V/g" php.sl > php.n && mv php.n php.sl

_GETDISTINFO = \
    _version=`$(VERSION_TOOL) -l perl -d short version.pl`; \
    _date=`date '+%Y%m%d'`;

_BUILDDIST = \
    echo "Creating tarball..."; \
	$(TAR_TOOL) -o $${_tarball} -c 'gzip -9' -u child -g child -e $(EXCLUDE) . ;\
    ls -l $${_tarball}; \
    echo "Done"

release:
	set -e; $(_GETDISTINFO) \
    _distname="phpmode-$${_version}"; \
    _tarball="$${_distname}.tar.gz"; \
    echo "Release Distribution: PhpMode Version $$_version"; \
    $(_BUILDDIST)

snap:
	set -e; $(_GETDISTINFO) \
    _distname="phpmode-$${_date}"; \
    _tarball="$${_distname}.tar.gz"; \
    echo "Snap of whole source tree: PhpMode Version $$_version as of $$_date"; \
    $(_BUILDDIST)

new-version:
	OPT=-iv; $(NEWVERS)

new-revision:
	OPT=-ir; $(NEWVERS)

new-patchlevel:
	OPT=-il; $(NEWVERS)

new-release:
	OPT=-s$(R); $(NEWVERS)

update-version:
	$(UPDATEVERS)

fixperm:
	$(SHTOOL) fixperm *

# $Id: Makefile,v 1.6 2002/03/06 18:37:36 child Exp $

##EOF##
