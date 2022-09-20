if [ $1 ];then
    for i in *R1*.fastq.gz; do h=${i/_R1*.fastq.gz/} ; sh /home/tianxl/pipeline/WGS_tools/wgs_calling.sh $h $h $1;done
else
    echo 'fastq path must be entered!'
fi
