
-- Leave the following query code untouched
DROP PROCEDURE IF EXISTS sp_update_cert_count_totals;
DELIMITER //

-- ------- Write your code below this line -----------
CREATE PROCEDURE sp_update_cert_count_totals()
BEGIN
    -- Update the cert_total column with the count of people holding each certificate
    UPDATE bsg_cert 
    SET cert_total = (
        SELECT COUNT(*) 
        FROM bsg_cert_people 
        WHERE bsg_cert_people.cid = bsg_cert.id
    );

END //


-- ------- Do not alter query code below this line -----------
DELIMITER ;