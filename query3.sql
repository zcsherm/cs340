
-- Leave the following query code untouched
Drop TABLE IF EXISTS diag_function_cert_use;
CREATE TABLE diag_function_cert_use (
    used INT DEFAULT 0
);

INSERT INTO diag_function_cert_use (used) VALUES (0)
ON DUPLICATE KEY UPDATE used = used;

DELIMITER //
DROP FUNCTION  IF EXISTS func_cert_count;

-- ------- Write your code below this line -----------
CREATE FUNCTION func_cert_count(cert_title VARCHAR(255)) 
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE cert_count INT;

    -- SELECT query to get the certificate count
    SELECT COUNT(*) INTO cert_count
    FROM bsg_cert_people
    JOIN bsg_cert ON bsg_cert_people.cid = bsg_cert.id
    WHERE bsg_cert.title = cert_title;
    -- Increment the used attribute
    UPDATE diag_function_cert_use SET used = used + 1;
    RETURN cert_count;
END //


-- ------- Do not alter query code below this line -----------
DELIMITER ;