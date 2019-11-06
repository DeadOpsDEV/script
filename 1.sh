ancienRouteur=lol
nouveauRouteur=mdr
as=`cat "www.umontpellier.fr.[-I].rte"|head -n 2|tail -n 1|awk '{print $2}'`

echo "\"$ancienRouteur\" -- \"$nouveauRouteur\"[label=\"$as\"];">>test.txt