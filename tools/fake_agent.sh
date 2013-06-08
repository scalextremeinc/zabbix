tmp=`mktemp`

printf "ZBXD\x01" >> $tmp
size=`wc -c $3 | cut -d' ' -f1`
printf "0: %.16x" $size | xxd -r -g0 >> $tmp
cat $3 >> $tmp

echo "tmp: $tmp"

cat $tmp | nc $1 $2
