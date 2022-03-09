WITH PORTS AS (
  SELECT
    port_name, port_longitude, port_latitude
  FROM
    `bigquery-public-data.geo_international_ports.world_port_index` 
  --WHERE
   -- country = 'AL'
),
OTHER_PORTS AS (
  SELECT 
    a.port_name, a.port_longitude, a.port_latitude, ST_UNION_AGG(ST_GEOGPOINT(b.port_longitude, b.port_latitude)) AS `other_ports_coord`
  FROM 
    PORTS AS a
  CROSS JOIN 
    PORTS AS b
  WHERE 
    a.port_name != b.port_name AND 
    (a.port_longitude, a.port_latitude) != (b.port_longitude, b.port_longitude)
  GROUP BY 
    a.port_name, a.port_longitude, a.port_latitude
),
COUNTRY_CLOSEST_POINT AS (
  SELECT
    port_name, port_longitude, port_latitude, ST_CLOSESTPOINT(other_ports_coord, ST_GEOGPOINT(port_longitude, port_latitude)) AS `closest_point`
  FROM 
    OTHER_PORTS
  ORDER BY port_name
), 
COUNTRY_CLOSEST_PORT AS (
  SELECT 
    a.port_name, b.port_name AS `closest_name`, ST_DISTANCE(ST_GEOGPOINT(a.port_longitude, a.port_latitude), closest_point) AS `closest_distance`
  FROM 
    COUNTRY_CLOSEST_POINT AS a
  INNER JOIN 
    PORTS AS b
  ON 
    (ST_X(closest_point), ST_Y(closest_point)) = (b.port_longitude, b.port_latitude)
)

SELECT 
  *
FROM 
  COUNTRY_CLOSEST_PORT
ORDER BY 
  port_name