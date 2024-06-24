-- Drop the temporary tables if they alreaady exists
DROP TEMPORARY TABLE IF EXISTS tmp_voyage_events;
DROP TEMPORARY TABLE IF EXISTS tmp_voyage_segments;

-- Create the first temporary table to store voyage events with calculated fields
CREATE TEMPORARY TABLE tmp_voyage_events AS
SELECT
    id,
    event,
    -- Calculate the event timestamp in UTC from the given format
    DATE_ADD('1900-01-01', INTERVAL dateStamp DAY) + INTERVAL timeStamp * 24 HOUR AS event_utc,
    voyage_From,
    lat,
    lon,
    imo_num,
    voyage_Id,
    allocatedVoyageId,
    -- Use window functions to do the caluculations based on the previous event, ordered by the event_utc timestamp
    LAG(event) OVER (ORDER BY DATE_ADD('1900-01-01', INTERVAL dateStamp DAY) + INTERVAL timeStamp * 24 HOUR) AS prev_event,
    LAG(DATE_ADD('1900-01-01', INTERVAL dateStamp DAY) + INTERVAL timeStamp * 24 HOUR) OVER (ORDER BY DATE_ADD('1900-01-01', INTERVAL dateStamp DAY) + INTERVAL timeStamp * 24 HOUR) AS prev_event_utc,
    LAG(voyage_From) OVER (ORDER BY DATE_ADD('1900-01-01', INTERVAL dateStamp DAY) + INTERVAL timeStamp * 24 HOUR) AS prev_voyage_From,
    LAG(lat) OVER (ORDER BY DATE_ADD('1900-01-01', INTERVAL dateStamp DAY) + INTERVAL timeStamp * 24 HOUR) AS prev_lat,
    LAG(lon) OVER (ORDER BY DATE_ADD('1900-01-01', INTERVAL dateStamp DAY) + INTERVAL timeStamp * 24 HOUR) AS prev_lon
FROM voyages
WHERE imo_num = '9434761'  -- Specify the IMO number for the vessel
  AND voyage_Id = '6'      -- Specify the voyage ID
  AND allocatedVoyageId IS NULL;

-- Create a second temporary table to store the voyage segments
CREATE TEMPORARY TABLE tmp_voyage_segments AS
SELECT
    id,
    event,
    event_utc,
    voyage_From,
    lat,
    lon,
    prev_event,
    prev_event_utc,
    prev_voyage_From,
    -- Calculate the distance covered by the ship between two ports from a SOSP event to an EOSP evemt
    CASE
        WHEN event = 'EOSP' THEN 2 * 6371 * ASIN(SQRT(POWER(SIN(RADIANS(lat - prev_lat) / 2), 2) + COS(RADIANS(prev_lat)) * COS(RADIANS(lat)) * POWER(SIN(RADIANS(lon - prev_lon) / 2), 2)))
        ELSE NULL
    END AS distance_km,
    -- Calculate the Sailing time between the two ports from a SOSP event to an EOSP event
    CASE
        WHEN event = 'EOSP' THEN TIMESTAMPDIFF(HOUR, prev_event_utc, event_utc)
        ELSE NULL
    END AS sailing_time_hours,
    -- Calculate the Port stay duration at a port from an EOSP event to SOSP event
    CASE
        WHEN event = 'SOSP' THEN TIMESTAMPDIFF(MINUTE, prev_event_utc, event_utc) / 1440.0
        ELSE NULL
    END AS port_stay_duration_days,
    -- Assign a voyage segment ID based on SOSP and EOSP events
    SUM(CASE WHEN event = 'SOSP' THEN 1 ELSE 0 END) OVER (ORDER BY event_utc) AS segment_id
FROM tmp_voyage_events
WHERE event IN ('SOSP', 'EOSP');

-- Final select to get the required fields and convert distancesfrom kilometers to nautical miles
SELECT
    segment_id,
    id,
    event,
    event_utc,
    voyage_From,
    prev_event,
    prev_event_utc,
    prev_voyage_From,
    lat AS current_lat,
    lon AS current_lon,
    sailing_time_hours AS sailing_time,
    port_stay_duration_days AS port_stay_duration,
    -- Conversion of distances from kms to nautical miles
    CASE
        WHEN distance_km IS NOT NULL THEN distance_km * 0.539957
        ELSE NULL
    END AS distance_travelled
FROM tmp_voyage_segments
ORDER BY segment_id, event_utc;
