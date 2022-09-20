#!/bin/bash

a=(`cat name1`)

b=(`cat name2`)


for (( i = 0; i < ${#a[@]}; i++))

do
 if [ $2 ] && [ $2 == 'sed' ];then
   sed -i  "s/${a[$i]}/${b[$i]}/" $1
 else
   rename  ${a[$i]} ${b[$i]} *
 fi
       
done
