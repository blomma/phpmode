#!/usr/bin/perl

use Getopt::Std;
use HTML::Parser( );

# Parse arguments
# -D directory -O outputfile
getopt("DO");

# First the directory mentioned looking for the function html files
opendir( DIR, $opt_D )
  or die "Can't opendir $opt_D: $!";

my @titleArray;
my $check = 0;

while( defined( $file = readdir( DIR )))
{
	# Skip the dot . ..
	next if $file =~ /^\.\.?$/;

	# we only want files that start with function.xxx
	next unless $file =~ /^function\.[a-zA-Z_-]+$\.html/;
	
	# Update the count
	$check++;
	my $path = $opt_D . $file;

	sub titleHandler
	{
		return if shift ne "title";
		my $self = shift;
		$self->handler( text => sub{ push @titleArray, lc(shift) }, "dtext" );
		$self->handler( end => sub{ shift->eof if shift eq "title"; },
			"tagname,self" );
	}

	my $Parser = HTML::Parser->new( api_version => 3 );
	$Parser->handler( start => \&titleHandler, "tagname, self" );
	$Parser->parse_file( $path ) || die $!;
}

my %hash = ();
my $code;

foreach $title ( @titleArray )
{
	chomp $title;
	my $l = length $title;
	push ( @{$hash{$l}}, $title );
}

foreach $len( sort{ $a <=> $b } keys %hash )
{
	my $count = 0;
	my $it = 1;
	$code .= '() = define_keywords_n ($1,';
	$code .= "\n\"";
	foreach $item( @{$hash{$len}} )
	{
		$count += $len;
		if( $count < 40 or $it == 1)
		{
			$code .= $item;
		} else {
			$count = 0;
			$code .= "\"\n+ \"$item";
        }
		$it++;
	}

	$code .= "\",\n$len,1);\n\n";
}

print $code;
#print $check;
