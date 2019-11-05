#!/bin/bash

liste_destination=`cat liste_dest`
liste_port_udp=`cat liste_port_udp`
liste_port_tcp=`cat liste_port_tcp`

rm *.rte

for dest in $liste_destination 
do
    tab_protocole=()
    somme_etoile_ICMP=nul
    somme_etoile_UDP=nul
    somme_etoile_TCP=nul
    fin=false
    dest_resolution=`host $dest|grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'`

    # On vérifie avec quels protocoles la destination est joignable
    for protocole in "-I" "-U" "-T"; do
        traceroute=`traceroute $protocole -q 1 -w 0.8 $dest_resolution -n|tail -n 1|awk '{print $2}'`
        if [ "$traceroute" == "$dest_resolution" ]; then
            tab_protocole=( ${tab_protocole[*]} $protocole )
        fi
    done

    echo "Résolution d'hôte : $dest_resolution"

    for ((nbHop=1 ; nbHop<=30 ; nbHop++))
    do
    
        for protocole in "${!tab_protocole[@]}"; do
            hop=`traceroute ${tab_protocole[$protocole]} $dest_resolution -f $nbHop -m $nbHop -q 1 -w 0.8 -A -n|grep -v "traceroute"|awk '{print $2,$3}'`
            cible=`echo "$hop"|awk '{print $1}'`

            if [ "$cible" != "*" ]; then
                if [ "$cible" == "$dest_resolution" ]; then
                    AS_hop=`echo $hop|awk '{print $2}'`
                    echo "$cible-$dest $AS_hop" >> $dest.[${tab_protocole[$protocole]}].rte 
                else
                    echo "[${tab_protocole[$protocole]}] $hop"
                    echo "$hop" >> $dest.[${tab_protocole[$protocole]}].rte 
                fi
            fi

            if [ "$cible" == "*" ]; then
        
                if [ "${tab_protocole[$protocole]}" == "-U" ];then
                    for port_udp in $liste_port_udp
                    do
                        hop_port=`traceroute ${tab_protocole[$protocole]} $dest_resolution -f $nbHop -m $nbHop -q 1 -w 0.8 -A -n -p $port_udp|grep -v "traceroute"|awk '{print $2,$3}'`
                        cible_port_udp=`echo "$hop_port"|awk '{print $1}'`
                        etoile_UDP=`echo "$cible_port_udp"|grep "*"|wc -l`
                        
                        if [ "$etoile_UDP" != "1" ]; then
                            echo "Etoile enlevé avec le port $port_udp => [${tab_protocole[$protocole]}] $hop_port ($etoile_UDP)"
                            break
                        fi
                    done
                    somme_etoile_UDP=$(($somme_etoile_UDP+$etoile_UDP))
                fi
                if [ "${tab_protocole[$protocole]}" == "-T" ];then
                    for port_tcp in $liste_port_tcp
                    do
                        hop_port=`traceroute ${tab_protocole[$protocole]} $dest_resolution -f $nbHop -m $nbHop -q 1 -w 0.8 -A -n -p $port_tcp|grep -v "traceroute"|awk '{print $2,$3}'`
                        cible_port_tcp=`echo "$hop_port"|awk '{print $1}'`
                        etoile_TCP=`echo "$cible_port_tcp"|grep "*"|wc -l`
                        
                        if [ "$etoile_TCP" != "1" ]; then
                            echo "Etoile enlevé avec le port $port_tcp => [${tab_protocole[$protocole]}] $hop_port ($etoile_TCP)"
                            echo "$hop_port" >> $dest.[${tab_protocole[$protocole]}].rte 
                            break
                        fi
                    done
                    somme_etoile_TCP=$(($somme_etoile_TCP+$etoile_TCP))
                fi
                if [ "${tab_protocole[$protocole]}" == "-I" ]; then
                    etoile_ICMP=`echo "$cible"|grep "*"|wc -l`
                    somme_etoile_ICMP=$(($somme_etoile_ICMP+$etoile_ICMP))
                fi

            fi

            if [ "$cible" == "$dest_resolution" ]; then
                echo "Found ==> [${tab_protocole[$protocole]}] $dest"
                fin=true
                # break
            fi
        done

        echo ""

        if [ $fin == "true" ]; then
            break
        fi
        
	done

    # On prend le fichier .rte avec la meilleur route possible (moins d'étoile donc le plus gros fichier)
    meilleur_route=`ls -lSh $dest.*|awk '{print $9}'|head -n 1`

    if [ "$meilleur_route" == "$dest.[-I].rte" ]; then
        if [ -f "$dest.[-T].rte" ]; then
            rm $dest.[-T].rte
        fi
        if [ -f "$dest.[-U].rte" ]; then
            rm $dest.[-U].rte
        fi
    fi

    if [ "$meilleur_route" == "$dest.[-U].rte" ]; then
        if [ -f "$dest.[-T].rte" ]; then
            rm $dest.[-T].rte
        fi
        if [ -f "$dest.[-I].rte" ]; then
            rm $dest.[-I].rte
        fi
    fi

    if [ "$meilleur_route" == "$dest.[-T].rte" ]; then
        if [ -f "$dest.[-I].rte" ]; then
            rm $dest.[-I].rte
        fi
        if [ -f "$dest.[-U].rte" ]; then
            rm $dest.[-U].rte
        fi
    fi

    echo "etoile_ICMP = $somme_etoile_ICMP"
    echo "etoile_UDP = $somme_etoile_UDP"
    echo "etoile_TCP = $somme_etoile_TCP"
    echo ""
    echo "exist_ICMP = $exist_ICMP"
    echo "exist_UDP = $exist_UDP"
    echo "exist_TCP = $exist_TCP"

done  
