#!/bin/bash

# Pass the input directories as arguments
ONE_ARC_DIR=$1
THREE_ARC_DIR=$2
OUTPUT_DIR=$3

# Formats of filenames are assumed to be:
### n37_e038_1arc_v3.bil - 1 arc
### N36E036.hgt - 3 arc - This was from another set of 3 arc gap-filled DEMs
### n38_e038_3arc_v2.bil - 3 arc

# Note that all of this data was downloaded using Earth Explorer - 1-arc and 3-arc voidfilled

# Make the output directory if needed
mkdir $OUTPUT_DIR

# Loop through all of the files in ONE_ARC_DIR
for f in $( ls $ONE_ARC_DIR ); do
	# Skip if it's not a .bil file
	extension="${f##*.}"
	if [ $extension != "bil" ]; then
		continue
	fi
	
	echo $f

	# Extract the positions from the filenames
	north=${f:1:2}
	east=${f:5:3}

	# And use the positions to find the correct 3 arc file
	#three_arc_file="N"$north"E"$east".hgt"
	three_arc_file="n"$north"_e"$east"_3arc_v2.bil"

	# Set output file name
	output_file="N"$north"E"$east".tif"

	# Now do the geo-processing 
	# Merge the two DEMs; Notice that we place the 1 arc DEM twice, first because it sets the output resolution, and last because it needs to be overlayed on top:
	gdal_merge.py $ONE_ARC_DIR/$f $THREE_ARC_DIR/$three_arc_file $ONE_ARC_DIR/$f -n -32767 -o temp.tif

	# Create a temporary index to clip to:
	gdaltindex temp.shp $ONE_ARC_DIR/$f

	# Cut the DEM to the bounds of the shapefile
	gdalwarp -cutline temp.shp -crop_to_cutline temp.tif $OUTPUT_DIR/$output_file

	# Remove temporary files
	rm temp.*

done 

