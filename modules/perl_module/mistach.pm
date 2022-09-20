#!/usr/bin/perl
package mistach;
# $a="ATTCCGGGAT";
# $one_match=fuzzy_pattern($a,1);
# print "$one_match\n";

sub make_approximate {
    my ($pattern, $mismatches_allowed) = @_;
    #print "$pattern\n";
    if ($mismatches_allowed == 0) { return $pattern }
    elsif (length($pattern) <= $mismatches_allowed){ 
        $pattern =~ tr/ACTG/./; 
        return $pattern;
    }
    else {
        my ($first, $rest) = $pattern =~ /^(.)(.*)/;
        my $after_match = make_approximate($rest, $mismatches_allowed);
        if ($first =~ /[ACGT]/) {
            my $after_miss = make_approximate($rest, $mismatches_allowed-1);
            return "(?:$first$after_match|.$after_miss)";
        }
        else { return "$first$after_match" }
    }   
}
sub fuzzy_pattern {
    my ($original_pattern, $mismatches_allowed) = @_;
    $mismatches_allowed >= 0
    or die "Number of mismatches must be greater than or equal to zero\n";
    #print "$mismatches_allowed\n";
    my $new_pattern = make_approximate($original_pattern, $mismatches_allowed);
    return qr/$new_pattern/;
    print "$new_pattern\n";
}

1;