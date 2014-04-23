#!/usr/bin/perl -w

use strict;
use warnings;

my %count;
if (defined($ARGV[0])) 
{
	open(INPUT, "<$ARGV[0]");

	while(my $line = <INPUT>)
	{
		$line =~ s/\n//;
		foreach my $str (split /\t+/, $line)
		{
			$count{$str}++;
		}
	}

	close(INPUT);
}
else
{
	while(my $line = <STDIN>)
	{
		$line =~ s/\n//;
		foreach my $str (split /\t+/, $line)
		{
			$count{$str}++;
		}
	}

}

foreach my $str (sort keys %count) {
    printf "%s\t%s\n", $str, $count{$str};
}

exit;
