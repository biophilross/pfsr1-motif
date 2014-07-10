PfSR1 RNA Binding Motif Analysis
================================

This is a project looking to find RNA binding motifs within enriched transcript sequences based on an immunoprecipitation experiment done with PfSR1, an SR protein found in Plasmodium falciparum thats is believed to be involved in RNA alternative splicing events and other types of post transcriptional regulation.

In order to start the analysis first run `make help`.

Initially you will want to run `make get-data` and `make edit-data`. In order to do this you must have samtools and bedtools installed and in your path.

To run through the rest of the workflow using the default parameters just use `make all`
