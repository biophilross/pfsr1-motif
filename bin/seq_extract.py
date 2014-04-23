# import modules
import sys
import argparse
import textwrap
from src.fasta import read_fasta

def main():
	parser = argparse.ArgumentParser(description = "Extract full gene sequences from genome fasta file")
	parser.add_argument("-l", dest = "loc_file", help = "Genome location file")
	parser.add_argument("-g", dest = "genome_file", help = "Genome split by chromosome")
	args = parser.parse_args()

	# store genome into dictionary split by chromosome
	genome = read_fasta(args.genome_file)

	# use locations file to grab full gene sequences
	full_genes = dict()
	reverse_strand = False
	with open(args.loc_file) as f:
		for line in f:
			id, location = line.split("\t")
			chr, coordinates = location.split(":")
			if(coordinates[-2] == "-"):
				reverse_strand = True
			coordinates = coordinates[:-4]
			start, stop = coordinates.split("-")
			if(reverse_strand):
				full_genes[id] = genome[chr][int(start) - 1:int(stop)][::-1]
			else:
				full_genes[id] = genome[chr][int(start) - 1:int(stop)]

	for key in full_genes.keys():
		gene_id = ">" + key + "\n"
		seq = "\n".join(textwrap.wrap(full_genes[key], width=60))
		sys.stdout.write(gene_id + seq + "\n")

if __name__ == "__main__":
	main() 
