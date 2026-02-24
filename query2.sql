
-- Leave the following query code untouched
DROP VIEW  IF EXISTS v_cert_people;

-- ------- Write your code below this line -----------
CREATE VIEW v_cert_people AS
SELECT 
    bsg_cert.title,
    bsg_people.fname,
    bsg_people.lname,
    bsg_planets.name
    -- columns here
FROM 
    bsg_cert_people
JOIN 
    bsg_people ON bsg_people.id = bsg_cert_people.pid
JOIN 
    bsg_cert ON bsg_cert_people.cid = bsg_cert.id
LEFT JOIN 
    bsg_planets ON bsg_people.homeworld = bsg_planets.id
ORDER BY 
    bsg_cert.title;

