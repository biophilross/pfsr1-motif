# import modules
from __future__ import division

import sys
import argparse

def main():
	parser = argparse.ArgumentParser(description = "This script adds a column to the inputed gene hits file that's represented as the normalized motif hits value")
	parser.add_argument("-i", dest = "hits_file", help = "Gene Hits File")
	args = parser.parse_args()

	with open(args.hits_file) as f:
		sys.stdout.write("ID\tHits\tLength\tNormalized\tProduct\n")
		for line in f:
			line.rstrip("\n")
			id, hits, length, product = line.split("\t")
			if(int(length) > 0):
				norm = (int(hits) / int(length))
			else:
				norm = 0
			sys.stdout.write(str(id) + "\t" + str(hits) + "\t" + str(length) + "\t" + str(norm) + "\t" + str(product))
	

if __name__ == "__main__":
	main() 
