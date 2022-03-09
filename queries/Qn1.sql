SELECT 
  country, COUNT(cargo_wharf) AS `port_count`
FROM 
  `bigquery-public-data.geo_international_ports.world_port_index` 
WHERE 
  cargo_wharf = true
GROUP BY country
ORDER BY country DESC
LIMIT 1