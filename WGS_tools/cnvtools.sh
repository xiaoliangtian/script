cnvtools call -l bam.list -t $1

h=${i//}
r=`ls $h`
if [ $r ];then
    echo "OK"
else 
   sh /home/tianxl/pipeline/WGS_tools/cnvtools.sh $1 
fi
