# Makefile to recreate motif-analysis workflow

# VARIABLES #################################################################

# Parameters
bgseqs               ?= 100
fimothresh           ?= 0.0001
std                  ?= 3
# Directories
WORKDIR              := $(CURDIR)
PF3D7                := $(WORKDIR)/data/pf3d7
MOTIFS               := $(WORKDIR)/data/motifs
PROBES               := $(WORKDIR)/data/probes
FIMO                 := $(WORKDIR)/data/fimo-$(fimothresh)-$(std)
RESULTS              := $(WORKDIR)/results
BIN                  := $(WORKDIR)/bin
# Annotation files
GFFWITHFASTA         := $(PF3D7)/plasmodb.gff
GFF                  := $(PF3D7)/pf3d7v11.0.gff
GENES                := $(PF3D7)/genes.gff
EXONS                := $(PF3D7)/exons.gff
MRNAS                := $(PF3D7)/mrnas.gff
INTRONS              := $(PF3D7)/introns.bed
INTERGENIC           := $(PF3D7)/intergenic.bed
# Sequence files
GENOME               := $(PF3D7)/genome.fasta
GENOMEIDX            := $(PF3D7)/genome.fasta.fai
BEDGENOME            := $(PF3D7)/chromosome_lengths.genome
TRANSCRIPTS          := $(PF3D7)/transcripts.fasta
# Text files
ALIASES              := $(PF3D7)/aliases.txt
SANITYCHECK          := $(RESULTS)/sanity_check.txt-$(fimothresh)
# Probe files
POSSEQS              := $(PROBES)/PositiveSequences.txt
BGBED                := $(PROBES)/bgseqs.bed
BGSEQS               := $(PROBES)/bgseqs.fasta
# Motif files
SBM1                 := $(MOTIFS)/SBM1.meme
SBM2                 := $(MOTIFS)/SBM2.meme
# Fimo output
FPSBM1               := $(FIMO)/positive_seqs_SBM1
FPSBM2               := $(FIMO)/positive_seqs_SBM2
FTSBM1               := $(FIMO)/transcripts_SBM1
FTSBM2               := $(FIMO)/transcripts_SBM2
NORMSBM1             := $(FIMO)/SBM1_norm_hits.txt
NORMSBM2             := $(FIMO)/SBM2_norm_hits.txt
OUTLIERSSBM1         := $(FIMO)/SBM1_outliers.txt
OUTLIERSSBM2         := $(FIMO)/SBM2_outliers.txt
GENOMESBM1           := $(FIMO)/genome_SBM1
GENOMESBM2           := $(FIMO)/genome_SBM2

# HELP ########################################################################

help:
	@echo ""
	@echo "Makefile for Motif Analysis Workflow"
	@echo ""
	@echo "Run 'make get-data' prior to running make all to download relevant data sets"
	@echo ""
	@echo "USAGE:"
	@echo "   make all                  run entire workflow with default paramters & inputs"
	@echo "   make get-data             downloads relevant data sets"
	@echo "   make edit-data            format and clean data"
	@echo "   make run-fimo             run fimo on transcripts and genome"
	@echo "   make sanity-check         run sanity check"
	@echo "   make get-outliers         find statistically significant genes"
	@echo "   make discover-motifs      reccapitulate motifs"
	@echo "   make help                 print this message"
	@echo ""
	@echo "PARAMETERS:"
	@echo "   bgseqs                    number of background sequences (100)"
	@echo "   fimothresh                fimo motif search threshold (0.0001)"
	@echo "   std                       number of standard deviations to use (3)"
	@echo ""

# ALL #########################################################################

all: edit-data run-fimo sanity-check get-outliers discover-motifs

# GET-DATA ####################################################################

# DOWNLOAD PF3D7 DATA
get-data: get-gff get-genome get-transcripts get-aliases

get-gff:
	wget http://plasmodb.org/common/downloads/release-11.0/Pfalciparum3D7/gff/data/PlasmoDB-11.0_Pfalciparum3D7.gff -O $(GFFWITHFASTA)

get-genome:
	wget http://plasmodb.org/common/downloads/release-11.0/Pfalciparum3D7/fasta/data/PlasmoDB-11.0_Pfalciparum3D7_Genome.fasta -O $(GENOME)

get-transcripts:
	wget http://plasmodb.org/common/downloads/release-11.0/Pfalciparum3D7/fasta/data/PlasmoDB-11.0_Pfalciparum3D7_AnnotatedTranscripts.fasta -O $(TRANSCRIPTS)

