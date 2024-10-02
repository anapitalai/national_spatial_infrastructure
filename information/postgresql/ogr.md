ogr2ogr \
  -nln osm_buildings \
  -nlt PROMOTE_TO_MULTI \
  -lco GEOMETRY_NAME=geom \
  -lco FID=gid \
  -lco PRECISION=NO \
  Pg:"dbname=app host=localhost user=postgres port=5432" \
  gis_osm_buildings_a_free_1.shp


ogr2ogr -f "ESRI Shapefile" mydata.shp PG:"host=170.64.179.236 user=app dbname=app password=e9DLDNCdRDkOjkzw8fZXDP0llk93EyAiOqgyW2QUYQj04pKCgMxy0HuUitn3WqMO" "buildings"

ogr2ogr -f "PostgreSQL" PG:"host=170.64.179.236 user=app dbname=app password=e9DLDNCdRDkOjkzw8fZXDP0llk93EyAiOqgyW2QUYQj04pKCgMxy0HuUitn3WqMO port=5432" gis_osm_landuse_a_free_1.shp -skipfailures


https://www.bostongis.com/PrinterFriendly.aspx?content_name=ogr_cheatsheet
