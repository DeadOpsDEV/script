#!/bin/bash

liste_destination=`cat liste_dest`

for dest in $liste_destination 
do
    etoile_ICMP=0
    fin=false
    dest_resolution=`host $dest|grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'`
    echo "Résolution d'hôte : $dest_resolution"
    for ((nbHop=1 ; nbHop<=30 ; nbHop++))
    do
			# hop=`traceroute $protocole $dest -f $nbHop -m $nbHop -q 1 -w 20 -A|grep -v "traceroute"|awk '{print $2,$4}'` 
			
			# echo "[$protocole] $hop"	

            #     if [ "$hop" == "*" ]; then
            #         etoile=true
            #     fi
            #     cible=`echo "$hop"|awk '{print $1}'`
            #     if [ "$cible" == "$dest" ]; then
            #         echo "[$protocole] $dest == > $hop ($nbHop)"
            #         echo "[$protocole] étoiles == > $etoile"
            #         echo ""
            #         break
            #     fi   

        for protocole in "-I" "-U" "-T"; do
            hop=`traceroute $protocole $dest_resolution -f $nbHop -m $nbHop -q 1 -w 20 -A -n|grep -v "traceroute"|awk '{print $2,$3}'`
            cible=`echo "$hop"|awk '{print $1}'`
            echo "[$protocole] $hop"

            if [ "$cible" == "*" ]; then
        
                if [ "$protocole" == "-U" ];then
                    etoile_ICMP=`echo "$cible"|wc -l`
                    etoile_ICMP=$(($etoile_ICMP+$etoile_ICMP))
                fi

            fi

            if [ "$cible" == "$dest_resolution" ]; then
                echo "Found ==> $dest"
                if [ "$cible" == "*" ] && [ "$protocole" != "-I" ]; then
                    echo "protocole : $protocole"
                fi
                fin=true
                break
            fi
        done
        
        echo ""
        if [ $fin == "true" ]; then
            break
        fi

	done

    echo "etoile_ICMP = $etoile_ICMP"
       
        # if [ "$hop" != "$dest" ]; then
        #     echo "[$protocole] Cible non atteinte"
        #     echo "[$protocole] étoiles == > $etoile"
        #     echo ""
        # fi

        	

done  
