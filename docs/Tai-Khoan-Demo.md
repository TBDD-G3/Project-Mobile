# Tài khoản demo

Tài khoản mẫu dùng để quay video demo và bảo vệ bài tập lớn. Dữ liệu nằm trên
Firebase project `project-mobile-c0faa`, không phụ thuộc nhánh Git.

## Thông tin đăng nhập

| Trường | Giá trị |
| --- | --- |
| Email | `demo.expensetracker.2026@gmail.com` |
| Mật khẩu | `Demo@2026` |
| Tên hiển thị | Người dùng Demo |
| UID | `U6Fw6V930vOtSJLfK4HQD8tlClA2` |

Đăng nhập ở màn Đăng nhập của app (web `flutter run -d chrome` hoặc Android).
Mật khẩu không nằm trong mã nguồn: script đọc từ biến môi trường `DEMO_PASSWORD`
hoặc hỏi khi chạy.

## Dữ liệu đang có

- **3 ví**: Tiền mặt 5.955.000 ₫, Vietcombank 16.664.000 ₫, MoMo 657.000 ₫ —
  tổng 23.276.000 ₫.
- **91 giao dịch** từ 01/09/2026 đến 01/11/2026: lương 15 triệu/tháng 9–10,
  thưởng 1,2 triệu, thu nhập phụ 0,8 triệu, hóa đơn cố định (nhà, điện, nước,
  internet, điện thoại), ăn uống – di chuyển – mua sắm – giải trí hằng ngày,
  và 1 giao dịch chuyển khoản nội bộ mỗi tháng (rút tiền mặt từ ngân hàng).
- **5 ngân sách tháng 11/2026**: tổng hạn mức 9.400.000 ₫; Ăn uống
  520.000/600.000 ₫ (87%, màu cam) để demo cảnh báo gần vượt hạn mức.
- **13 danh mục mặc định** do `InitialSeeder` tạo khi app khởi động.

Số dư từng ví trong Firestore đã tính sẵn theo toàn bộ giao dịch, không cần
chạy lại gì thêm.

## Chạy lại / nạp lại dữ liệu

```bash
# xem trước số liệu, không ghi
python tools/seed_demo.py --dry-run

# ghi lên Firestore (hỏi mật khẩu nếu chưa đặt biến môi trường)
export DEMO_PASSWORD='Demo@2026'     # Windows PowerShell: $env:DEMO_PASSWORD='Demo@2026'
python tools/seed_demo.py
```

Script tạo tài khoản nếu chưa có, nếu đã có thì đăng nhập rồi ghi đè. Mọi
document dùng ID cố định (`demo-wallet-*`, `demo-tx-*`, `demo-budget-*`) nên
chạy nhiều lần không sinh dữ liệu trùng.

## Lưu ý

- Đây là tài khoản demo công khai: chỉ chứa dữ liệu mẫu, không dùng mật khẩu
  này cho tài khoản thật và không nhập dữ liệu cá nhân vào.
- Script chỉ dùng Web API key công khai trong `lib/firebase_options.dart` và
  idToken của chính tài khoản demo, không cần service account key.
- Muốn đổi mức chi, số ví hay hạn mức thì sửa `WALLETS`, `build_transactions()`
  hoặc `BUDGETS` trong `tools/seed_demo.py` rồi chạy lại.
