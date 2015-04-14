
all:
	echo "Install using: make install"

install:
	install -d -m 0700 $(DESTDIR)/etc/webknock/
	install -m640 scripts/deploy.sh  /usr/sbin/firewall-deploy
	install -m640 etc/custom.rules $(DESTDIR)/etc/webknock/
	install -m640 etc/hosts.allow $(DESTDIR)/etc/webknock/
	install -m640 etc/sudoers.webknock $(DESTDIR)/etc/sudoers.d/webknock
	install -m640 etc/webknock.conf $(DESTDIR)/etc/webknock/
	install -m644 web/webknock.php $(DESTDIR)/var/www/html/
	install -m644 cron/webknock-cleanup $(DESTDIR)/etc/cron.hourly/

