liste_fichier_rte=`ls *.rte ` 
echo "">cartographie.txt
echo "graph g {">cartographie.xdot

for fichier in $liste_fichier_rte
do
    echo "bonjour : $fichier"
    ligne_max=`cat $fichier|wc -l`
    echo "ligne_max = $ligne_max"

    for ((ligne_min=1 ; ligne_min<=ligne_max ; ligne_min++))
    do
        ancienRouteur=`cat $fichier|head -n "$ligne_min"|tail -n 1|awk '{print $1}'`
        nouveauRouteur=`cat $fichier|head -n "$(($ligne_min+1))"|tail -n 1|awk '{print $1}'`
        as=`cat "$fichier"|head -n $ligne_min|tail -n 1|awk '{print $2}'|tr -cd '[:alnum:]'`

        if [ $ancienRouteur != $nouveauRouteur ]; then
            if [ "$as" == "" ]; then
                echo "\"$ancienRouteur\" -- \"$nouveauRouteur\"[label=\"*\"];">>cartographie.txt
            else
                echo "\"$ancienRouteur\" -- \"$nouveauRouteur\"[label=\"$as\"];">>cartographie.txt
            fi
        fi 
    done
                                                         
done
cat cartographie.txt|sort -u>>cartographie.xdot
echo "}">>cartographie.xdot
dot -Tpdf cartographie.xdot -o cartographie.pdf
xdg-open cartographie.pdf
