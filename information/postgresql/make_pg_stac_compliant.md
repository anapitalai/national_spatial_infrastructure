python -m pip install pypgstac[psycopg]

Or can be built locally

git clone https://github.com/stac-utils/pgstac
cd pgstac/pypgstac
python -m pip install .


## Install postgresql-16
## Install postgis
### to get the commandline tools shp2pgsql, raster2pgsql you need to do this
sudo apt install postgis
apt install postgresql-16-postgis-3

apt install postgresql-14-pgrouting
apt install osm2pgrouting

## localDB postgres postgres postgres localhost

## Creating the stac compliant tables
Set up the variables for db connection

export PGHOST=localhost
export PGPORT=5432
export PGUSER=postgres
export PGDATABASE=satellite_stac
export PGPASSWORD=postgres
or pypgstac database create --dsn "postgresql://postgres:postgres@localhost:5432/satellite_stac"
pypgstac migrate
         version


Stac compliant db==========>fastapi=============>titiler(Vizualisation)
