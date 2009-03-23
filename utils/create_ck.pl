#!/usr/bin/perl

use Getopt::Std;

# Parse arguments
# -I inputfile -O outputfile
getopt("IO");

my %hash = ();

while (<>)
{
	chomp;
	my $l = length $_;
	push ( @{$hash{$l}}, $_ );
}

foreach $len (sort{ $a <=> $b } keys %hash)
{
	print '() = define_keywords_n ($1,';
	my $count = 0;
	print "\n";
    print "\"";
	foreach $test ( @{$hash{$len}} )
	{
		$count += $len;
		if ($count < 40)
		{
			print $test;
		} else {
            $count = 0;
            print "\"";
            print "\n";
            print "+ \"";
			print $test;
        }
	}
	print "\",\n";
	print "$len,0);";
	print "\n\n";
}