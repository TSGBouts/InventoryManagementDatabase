SET GLOBAL event_scheduler = ON;

DELIMITER $$
CREATE EVENT daily_ship_due_orders
  ON SCHEDULE EVERY 1 DAY
  STARTS CONCAT(DATE_FORMAT(NOW(), '%Y-%m-%d'), ' 00:00:00')
  COMMENT 'Move orders to shipped status 3 days after order_date'
DO
BEGIN
  UPDATE orders
     SET status_id = 2
   WHERE status_id = 1
     AND order_date <= DATE_SUB(NOW(), INTERVAL 3 DAY);
END$$
DELIMITER ;