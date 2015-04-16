%define name		pmfw
%define version		0.1
%define release		1

Summary: A simple poorman's firewall rule manager
Name: %{name}
Version: %{version}
Release: %{release}
License: MIT
Source: %{name}-%{version}.tar.gz
Group: System Environment/Daemons
Packager: Danny Sung <danny@dannysung.com>
BuildArch: noarch
Requires: bind-utils, tmpwatch

%description
This is simple poorman's firewall rule manager.  It's a set of scripts that helps aid in configuraable/extensible firewall rules.

%package webknock-client
Summary: pmfw Webknock Client
Group: Applications/Internet

%description webknock-client
This is the webclient for the companion pmfw-webknock-server

%package webknock-server
Summary: Webknock PHP server
Group: System Environment/Daemons
Requires: httpd, php

%description webknock-server
This provides the web interface for webknock.

Copy the file from /var/lib/pmfw/default-webknock.php to your website like: /var/www/html/please_let_me_in/index.php

Now you can use the webknock-client to send a webknock to this host.

Note: "requiretty" must not be enabled in your /etc/sudoers file.

%prep
%setup -n %{name}

%build

%install
mkdir -p %{buildroot}${DESTDIR}/usr/bin/
mkdir -p %{buildroot}${DESTDIR}/usr/sbin/
mkdir -p %{buildroot}${DESTDIR}/etc/cron.hourly/
mkdir -p %{buildroot}${DESTDIR}/etc/sudoers.d/
mkdir -p %{buildroot}${DESTDIR}/var/lib/%{name}/

make DESTDIR=${RPM_BUILD_ROOT} install

%files
%doc README.md
%dir /etc/pmfw/
%dir /var/lib/pmfw/
%config /etc/pmfw/custom.rules
%config /etc/pmfw/hosts.allow
%config /etc/sudoers.d/pmfw
%config	/etc/pmfw/pmfw.conf
%attr(0755,-,-) /usr/sbin/pmfw-deploy
/etc/cron.hourly/*

%files webknock-server
/var/lib/pmfw/default-webknock.php
%config /etc/pmfw/webknock.rules
%attr(0755,apache,apache) /var/spool/webknock/

%files webknock-client
/usr/bin/webknock

