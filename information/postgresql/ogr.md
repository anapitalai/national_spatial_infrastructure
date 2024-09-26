ogr2ogr \
  -nln osm_buildings \
  -nlt PROMOTE_TO_MULTI \
  -lco GEOMETRY_NAME=geom \
  -lco FID=gid \
  -lco PRECISION=NO \
  Pg:"dbname=app host=localhost user=postgres port=5432" \
  gis_osm_buildings_a_free_1.shp
