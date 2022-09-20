
die "Usage: perl $0 input > out \n" unless @ARGV == 1;

$input = $ARGV[0];
open(IN,$input);

while(<IN>){
    chomp;
    unless (/^>/){
        $len = length($_);
        for($i=0;$i<($len-100);$i++){
            $seqNum = 'num'.$i;
            $seq = substr($_,$i,100);
            print ">$seqNum\n$seq\n";
        }
    }
}