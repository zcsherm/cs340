-- Note: Only use single-line comments in this file.

-- Citation for the following code:
-- Date: 
-- Copied from /OR/ Adapted from /OR/ Based on 
-- (Explain degree of originality)
-- Source URL: 
-- If AI tools were used:
-- (Explain the use of tools and include a summary of the prompts submitted to the AI tool)


-- Leave the following query code untouched
DROP PROCEDURE IF EXISTS sp_delete_cert_person_update_total;
DELIMITER //

-- ------- Write your code below this line -----------
CREATE PROCEDURE sp_delete_cert_person_update_total (
    IN input_cid INT,
    IN input_pid INT
)
BEGIN
    -- Declare a variable to store the number of rows affected by the DELETE

    -- Attempt to delete the row with the specified cid and pid

    -- Get the number of rows affected by the DELETE

    -- Check if the DELETE was successful
    IF rows_affected > 0 THEN
        CALL sp_update_cert_count_totals();
        -- Return single combined success message
        SELECT 'cert deleted and cert count total updated' AS message;
    ELSE
        -- Return error message
        SELECT 'Delete error!' AS message;
    END IF;
END //


-- ------- Do not alter query code below this line -----------
DELIMITER ;