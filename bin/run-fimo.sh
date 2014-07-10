#!/bin/bash

# halt in case of errors
set -u
set -e

<<DESCRIPTION
	A FIMO wrapper script

	Dependencies: 
	Author: http://methodicallyadventurous.com
DESCRIPTION

# FUNCTIONS ###################################################################
usage() {
cat << EOF

Usage: $(basename $0) -m <motif-file> -s <sequence-file> -t <threshold> -o <output-dir>

OPTIONS:
  -m           meme formatted motif file
  -s           fasta seqence file to search through
  -t           fimo threshold (1e-4)
  -o           name of output directory

WARNING: Will always overwrite output directory

EOF
exit 1
}

echoerr() {
	ecoh "$@" 1>&2;
}

# display usage
if [ $# -eq 0 ]; then
	usage
fi

# ARGS ########################################################################
while getopts "t:o:m:s:" OPTION; do
	
	case $OPTION in
		t)
			THRESHOLD=$OPTARG
			;;
		o)
			OUTPUTDIR=$OPTARG
			;;
		m)
			MOTIFFILE=$OPTARG
			;;
		s)
			SEQUENCEFILE=$OPTARG
			;;	
		*)
			usage
			;;
	esac
done


# RUN MAIN ####################################################################

fimo --bgfile motif-file --thresh $THRESHOLD --oc $OUTPUTDIR --max-stored-scores 100000000 $MOTIFFILE $SEQUENCEFILE

exit
