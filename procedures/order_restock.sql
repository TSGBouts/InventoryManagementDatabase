DROP PROCEDURE IF EXISTS order_restock;
DELIMITER $$

CREATE PROCEDURE order_restock(
    IN p_supplier_id  INT,
    IN p_warehouse_id INT
)
BEGIN
    DECLARE v_restock_id INT;

    IF EXISTS (
        SELECT 1
          FROM inventories
         WHERE warehouse_id = p_warehouse_id
           AND quantity < 50
    ) THEN

        INSERT INTO restocks (supplier_id, status_id, order_date, expected_date)
        VALUES (p_supplier_id, 1, NOW(), DATE_ADD(NOW(), INTERVAL 1 WEEK));
        SET v_restock_id = LAST_INSERT_ID();

        INSERT INTO restockproducts (restock_id, product_id)
        SELECT v_restock_id, product_id
		FROM inventories
		WHERE warehouse_id = p_warehouse_id
		AND quantity < 50;
    END IF;
END$$

DELIMITER ;