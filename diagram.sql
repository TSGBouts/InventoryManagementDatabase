-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema InventoryControlManagement
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema InventoryControlManagement
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `InventoryControlManagement` DEFAULT CHARACTER SET utf8 ;
USE `InventoryControlManagement` ;

-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`Customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`Customers` (
  `customer_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `phone_number` VARCHAR(45) NOT NULL,
  `address` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE INDEX `phone_number_UNIQUE` (`phone_number` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`Statuses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`Statuses` (
  `status_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`status_id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`Coupons`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`Coupons` (
  `coupon_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `coupon_code` CHAR(10) NOT NULL,
  `discount` DECIMAL(3,2) UNSIGNED NOT NULL,
  PRIMARY KEY (`coupon_id`),
  UNIQUE INDEX `coupon_code_UNIQUE` (`coupon_code` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`Shippers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`Shippers` (
  `shipper_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`shipper_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`Orders` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `order_date` DATETIME NOT NULL,
  `expected_date` DATETIME NOT NULL,
  `arrived_date` DATETIME NULL,
  `status_id` INT NOT NULL,
  `coupon_id` INT NULL,
  `shipper_id` INT NULL,
  PRIMARY KEY (`order_id`),
  INDEX `fk_Orders_Customers_idx` (`customer_id` ASC) VISIBLE,
  INDEX `fk_Orders_Statuses1_idx` (`status_id` ASC) VISIBLE,
  INDEX `fk_Orders_Coupons1_idx` (`coupon_id` ASC) VISIBLE,
  INDEX `fk_Orders_Shippers1_idx` (`shipper_id` ASC) VISIBLE,
  CONSTRAINT `fk_Orders_Customers`
    FOREIGN KEY (`customer_id`)
    REFERENCES `InventoryControlManagement`.`Customers` (`customer_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Orders_Statuses1`
    FOREIGN KEY (`status_id`)
    REFERENCES `InventoryControlManagement`.`Statuses` (`status_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Orders_Coupons1`
    FOREIGN KEY (`coupon_id`)
    REFERENCES `InventoryControlManagement`.`Coupons` (`coupon_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Orders_Shippers1`
    FOREIGN KEY (`shipper_id`)
    REFERENCES `InventoryControlManagement`.`Shippers` (`shipper_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`Products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`Products` (
  `product_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `sku` VARCHAR(45) NOT NULL,
  `unit_cost` DECIMAL(7,2) UNSIGNED NOT NULL,
  `reorder_point` INT NOT NULL,
  `reorder_quantity` INT NOT NULL,
  PRIMARY KEY (`product_id`),
  UNIQUE INDEX `sku_UNIQUE` (`sku` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`OrderProducts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`OrderProducts` (
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `quantity` INT UNSIGNED NOT NULL,
  INDEX `fk_OrderProducts_Orders1_idx` (`order_id` ASC) VISIBLE,
  PRIMARY KEY (`order_id`, `product_id`),
  INDEX `fk_OrderProducts_Products1_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_OrderProducts_Orders1`
    FOREIGN KEY (`order_id`)
    REFERENCES `InventoryControlManagement`.`Orders` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_OrderProducts_Products1`
    FOREIGN KEY (`product_id`)
    REFERENCES `InventoryControlManagement`.`Products` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`Warehouses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`Warehouses` (
  `warehouse_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  `city` VARCHAR(255) NOT NULL,
  `country` VARCHAR(45) NOT NULL,
  `capacity` INT NOT NULL,
  PRIMARY KEY (`warehouse_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`Inventories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`Inventories` (
  `warehouse_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `quantity` INT UNSIGNED NOT NULL,
  `last_updated` DATETIME NOT NULL,
  PRIMARY KEY (`warehouse_id`, `product_id`),
  INDEX `fk_Inventories_Warehouses1_idx` (`warehouse_id` ASC) VISIBLE,
  INDEX `fk_Inventories_Products1_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_Inventories_Warehouses1`
    FOREIGN KEY (`warehouse_id`)
    REFERENCES `InventoryControlManagement`.`Warehouses` (`warehouse_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Inventories_Products1`
    FOREIGN KEY (`product_id`)
    REFERENCES `InventoryControlManagement`.`Products` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`Suppliers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`Suppliers` (
  `supplier_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`supplier_id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`Restocks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`Restocks` (
  `restock_id` INT NOT NULL AUTO_INCREMENT,
  `supplier_id` INT NOT NULL,
  `status_id` INT NOT NULL,
  `order_date` DATETIME NOT NULL,
  `expected_date` DATETIME NOT NULL,
  `received_date` DATETIME NULL,
  PRIMARY KEY (`restock_id`),
  INDEX `fk_Restocks_Suppliers1_idx` (`supplier_id` ASC) VISIBLE,
  INDEX `fk_Restocks_Statuses1_idx` (`status_id` ASC) VISIBLE,
  CONSTRAINT `fk_Restocks_Suppliers1`
    FOREIGN KEY (`supplier_id`)
    REFERENCES `InventoryControlManagement`.`Suppliers` (`supplier_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Restocks_Statuses1`
    FOREIGN KEY (`status_id`)
    REFERENCES `InventoryControlManagement`.`Statuses` (`status_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `InventoryControlManagement`.`RestockProducts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `InventoryControlManagement`.`RestockProducts` (
  `product_id` INT NOT NULL,
  `restock_id` INT NOT NULL,
  PRIMARY KEY (`product_id`, `restock_id`),
  INDEX `fk_RestockProducts_Products1_idx` (`product_id` ASC) VISIBLE,
  INDEX `fk_RestockProducts_Restocks1_idx` (`restock_id` ASC) VISIBLE,
  CONSTRAINT `fk_RestockProducts_Products1`
    FOREIGN KEY (`product_id`)
    REFERENCES `InventoryControlManagement`.`Products` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_RestockProducts_Restocks1`
    FOREIGN KEY (`restock_id`)
    REFERENCES `InventoryControlManagement`.`Restocks` (`restock_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
