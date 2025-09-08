# Ingesting Sentinel-2 Data for Papua New Guinea into PostgreSQL/PostGIS

This guide explains how to download, process, and load Sentinel-2 satellite imagery for Papua New Guinea into a PostgreSQL/PostGIS database, making it STAC-compliant.

## Prerequisites
- PostgreSQL with PostGIS extension enabled
- Sufficient disk space and RAM
- Python 3.x
- GDAL, rasterio, and pystac libraries
- SentinelHub or Copernicus Open Access Hub account (optional)

## 1. Download Sentinel-2 Data

### Using SentinelHub or Copernicus Open Access Hub
- Register and obtain API credentials
- Use `sentinelhub-py` or `sentinelsat` to search and download imagery

#### Example: Download with sentinelsat
```bash
pip install sentinelsat
sentinelsat --user <username> --password <password> \
  --area "Papua New Guinea" --sentinel 2 --cloud 20 \
  --start 2025-01-01 --end 2025-01-31 \
  --download
```

## 2. Preprocess Data
- Unzip downloaded SAFE files
- Use GDAL/rasterio to convert JP2 bands to GeoTIFF or COG
- Reproject to EPSG:4326 if needed
- Clip to Papua New Guinea boundary (use a shapefile or GeoJSON)

#### Example: Convert and Clip with GDAL
```bash
gdalwarp -t_srs EPSG:4326 -cutline png_boundary.shp -crop_to_cutline \
  input.jp2 output.tif
```

## 3. Prepare STAC Metadata
- Use pystac to create STAC Item and Collection metadata
- Include asset links to processed GeoTIFFs
- Add spatial/temporal extent, cloud cover, and other properties

#### Example: Create STAC Item
```python
import pystac
item = pystac.Item(
    id="S2A_20250101T000000",
    geometry=png_geometry,
    bbox=png_bbox,
    datetime="2025-01-01T00:00:00Z",
    properties={"cloud_cover": 10}
)
item.add_asset("B04", pystac.Asset(href="output_B04.tif", media_type=pystac.MediaType.GEOTIFF))
item.add_asset("B08", pystac.Asset(href="output_B08.tif", media_type=pystac.MediaType.GEOTIFF))
item.validate()
```

## 4. Load Data into PostgreSQL/PostGIS
- Use raster2pgsql for raster data
- Use ogr2ogr for vector metadata
- Insert STAC metadata into dedicated tables

#### Example: Load Raster
```bash
raster2pgsql -s 4326 -I -C -M output.tif public.sentinel2_rasters | psql -U <user> -d <db>
```

#### Example: Load STAC Metadata
```bash
ogr2ogr -f "PostgreSQL" PG:"dbname=<db> user=<user>" stac_items.geojson -nln public.stac_items
```

## 5. Make Database STAC-Compliant
- Create tables: collections, items, assets, links
- Add spatial indexes
- Ensure metadata follows STAC spec

#### Example: Table Schema
```sql
CREATE TABLE public.stac_items (
    id VARCHAR PRIMARY KEY,
    geometry GEOMETRY(POLYGON, 4326),
    bbox FLOAT8[],
    datetime TIMESTAMP,
    properties JSONB
);
CREATE INDEX stac_items_geom_idx ON public.stac_items USING GIST (geometry);
```

## 6. Query and Visualize
- Use SQL to query by date, cloud cover, location
- Connect QGIS or other GIS tools to visualize
- Build APIs for web access

## References
- [STAC Specification](https://stacspec.org/)
- [Copernicus Open Access Hub](https://scihub.copernicus.eu/)
- [SentinelHub](https://www.sentinel-hub.com/)
- [pystac Documentation](https://pystac.readthedocs.io/)
- [GDAL Documentation](https://gdal.org/)

---

# Ingesting Landsat 8 Data for Papua New Guinea into PostgreSQL/PostGIS

This section explains how to download, process, and load Landsat 8 imagery for Papua New Guinea into a PostgreSQL/PostGIS database, making it STAC-compliant.

## Prerequisites
- PostgreSQL with PostGIS extension enabled
- Sufficient disk space and RAM
- Python 3.x
- GDAL, rasterio, and pystac libraries
- USGS EarthExplorer or AWS account (optional)

## 1. Download Landsat 8 Data

### Using USGS EarthExplorer or AWS Open Data
- Register and obtain API credentials (EarthExplorer)
- Use `landsatxplore` or AWS CLI to search and download imagery

#### Example: Download with landsatxplore
```bash
pip install landsatxplore
landsatxplore search --username <username> --password <password> \
  --lat  -6.0 --lon 145.0 --start 2025-01-01 --end 2025-01-31 \
  --cloud 20 --dataset LANDSAT_8_C1
landsatxplore download <scene_id> --output ./landsat8_data
```

#### Example: Download from AWS
```bash
aws s3 cp s3://landsat-pds/c1/L8/scene_id/ . --recursive
```

## 2. Preprocess Data
- Unzip downloaded files
- Use GDAL/rasterio to convert bands to GeoTIFF or COG
- Reproject to EPSG:4326 if needed
- Clip to Papua New Guinea boundary (use a shapefile or GeoJSON)

#### Example: Convert and Clip with GDAL
```bash
gdalwarp -t_srs EPSG:4326 -cutline png_boundary.shp -crop_to_cutline \
  LC08_L1TP_XXX_B4.TIF output_B4.tif
```

## 3. Prepare STAC Metadata
- Use pystac to create STAC Item and Collection metadata
- Include asset links to processed GeoTIFFs
- Add spatial/temporal extent, cloud cover, and other properties

#### Example: Create STAC Item
```python
import pystac
item = pystac.Item(
    id="L8_20250101T000000",
    geometry=png_geometry,
    bbox=png_bbox,
    datetime="2025-01-01T00:00:00Z",
    properties={"cloud_cover": 15}
)
item.add_asset("B4", pystac.Asset(href="output_B4.tif", media_type=pystac.MediaType.GEOTIFF))
item.add_asset("B5", pystac.Asset(href="output_B5.tif", media_type=pystac.MediaType.GEOTIFF))
item.validate()
```

## 4. Load Data into PostgreSQL/PostGIS
- Use raster2pgsql for raster data
- Use ogr2ogr for vector metadata
- Insert STAC metadata into dedicated tables

#### Example: Load Raster
```bash
raster2pgsql -s 4326 -I -C -M output_B4.tif public.landsat8_rasters | psql -U <user> -d <db>
```

#### Example: Load STAC Metadata
```bash
ogr2ogr -f "PostgreSQL" PG:"dbname=<db> user=<user>" landsat8_items.geojson -nln public.stac_items
```

## 5. Make Database STAC-Compliant
- Create tables: collections, items, assets, links (reuse Sentinel-2 schema)
- Add spatial indexes
- Ensure metadata follows STAC spec

## 6. Query and Visualize
- Use SQL to query by date, cloud cover, location
- Connect QGIS or other GIS tools to visualize
- Build APIs for web access

## References
- [USGS EarthExplorer](https://earthexplorer.usgs.gov/)
- [AWS Landsat Open Data](https://registry.opendata.aws/landsat-8/)
- [landsatxplore Documentation](https://landsatxplore.readthedocs.io/)
- [pystac Documentation](https://pystac.readthedocs.io/)
- [GDAL Documentation](https://gdal.org/)
