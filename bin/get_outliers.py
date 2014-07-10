#!/usr/bin/env python

# import modules
import sys
import argparse
from pandas import *

def main():
	parser = argparse.ArgumentParser(description = "")
	parser.add_argument("-i", dest = "norm_file", help = "Normalized Hits File")
	parser.add_argument("-s", dest = "std_val", help = "Number of Standard Deviations")
	args = parser.parse_args()

	data = read_table(args.norm_file, sep='\t')
	norm_hits = data.columns[2]
	outliers = data[data[norm_hits] > data[norm_hits].std() * int(args.std_val)]

	outliers.to_csv(sys.stdout, sep='\t', index=False)

if __name__ == "__main__":
	main() 
