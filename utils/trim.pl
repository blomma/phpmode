#!/usr/bin/perl

sub trim
{
	my @out = @_;
	for (@out)
	{
		s/^\s+//;
		s/\s+$//;
	}
	return wantarray ? @out : $out[0];
}

while (<>)
{
	print &trim($_)."\n";
}
