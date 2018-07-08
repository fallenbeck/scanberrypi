#!/bin/bash
# Script to postprocess scanned files

# Load the configuration file
configfile="/opt/scanberrypi/etc/scanberrypi.conf"
[ ! -f "$configfile" ] && echo "Config file $configfile not found" && exit 1
source $configfile

# Print how script is used
function usage {
	# echo "usage: $*"
	echo "Script to postprocess scanned files."
	echo ""
	echo "`basename $0` [-h]"
	echo "`basename $0` [-d] [-o] [-u] -f <inputfile>"
	echo ""
	echo " 	with:"
	echo "  -h      Print this short help message"
	echo "  -d      Cleanup after postprocessing"
	echo "  -o      Run OCR on file (if <inputfile> must be a pdf)"
	echo "  -u      Upload file to FTP host (needs to be defined in config file)"
	echo "  -f      Input file"
	exit 0
}

delete=false
ocr=false
upload=false
inputfile=""

while getopts df:hou opt
do
	case $opt in
		d)
			delete=true
			;;
		f)
			echo "Inputfile: $OPTARG"
			inputfile=($OPTARG)
			;;
		h)
			usage
			;;
		o)
			ocr=true
			;;
		u)
			upload=true
			;;
		# :)
		# 	echo "Option -$OPTARG requires an argument."
		# 	exit
		# 	;;
		*)
			echo "Invalid argument."
			echo "Usage:"
			usage
			;;
	esac
done


# Sanity checks
[ ! -f $inputfile ] && echo "Cannot find $inputfile" && exit 1


logger -t "scanberrypi postprocess: $0" "Starting postprocessing of $inputfile"
### Functions for postprocessing

function delete {
  logger -t "scanberrypi postprocess: $0" "Delete $1"
  rm $1
}

function ocr {
	logger -t "scanberrypi postprocess: $0" "Run OCR on $1"
	tmp=$( mktemp )
	cp "$1" $tmp

  	ocrmypdf $tmp "$1"
	logger -t "scanberrypi postprocess: $0" "Saved $1"
	rm $tmp
}

# FTP upload function
function upload {
	logger -t "scanberrypi postprocess: $0" "Upload $1 to $ftp_host:$ftp_dir"

	ncftp -u $ftp_user -p "$ftp_pass" $ftp_host <<EOF
cd "$ftp_dir"
put $1
bye
EOF
}

# Do the work

if [ $ocr = true ]; then
	ocr "$inputfile"
fi

if [ $upload = true ]; then
	upload "$inputfile"
fi

if [ $delete = true ]; then
	delete "$inputfile"
fi

logger -t "scanberrypi postprocess: $0" "Finished postprocessing of $inputfile"
