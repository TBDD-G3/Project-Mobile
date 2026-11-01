"""Nạp dữ liệu demo cho Expense Tracker (Firestore project-mobile-c0faa).

Script tạo (hoặc đăng nhập) một tài khoản Firebase Auth rồi ghi thẳng ví /
giao dịch / ngân sách vào Firestore bằng idToken của chính tài khoản đó, nên
đi qua đúng Security Rules (mỗi document phải có userId == uid).

Thông tin tài khoản demo và mô tả dữ liệu: docs/Tai-Khoan-Demo.md

Chạy:
    set DEMO_PASSWORD=<mật khẩu>          # Windows (bash: export DEMO_PASSWORD=...)
    python tools/seed_demo.py --dry-run   # chỉ in số liệu, không ghi
    python tools/seed_demo.py             # ghi lên Firestore

Mật khẩu không lưu trong mã nguồn: đọc từ biến môi trường DEMO_PASSWORD,
nếu không có thì hỏi ngay khi chạy. Email đổi bằng DEMO_EMAIL.
"""

from __future__ import annotations

import argparse
import getpass
import json
import os
import random
import urllib.error
import urllib.request
from datetime import datetime, timedelta, timezone

# Web API key lấy từ lib/firebase_options.dart (khóa công khai của Firebase,
# không phải service account key).
API_KEY = "AIzaSyCXJ3Oj5CWJs05mNHk6ZhPNyq6pWSqrOXw"
PROJECT = "project-mobile-c0faa"
EMAIL = os.environ.get("DEMO_EMAIL", "demo.expensetracker.2026@gmail.com")
DISPLAY_NAME = "Người dùng Demo"

VN = timezone(timedelta(hours=7))


def ts(y, m, d, hh=9, mm=0):
    return datetime(y, m, d, hh, mm, tzinfo=VN).isoformat()


# ---------------------------------------------------------------- ví
WALLETS = [
    # id, tên, loại, số dư đầu kỳ (trước 01/09/2026), màu
    ("demo-wallet-cash", "Tiền mặt", "cash", 1_200_000, "#4CAF50"),
    ("demo-wallet-vcb", "Vietcombank", "bank", 9_500_000, "#1565C0"),
    ("demo-wallet-momo", "MoMo", "ewallet", 2_500_000, "#E91E63"),
]

FOOD_NOTES = ["Ăn sáng", "Cơm trưa", "Cà phê", "Ăn tối", "Trà sữa", "Bún chả",
              "Cơm tấm", "Bánh mì", "Phở", "Đi chợ"]
MOVE_NOTES = ["Xăng xe", "Grab đi làm", "Gửi xe", "Vé xe buýt", "Grab về nhà"]
SHOP_NOTES = ["Áo thun", "Giày sneaker", "Đồ dùng học tập", "Siêu thị", "Tai nghe"]
FUN_NOTES = ["Vé xem phim", "Netflix", "Cà phê cuối tuần", "Game", "Nhạc số"]
HEALTH_NOTES = ["Thuốc cảm", "Khám răng", "Vitamin"]


