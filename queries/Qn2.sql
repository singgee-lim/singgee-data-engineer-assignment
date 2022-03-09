SELECT
  country, port_name, port_latitude, port_longitude
FROM
  `bigquery-public-data.geo_international_ports.world_port_index` 
WHERE 
  (provisions, water, fuel_oil, diesel) = (true, true, true, true)
ORDER BY
  ST_DISTANCE( ST_GEOGPOINT(-38.706256, 32.610982), ST_GEOGPOINT(port_longitude, port_latitude) ) ASC
LIMIT 1