Summary: A simple poorman's web knocker
Name: webknock
Version: 0.01
Release: 1
License: MIT
Group: System Environment/Daemons
Packager: Danny Sung <danny@dannysung.com>

%description
This is simple poorman's "web" knocker.  It helps maintain your firewall rules,
but allows for a simple PHP script to allow access to services like SSH.


%prep
%setup

%build

%install
make DESTDIR=${RPM_BUILD_ROOT} install

%files
%doc README.md
/etc/webknock/
%config /etc/webknock/hosts.allow
%config /etc/sudoers.d/webknock
%config install -m644 $(DESTDIR)/var/www/html/webknock.php
%config	/etc/webknock/webknock.conf
/usr/sbin/firewall-deploy
$(DESTDIR)/etc/cron.hourly/*

