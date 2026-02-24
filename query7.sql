
-- Leave the following query code untouched
DROP PROCEDURE  IF EXISTS sp_modify_cert_table;
DELIMITER //

-- ------- Write your code below this line -----------
CREATE PROCEDURE sp_modify_cert_table()
BEGIN
    -- Add the new column cert_total to bsg_cert table
    ALTER TABLE bsg_cert ADD COLUMN cert_total INT DEFAULT 0;

END //


-- ------- Do not alter query code below this line -----------
DELIMITER ;
