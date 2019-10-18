OUTPUT=$(ls -1)
#echo "${OUTPUT}"

echo ""

test=$(echo "$OUTPUT"|grep '.sh')
echo $test
