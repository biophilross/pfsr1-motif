import os,sys

def read_fasta(fasta_file):

	seqs = dict()
	with open(fasta_file) as f:
		header = f.readline()
		header = header.rstrip(os.linesep)
		header = header.replace(">", "")
		header = header.replace(" ", "")
		id = header.split("|")[0]
		sequences = []
		for line in f:
			line = line.rstrip("\n")
			if(line[0] == ">"):
				seqs[id] = "".join(sequences)
				header = line
				header = header.replace(">", "")
				header = header.replace(" ", "")
				id = header.split("|")[0]
				sequences = []
			else:
				line = line.replace("\r", "")
				sequences.append(line)

	seqs[id] = "".join(sequences)
	return(seqs)
