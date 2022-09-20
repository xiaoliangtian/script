for i in *.out; do echo $i ` head -4 $i | tail -1` ;done > list
for i in *.out; do  head -2 $i | tail -1 ;done |sed  's/^/\t/' -  | head -1 > header
cat header list > WGA.fsi.xls
sed -i 's/\..*out//' WGA.fsi.xls
sed -i 's/ /\t/g' WGA.fsi.xls

