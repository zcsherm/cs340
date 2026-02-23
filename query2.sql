-- Note: Only use single-line comments in this file.

-- Citation for the following code:
-- Date: 
-- Copied from /OR/ Adapted from /OR/ Based on 
-- (Explain degree of originality)
-- Source URL: 
-- If AI tools were used:
-- (Explain the use of tools and include a summary of the prompts submitted to the AI tool)


-- Leave the following query code untouched
DROP VIEW  IF EXISTS v_cert_people;

-- ------- Write your code below this line -----------
CREATE VIEW v_cert_people AS
SELECT 
    bsg_cert.title AS "Certificate Title",
    bsg_people.fname AS "First Name",
    bsg_people.lname AS "Last Name",
    bsg_planets.name AS "Homeworld"
    -- columns here
FROM 
    bsg_cert_people
JOIN 
    bsg_people ON bsg_people.id = bsg_cert_people.pid
JOIN 
    bsg_cert ON bsg_cert_people.cid = bsg_cert.id
LEFT JOIN 
    bsg_planets ON bsg_people.homeworld_id = bsg_planets.id
ORDER BY 
    bsg_cert.title

