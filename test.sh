test=`cat "www.umontpellier.fr.[-T].rte"`
a=`echo "$test"|head -n 1|awk '{print $1}'`
compter=`cat "www.umontpellier.fr.[-T].rte"|wc -l`
echo "$a"
echo "$compter"
