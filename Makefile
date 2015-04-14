
all:
	echo "Install using: make install"

install:
	install -d -m 0700 $(DESTDIR)/etc/pmfw/
	install -m750 scripts/deploy.sh $(DESTDIR)/usr/sbin/pmfw-deploy
	install -m640 etc/custom.rules $(DESTDIR)/etc/pmfw/
	install -m640 etc/hosts.allow $(DESTDIR)/etc/pmfw/
	install -m640 etc/sudoers.webknock $(DESTDIR)/etc/sudoers.d/pmfw
	install -m640 etc/pmfw.conf $(DESTDIR)/etc/pmfw/
	install -d -m 0700 $(DESTDIR)/var/spool/webknock/
	install -m644 webknock-server/webknock.php $(DESTDIR)/var/lib/pmfw/default-webknock.php
	install -m755 cron/pmfw-update $(DESTDIR)/etc/cron.hourly/
	install -m755 webknock-client/webknock $(DESTDIR)/usr/bin/


rpm:
	(cd .. && tar czf ~/rpmbuild/SOURCES/pmfw-0.1.tar.gz pmfw/ )
	rpmbuild -ba pmfw.spec
