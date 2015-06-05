# pmfw
This is a Poor-man's firewall rule management framework.

Briefly it allows you to quickly make use of common rules.  In addition it
allows for extensibility, eg. via the included webknock tool.

I found myself creating the same set of iptables rules across multiple servers
and virtual machines.  So I decided to consolidate this into one easy to
install package where I can change as few things as possible per hose.


## Configuration ##

pmfw can be configured by editing a few files.

/etc/pmfw/hosts.allow: Add one IP address per line for hosts you want to always allow ssh access to (tcp port 22).

/etc/pmfw/custom.rules: Here you can create custom rules that you want to always include.  This should be in the same format that iptables-save expects.  For example, this line will allow NTP (UDP Port 123).
<pre>
-A in_pub_udp -p udp -m udp --sport 123 --dport 123 -j ACCEPT
</pre>

/etc/pmfw/pmfw.conf: Here, I've consolidated several common services into simple variables that can be turned on/off.  By default it looks like this:
<pre>
# Set this to your internet-facing interface
iface_internet="eth0"

# Allow standard ping packets
allow_ping=1

# Allow http traffic
allow_http=0

# Allow https traffic
allow_https=0

# Allow ntp traffic
allow_ntp=1

# Allow webknock server (the webknock-server package should be installed and requires manual configuration)
allow_webknock=1

# Make use of some default logging
default_logging=1

# Allow auto-configuration via cron (set this to 1 once you've verified your firewall rules)
allow_cron=0
</pre>

This configures eth0 as the primary internet interface.  And it allows Ping and NTP packets.  It also allows webknocking to work.  (more on that below).


/etc/pmfw/webknock.rules: Webknock.rules is a schell script that will be
executed.  Any output given will be included in the final generated rule set.
This is a script allowing you to create any complexity of conditions you want.
By default, this just allows ssh for the given IP:
<pre>
-A in_pub_tcp -p tcp -m tcp --dport 22 -s "$ip" -j ACCEPT
</pre>


## WebKnock Client ##

Ensure you install the @webknock@ script in your path somewhere, such as ~/bin/
or /usr/local/bin/.  Then, create a file in @~/.webknock@ that looks like this:

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


If you want something more secure, I suggest Judd Vinet's knockd server
http://www.zeroflux.org/projects/knock.  Or fwknop for Single Packet
Authorization.  However, webknock is probably good enough for most people who
just want to reduce the number of illegal login attempts visible in the system
logs.

