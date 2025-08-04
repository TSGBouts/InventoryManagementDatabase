DROP PROCEDURE allocate_inventory

DELIMITER $$

CREATE PROCEDURE allocate_inventory(
    IN p_order_id    INT,
    IN p_product_id  INT,
    IN p_qty         INT
)
BEGIN
    DECLARE done   TINYINT DEFAULT 0;
    DECLARE w_id  INT;
    DECLARE w_qty INT;
    DECLARE take  INT;

    DECLARE cur_ware CURSOR FOR
      SELECT warehouse_id, quantity
        FROM inventories
       WHERE product_id = p_product_id
         AND quantity > 0
       ORDER BY warehouse_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND 
      SET done = 1;

    OPEN cur_ware;
    read_loop: LOOP
      FETCH cur_ware INTO w_id, w_qty;
      IF done THEN 
        LEAVE read_loop; 
      END IF;

      SET take = LEAST(p_qty, w_qty);

      UPDATE inventories
         SET quantity = quantity - take,
             last_updated = NOW()
       WHERE warehouse_id = w_id
         AND product_id   = p_product_id;

      SET p_qty = p_qty - take;
      IF p_qty <= 0 THEN 
        LEAVE read_loop; 
      END IF;
    END LOOP;
    CLOSE cur_ware;
END$$

DELIMITER ;