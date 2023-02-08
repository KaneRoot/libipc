all: build

help:
	@echo "usage: make [build|install|serve-doc]"

ZIGOPTIM ?= ReleaseSafe
build:
	zig build -Doptimize=$(ZIGOPTIM)

PREFIX     ?= /usr/local
LIBDIR     ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include
install-library:
	[ -d $(LIBDIR) ] || install -m 0755 -d $(LIBDIR)
	install zig-out/lib/libipc* $(LIBDIR)
install-header:
	[ -d $(INCLUDEDIR) ] || install -m 0755 -d $(INCLUDEDIR)
	install libipc.h $(INCLUDEDIR)
install: install-library install-header

uninstall-library:
	rm $(LIBDIR)/libipc.a \
		$(LIBDIR)/libipc.so \
		$(LIBDIR)/libipc.so.*
uninstall-header:
	rm $(INCLUDEDIR)/libipc.h
uninstall: uninstall-library uninstall-header

mrproper:
	rm -r docs zig-cache zig-out 2>/dev/null || true

DOC_HTTPD_ACCESS_LOGS ?= /tmp/access.log
DOC_HTTPD_ADDR        ?= 127.0.0.1
DOC_HTTPD_PORT        ?= 35000
serve-doc:
	darkhttpd docs/ --addr $(DOC_HTTPD_ADDR) --port $(DOC_HTTPD_PORT) --log $(DOC_HTTPD_ACCESS_LOGS)

PACKAGE ?= libipc
VERSION ?= 0.1.0
PKG = $(PACKAGE)-$(VERSION)
dist-dir:
	[ -d $(PKG) ] || ln -s . $(PKG)
$(PKG).tar.gz: dist-dir
	tar zcf $@ \
		$(PKG)/src \
		$(PKG)/build.zig \
		$(PKG)/libipc.h \
		$(PKG)/makefile* \
		$(PKG)/README* \
		$(PKG)/TODO*
dist-rm-dir:
	rm $(PKG)
dist-gz: $(PACKAGE)-$(VERSION).tar.gz
dist: dist-gz dist-rm-dir

# You can add your specific instructions there.
-include makefile.user
