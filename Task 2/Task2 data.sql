-- create a table named 'Voyages in the Schema 'task2'
CREATE TABLE task2.voyages (
    id INT,                             -- Unique identifier for each of the event
    event VARCHAR(50),                  -- Type of the event
    dateStamp INT,                      -- Occuring date of the event in serialized date format
    timeStamp FLOAT,                    -- Occuring time of the event in decimal hours
    voyage_From VARCHAR(50),            -- Port from which the voyage begin
    lat DECIMAL(9,6),                   -- Latitude of the vessel at the time of the event 
    lon DECIMAL(9,6),                   -- Longitude of the vessel at the time of the event
    imo_num VARCHAR(20),                -- A unique identifer of vessels/ships
    voyage_Id VARCHAR(20),              -- Voyage Identifier
    allocatedVoyageId VARCHAR(20)       -- Allocatedvoyage identifier
);

INSERT INTO voyages VALUES              -- Inserting the data into the voyages table
(1, 'SOSP', 43831, 0.708333, 'Port A', 34.0522, -118.2437, '9434761', '6', NULL),   -- row1
(2, 'EOSP', 43832, 0.333333, 'Port B', 36.7783, -119.4179, '9434761', '6', NULL),   -- row2
(3, 'SOSP', 43832, 0.583333, 'Port B', 36.7783, -119.4179, '9434761', '6', NULL),   -- row3
(4, 'EOSP', 43833, 0.123333, 'Port C', 36.1716, -115.1391, '9434761', '6', NULL),   -- row4
(5, 'SOSP', 43833, 0.693333, 'Port C', 36.1716, -115.1391, '9434761', '6', NULL),   -- row5
(6, 'EOSP', 43834, 0.583333, 'Port A', 34.0522, -118.2437, '9434761', '6', NULL);   -- row6
