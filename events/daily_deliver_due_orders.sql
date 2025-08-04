SET GLOBAL event_scheduler = ON;

DELIMITER $$
CREATE EVENT daily_deliver_due_orders
  ON SCHEDULE EVERY 1 DAY
  STARTS CONCAT(DATE_FORMAT(NOW(), '%Y-%m-%d'), ' 00:00:00')
  COMMENT 'Move orders to delivered status 7 days after order_date'
DO
BEGIN
  UPDATE orders
     SET status_id = 3
   WHERE status_id = 2
     AND order_date <= DATE_SUB(NOW(), INTERVAL 7 DAY);
END$$
DELIMITER ;