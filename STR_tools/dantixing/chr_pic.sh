grep  "^$2" $1 > $1.$2
awk '{print $2}' $1.$2 | sed '$d' > $1.$2.txt
