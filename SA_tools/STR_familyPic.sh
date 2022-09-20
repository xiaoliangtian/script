grep  "^Chr" $1 > $1.$2
awk '{print $2}' $1.$2 | sed '$d' > $1.$2.txt
sed -i 's/$/\t0.03/' $1.$2.txt
cat /home/tianxl/pipeline/STR_tools/dantixing/header $1.$2.txt > $1.$2.txt.txt
perl /opt/seqtools/source/v1_4_2pre2/tools/tableTools.pl --postprocess '{ labels => PLIST }' --plist $1.$2.txt.txt > $1.$2.plist
perl /opt/seqtools/source/v1_4_2pre2/coloredChromosomes.pl --o $1.$2.ps --labelFile $1.$2.plist --labelMap /opt/seqtools/source/v1_4_2pre2/tools/gamesLoci_STR_v3.plist --chromosomeSpec /opt/seqtools/source/v1_4_2pre2/configs/humanChromosomes_hg19_12.cfg
ps2pdf $1.$2.ps > $1.$2.pdf
rm $1.$2.ps $1.$2 $1.$2.txt $1.$2.txt.txt $1.$2.plist 
#sed -i 's/$/\t0.03/' $1
#cat /home/tianxl/pipeline/STR_tools/dantixing/header $1 > $1.txt
#perl /opt/seqtools/source/v1_4_2pre2/tools/tableTools.pl --postprocess '{ labels => PLIST }' --plist $1.txt > $1.plist
#perl /opt/seqtools/source/v1_4_2pre2/coloredChromosomes.pl --o $1.ps --labelFile $1.plist --labelMap /opt/seqtools/source/v1_4_2pre2/tools/gamesLoci_STR_v3.plist --chromosomeSpec /opt/seqtools/source/v1_4_2pre2/configs/humanChromosomes_hg19_12.cfg
#ps2pdf $1.ps > $1.pdf
