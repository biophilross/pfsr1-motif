# Makefile to recreate motif-analysis workflow

# VARIABLES #################################################################

# Directories
WORKDIR              := $(CURDIR)
PF3D7                := $(WORKDIR)/data/pf3d7
MOTIFS               := $(WORKDIR)/data/motifs
PROBES               := $(WORKDIR)/data/probes
RESULTS              := $(WORKDIR)/results
BIN                  := $(WORKDIR)/bin
# Sequence files
GENOME 							 := $(PF3D7)/genome.fasta
ANNOTATEDTRANSCRIPTS := $(PF3D7)/annotated_transcripts.fasta
# Annotation files
FULLGFF							 := $(PF3D7)/
# Text files
ALIASES							 := $(PF3D7)/aliases.txt
# Inputs
fimo_threshold       := 1e-4 # using 1e-5 returns 0 hits...1e-4 returns the highest fold increase
std_val              := 3 # number of standard deviations to look for outliers in

# HELP ########################################################################

help:
	@echo ''
	@echo 'Makefile for Motif Analysis Workflow'
	@echo ''
	@echo 'Usage:'
	@echo '   make all               run entire workflow with default paramters & inputs'
	@echo '   make get-data          downloads relevant data sets'
	@echo '   make create-inputs     format data to be used as inputs'
	@echo ''

# ALL #########################################################################

all: get-data create-inputs sanity-check find-outliers get-outliers discover-motifs

# GET-DATA ####################################################################

# DOWNLOAD PF3D7 DATA
get-data: annotated_transcripts.fasta genome.fasta gene_aliases.txt

annotated_transcripts.fasta:
	wget --quiet -O $(PF3D7)/$@ http://plasmodb.org/common/downloads/release-11.0/Pfalciparum3D7/fasta/data/PlasmoDB-11.0_Pfalciparum3D7_AnnotatedTranscripts.fasta

genome.fasta:
	wget --quiet -O $(PF3D7)/$@ http://plasmodb.org/common/downloads/release-11.0/Pfalciparum3D7/fasta/data/PlasmoDB-11.0_Pfalciparum3D7_Genome.fasta

gene_aliases.txt:
	wget --quiet -O $(PF3D7)/$@ http://plasmodb.org/common/downloads/release-11.0/Pfalciparum3D7/txt/PlasmoDB-11.0_Pfalciparum3D7_GeneAliases.txt 

background-sequences:
	bedtools random -l 180 -n 100 -seed 113


# FORMAT-DATA #################################################################
create-inputs: transcript_lengths.txt transcript_products.txt transcript_locations.txt

# Extract different fields from annotated transcripts file
transcript_lengths.txt: annotated_transcripts.fasta
	python $(BIN)/at_extract.py -i $(PF3D7)/$^ -f length | sort -k1 > $(PF3D7)/$@
transcript_products.txt: annotated_transcripts.fasta
	python $(BIN)/at_extract.py -i $(PF3D7)/$^ -f product | sort -k1 > $(PF3D7)/$@
transcript_locations.txt: annotated_transcripts.fasta
	python $(BIN)/at_extract.py -i $(PF3D7)/$^ -f location | sort -k1 > $(PF3D7)/$@ 


# SANITY-CHECK ################################################################
sanity-check: fimo_positive_seqs_SBM1 fimo_positive_seqs_SBM2 fimo_all_transcripts_SBM1 fimo_all_transcripts_SBM2 sanity_check.txt

fimo_positive_seqs_SBM1: $(MOTIFS)/SBM1.meme
	bash $(BIN)/searchmotif -m $^ -s $(PROBES)/PositiveSequences.txt -t $(fimo_threshold) -o $(RESULTS)/$@	

fimo_all_transcripts_SBM1: $(MOTIFS)/SBM1.meme
	bash $(BIN)/searchmotif -m $^ -s $(PF3D7)/annotated_transcripts.fasta -t $(fimo_threshold) -o $(RESULTS)/$@	

fimo_positive_seqs_SBM2: $(MOTIFS)/SBM2.meme
	bash $(BIN)/searchmotif -m $^ -s $(PROBES)/PositiveSequences.txt -t $(fimo_threshold) -o $(RESULTS)/$@	

fimo_all_transcripts_SBM2: $(MOTIFS)/SBM2.meme
	bash $(BIN)/searchmotif -m $^ -s $(PF3D7)/annotated_transcripts.fasta -t $(fimo_threshold) -o $(RESULTS)/$@	

