<?php
/*

This file should be relocated to any web accessible directory.  Be sure you update your /etc/sudoers.d/webknock file appropriately. 

If using HAProxy, ensure your /etc/haproxy/haproxy.cfg contains something like this:

        backend www
            timeout server 30s
            option forwardfor header X-HAProxy-Client-IP
            server www1 127.0.0.1:80

*/
?>
<html>
<body>
<?php
$ClientIP='';
if( array_key_exists('HTTP_X_HAPROXY_CLIENT_IP', $_SERVER) ) {
    $ClientIP=$_SERVER['HTTP_X_HAPROXY_CLIENT_IP'];
} else {
    $ClientIP=$_SERVER['REMOTE_ADDR'];
}

?>
Your IP is: <?php print $ClientIP;?><br/>

<?php
if( !empty($ClientIP) ) {
    touch("/var/spool/webknock/$ClientIP");
    system("sudo /etc/cron.hourly/webknock");
}
?>

</body>
</html>
