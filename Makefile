# Copyright (c) 2016 Hewlett Packard Enterprise Development LP
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

distdir = eucalyptus-selinux-$(shell sed -n '/^policy_module/s/.*, \([0-9.]*\).*/\1/p' eucalyptus.te)

include /usr/share/selinux/devel/Makefile

.PHONY: all clean dist distdir relabel

all: eucalyptus.pp

eucalyptus.if: eucalyptus.te eucalyptus.if.m4 eucalyptus.if.in
	@echo "#" > $@
	@echo "# This is a generated file!  Instead of modifying this file, the" >> $@
	@echo "# $(notdir $@).in or $(notdir $@).m4 file should be modified." >> $@
	@echo "#" >> $@
	$(verbose) cat $@.in >> $@
	$(verbose) grep -E '^[[:blank:]]*eucalyptus_domain_template\(.*\)' eucalyptus.te \
		| $(M4) -D self_contained_policy $(M4PARAM) $(m4divert) eucalyptus.if.m4 $(m4undivert) - \
		| sed -e 's/dollarszero/\$$0/' -e 's/dollarsone/\$$1/' >> $@

relabel:
	restorecon -Riv -e /var/lib/eucalyptus/instances/* /etc/eucalyptus /usr/lib/eucalyptus /usr/sbin/euca* /var/lib/eucalyptus/ /var/log/eucalyptus /var/run/eucalyptus

distdir: Makefile COPYING TODO eucalyptus.te eucalyptus.fc eucalyptus.if.m4 eucalyptus.if.in eucalyptus-selinux.spec
	rm -rf $(distdir)
	mkdir -p $(distdir)
	cp -pR $^ $(distdir)

dist: distdir
	mkdir -p dist
	tar -cJ -f dist/$(distdir).tar.xz $(distdir)
	rm -rf $(distdir)

clean:
	rm -rf dist
	rm -rf tmp
	rm -rf $(distdir)
	rm -f  eucalyptus.if
	rm -f  eucalyptus.pp