def build_transactions():
    """Sinh giao dịch 01/09/2026 – 01/11/2026, số tiền và ghi chú cố định."""
    rnd = random.Random(42)
    rows = []  # (wallet, category, type, amount, date, note, to_wallet)

    def add(w, c, t, amount, date, note, to=None):
        rows.append((w, c, t, float(amount), date, note, to))

    # Rút tiền mặt từ ngân hàng về ví (chuyển khoản nội bộ)
    add("demo-wallet-vcb", None, "transfer", 4_000_000,
        ts(2026, 9, 1, 8), "Rút tiền mặt", to="demo-wallet-cash")
    add("demo-wallet-vcb", None, "transfer", 4_000_000,
        ts(2026, 10, 1, 8), "Rút tiền mặt", to="demo-wallet-cash")
    add("demo-wallet-vcb", None, "transfer", 2_000_000,
        ts(2026, 11, 1, 8), "Rút tiền mặt", to="demo-wallet-cash")

    for month, days in ((9, 30), (10, 31)):
        add("demo-wallet-vcb", "cat-inc-luong", "income", 15_000_000,
            ts(2026, month, 5, 8, 30), f"Lương tháng {month}")
        if month == 10:
            add("demo-wallet-vcb", "cat-inc-thuong", "income", 1_200_000,
                ts(2026, 10, 20, 15), "Thưởng dự án")
            add("demo-wallet-momo", "cat-inc-phu", "income", 800_000,
                ts(2026, 10, 25, 20), "Nhận tiền freelance")

        add("demo-wallet-vcb", "cat-exp-hoa-don", "expense", 4_500_000,
            ts(2026, month, 3, 10), "Tiền nhà")
        add("demo-wallet-vcb", "cat-exp-hoa-don", "expense",
            rnd.randrange(760, 880) * 1000, ts(2026, month, 10, 19), "Tiền điện")
        add("demo-wallet-vcb", "cat-exp-hoa-don", "expense",
            rnd.randrange(110, 150) * 1000, ts(2026, month, 10, 19), "Tiền nước")
        add("demo-wallet-vcb", "cat-exp-hoa-don", "expense", 220_000,
            ts(2026, month, 12, 9), "Internet")
        add("demo-wallet-momo", "cat-exp-hoa-don", "expense", 100_000,
            ts(2026, month, 15, 11), "Nạp điện thoại")

        day = 1
        while day <= days - 1:
            add("demo-wallet-cash", "cat-exp-an-uong", "expense",
                rnd.randrange(35, 165) * 1000,
                ts(2026, month, day, 7 + rnd.randrange(0, 12)),
                rnd.choice(FOOD_NOTES))
            day += 2

        day = 2
        while day <= days - 1:
            add("demo-wallet-cash", "cat-exp-di-chuyen", "expense",
                rnd.randrange(20, 110) * 1000,
                ts(2026, month, day, 8 + rnd.randrange(0, 10)),
                rnd.choice(MOVE_NOTES))
            day += 4

        for day in rnd.sample(range(4, days - 2, 2), 4):
            add("demo-wallet-cash", "cat-exp-an-uong", "expense",
                rnd.randrange(30, 70) * 1000, ts(2026, month, day, 16),
                rnd.choice(["Cà phê", "Trà sữa", "Bánh ngọt"]))

        add("demo-wallet-momo", "cat-exp-mua-sam", "expense",
            rnd.randrange(320, 720) * 1000, ts(2026, month, 8, 20),
            rnd.choice(SHOP_NOTES))
        add("demo-wallet-vcb", "cat-exp-mua-sam", "expense",
            rnd.randrange(250, 480) * 1000, ts(2026, month, 22, 18),
            rnd.choice(SHOP_NOTES))
        add("demo-wallet-momo", "cat-exp-giai-tri", "expense",
            rnd.randrange(120, 260) * 1000, ts(2026, month, 14, 21),
            rnd.choice(FUN_NOTES))
        add("demo-wallet-momo", "cat-exp-giai-tri", "expense", 99_000,
            ts(2026, month, 18, 22), "Netflix")
        add("demo-wallet-cash", "cat-exp-suc-khoe", "expense",
            rnd.randrange(280, 480) * 1000, ts(2026, month, 17, 16),
            rnd.choice(HEALTH_NOTES))
        add("demo-wallet-vcb", "cat-exp-giao-duc", "expense",
            1_500_000 if month == 9 else 450_000, ts(2026, month, 6, 14),
            "Học phí" if month == 9 else "Sách chuyên ngành")
        if month == 10:
            add("demo-wallet-cash", "cat-exp-khac", "expense", 200_000,
                ts(2026, 10, 28, 17), "Quà tặng sinh nhật")

    add("demo-wallet-cash", "cat-exp-an-uong", "expense", 45_000,
        ts(2026, 11, 1, 7, 20), "Ăn sáng")
    add("demo-wallet-momo", "cat-exp-an-uong", "expense", 120_000,
        ts(2026, 11, 1, 11, 45), "Cơm trưa")
    add("demo-wallet-cash", "cat-exp-an-uong", "expense", 55_000,
        ts(2026, 11, 1, 15, 10), "Cà phê")
    add("demo-wallet-momo", "cat-exp-an-uong", "expense", 180_000,
        ts(2026, 11, 1, 19, 30), "Ăn tối")
    add("demo-wallet-cash", "cat-exp-an-uong", "expense", 120_000,
        ts(2026, 11, 1, 20, 30), "Đi chợ")
    add("demo-wallet-cash", "cat-exp-di-chuyen", "expense", 35_000,
        ts(2026, 11, 1, 8, 10), "Gửi xe")
    add("demo-wallet-momo", "cat-exp-mua-sam", "expense", 299_000,
        ts(2026, 11, 1, 16), "Siêu thị")
    add("demo-wallet-momo", "cat-exp-giai-tri", "expense", 120_000,
        ts(2026, 11, 1, 21), "Vé xem phim")
    return rows


BUDGETS = [
    ("cat-exp-an-uong", 600_000),
    ("cat-exp-di-chuyen", 500_000),
    ("cat-exp-mua-sam", 1_500_000),
    ("cat-exp-hoa-don", 6_000_000),
    ("cat-exp-giai-tri", 800_000),
]


def balances(rows):
    result = {w[0]: w[3] for w in WALLETS}
    for wallet, _, kind, amount, _, _, to in rows:
        if kind == "expense":
            result[wallet] -= amount
        elif kind == "income":
            result[wallet] += amount
        else:
            result[wallet] -= amount
            result[to] += amount
    return result


