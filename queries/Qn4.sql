WITH COUNTRY_PORT AS (
  SELECT
    country, port_name, port_longitude, port_latitude
  FROM
    `bigquery-public-data.geo_international_ports.world_port_index` 
),
COUNTRY_OTHER_PORTS AS (
  SELECT a.country, a.port_name, a.port_longitude, a.port_latitude, ST_UNION_AGG(ST_GEOGPOINT(b.port_longitude, b.port_latitude)) AS `other_ports_coord`
  FROM 
    COUNTRY_PORT AS a
  CROSS JOIN 
    COUNTRY_PORT AS b
  WHERE 
    (a.country) = (b.country) AND 
    a.port_name != b.port_name AND 
    (a.port_longitude, a.port_latitude) != (b.port_longitude, b.port_longitude)
  GROUP BY a.country, a.port_name, a.port_longitude, a.port_latitude
),
COUNTRY_CLOSEST_POINT AS (
  SELECT
    country, port_name, port_longitude, port_latitude, ST_CLOSESTPOINT(other_ports_coord, ST_GEOGPOINT(port_longitude, port_latitude)) AS `closest_point`
  FROM 
    COUNTRY_OTHER_PORTS
  --WHERE 
  --  country = 'AG'
  ORDER BY country, port_name
), COUNTRY_CLOSEST_PORT AS (
  SELECT 
    a.country, a.port_name,-- ST_GEOGPOINT(a.port_longitude, a.port_latitude) AS `port_coord`, 
    b.port_name AS `closest_port_name`, --closest_point AS `closest_port_coord`,
    ST_DISTANCE(ST_GEOGPOINT(a.port_longitude, a.port_latitude), closest_point) AS `closest_port_distance`
  FROM 
    COUNTRY_CLOSEST_POINT AS a
  INNER JOIN 
    COUNTRY_PORT AS b
  ON 
    (a.country, ST_X(closest_point), ST_Y(closest_point)) = (b.country, b.port_longitude, b.port_latitude)
)

SELECT country, AVG(closest_port_distance) AS `average_closest_distance`, MAX(closest_port_distance) AS `max_distance`
FROM COUNTRY_CLOSEST_PORT
GROUP BY country
ORDER BY country
