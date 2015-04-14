
all:
	echo "Install using: make install"

install:
	install -d -m 0700 $(DESTDIR)/etc/webknock/
	install -m750 scripts/deploy.sh $(DESTDIR)/usr/sbin/firewall-deploy
	install -m640 etc/custom.rules $(DESTDIR)/etc/webknock/
	install -m640 etc/hosts.allow $(DESTDIR)/etc/webknock/
	install -m640 etc/sudoers.webknock $(DESTDIR)/etc/sudoers.d/webknock
	install -m640 etc/webknock.conf $(DESTDIR)/etc/webknock/
	install -m644 web/webknock.php $(DESTDIR)/var/lib/webknock/default-webknock.php
	install -m755 cron/webknock-update $(DESTDIR)/etc/cron.hourly/
	install -m755 scripts/webknock $(DESTDIR)/usr/bin/


rpm:
	(cd .. && tar czf ~/rpmbuild/SOURCES/webknock-0.1.tar.gz webknock/ )
	rpmbuild -ba webknock.spec
