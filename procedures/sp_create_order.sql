DROP PROCEDURE create_order;

DELIMITER $$

CREATE PROCEDURE create_order (p_customer_id INT, p_coupon_id INT, p_products_json JSON)

BEGIN
	DECLARE v_order_id INT;
    DECLARE v_low_stock INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

START TRANSACTION;

SELECT jt.product_id, jt.qty
FROM JSON_TABLE(p_products_json, 
				'$[*]' COLUMNS (
                    product_id INT PATH '$.id',
                    qty        INT PATH '$.qty')
               ) AS jt;

SELECT COUNT(*) INTO v_low_stock
FROM JSON_TABLE(
        p_products_json,
        '$[*]' COLUMNS (
            product_id INT PATH '$.id',
            qty        INT PATH '$.qty'
        )
     ) AS jt
WHERE NOT EXISTS (
        SELECT 1
        FROM inventories i
        WHERE i.product_id = jt.product_id
		AND jt.qty > (SELECT COALESCE(SUM(i.quantity), 0)
					  FROM   inventories i
					  WHERE  i.product_id = jt.product_id)
	);
      
IF v_low_stock > 0 THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough inventory to complete order';
END IF;

IF p_customer_id IS NULL THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'customer_id is mandatory';
    ROLLBACK;
END IF;

IF coupon_id NOT IN (NULL, 1, 2, 3, 4, 5) THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Invalid coupon_id';
    ROLLBACK;
END IF;	

INSERT INTO ORDERS (customer_id, order_date, expected_date, status_id, coupon_id)
VALUES (p_customer_id, NOW(), DATE_ADD(NOW(), INTERVAL 1 WEEK), 1, p_coupon_id);
SET v_order_id := LAST_INSERT_ID();

INSERT INTO orderproducts (order_id, product_id, quantity)
SELECT v_order_id, jt.product_id, jt.qty
FROM JSON_TABLE(p_products_json,
				'$[*]' COLUMNS (
					product_id INT PATH '$.id',
                    qty        INT PATH '$.qty')
               ) AS jt;

CALL allocate_inventory(v_order_id, jt.product_id, jt.qty);

    COMMIT;
END$$

DELIMITER ;