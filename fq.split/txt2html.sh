# !/bin/sh
 
file_input=$1
file_output=$2
 
td_str=''
 
function create_html_head(){
  echo -e "<html>
    <body>
      <h1>$file_input</h1>"
}
 
function create_table_head(){
  echo -e "<table border="1">"
}
 
function create_td(){
#  if [ -e ./"$1" ]; then
    echo $1
    td_str=`echo $1 | awk  '{i=1; while(i<=NF) {print "<td>"$i"</td>";i++}}'`
    echo $td_str
#  fi
}
 
function create_tr(){
  create_td "$1"
  echo -e "<tr>
    $td_str
  </tr>" >> $file_output
}
 
function create_table_end(){
  echo -e "</table>"
}
 
function create_html_end(){
  echo -e "</body></html>"
}
 
 
function create_html(){
  rm -rf $file_output
  touch $file_output
 
  create_html_head >> $file_output
  create_table_head >> $file_output
 
  while read line
  do
    echo $line
    create_tr "$line"
  done < $file_input
 
  create_table_end >> $file_output
  create_html_end >> $file_output
}
 
create_html