get-aliases:
	wget http://plasmodb.org/common/downloads/release-11.0/Pfalciparum3D7/txt/PlasmoDB-11.0_Pfalciparum3D7_GeneAliases.txt -O $(ALIASES)


# FORMAT-DATA #################################################################
edit-data: make-gff make-genome make-annotations make-bgseqs

# Format annotation files
make-gff:
	$(BIN)/strip-fasta-from-gff -i $(GFFWITHFASTA) -o $(GFF)

make-genome:
	samtools faidx $(GENOME)
	cut -f1,2 $(GENOMEIDX) > $(BEDGENOME)

make-annotations:
	cat $(GFF) | awk '$$3 ~ /exon/ || NR ==1 {print $$0}' > $(EXONS)
	cat $(GFF) | awk '$$3 ~ /gene/ || NR ==1 {print $$0}' > $(GENES)
	cat $(GFF) | awk '$$3 ~ /mRNA/ || NR ==1 {print $$0}' > $(MRNAS)
	bedtools complement -i $(EXONS) -g $(BEDGENOME) | bedtools intersect -a - -b $(GENES) > $(INTRONS)
	bedtools complement -i $(EXONS) -g $(BEDGENOME) | bedtools intersect -a - -b $(GENES) -v > $(INTERGENIC)

# Create background sequences for dreme motif recapitulation
make-bgseqs:
	bedtools random -l 180 -n $(bgseqs) -seed 113 -g $(BEDGENOME) > $(BGBED)
	bedtools getfasta -fi $(GENOME) -bed $(BGBED) -fo $(BGSEQS)

# RUN-FIMO ####################################################################
run-fimo: make-directories transcript-wide genome-wide

make-directories:
	@if [ ! -d $(FIMO) ]; then mkdir $(FIMO); fi

transcript-wide:
	bash $(BIN)/run-fimo.sh -m $(SBM1) -s $(POSSEQS) -t $(fimothresh) -o $(FPSBM1)
	bash $(BIN)/run-fimo.sh -m $(SBM1) -s $(TRANSCRIPTS) -t $(fimothresh) -o $(FTSBM1)
	bash $(BIN)/run-fimo.sh -m $(SBM2) -s $(POSSEQS) -t $(fimothresh) -o $(FPSBM2)
	bash $(BIN)/run-fimo.sh -m $(SBM2) -s $(TRANSCRIPTS) -t $(fimothresh) -o $(FTSBM2)

genome-wide:
	bash $(BIN)/run-fimo.sh -m $(SBM1) -s $(GENOME) -t 1e-3 -o $(GENOMESBM1)
	bash $(BIN)/run-fimo.sh -m $(SBM2) -s $(GENOME) -t 1e-3 -o $(GENOMESBM2)


# SANITY-CHECK ################################################################
sanity-check: compare-output

compare-output:
	python $(BIN)/sanity_check.py -p1 "$(FPSBM1)/fimo.gff" -p2 "$(FPSBM2)/fimo.gff" -t1 "$(FTSBM1)/fimo.gff" -t2 "$(FTSBM2)/fimo.gff" -p $(POSSEQS) -t $(TRANSCRIPTS) > $(SANITYCHECK)


# OUTLIERS ####################################################################
get-outliers: calc-normalized-hits calc-outliers

calc-normalized-hits:
	python $(BIN)/normalized_hits.py -f "$(FTSBM1)/fimo.gff" -t $(TRANSCRIPTS) > $(NORMSBM1)
	python $(BIN)/normalized_hits.py -f "$(FTSBM2)/fimo.gff" -t $(TRANSCRIPTS) > $(NORMSBM2)

calc-outliers:
	python $(BIN)/get_outliers.py -i $(NORMSBM1) -s $(std) > $(OUTLIERSSBM1)
	python $(BIN)/get_outliers.py -i $(NORMSBM2) -s $(std) > $(OUTLIERSSBM2)

# DISCOVER-MOTIFS ##############################################################
discover-motifs: run-meme run-dreme

run-meme:
	meme $(POSSEQS) -oc $(RESULTS)/meme_oops -dna -minw 7 -maxw 8 -mod oops
	meme $(POSSEQS) -oc $(RESULTS)/meme_anr -dna -minw 7 -maxw 8 -mod anr
	
run-dreme:
	dreme -p $(POSSEQS) -n $(BGSEQS) -oc $(RESULTS)/dreme -mink 7 -maxk 8


# CLEAN #######################################################################
clean-pf3d7:
	rm -rf $(PF3D7)/*

clean-results:
	rm -rf $(RESULTS)/*

.PHONY: all help
