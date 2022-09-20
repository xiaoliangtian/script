for i in *.rate 
do 
  cat $i $i\_1 > $i.ka
  Rscript /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/kafang.R $i.ka > $i.out 
  grep 'p-value' $i.out > $i.ka.last
  cat $i.ka $i.ka.last $i.cpi > $i.last.txt
done
