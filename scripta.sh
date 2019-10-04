#!/bin/bash

destination=`cat liste_dest`

echo "" > collecte/icmp_route
echo "" > collecte/tcp_route
echo "" > collecte/udp_route

for i in $destination 
do
	
	for ((nbHop=0 ; nbHop<30 ; nbHop++))
	do
		test=`traceroute -I -f $nbHop -m $nbHop -q 1 -w 20 $i|grep -v "traceroute"|sed -e "s/ /,/g"|cut -d "," -f4`
		if [ $destination -eq $test ]
		then
			echo "$destination = $test"	 
		fi
	done  
		

done  
