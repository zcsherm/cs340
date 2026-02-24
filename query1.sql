
-- Leave the following query code untouched
DROP PROCEDURE IF EXISTS sp_query1;
DELIMITER //

-- ------- Write your code below this line -----------
CREATE PROCEDURE sp_query1 (IN timeNow VARCHAR(4), OUT greeting VARCHAR(50))
BEGIN
    DECLARE current_hour INT;
    DECLARE formatted_time TIME;
    
    -- Validate input format
    IF LENGTH(timeNow) != 4 OR timeNow NOT REGEXP '^[0-2][0-9][0-5][0-9]$' THEN
        SET greeting = 'Invalid time format. Please use HHMM.';
    ELSE

        -- Convert the input timeNow to TIME format
            SET formatted_time = STR_TO_DATE(timeNow, '%H%i');
        -- Check for valid time range
        IF formatted_time IS NULL THEN
            SET greeting ='Invalid time format. Please use HHMM.';
        END IF;
        -- SET OUTVAR 'greeting' to a string value based on current_hour
            -- e.g. SET greeting = 'Good evening';
        SET current_hour = HOUR(formatted_time);
        IF current_hour >= 6 AND current_hour < 12 THEN
            SET greeting = 'Good morning';
        ELSEIF current_hour >= 12 AND current_hour < 17 THEN
            SET greeting = 'Good afternoon';
        ELSEIF current_hour >= 17 THEN
            SET greeting = 'Good evening';
        ELSE
            SET greeting = 'Good late night';
        END IF;
    END IF;
END //
-- ------- Do not alter query code below this line -----------
DELIMITER ;