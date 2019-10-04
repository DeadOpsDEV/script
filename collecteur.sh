#!/bin/bash

echo "">cartographie.txt
echo "graph g {">cartographie.xdot
for dest in 'www.umontpellier.fr' 'www.iutbeziers.fr' 'www.cines.fr' 'urfist.univ-toulouse.fr' 'www.ville-beziers.fr'
do
	tab=()
	for hop in `traceroute -IUT $dest|grep -v "*"|grep -v "traceroute"|sed -e "s/ /,/g"|cut -d "," -f4 `
	do

		tab=( ${tab[*]} $hop )

	done
        
	for i in "${!tab[@]}"
        do
		if [ "${tab[$i]}" != "${tab[$i+1]}" ]
		then
        		echo "\"${tab[$i]}\" -- \"${tab[$i+1]}\";">>cartographie.txt  
        	fi
	done

	echo ""
 done

cat cartographie.txt|grep -v "\"\""|sed -e "s/(//g"|sed -e "s/)//g"|sort -u>>cartographie.xdot
echo "}">>cartographie.xdot
xdot cartographie.xdot
