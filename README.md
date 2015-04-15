# pmfw
This is a Poor-man's firewall rule management framework.

Briefly it allows you to quickly make use of common rules.  In addition it allows for extensibility, eg. via the included webknock tool.

## Configuration ##

/etc/pmfw/custom.rules
/etc/pmfw/hosts.allow
/etc/pmfw/pmfw.conf 
/etc/pmfw/webknock.rules


## WebKnock Client ##

create a file in ~/.webknock that looks like this:

	key,http://my.server.example.com/my/secret/path/

Then you'll be able to run webknock to open up the port for a short period of time:

	webknock key

## WebKnock Server ##

The Poor-man's web-knocker is a simple added layer to your security system.
This is a bit simpler than using a dedicated packet-based port knocker as it
allows you to use standard web clients, nor does it require a dedicated daemon.

Simply copy the file default-webknock.php into your server directory somehwere, like so:

	cp /var/lib/pmfw/default-webknock.php /var/www/html/my/secret/path/index.php

You will then be able to use the webknock client above.  Or simply use curl like so:

	curl http://my.server.example.com/my/secret/path/

On success, you'll get a notice showing your extern IP address.  And from there
you should be able to access your system depending on the rules specified in
the Configruation section.

