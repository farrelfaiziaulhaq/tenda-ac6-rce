#!/firmadyne/busybox sh
BB=/firmadyne/busybox
export PATH=/sbin:/bin:/usr/sbin:/usr/bin

$BB mount -t proc proc /proc 2>/dev/null
$BB mount -t sysfs sysfs /sys 2>/dev/null
$BB mkdir -p /dev/pts /tmp /var/run /var/lock /var/log
$BB mount -t devpts devpts /dev/pts 2>/dev/null

$BB ifconfig lo 127.0.0.1 up 2>/dev/null
$BB ifconfig eth0 up 2>/dev/null
$BB brctl addbr br0 2>/dev/null
$BB brctl addif br0 eth0 2>/dev/null
$BB ifconfig eth0 0.0.0.0 up 2>/dev/null
$BB ifconfig br0 10.0.2.15 netmask 255.255.255.0 up 2>/dev/null
$BB route add default gw 10.0.2.2 2>/dev/null

$BB rm -f /var/cfm_socket
/cfm_mib >/tmp/c.log 2>&1 &
$BB sleep 3
$BB echo ===START-CFM

i=0
while $BB [ $i -lt 3 ]; do
  /bin/httpd >/tmp/h$i.log 2>&1 &
  $BB sleep 4
  i=$((i+1))
done

$BB echo ===PS
$BB ps w
$BB echo ===H0
$BB cat /tmp/h0.log
$BB echo ===TCP
$BB cat /proc/net/tcp
$BB echo ===UNIX
$BB cat /proc/net/unix
$BB echo ===END

while :; do
  $BB sh -i </firmadyne/ttyS1 >/firmadyne/ttyS1 2>&1
  $BB sleep 1
done
