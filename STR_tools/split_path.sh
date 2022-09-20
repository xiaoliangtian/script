for i in *S_*.type ; do echo $i ;done > name
sed -i 's/S_.*//' name
for i in `cat name`; do
	 mkdir $i
	cd $i 
	ln -s ../$i*.type ./
	cd ../ 
done
