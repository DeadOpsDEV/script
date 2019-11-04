liste_fichier_rte=`ls www.ville-beziers.fr.[-T].rte` 
echo "">cartographie.txt
echo "graph g {">cartographie.xdot

for fichier in $liste_fichier_rte
do
    tab=()
    echo "bonjour : $fichier"
    ligne_max=`cat $fichier|wc -l`
    echo "ligne_max = $ligne_max"

    for ((ligne_min=1 ; ligne_min<=ligne_max ; ligne_min++))
    do
        test=`cat $fichier`
        acienRouteur=`echo "$test"|head -n "$ligne_min"|awk '{print $1}'`
        # tab=( ${tab[*]} $ip_hop )
        nouveauRouteur=`echo "$test"|head -n "$(($ligne_min+1))"|awk '{print $1}'`
        if [ "$acienRouteur" != "$nouveauRouteur" ]; then
            echo "\"$acienRouteur\" -- \"$nouveauRouteur\";">>cartographie.txt
        fi
    done

    # for i in "${!tab[@]}"
    # do
    #     if [ "${tab[$i]}" != "${tab[$i+1]}" ]
    #     then
    #         echo "\"${tab[$i]}\" -- \"${tab[$i+1]}\";">>cartographie.txt
    #     fi
    # done
    echo "">>cartographie.txt
done
echo "}">>cartographie.xdot
xdot cartographie.xdot
