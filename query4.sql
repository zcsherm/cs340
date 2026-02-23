-- Note: Only use single-line comments in this file.

-- Citation for the following code:
-- Date: 
-- Copied from /OR/ Adapted from /OR/ Based on 
-- (Explain degree of originality)
-- Source URL: 
-- If AI tools were used:
-- (Explain the use of tools and include a summary of the prompts submitted to the AI tool)

-- Leave the following query code untouched
DROP PROCEDURE IF EXISTS sp_insert_person;
DELIMITER //

-- ------- Write your code below this line -----------

CREATE PROCEDURE sp_insert_person(
    IN fname VARCHAR(255),
    IN lname VARCHAR(255),
    IN age INT,
    IN homeworld INT,
    IN cert_id INT,
    OUT person_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- In case of an error, set the person_id to -99
        SET person_id = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    -- Insert into bsg_people table
    INSERT INTO bsg_people (fname, lname, age, homeworld_id)
    VALUES (fname, lname, age, homeworld);
    -- Get the last inserted id
    SET person_id = LAST_INSERT_ID();
    
    -- Insert into bsg_cert_people table
    INSERT INTO bsg_cert_people (pid, cid)
    VALUES (person_id, cert_id);
    COMMIT;
    RETURN person_id;
END //


-- ------- Do not alter query code below this line -----------
DELIMITER ;