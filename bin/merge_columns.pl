#!/usr/bin/perl -w

## WARNING: FIRST FILE MUST ALWAYS BE THE LARGER FILE WITH MORE INFORMATION

# This script is to use when I want to merge columns of information where the
# first column is always some sort of sequence or gene id and the second column
# is something about that sequence of interest such as it's length or something
# else

use strict;
use warnings;

# Create usage message here and use input argument to sepcify how many columns
# to print out and in what order

die("
Usage: perl merge_columns.pl <big-file> <small-file> > <combined-file>

WARNING: Big file must be larger than small file!
\n") unless @ARGV == 2;

# create hash of all rows in first file
my %hashONE;
open(INPUT, "<$ARGV[0]") || die("Could not open file... $ARGV[0]");
while(my $line = <INPUT>)
{
	$line =~ s/\n//;
	my ($ID, $value) = split(/\t/, $line);
	my @IDsplit = split(/:/, $ID);
	$ID = $IDsplit[0];
	$hashONE{"$ID"} = $value;
}
close(INPUT);

# create hash of all rows in second file
my %hashTWO;
open(INPUT, "<$ARGV[1]") || die("Could not open file... $ARGV[1]");
while(my $line = <INPUT>)
{
	$line =~ s/\n//;
	my ($ID, $value) = split(/\t/, $line);
	$hashTWO{"$ID"}{"Value1"} = $value1;
	#$hashTWO{"$ID"}{"Value2"} = $value2;
	#$hashTWO{"$ID"}{"Value3"} = $value3;
}
close(INPUT);

# Cycle through every key of first hash, see if they exist in the second
# hash and print out merged row of ID plus the two stats you want...
foreach my $key (keys %hashONE)
{
	if (defined($hashTWO{"$key"}))
	{
		printf STDOUT "%s\t%s\t%s\t%s\t%s\n", $key, $hashONE{"$key"}, $hashTWO{"$key"}{"Value1"}, $hashTWO{"$key"}{"Value2"}, $hashTWO{"$key"}{"Value3"};
	}
#	else
#	{
#		printf "%s\t%s\tEMPTY\n", $key, $hashONE{"$key"};
#	}
}
