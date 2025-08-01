import random, datetime
import mysql.connector
import numpy as np

# ── CONFIG ───────────────────────────────────────────────
DB_NAME  = "inventorycontrolmanagement"   # change to your DB
TRUNCATE_FIRST = True                     # set False if you want to append
MIN_QTY   = 50
MAX_QTY   = 250
FILL_RATE = 0.95                          # target % of capacity
# ─────────────────────────────────────────────────────────

cnx = mysql.connector.connect(
    host="localhost",
    user="root",
    password="your_password",
    database=DB_NAME,
)
cur = cnx.cursor(dictionary=True)

try:
    # 0. optional truncate
    if TRUNCATE_FIRST:
        print("Truncating Inventories …")
        cur.execute("TRUNCATE TABLE Inventories")

    # 1. fetch data
    cur.execute("SELECT warehouse_id, capacity FROM Warehouses")
    warehouses = cur.fetchall()
    print(f"Warehouses found: {len(warehouses)}")

    cur.execute("SELECT product_id FROM Products")
    product_ids = [r["product_id"] for r in cur.fetchall()]
    print(f"Products found: {len(product_ids)}")

    if not warehouses or not product_ids:
        raise RuntimeError("No warehouses or products found—aborting.")

    # 2. date range this month
    today = datetime.datetime.now()
    first = today.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    sec_range = int((today - first).total_seconds())
    rand_date = lambda: first + datetime.timedelta(seconds=random.randint(0, sec_range))

    insert_sql = """
        INSERT INTO Inventories (warehouse_id, product_id, quantity, last_updated)
        VALUES (%s, %s, %s, %s)
    """

    # 3. generate + insert
    for w in warehouses:
        wid, cap = w["warehouse_id"], w["capacity"]

        qty_raw = np.random.randint(MIN_QTY, MAX_QTY + 1, len(product_ids))
        scale   = min(FILL_RATE * cap / qty_raw.sum(), 1.0)
        qty     = np.maximum((qty_raw * scale).astype(int), MIN_QTY)

        rows = [(wid, pid, int(q), rand_date()) for pid, q in zip(product_ids, qty)]

        try:
            cur.executemany(insert_sql, rows)
            print(f"Warehouse {wid}: inserted {len(rows):,} rows "
                  f"(total {qty.sum():,} units, cap {cap})")
        except mysql.connector.Error as err:
            print(f"Warehouse {wid} failed →", err.msg)
            cnx.rollback()
            continue

    cnx.commit()
    print("Done!")

finally:
    cur.close()
    cnx.close()