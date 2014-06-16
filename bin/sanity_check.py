#!/usr/bin/env python

"""
Description: Use this script to make sure there is an actual fold increase in the
amount of motifs present in the so called enriched sequences versus the rest of the genome
"""

# import modules
from __future__ import division

import sys
import argparse
from src.fasta import read_fasta
from src.file_len import file_len
from src.seq_len import seq_len

def main():
	parser = argparse.ArgumentParser(description = "")
	parser.add_argument("-p1", dest = "positive_SBM1", help = "Positive SBM1 Search Results")
	parser.add_argument("-p2", dest = "positive_SBM2", help = "Positive SBM2 Search Results")
	parser.add_argument("-t1", dest = "transcripts_SBM1", help = "Transcript SBM1 Search Results")
	parser.add_argument("-t2", dest = "transcripts_SBM2", help = "Transcript SBM2 Search Results")
	parser.add_argument("-p", dest = "positive_sequences", help = "Positive Sequences FASTA File")
	parser.add_argument("-t", dest = "transcript_sequences", help = "Transcript Sequences FASTA file")
	args = parser.parse_args()

	# calculate number of hits per search
	p1_hits = file_len(args.positive_SBM1) - 1
	p2_hits = file_len(args.positive_SBM2) - 1
	t1_hits = file_len(args.transcripts_SBM1) - 1
	t2_hits = file_len(args.transcripts_SBM2) - 1

	# read fasta files into dictionaries
	pos_seq = read_fasta(args.positive_sequences)
	trans_seq = read_fasta(args.transcript_sequences)

	# count number of bases per dictionary aka number of bases per file
	pos_bases = 0
	trans_bases = 0
	for key in pos_seq.keys():
		pos_bases += seq_len(pos_seq[key])

	for key in trans_seq.keys():
		trans_bases += seq_len(trans_seq[key])

	# calculate hits per base statistic for each motif
	psSBM1hpb = p1_hits / pos_bases
	psSBM2hpb = p2_hits / pos_bases
	ttSBM1hpb = t1_hits / trans_bases
	ttSBM2hpb = t2_hits / trans_bases

	# calculate fold increase statistics
	SBM1_fold_increase = psSBM1hpb / ttSBM1hpb
	SBM2_fold_increase = psSBM2hpb / ttSBM2hpb

	# write report to stdout
	sys.stdout.write("##########\n")
	sys.stdout.write("\n")
	sys.stdout.write("SANITY CHECK STATS\n")
	sys.stdout.write("\n")
	sys.stdout.write("Total Bases in Positive Sequences: " + str(pos_bases) + "\n")
	sys.stdout.write("Total Bases in Annotated Transcripts: " + str(trans_bases) + "\n")
	sys.stdout.write("\n")
	sys.stdout.write("Positive SBM1 Hits: " + str(p1_hits) + "\n")
	sys.stdout.write("Positive SBM2 Hits: " + str(p2_hits) + "\n")
	sys.stdout.write("Transcript SBM1 Hits: " + str(t1_hits) + "\n")
	sys.stdout.write("Transcript SBM2 Hits: " + str(t2_hits) + "\n")
	sys.stdout.write("\n")
	sys.stdout.write("Positive Sequence SBM1 Hits Per Base: " + str(psSBM1hpb) + "\n")
	sys.stdout.write("Positive Sequence SBM2 Hits Per Base: " + str(psSBM2hpb) + "\n")
	sys.stdout.write("Total Transcript SBM1 Hits Per Base: " + str(ttSBM1hpb) + "\n")
	sys.stdout.write("Total Transcript SBM2 Hits Per Base: " + str(ttSBM2hpb) + "\n")
	sys.stdout.write("\n")
	sys.stdout.write("Fold Increase for SBM1: " + str(SBM1_fold_increase) + "\n")
	sys.stdout.write("Fold Increase for SBM2: " + str(SBM2_fold_increase) + "\n")
	sys.stdout.write("\n")
	sys.stdout.write("##########\n")

if __name__ == "__main__":
	main() 
