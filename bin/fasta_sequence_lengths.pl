#!/usr/bin/perl

use strict;
use warnings;

my $inFile = shift; 
open(IN, "$inFile");

## By default Perl pulls in chunks of text up to a newline (\n) character; newline is
## the default Input Record Separator. You can change the Input Record Separator by
## using the special variable "$/". When dealing with FASTA files I normally change the
## Input Record Separator to ">" which allows your script to take in a full, multiline
## FASTA record at once.

$/ = ">";

## At each input your script will now read text up to and including the first ">" it encounters.
## This means you have to deal with the first ">" at the begining of the file as a special case.

my $junk = <IN>; # Discard the ">" at the begining of the file

## Now read through your input file one sequence record at a time. Each input record will be a
## multiline FASTA entry.

while ( my $record = <IN> ) {
	$record =~ s/>//;
# Remove the ">" from the end of $record, and realize that the ">" is already gone from the begining of the record
# Now split up your record into its definition line and sequence lines using split at each newline.
# The definition will be stored in a scalar variable and each sequence line as an
# element of an array.
	my ($defLine, @seqLines) = split /\n/, $record;
# Join the individual sequence lines into one single sequence and store in a scalar variable.
	my $sequence = join('',@seqLines); # Concatenates all elements of the @seqLines array into a single string.
	$sequence =~ s/\r//g;
	$defLine =~ s/\r//g;

	printf "$defLine\n";
	
# Print your definition; remember the ">" has already been removed. Remember to print a newline.
	printf "Seq Length: %s\n", length($sequence); # Print the sequence length and a newline and make sure to subtract the number of elements found in the seqLines array because there's a character that it's counting within the length function that I can't figure out how to remove...
}
