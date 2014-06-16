#!/usr/bin/env python

"""
Description: Use this script to extract the id and either product, location,
length, or annotation of a transcript from Pf3D7 annotated transcripts file
"""

# import modules
import sys
import argparse

def main():
	parser = argparse.ArgumentParser(description = "Extract gene id and <field_name> from annotated_trascripts.fasta. <field_name> can be either 'product' 'length' 'location' or 'so'")
	parser.add_argument("-i", dest = "input_name", help = "Input Filename")
	parser.add_argument("-f", dest = "field_name", help = "Field Name ")
	args = parser.parse_args()

	# print header to file
	sys.stdout.write("gene_id\t" + args.field_name)
	with open(args.input_name) as f:
		for line in f:
			if(line[0] == '>'):
				# strip white space and > character
				line = line.strip()
				line = line.replace(" ", "")
				line = line.lstrip('>')
				line_array = line.split("|")
				# assign each annotation to a separate variable
				id = line_array[0].split(":")[0]
				product = line_array[2].replace("product=", "")
				location = line_array[3].replace("location=", "")
				length = line_array[4].replace("length=", "")
				so = line_array[6].replace("SO=", "")
				# print appropriate fields to stdout
				if(args.field_name == "product"):
					sys.stdout.write(id + "\t" + product + "\n")	
				elif(args.field_name == "length"):
					sys.stdout.write(id + "\t" + length + "\n")	
				elif(args.field_name == "location"):
					sys.stdout.write(id + "\t" + location + "\n")	
				elif(args.field_name == "so"):
					sys.stdout.write(id + "\t" + so + "\n")	
			

if __name__ == "__main__":
	main()
