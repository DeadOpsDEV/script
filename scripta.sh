#!/bin/bash

liste_destination=`cat liste_dest`

echo "" > collecte/icmp_route
echo "" > collecte/tcp_route
echo "" > collecte/udp_route

for dest in $liste_destination 
do
	for protocole in "-I" "-U" "-T"; do
		for ((nbHop=1 ; nbHop<=30 ; nbHop++))
		do
			test=`traceroute $protocole $dest -f $nbHop -m $nbHop -q 1 -w 20|grep -v "traceroute"|awk '{print $2}'`
			echo $test >> temp 

			if [ "$test" == "$dest" ]; then
				echo "[$protocole] $dest == > $test ($nbHop)"
				if [ `cat temp|grep "*"` ]; then
					echo "changes les ports"
				fi
				break
			fi	
		done
		#echo "" > temp   
	done	

done  
