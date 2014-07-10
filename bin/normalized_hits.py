#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Description: Takes in an annotated transcripts file and a fimo.gff file to produce
a normalized hits file by transcript length

Version = 1.0
Author  = "Philipp Ross"
License = "Apache v2.0"
"""

# import modules
from __future__ import division
import os
import sys
import argparse

def main():

	parser = argparse.ArgumentParser(description = "Count and normalize transcript hits in fimo file and print to stdout")
	parser.add_argument("-f", dest = "fimo_file", help = "Fimo.gff file")
	parser.add_argument("-t", dest = "transcripts_file", help = "Annotated transcripts file")
	args = parser.parse_args()

	fimo_dict = dict()
	with open(args.fimo_file) as ff:
		next(ff) # skip first line
		for line in ff:
			line = line.rstrip()
			fields = line.split("\t")
			transcript_id = fields[0]
			if transcript_id in fimo_dict.keys():
				fimo_dict[transcript_id] += 1
			else:
				fimo_dict[transcript_id] = 1

	transcript_dict = dict()
	with open(args.transcripts_file) as tf:
		for line in tf:
			line = line.rstrip()
			if(line[0] == '>'):
				line = line.replace(" ", "")
				line = line.lstrip('>')
				fields = line.split("|")
				# assign each annotation to a separate variable
				transcript_id = fields[0].split(":")[0]
				product = fields[2].replace("product=", "")
				location = fields[3].replace("location=", "")
				length = fields[4].replace("length=", "")
				so = fields[6].replace("SO=", "")
				if(transcript_id not in transcript_dict.keys()):
					transcript_dict[transcript_id] = {
							"product"  : product, \
							"location" : location, \
							"length"   : int(length), \
							"so"       : so \
							}

	print >> sys.stdout, "id\thits\tnorm_hits\tproduct" 
	for transcript_id in fimo_dict.keys():
		hits = fimo_dict[transcript_id]
		norm_hits = fimo_dict[transcript_id] / transcript_dict[transcript_id]["length"]
		product = transcript_dict[transcript_id]["product"]
		print >> sys.stdout, "%s\t%s\t%s\t%s" % (transcript_id, hits, norm_hits, product)


if __name__ == "__main__":
	main()
