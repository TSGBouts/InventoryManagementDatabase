import datetime
import random
import sys

import mysql.connector

# ── CONFIG ────────────────────────────────────────────────────────────────
DB_NAME             = "InventoryControlManagement"
DB_USER             = "root"
DB_PASSWORD         = "your_password"
DB_HOST             = "localhost"
DB_PORT             = 3306

CREATE_DB_IF_MISSING = True     # auto‑create DB if it doesn't exist

NUM_ORDERS     = 200
CUSTOMER_MAX   = 100
ARRIVAL_PROB   = 0.80           # probability the order has arrived
COUPON_NULL_P  = 0.40           # probability coupon_id is NULL

START_DATE     = datetime.date(2024, 1, 1)
TODAY          = datetime.date.today()
# ──────────────────────────────────────────────────────────────────────────


def random_date(start: datetime.date, end: datetime.date) -> datetime.date:
    """Return a random date between *start* and *end* (inclusive)."""
    delta = (end - start).days
    return start + datetime.timedelta(days=random.randint(0, delta))


def build_order(order_id: int):
    """Return a tuple that matches the Orders table schema."""
    customer_id = random.randint(1, CUSTOMER_MAX)

    order_date = random_date(START_DATE, TODAY)
    expected_date = order_date + datetime.timedelta(days=7)

    has_arrived = random.random() < ARRIVAL_PROB
    arrived_date = (
        expected_date + datetime.timedelta(days=random.randint(-2, 7))
        if has_arrived
        else None
    )

    # status_id logic
    if (TODAY - order_date).days < 3:
        status_id = 1
    elif arrived_date is None:
        status_id = 2
    else:
        status_id = 3 if arrived_date.year >= 2025 else 4

    coupon_id = None if random.random() < COUPON_NULL_P else random.randint(1, 5)
    shipper_id = None if status_id == 1 else random.randint(1, 5)

    return (
        order_id,
        customer_id,
        order_date,
        expected_date,
        arrived_date,
        status_id,
        coupon_id,
        shipper_id,
    )


def ensure_database(cursor, db_name: str):
    cursor.execute(
        "SELECT SCHEMA_NAME FROM information_schema.schemata WHERE SCHEMA_NAME=%s",
        (db_name,),
    )
    if cursor.fetchone() is None:
        print(f"Database '{db_name}' does not exist — creating it …")
        cursor.execute(f"CREATE DATABASE `{db_name}`")
    else:
        print(f"Using existing database '{db_name}'")
    cursor.execute(f"USE `{db_name}`")


def ensure_orders_table(cursor):
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS Orders (
        order_id      INT PRIMARY KEY,
        customer_id   INT NOT NULL,
        order_date    DATE NOT NULL,
        expected_date DATE NOT NULL,
        arrived_date  DATE NULL,
        status_id     INT NOT NULL,
        coupon_id     INT NULL,
        shipper_id    INT NULL
    )
    """
    cursor.execute(create_table_sql)


def main():
    # Always have these defined so `finally` can reference them
    cnx = None
    cursor = None

    try:
        # first connect WITHOUT specifying database (allows us to create it)
        cnx = mysql.connector.connect(
            host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD
        )
        cursor = cnx.cursor()

        if CREATE_DB_IF_MISSING:
            ensure_database(cursor, DB_NAME)
        else:
            cursor.execute(f"USE `{DB_NAME}`")

        ensure_orders_table(cursor)

        insert_sql = (
            "INSERT INTO Orders "
            "(order_id, customer_id, order_date, expected_date, arrived_date, "
            "status_id, coupon_id, shipper_id) VALUES "
            "(%s, %s, %s, %s, %s, %s, %s, %s)"
        )

        rows = [build_order(i) for i in range(1, NUM_ORDERS + 1)]
        cursor.executemany(insert_sql, rows)
        cnx.commit()

        print(f"Inserted {len(rows)} rows into Orders.")

    except mysql.connector.Error as err:
        print("MySQL Error:", err.msg)
        sys.exit(1)

    finally:
        if cursor is not None:
            cursor.close()
        if cnx is not None and cnx.is_connected():
            cnx.close()


if __name__ == "__main__":
    sys.exit(main())
