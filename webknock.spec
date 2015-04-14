%define name		webknock
%define version		0.1
%define release		1

Summary: A simple poorman's web knocker
Name: %{name}
Version: %{version}
Release: %{release}
License: MIT
Source: %{name}-%{version}.tar.gz
Group: System Environment/Daemons
Packager: Danny Sung <danny@dannysung.com>
BuildArch: noarch
Requires: bind-utils

%description
This is simple poorman's "web" knocker.  It helps maintain your firewall rules,
but allows for a simple PHP script to allow access to services like SSH.

%package client
Summary: Webknock Client
Group: Applications/Internet

%description client
This a client for a poorman's web knocker.

%package php
Summary: Webknock PHP server
Group: System Environment/Daemons

%description php
This provides the web interface for webknock.


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
%dir /etc/webknock/
%config /etc/webknock/custom.rules
%config /etc/webknock/hosts.allow
%config /etc/sudoers.d/webknock
%config	/etc/webknock/webknock.conf
/usr/sbin/*
/etc/cron.hourly/*

%files php
/var/lib/webknock/default-webknock.php

%files client
/usr/bin/webknock

