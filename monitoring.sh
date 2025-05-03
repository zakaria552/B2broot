#!/bin/bash
archi=$(uname -a)
vcpu=$(nproc --all)
cpu=$(lscpu | grep "^Socket(s):" | awk {'print $2'})
total=$(free -m | grep "Mem:" | awk {'print $2'})
used=$(free -m | grep "Mem:" | awk {'print $3'})
usage=$(awk -v u="$used" -v t="$total" 'BEGIN { printf "%.2f", (u/t)*100 }')
usedDisk=$(df --total -m | grep "^total" | awk '{print $3}')
totalDisk=$(lsblk | grep "^sda" | awk '{print $4}')
totalDiskNum=$(lsblk | grep "^sda" | awk '{print $4+0}')
diskUsage=$(($usedDisk * 100 / ($totalDiskNum * 1000)))
cpuLoad=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
boot=$(who -b | awk '{print $3 " " $4}')
tcp=$(cat /proc/net/tcp | grep "01" | wc -l)
userLog=$(who | wc -l)
ip=$(hostname -I)
mac=$(ip link | grep "link/ether" | awk '{print $2}')
sudo=$(cat /var/log/sudo/sudo.log | wc -l)
hostname=$(hostname)
date=$(date | awk '{print $1" "$2" "$3" "$4" "$6}')

if lsblk | grep -q "lvm"; then
	lvm="yes"

else 
	lvm="no"
fi

message="\n\t#Architecture : $(uname -a) \n\t#CPU physical : $cpu \n\t#vCPU : $vcpu\n\t#Memory Usage : $used/$total MB ($usage%)
\n\t#Disk Usage : $usedDisk/$totalDisk ($diskUsage%)\n\t#CPU load : ${cpuLoad}\n\t#Last boot : $boot\n\t#LVM use : $lvm
\n\t#Connections TCP : $tcp ESTABLISHED\n\t#User log : $userLog\n\t#Network : IP $ip ($mac)\n\t#Sudo : $sudo cmd\n"


echo -e $message | wall
: '
for t in $(who | awk {'print $2'})
do
	echo "sending to $t"
	echo -e $message > /dev/$t
done
'
