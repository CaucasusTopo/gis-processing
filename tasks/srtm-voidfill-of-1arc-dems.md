# SRTM Voidfill of 1 arc DEMs

### Overview

The task is to take the SRTM 1 Arc DEMs, which have a resolution of ~25m, and merge them with 3 Arc DEMs, which have a resolution of ~90m, to fill the empty spaces in the former so that the resulting DEMs are complete.

The starting point is a set of 1 arc DEMs, some of which have pixels with no value. We have an identical set of 3 arc DEMs which are complete.

This can be done in ArcMap using the Mosaic to New Raster tool. Just make sure that the 1 arc DEM is above the 3 arc in the list, and that the bottom two fields are set to "First". Pixel type should also be set to 16 bit unsigned.

However, the method here was used for processing a large number of DEMs with a script. The filenames follow a standard format, and if that changes, some minor script changes would be required. The main function is the gdal_merge.py function in GDAL, which mosaics images together - the last image being mosaiced on top. 

### Trials

This works, but it gets padded with a few too many pixels...:

gdal_merge.py n40_e041_1arc_v3.bil ../temp3arc/N40E041.hgt n40_e041_1arc_v3.bil -n -32767 -o ../test.tif

The problem is that the original image is 3601x3601 pixels, but because the merged pixels are bigger, it ends up at 3603x3603 pixels. This is no good because those edge pixels are from the 3 arc data, and will cause problems later.

Another option is:

gdal_fillnodata.py n40_e041_1arc_v3.bil test1.tif  

But this is not great because it would work for small gaps, but not the very large gaps in the SRTM data.



