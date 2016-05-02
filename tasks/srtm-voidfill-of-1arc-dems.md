# SRTM Voidfill of 1 arc DEMs

### Overview

The task is to take the SRTM 1 Arc DEMs, which have a resolution of ~25m, and merge them with 3 Arc DEMs, which have a resolution of ~90m, to fill the empty spaces in the former so that the resulting DEMs are complete.

The starting point is a set of 1 arc DEMs, some of which have pixels with no value. We have an identical set of 3 arc DEMs which are complete.

This can be done in ArcMap using the Mosaic to New Raster tool. Just make sure that the 1 arc DEM is above the 3 arc in the list, and that the bottom two fields are set to "First". Pixel type should also be set to 16 bit unsigned. The resulting DEM may have extra pixels around the edge, since the 3 arc DEM is typically a little bit bigger. So then you must run the Clip tool, clipping the new DEM to the bounds of the original 1 arc DEM.

However, the method here was used for processing a large number of DEMs with a script. The filenames follow a standard format, and if that changes, some minor script changes would be required. The main function is the gdal_merge.py function in GDAL, which mosaics images together - the last image being mosaiced on top. 

### Trials

#### gdal_fillnodata.py

One option is:

gdal_fillnodata.py n40_e041_1arc_v3.bil test.tif  

But this is not great because it would work for small gaps, but not the very large gaps in the SRTM data.

#### gdal_merge.py

This works, but it gets padded with a few too many pixels...:

gdal_merge.py n40_e041_1arc_v3.bil ../temp3arc/N40E041.hgt n40_e041_1arc_v3.bil -n -32767 -o ../test.tif

The problem is that the original image is 3601x3601 pixels, but because the merged pixels are bigger, it ends up at 3603x3603 pixels. This is no good because those edge pixels are from the 3 arc data, and will cause problems later.

We can then clip this back to original size by first creating a shapefile of the original bounds, and then clipping the output DEM to the shapefile bounds. For example:

gdaltindex test.shp n40_e041_1arc_v3.bil
gdalwarp -cutline test.shp -crop_to_cutline ../test.tif ../test-clipped.tif

### End results:

The final steps look like this:

	# Merge the two DEMs; Notice that we place the 1 arc DEM twice, first because it sets the output resolution, and last because it needs to be overlayed on top:
	gdal_merge.py temp1arc/n40_e041_1arc_v3.bil temp3arc/N40E041.hgt temp1arc/n40_e041_1arc_v3.bil -n -32767 -o temp.tif

	# Create a temporary index to clip to:
	gdaltindex temp.shp temp1arc/n40_e041_1arc_v3.bil

	# Cut the DEM to the bounds of the shapefile
	gdalwarp -cutline temp.shp -crop_to_cutline temp.tif output.tif

We have created a bash script for this to work for the Caucasus DEMs, which follows the naming pattern of the DEMs we have. It is located in scripts/srtm-voidfill-of-1arc-dems.sh

