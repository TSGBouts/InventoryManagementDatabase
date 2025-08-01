import pandas as pd

# ──────────────────────────────────────────────────────────────────────
# 1.  READ & BASIC CLEAN
# ──────────────────────────────────────────────────────────────────────
xls = pd.ExcelFile("online_retail_II.xlsx")
df  = pd.concat([xls.parse(sheet) for sheet in xls.sheet_names], ignore_index=True)

# keep the three columns we need and drop obvious nulls
df = df[["StockCode", "Description", "Price"]].dropna(subset=["StockCode", "Description"])

# normalise text columns
df["StockCode"]   = df["StockCode"].astype(str).str.strip()
df["Description"] = df["Description"].astype(str).str.strip()

# ──────────────────────────────────────────────────────────────────────
# 2.  DEDUPLICATE BY SKU
# ──────────────────────────────────────────────────────────────────────
df = (df.sort_values("StockCode")              # stable order
        .drop_duplicates("StockCode", keep="first"))

# ──────────────────────────────────────────────────────────────────────
# 3.  ADD SCHEMA COLUMNS
# ──────────────────────────────────────────────────────────────────────
# 40 % markup → cost = 60 % of unit price
df["unit_cost"]        = (df["Price"].astype(float) * 0.60).round(2)
df["reorder_point"]    = 50
df["reorder_amount"]   = 100      # (column is called “amount” in your table)

# ──────────────────────────────────────────────────────────────────────
# 4.  QUALITY FILTERS
# ──────────────────────────────────────────────────────────────────────
mask_ok = (
    (df["unit_cost"] > 0) &                     # cost must be positive
    (df["Price"].astype(float) >= 0) &          # no negative prices
    (df["Price"].astype(float) <= 100) &        # drop items > $100 list price
    (df["StockCode"].str.len() >= 6) &          # SKU length ≥ 6
    (df["Description"] == df["Description"].str.upper())   # name all caps
)
df = df[mask_ok].copy()

# ──────────────────────────────────────────────────────────────────────
# 5.  REMOVE DUPES BY FIRST WORD OF NAME
# ──────────────────────────────────────────────────────────────────────
df["first_word"] = df["Description"].str.split().str[0]
df = (df.sort_values(["first_word", "StockCode"])
        .drop_duplicates("first_word", keep="first")
        .drop(columns="first_word"))

# ──────────────────────────────────────────────────────────────────────
# 6.  RENAME/REORDER FOR CSV EXPORT
# ──────────────────────────────────────────────────────────────────────
df = (df.rename(columns={
        "StockCode":   "sku",
        "Description": "name"
      })
      [["sku", "name", "unit_cost", "reorder_point", "reorder_amount"]])

df.to_csv("products_clean.csv", index=False)
print(f"Wrote products_clean.csv with {len(df):,} validated SKUs")