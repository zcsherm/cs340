
-- Leave the following query code untouched
DROP PROCEDURE IF EXISTS sp_update_person_homeworld;
DELIMITER //

-- ------- Write your code below this line -----------
CREATE PROCEDURE sp_update_person_homeworld(
    IN person_id INT,
    IN myworld VARCHAR(255)
)
BEGIN
    DECLARE world_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Update error!' AS result;
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    -- Handle NULL input
    IF myworld IS NULL THEN
        UPDATE bsg_people SET homeworld = NULL WHERE id = person_id;
    ELSE
        -- Check if myworld is an integer
        IF myworld REGEXP '^[0-9]+$' THEN
            SET world_id = CAST(myworld AS UNSIGNED);
            
            -- Check if world_id exists as a planet, if so, update bsg_people
            IF EXISTS (SELECT 1 FROM bsg_planets WHERE id = world_id) THEN
                UPDATE bsg_people SET homeworld = world_id WHERE id = person_id;
            ELSE
                -- If the planet does not exist, rollback and return error
                ROLLBACK;
                SELECT 'Update error!' AS result;
            END IF;

        ELSE
            -- myworld is assumed to be a name, therefore proceed:
            -- Get the ID value of a planet with the name matching myworld's value
            SELECT id INTO world_id FROM bsg_planets WHERE name = myworld;
            -- Update the person's homeworld in bsg_people
            UPDATE bsg_people SET homeworld = world_id WHERE id = person_id;
        END IF;
    END IF;
    
    -- Return the updated person's details
    SELECT 
        p.fname,
        p.lname,
        CASE WHEN p.age IS NULL THEN 'NULL' ELSE CAST(p.age AS CHAR) END as age,
        CASE WHEN pl.name IS NULL THEN 'NULL' ELSE pl.name END as homeworld
    FROM bsg_people p
    LEFT JOIN bsg_planets pl ON p.homeworld = pl.id
    WHERE p.id = person_id;
    
    COMMIT;
END //


-- ------- Do not alter query code below this line -----------
DELIMITER ;