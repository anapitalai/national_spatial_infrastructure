conda create --name gdal
conda activate gdal
conda install -c conda-forge gdal
conda update -n base -c conda-forge conda

## install libgdal/libgdal-core/libpdal
https://quansight.com/post/introducing-lightweight-versions-of-gdal-and-pdal/


raster2pgsql -s 4326 -I -M -C MarkhamRiverDem.tif -F | psql -d app -h 170.64.179.236 -U app -p 5432