def summary(rows):
    spent = sum(a for _, _, t, a, _, _, _ in rows if t == "expense")
    earned = sum(a for _, _, t, a, _, _, _ in rows if t == "income")
    nov = [r for r in rows if r[4].startswith("2026-11")]
    print(f"  giao dịch : {len(rows)}  (tháng 11: {len(nov)})")
    print(f"  tổng thu  : {earned:,.0f} đ")
    print(f"  tổng chi  : {spent:,.0f} đ")
    bal = balances(rows)
    print("  số dư cuối:")
    for wid, name, _, _, _ in WALLETS:
        print(f"    {name:<12} {bal[wid]:>15,.0f} đ")
    print(f"    {'TỔNG':<12} {sum(bal.values()):>15,.0f} đ")
    print("  ngân sách 11/2026:")
    for cat, limit in BUDGETS:
        used = sum(a for _, c, t, a, d, _, _ in rows
                   if c == cat and t == "expense" and d.startswith("2026-11"))
        print(f"    {cat:<20} {used:>10,.0f} / {limit:>10,.0f} đ  ({used / limit:.0%})")


# ---------------------------------------------------------------- Firebase
def post(url, payload, token=None):
    data = json.dumps(payload).encode()
    req = urllib.request.Request(url, data=data, method="POST")
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode())


def sign_up(password):
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={API_KEY}"
    return post(url, {"email": EMAIL, "password": password, "returnSecureToken": True})


def sign_in(password):
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}"
    return post(url, {"email": EMAIL, "password": password, "returnSecureToken": True})


def doc_name(collection, doc_id):
    return f"projects/{PROJECT}/databases/(default)/documents/{collection}/{doc_id}"


def commit(token, writes):
    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents:commit"
    for i in range(0, len(writes), 100):
        post(url, {"writes": writes[i:i + 100]}, token)


def string(v):
    return {"stringValue": v}


def number(v):
    return {"doubleValue": float(v)}


def null():
    return {"nullValue": None}


def build_writes(uid, rows):
    writes = []
    now = datetime.now(VN).isoformat()

    user_fields = {
        "email": string(EMAIL),
        "displayName": string(DISPLAY_NAME),
        "currencyCode": string("VND"),
        "createdAt": {"timestampValue": now},
    }
    writes.append({"update": {"name": doc_name("users", uid), "fields": user_fields}})

    bal = balances(rows)
    for wid, name, kind, _, color in WALLETS:
        fields = {
            "userId": string(uid),
            "name": string(name),
            "type": string(kind),
            "balance": number(bal[wid]),
            "colorHex": string(color),
            "createdAt": {"timestampValue": ts(2026, 8, 25)},
        }
        writes.append({"update": {"name": doc_name("wallets", wid), "fields": fields}})

    for index, (wallet, cat, kind, amount, date, note, to) in enumerate(rows, 1):
        fields = {
            "userId": string(uid),
            "walletId": string(wallet),
            "categoryId": string(cat) if cat else null(),
            "type": string(kind),
            "amount": number(amount),
            "date": {"timestampValue": date},
            "note": string(note),
            "toWalletId": string(to) if to else null(),
        }
        writes.append({
            "update": {"name": doc_name("transactions", f"demo-tx-{index:04d}"), "fields": fields}
        })

    for cat, limit in BUDGETS:
        fields = {
            "userId": string(uid),
            "categoryId": string(cat),
            "month": {"integerValue": "11"},
            "year": {"integerValue": "2026"},
            "limitAmount": number(limit),
        }
        writes.append({
            "update": {"name": doc_name("budgets", f"demo-budget-{cat}"), "fields": fields}
        })
    return writes


def count_collection(token, collection, uid=None):
    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents:runQuery"
    query = {"structuredQuery": {
        "from": [{"collectionId": collection}],
        "select": {"fields": [{"fieldPath": "amount"}]},
    }}
    if uid:
        query["structuredQuery"]["where"] = {"fieldFilter": {
            "field": {"fieldPath": "userId"}, "op": "EQUAL",
            "value": {"stringValue": uid}}}
    rows = post(url, query, token)
    docs = [r["document"] for r in rows if "document" in r]
    total = sum(float(d["fields"]["amount"]["doubleValue"])
                for d in docs if "amount" in d.get("fields", {}))
    return len(docs), total


def verify(token, uid):
    for collection in ("wallets", "transactions", "budgets"):
        count, total = count_collection(token, collection, uid)
        print(f"  {collection:<13} {count:>3} document, tổng amount {total:,.0f}")
    count, _ = count_collection(token, "categories")
    print(f"  categories    {count:>3} danh mục dùng chung")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    rows = build_transactions()
    summary(rows)
    if args.dry_run:
        return

    password = os.environ.get("DEMO_PASSWORD") or getpass.getpass(f"Mật khẩu cho {EMAIL}: ")
    try:
        auth = sign_up(password)
        print(f"  tạo tài khoản mới: {auth['localId']}")
    except urllib.error.HTTPError as e:
        body = json.loads(e.read().decode())
        if body.get("error", {}).get("message") != "EMAIL_EXISTS":
            raise
        auth = sign_in(password)
        print(f"  tài khoản đã có, đăng nhập: {auth['localId']}")

    writes = build_writes(auth["localId"], rows)
    commit(auth["idToken"], writes)
    print(f"  đã ghi {len(writes)} document lên Firestore")
    verify(auth["idToken"], auth["localId"])


if __name__ == "__main__":
    main()
