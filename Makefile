# Makefile to recreate motif-analysis workflow

# DIRECTORIES
pf3d7 := ./data/pf3d7
motifs := ./data/motifs
probes := ./data/probes
inputs := ./data/inputs
results := ./results
bin := ./bin

# GLOBAL VARIABLES
fimo_threshold := 1e-4 # using 1e-5 returns 0 hits...1e-4 returns the highest fold increase
std_val := 3 # number of standard deviations to look for outliers in

# RUN ALL
all: get-data create-inputs sanity-check find-outliers get-outliers


# DOWNLOAD PF3D7 DATA
get-data: annotated_transcripts.fasta genome.fasta gene_aliases.txt

annotated_transcripts.fasta:
	wget --quiet -O $(pf3d7)/$@ http://plasmodb.org/common/downloads/release-11.0/Pfalciparum3D7/fasta/data/PlasmoDB-11.0_Pfalciparum3D7_AnnotatedTranscripts.fasta

genome.fasta:
	wget --quiet -O $(pf3d7)/$@ http://plasmodb.org/common/downloads/release-11.0/Pfalciparum3D7/fasta/data/PlasmoDB-11.0_Pfalciparum3D7_Genome.fasta

gene_aliases.txt:
	wget --quiet -O $(pf3d7)/$@ http://plasmodb.org/common/downloads/release-11.0/Pfalciparum3D7/txt/PlasmoDB-11.0_Pfalciparum3D7_GeneAliases.txt 


# CREATE FORMATTED DATA
create-inputs: transcript_lengths.txt transcript_products.txt transcript_locations.txt

transcript_lengths.txt: annotated_transcripts.fasta
	python $(bin)/at_extract.py -i $(pf3d7)/$^ -f length | sort -k1 > $(pf3d7)/$@
transcript_products.txt: annotated_transcripts.fasta
	python $(bin)/at_extract.py -i $(pf3d7)/$^ -f product | sort -k1 > $(pf3d7)/$@
transcript_locations.txt: annotated_transcripts.fasta
	python $(bin)/at_extract.py -i $(pf3d7)/$^ -f location | sort -k1 > $(pf3d7)/$@ 


# SANITY-CHECK
sanity-check: fimo_positive_seqs_SBM1 fimo_positive_seqs_SBM2 fimo_all_transcripts_SBM1 fimo_all_transcripts_SBM2 sanity_check.txt

fimo_positive_seqs_SBM1: $(motifs)/SBM1.meme
	bash $(bin)/searchmotif -m $^ -s $(probes)/PositiveSequences.txt -t $(fimo_threshold) -o $(results)/$@	

fimo_all_transcripts_SBM1: $(motifs)/SBM1.meme
	bash $(bin)/searchmotif -m $^ -s $(pf3d7)/annotated_transcripts.fasta -t $(fimo_threshold) -o $(results)/$@	

fimo_positive_seqs_SBM2: $(motifs)/SBM2.meme
	bash $(bin)/searchmotif -m $^ -s $(probes)/PositiveSequences.txt -t $(fimo_threshold) -o $(results)/$@	

fimo_all_transcripts_SBM2: $(motifs)/SBM2.meme
	bash $(bin)/searchmotif -m $^ -s $(pf3d7)/annotated_transcripts.fasta -t $(fimo_threshold) -o $(results)/$@	

sanity_check.txt:
	python $(bin)/sanity_check.py -p1 $(results)/fimo_positive_seqs_SBM1/fimo.txt -p2 $(results)/fimo_positive_seqs_SBM2/fimo.txt -t1 $(results)/fimo_all_transcripts_SBM1/fimo.txt -t2 $(results)/fimo_all_transcripts_SBM2/fimo.txt -p $(probes)/PositiveSequences.txt -t $(pf3d7)/annotated_transcripts.fasta > $(results)/$@


# FIND STATISTICAL OUTLIERS IN GENE HITS
find-outliers: SBM1_gene_hits.txt SBM2_gene_hits.txt SBM1_hits_len_prod.txt SBM2_hits_len_prod.txt norm_hits_SBM1.txt norm_hits_SBM2.txt

SBM1_gene_hits.txt:
	cat $(results)/fimo_all_transcripts_SBM1/fimo.txt | cut -f2 | sort | uniq -c | sort -gr | awk -f $(bin)/print_gene_hits.awk > $(results)/fimo_all_transcripts_SBM1/$@

SBM2_gene_hits.txt:
	cat $(results)/fimo_all_transcripts_SBM2/fimo.txt | cut -f2 | sort | uniq -c | sort -gr | awk -f $(bin)/print_gene_hits.awk > $(results)/fimo_all_transcripts_SBM2/$@

SBM2_hits_len_prod.txt: SBM2_gene_hits.txt transcript_lengths.txt transcript_products.txt
	bash $(bin)/join.sh $(results)/fimo_all_transcripts_SBM2/SBM2_gene_hits.txt $(pf3d7)/transcript_lengths.txt $(pf3d7)/transcript_products.txt $(results)/fimo_all_transcripts_SBM2/$@

SBM1_hits_len_prod.txt: SBM1_gene_hits.txt transcript_lengths.txt transcript_products.txt
	bash $(bin)/join.sh $(results)/fimo_all_transcripts_SBM1/SBM1_gene_hits.txt $(pf3d7)/transcript_lengths.txt $(pf3d7)/transcript_products.txt $(results)/fimo_all_transcripts_SBM1/$@

norm_hits_SBM1.txt: SBM1_hits_len_prod.txt 
	python $(bin)/calc_norm.py -i $(results)/fimo_all_transcripts_SBM1/$^ > $(results)/fimo_all_transcripts_SBM1/$@
	
norm_hits_SBM2.txt: SBM2_hits_len_prod.txt 
	python $(bin)/calc_norm.py -i $(results)/fimo_all_transcripts_SBM2/$^ > $(results)/fimo_all_transcripts_SBM2/$@


# GENES PRINT LIST OF STATISTICALLY SIGNIFICANT GENES 
get-outliers: SBM1_outliers.csv SBM2_outliers.csv

SBM1_outliers.csv: norm_hits_SBM1.txt
	python $(bin)/get_outliers.py -i $(results)/fimo_all_transcripts_SBM1/$^ -s $(std_val) > $(results)/fimo_all_transcripts_SBM1/$@

SBM2_outliers.csv: norm_hits_SBM2.txt
	python $(bin)/get_outliers.py -i $(results)/fimo_all_transcripts_SBM2/$^ -s $(std_val) > $(results)/fimo_all_transcripts_SBM2/$@

# RUN MEME TO RECAPITULATE MOTIFS
run-meme: meme_out

meme_out: $(probs)/PositiveSequences.txt
	module load meme
	meme $^ -oc $(results)/$@ -dna -minw 7 -maxw 8 -mod oops 

fimo_on_meme:
	

# VIEW RESULTS

# CLEAN DATA DIRECTORIES
clean: clean-pf3d7 clean-results

clean-pf3d7:
	rm -rf $(pf3d7)/*

clean-results:
	rm -rf $(results)/*

.PHONY: all view clean
