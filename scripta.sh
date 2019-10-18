#!/bin/bash

liste_destination=`cat liste_dest`

for dest in $liste_destination 
do
	for protocole in "-I" "-U" "-T"; do

		etoile=false

                for ((nbHop=1 ; nbHop<=30 ; nbHop++))
		do
			hop=`traceroute $protocole $dest -f $nbHop -m $nbHop -q 1 -w 20 -A|grep -v "traceroute"|awk '{print $2,$4}'` 
			
			echo "[$protocole] $hop"	

                        if [ "$hop" == "*" ]; then
                                etoile=true
                        fi
                        cible=`echo "$hop"|awk '{print $1}'`
                        if [ "$cible" == "$dest" ]; then
                                echo "[$protocole] $dest == > $hop ($nbHop)"
                                echo "[$protocole] étoiles == > $etoile"
                                echo ""
                                break
                        fi   
		done
       
                if [ "$hop" != "$dest" ]; then
                        echo "[$protocole] Cible non atteinte"
                        echo "[$protocole] étoiles == > $etoile"
                        echo ""
                fi

                etoile=false

	done	

done  
