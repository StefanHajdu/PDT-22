select name, way from planet_osm_polygon where admin_level='4';

CREATE EXTENSION postgis;

CREATE TABLE bus_stops (
  bus_stop_id SERIAL PRIMARY KEY,
  geom Geometry(Point)
);

CREATE TABLE cities (
  city_id SERIAL PRIMARY KEY,
  name VARCHAR(150),
  geom Geometry(Polygon)
);

INSERT INTO bus_stops (geom) VALUES ('POINT(1 2)');
INSERT INTO bus_stops (geom) VALUES ('POINT(1 3)');
INSERT INTO bus_stops (geom) VALUES ('POINT(2 3)');
INSERT INTO bus_stops (geom) VALUES ('POINT(7 10)');
INSERT INTO bus_stops (geom) VALUES ('POINT(10 10)');

-- Create one city boundary (shaped like a square)
INSERT INTO cities (geom) VALUES ('POLYGON((0 0, 5 0, 5 5, 0 5, 0 0))');

select * from cities;

select 
	c.city_id,
	count(*) as count
from
	bus_stops b
join
	cities c
on
	ST_Contains(c.geom, b.geom)
group by
	c.city_id;

CREATE TABLE geometries (name varchar, geom geometry);

INSERT INTO geometries VALUES
  ('Point', 'POINT(0 0)'),
  ('Linestring', 'LINESTRING(0 0, 1 1, 2 1, 2 2)'),
  ('Polygon', 'POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))'),
  ('PolygonWithHole', 'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0),(1 1, 1 2, 2 2, 2 1, 1 1))'),
  ('Collection', 'GEOMETRYCOLLECTION(POINT(2 0),POLYGON((0 0, 1 0, 1 1, 0 1, 0 0)))');
  
  
SELECT name, ST_AsText(geom) FROM geometries;

SELECT * FROM geometry_columns;

SELECT name, ST_GeometryType(geom), ST_NDims(geom), ST_SRID(geom) FROM geometries;

SELECT ST_AsText(ST_EndPoint(geom))
  FROM geometries
  WHERE name = 'Linestring';
  
  
SELECT geom
  FROM geometries
  WHERE name LIKE 'Polygon%';
  
SELECT name, ST_Area(geom)
  FROM geometries
  WHERE name LIKE 'Polygon%';
  
  
SELECT 'SRID=4326;POINT(0 0)'::geometry;


PROJCS["WGS 84 / Pseudo-Mercator",
GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],
AUTHORITY["EPSG","6326"]],
PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],
UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],
AUTHORITY["EPSG","4326"]],
PROJECTION["Mercator_1SP"],
PARAMETER["central_meridian",0],
PARAMETER["scale_factor",1],
PARAMETER["false_easting",0],
PARAMETER["false_northing",0],
UNIT["metre",1,AUTHORITY["EPSG","9001"]],
AXIS["X",EAST],
AXIS["Y",NORTH],
EXTENSION["PROJ4","+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs"],
AUTHORITY["EPSG","3857"]]


-- Solutions

SELECT name, ST_AsText(
    ST_Transform(way, 4326)
    )
  FROM planet_osm_polygon WHERE admin_level='4';

SELECT name, ST_Area(ST_Transform(way, 26986))/1000000 FROM planet_osm_polygon WHERE admin_level='4';

Prvá Kúpeľná a.s.
POLYGON ((
2302057.7591829714 6325078.281305717,
2302071.607327626 6325065.769548367,
2302090.0418353016 6325087.1402556645,
2302089.0622237823 6325088.044927377,
2302107.029189597 6325109.193790076,
2302106.1386336703 6325110.115533483,
2302123.8050368596 6325131.622908357,
2302122.803161442 6325132.3398218,
2302141.2154052192 6325154.1032946715,
2302126.677079722 6325166.751738889,
2302108.3093637405 6325145.005302693,
2302109.4002947505 6325144.1176942475,
2302091.4667247836 6325122.388385903,
2302092.401808507 6325121.4666411495,
2302075.058231841 6325100.5396485515,
2302075.9487877674 6325099.822737818,
2302057.7591829714 6325078.281305717
))

StefanHome: Latitude/Longtitude POLYGON nodes:
  48.2443337 18.3104035,
  48.2443232 18.3103985,
  48.2443061 18.3104750,
  48.2442041 18.3104265,
  48.2442253 18.3103236,
  48.2442404 18.3103302,
  48.2442545 18.3102629,
  48.2443532 18.3103097,
  48.2443337 18.3104035

StefanHome Longtitude/Latitude POLYGON nodes:
   18.3104035 48.2443337, 
   18.3103985 48.2443232, 
   18.3104750 48.2443061, 
   18.3104265 48.2442041, 
   18.3103236 48.2442253, 
   18.3103302 48.2442404, 
   18.3102629 48.2442545, 
   18.3103097 48.2443532, 
   18.3104035 48.2443337



SELECT DISTINCT ST_SRID(way) FROM planet_osm_point;