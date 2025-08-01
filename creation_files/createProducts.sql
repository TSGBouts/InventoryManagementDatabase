LOAD DATA INFILE '.../ProgramData/MySQL/MySQL Server 8.0/Uploads/products_clean.csv'
INTO TABLE Products
FIELDS TERMINATED BY ','  ENCLOSED BY '"' 
LINES  TERMINATED BY '\n'
IGNORE 1 ROWS
(sku, name, unit_cost, reorder_point, reorder_amount);