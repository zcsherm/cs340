
-- Leave the following query code untouched
DROP PROCEDURE IF EXISTS sp_add_person_certification;
DELIMITER //

-- ------- Write your code below this line -----------
CREATE PROCEDURE sp_add_person_certification (
    IN person_id INT,
    IN cert_id INT
)
BEGIN
    DECLARE cert_exists INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction in case of an error
        ROLLBACK;
        -- Return -99 to indicate an error
        SELECT -99 AS cert_count;
    END;

    -- Start a transaction
    START TRANSACTION;

    -- Check if the certification exists
    SELECT COUNT(*) INTO cert_exists FROM bsg_cert WHERE id = cert_id;
    IF cert_exists = 0 THEN
        ROLLBACK;
        SELECT -99 AS cert_count;
    ELSE
        -- If the certification exists, insert the new certification for the person
        INSERT INTO bsg_cert_people (pid, cid)
        VALUES (person_id, cert_id);

        -- Commit the transaction
        COMMIT;

        -- Return the count of people with the new certification
        SELECT func_cert_count((SELECT title FROM bsg_cert WHERE id = cert_id)) AS cert_count;
    END IF;
END //


-- ------- Do not alter query code below this line -----------
DELIMITER ;