# Use this script to join columns of these files

# halt in case of error
#set -ue

FILE1=$1
FILE2=$2
FILE3=$3
FILE4=$4

join -a1 -o 0 1.2 2.2 -e "0" <(sort $FILE1) <(sort $FILE2) | join -a1 -o 0 1.2 1.3 2.2 -e "NA" - <(sort $FILE3) | sed 's/\s/\t/g' > $FILE4

exit
