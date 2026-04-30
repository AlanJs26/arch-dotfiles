#!/bin/bash


if [ $# -lt 3 ]; then
    cat <<EOF
Remove a textual watermark from a PDF file.  Requires qpdf and pdftx
to work correctly.  The correct usage is

Usage:

	remove-watermark WATERMARK "input_file.pdf" "ouput_file.pdf"
EOF
exit
fi

WATERMARK=$1
INBOUND=$2
OUTBOUND=$3

UNCOMPRESSED=`mktemp --dry-run 'uncompressed-XXXXXXXXXX.pdf'`
FIXED=`mktemp --dry-run 'fixed-XXXXXXXXXX.pdf'`
UNMARKED=`mktemp --dry-run 'unmarked-XXXXXXXXXX.pdf'`

WATERMARKLEN=${#WATERMARK}
BLANKS=`printf %${WATERMARKLEN}s`

qpdf --stream-data=uncompress "$INBOUND" $UNCOMPRESSED
sed -e 's/\[($WATERMARK)\]/[($BLANKS)]/g' < $UNCOMPRESSED > $FIXED
pdftk $FIXED output $UNMARKED
qpdf --stream-data=compress $UNMARKED "$OUTBOUND"
rm $UNCOMPRESSED $FIXED $UNMARKED
