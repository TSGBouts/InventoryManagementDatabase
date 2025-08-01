# Inventory Control Management Demo

A self‑contained MySQL sample database that models a small retailer’s **inventory, ordering, and restocking** workflow.  All schema, seed data, and helper scripts live in this repository so you can spin up the dataset locally in minutes and use it for SQL practice, demos, or backend prototypes.

![schema diagram](diagram.sql) <!-- export of Workbench model -->

---

## Contents

| File                                                     | Purpose                                                                                        |
| -------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| **online\_retail\_II.xlsx**                              | Raw e‑commerce transactions from Kaggle (online‑retail‑II dataset) — *source data only*        |
| **clean\_products.py**                                   | Cleans & normalises the Kaggle spreadsheet → `products.csv` used by `createProducts.sql`       |
| **customers.csv**                                        | 1 000 mock customer records generated with Mockaroo                                            |
| **create*.sql*\*                                         | DDL + static seed for reference tables (statuses, shippers, coupons, suppliers, warehouses, …) |
| **fill\_inventories.py**                                 | Populates the `inventories` table with per‑warehouse stock levels                              |
| **fill\_orders.py**                                      | Inserts 200 synthetic customer orders                                                          |
| **fill\_orderproducts.py / fill\_orderproducts\_cli.py** | Adds 1‑5 products (with quantities) to every order                                             |
| **insert\_restocks.sql**                                 | Inserts 20 restock purchase‑orders                                                             |
| **insert\_restockproducts.sql**                          | Attaches 1‑3 products to each restock                                                          |
| **createRestockProducts.sql**                            | DDL for the `restockproducts` join table                                                       |
| **diagram.sql**                                          | Workbench‑generated schema diagram (so you can reopen / tweak visually)                        |

---

## Data Sources

* **Products** – cleansed subset of the Kaggle *Online Retail II* dataset.  Only the most important columns (StockCode, Description, UnitPrice) are retained and duplicates are removed.
* **Customers** – Mockaroo‑generated fake customers (`customers.csv`).
* **Reference tables** – tiny hand‑curated lookup data (statuses, shippers, suppliers, warehouses, coupons).
* **Synthetic orders / restocks** – generated on the fly by Python scripts to simulate real‑world activity.

---

## Roadmap / Future Plans

* **Transactions** – wrap multi‑table inserts in ACID transactions to keep data consistent.
* **Views** – convenient read‑only views (e.g. `vw_order_detail`, `vw_inventory_by_supplier`).
* **Stored Procedures & Functions** – encapsulate business logic (`sp_place_order`, `fn_stock_available(product_id, qty)`).
* **Scheduled Events** – nightly restock suggestions based on reorder points.