sanity_check.txt:
	python $(BIN)/sanity_check.py -p1 $(RESULTS)/fimo_positive_seqs_SBM1/fimo.txt -p2 $(RESULTS)/fimo_positive_seqs_SBM2/fimo.txt -t1 $(RESULTS)/fimo_all_transcripts_SBM1/fimo.txt -t2 $(RESULTS)/fimo_all_transcripts_SBM2/fimo.txt -p $(PROBES)/PositiveSequences.txt -t $(PF3D7)/annotated_transcripts.fasta > $(RESULTS)/$@


# OUTLIERS ####################################################################
find-outliers: SBM1_gene_hits.txt SBM2_gene_hits.txt SBM1_hits_len_prod.txt SBM2_hits_len_prod.txt norm_hits_SBM1.txt norm_hits_SBM2.txt

SBM1_gene_hits.txt:
	cat $(RESULTS)/fimo_all_transcripts_SBM1/fimo.txt | cut -f2 | sort | uniq -c | sort -gr | awk -f $(BIN)/print_gene_hits.awk > $(RESULTS)/fimo_all_transcripts_SBM1/$@

SBM2_gene_hits.txt:
	cat $(RESULTS)/fimo_all_transcripts_SBM2/fimo.txt | cut -f2 | sort | uniq -c | sort -gr | awk -f $(BIN)/print_gene_hits.awk > $(RESULTS)/fimo_all_transcripts_SBM2/$@

SBM2_hits_len_prod.txt: SBM2_gene_hits.txt transcript_lengths.txt transcript_products.txt
	bash $(BIN)/join.sh $(RESULTS)/fimo_all_transcripts_SBM2/SBM2_gene_hits.txt $(PF3D7)/transcript_lengths.txt $(PF3D7)/transcript_products.txt $(RESULTS)/fimo_all_transcripts_SBM2/$@

SBM1_hits_len_prod.txt: SBM1_gene_hits.txt transcript_lengths.txt transcript_products.txt
	bash $(BIN)/join.sh $(RESULTS)/fimo_all_transcripts_SBM1/SBM1_gene_hits.txt $(PF3D7)/transcript_lengths.txt $(PF3D7)/transcript_products.txt $(RESULTS)/fimo_all_transcripts_SBM1/$@

norm_hits_SBM1.txt: SBM1_hits_len_prod.txt 
	python $(BIN)/calc_norm.py -i $(RESULTS)/fimo_all_transcripts_SBM1/$^ > $(RESULTS)/fimo_all_transcripts_SBM1/$@
	
norm_hits_SBM2.txt: SBM2_hits_len_prod.txt 
	python $(BIN)/calc_norm.py -i $(RESULTS)/fimo_all_transcripts_SBM2/$^ > $(RESULTS)/fimo_all_transcripts_SBM2/$@


# PRINT LIST OF STATISTICALLY SIGNIFICANT GENES 
get-outliers: SBM1_outliers.csv SBM2_outliers.csv

SBM1_outliers.csv: norm_hits_SBM1.txt
	python $(BIN)/get_outliers.py -i $(RESULTS)/fimo_all_transcripts_SBM1/$^ -s $(std_val) > $(RESULTS)/fimo_all_transcripts_SBM1/$@

SBM2_outliers.csv: norm_hits_SBM2.txt
	python $(BIN)/get_outliers.py -i $(RESULTS)/fimo_all_transcripts_SBM2/$^ -s $(std_val) > $(RESULTS)/fimo_all_transcripts_SBM2/$@

# RUN MEME TO RECAPITULATE MOTIFS
discover-motifs: run-meme run-dreme

run-meme:
	meme $(PROBES)/PositiveSequences.txt -oc $(RESULTS)/meme_oops -dna -minw 7 -maxw 8 -mod oops
	meme $(PROBES)/PositiveSequences.txt -oc $(RESULTS)/meme_anr -dna -minw 7 -maxw 8 -mod anr
	
run-dreme:
	dreme -p $(PROBES)/PositiveSequences.txt -n $(PROBES)/BackgroundSequencesRicherUp.txt -oc $(RESULTS)/dreme

# VIEW ########################################################################


# CLEAN #######################################################################
clean: clean-pf3d7 clean-results

clean-PF3D7:
	rm -rf $(PF3D7)/*

clean-RESULTS:
	rm -rf $(RESULTS)/*

.PHONY: all view clean help
