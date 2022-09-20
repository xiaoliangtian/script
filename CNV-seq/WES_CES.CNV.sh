#!/bin/bash
sample=$1
sampleName=$4
project=$2
outpath=$3
if [ $project == "WES" ];then
    ref="/home/zhangxp/tools/ref/cnvkit/hg19/WES/cnvkit_ref_WES.cnn"
elif [ $project == "CES" ];then
    ref="/home/zhangxp/tools/ref/cnvkit/CES/cnvkit_ref_CES.cnn"
elif [ $project == "WGS" ];then
    ref="/home/tianxl/database/ref/CNVwgsRef/WGS_ref.cnn"
else
    echo "error project"
    exit 1
fi
if [ $project == "WES" ] || [ $project == "CES" ];then
    /home/zhangxp/tools/cnvkit/cnvkit.py batch  -m amplicon $sample -r $ref  -d $outpath -p 10
else
    cnvkit.py batch   $sample -r $ref  -d $outpath -p 20
fi
wait
cd $outpath
sed -i 's/^chr//' $sampleName.dedup.sorted.cns $sampleName.dedup.sorted.cnr
perl /home/tianxl/pipeline/CNV-seq/cnvkit2type_v2.pl $sampleName.dedup.sorted.cns $sampleName.type $sampleName.qianhe > $sampleName.cnv
perl /home/tianxl/pipeline/CNV-seq/cnvkit2point.pl $sampleName.dedup.sorted.cnr $sampleName.cnv $sampleName.point
perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$sampleName".cnv > "$sampleName".band
awk '{print $2":"$3"-"$4}' "$sampleName".band | sed 's/^/chr/' - > $sampleName.intervals
awk '{print $2"\t"$3"\t"$4}' "$sampleName".band | sed '/start/d' - > $sampleName.bed
pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $sampleName.intervals --out $sampleName --noweb
sed -i 's/\.$/NoneGene/' $sampleName.loci
python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py $sampleName.intervals $sampleName.loci
paste "$sampleName".band  "$sampleName".intervals.result > "$sampleName".band_gene_v2.xls
wait
Rscript /home/tianxl/pipeline/utils/CNV.R $sampleName.point $sampleName
rm "$sampleName".band $sampleName.intervals   $sampleName.loci "$sampleName".intervals.result "$sampleName".log  "$sampleName".bed *targetcoverage.cnn "$sampleName".dedup.sorted.cns "$sampleName".dedup.sorted.cnr
