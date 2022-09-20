for i in *.type ; do perl /home/tianxl/pipeline/STR_tools/dantixing/erti_type.depth.pl -i $i -o test -m 1 > $i.erti;done
paste *.type.erti > all.erti.ty
python /home/tianxl/pipeline/SA_tools/var_pollution-stat.py -i all.erti.ty
wait 
for i in STR-L*[0-9]S*.type ; do echo $i ;done |  sed 's/_S.*.type//' > list
for i in `cat list`; do 
mkdir $i
cd $i
h=${i:0:9}
cp  ../"$h"F*.type ../"$h"M*.type ../"$i"*.type ./
if [ -f "$h"F*.type  -a -f "$h"M*.type -a -f "$i"*.type ];then
    sh /home/tianxl/pipeline/STR_tools/dantixing/erti.sh $h
    sh /home/tianxl/pipeline/STR_tools/dantixing/santi.sh $h
    sh /home/tianxl/pipeline/SA_tools/STR_familyPic.sh "$h".santi.pd santi
    sh /home/tianxl/pipeline/SA_tools/STR_familyPic.sh "$h".erti.pd erti

elif [ -f "$h"F*.type -a -f  "$i"*.type ] && [ ! -f "$h"M*.type ];then
    cat "$i"*.type > "$h"M_S10.type
    sh /home/tianxl/pipeline/STR_tools/dantixing/erti.sh $h
    sh /home/tianxl/pipeline/STR_tools/dantixing/santi.sh $h
    sh /home/tianxl/pipeline/SA_tools/STR_familyPic.sh "$h".santi.pd santi
    sh /home/tianxl/pipeline/SA_tools/STR_familyPic.sh "$h".erti.pd erti

elif [ -f "$h"M*.type -a -f "$i"*.type ] && [ ! -f "$h"F*.type ];then
    cat "$i"*.type > "$h"F_S10.type
    sh /home/tianxl/pipeline/STR_tools/dantixing/erti.sh $h
    sh /home/tianxl/pipeline/STR_tools/dantixing/santi.sh $h
    sh /home/tianxl/pipeline/SA_tools/STR_familyPic.sh "$h".santi.pd santi
    sh /home/tianxl/pipeline/SA_tools/STR_familyPic.sh "$h".erti.pd erti
fi  

cd ../
mv $i STR_result/
done
