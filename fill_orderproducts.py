import random
import sys

import mysql.connector

# ── CONFIG ────────────────────────────────────────────────────────────────
DB_NAME         = "InventoryControlManagement"
DB_USER         = "root"
DB_PASSWORD     = "your_password"
DB_HOST         = "localhost"
DB_PORT         = 3306

TRUNCATE_FIRST  = False   # change True to wipe existing rows

PRODUCT_MAX_ID  = 200     # highest product_id to sample from if Products table missing

# Distribution for #products per order (1 is most common)
NUM_PRODUCTS_WEIGHTS = [0.6, 0.25, 0.1, 0.04, 0.01]  # sums to 1 for 1–5

# Probability that quantity is exactly 1; else 2–5 chosen uniformly
QUANTITY_ONE_PROB = 0.85
# ──────────────────────────────────────────────────────────────────────────


def choose_num_products() -> int:
    return random.choices([1, 2, 3, 4, 5], weights=NUM_PRODUCTS_WEIGHTS)[0]


def choose_quantity() -> int:
    if random.random() < QUANTITY_ONE_PROB:
        return 1
    return random.randint(2, 5)


def fetch_order_ids(cursor):
    cursor.execute("SELECT order_id FROM Orders")
    return [row[0] for row in cursor.fetchall()]


def fetch_product_ids(cursor):
    try:
        cursor.execute("SELECT product_id FROM Products")
        rows = cursor.fetchall()
        if rows:
            return [row[0] for row in rows]
    except mysql.connector.Error:
        # Products table might not exist
        pass
    # fallback synthetic range
    return list(range(1, PRODUCT_MAX_ID + 1))


def build_order_product_rows(order_ids, product_ids):
    """Yield (order_id, product_id, quantity) tuples."""
    rows = []
    for oid in order_ids:
        n_products = choose_num_products()
        # ensure unique product_ids within one order
        chosen = random.sample(product_ids, k=n_products)
        for pid in chosen:
            rows.append((oid, pid, choose_quantity()))
    return rows


def ensure_orderproducts_table(cursor):
    sql = """
    CREATE TABLE IF NOT EXISTS OrderProducts (
        order_id  INT NOT NULL,
        product_id INT NOT NULL,
        quantity  INT NOT NULL DEFAULT 1,
        PRIMARY KEY (order_id, product_id),
        CONSTRAINT fk_op_order FOREIGN KEY (order_id) REFERENCES Orders(order_id),
        CONSTRAINT fk_op_product FOREIGN KEY (product_id) REFERENCES Products(product_id)
    )
    """
    cursor.execute(sql)


def main():
    cnx = None
    cur = None
    try:
        cnx = mysql.connector.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
        )
        cur = cnx.cursor()

        ensure_orderproducts_table(cur)

        if TRUNCATE_FIRST:
            print("Truncating OrderProducts …")
            cur.execute("TRUNCATE TABLE OrderProducts")

        order_ids = fetch_order_ids(cur)
        if not order_ids:
            print("No orders found in Orders table — nothing to insert.")
            return

        product_ids = fetch_product_ids(cur)
        if not product_ids:
            print("No product IDs available.")
            return

        rows = build_order_product_rows(order_ids, product_ids)

        insert_sql = (
            "INSERT IGNORE INTO OrderProducts (order_id, product_id, quantity) "
            "VALUES (%s, %s, %s)"
        )
        cur.executemany(insert_sql, rows)
        cnx.commit()

        print(f"Inserted {len(rows):,} rows into OrderProducts.")

    except mysql.connector.Error as err:
        print("MySQL Error:", err.msg)
        sys.exit(1)

    finally:
        if cur is not None:
            cur.close()
        if cnx is not None and cnx.is_connected():
            cnx.close()


if __name__ == "__main__":
    sys.exit(main())
