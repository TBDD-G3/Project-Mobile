# Thông báo — chốt khung làm việc cuối cùng

> Ngày chốt: 26/10/2026 · Tag: `v1.0-framework-locked` · Áp dụng cho toàn nhóm (3 thành viên).
> Đọc kỹ trước khi code tiếp. Có gì chưa rõ thì hỏi Leader, đừng tự đổi khung.

---

## 1. Đã thay đổi gì?

- **Toàn bộ Drift/SQLite đã bị xóa khỏi project.** Thư mục `lib/data/database/` không còn tồn tại.
- **100% dữ liệu chuyển sang Firebase Firestore + Firebase Authentication** (đúng yêu cầu Câu 7 — ORM với Documents của Firebase).
- 5 collection cố định: `users`, `wallets`, `categories`, `transactions`, `budgets` — mỗi bản ghi là 1 Document, chuyển đổi qua `fromDocument` / `toDocument`.
- Nhánh `develop` và `main` trên GitHub đã được cập nhật đến tag `v1.0-framework-locked`. Shell app `MainNavScreen` đã gắn sẵn 4 tab, mỗi tab là file placeholder ghi tên người phụ trách.

## 2. Bắt đầu từ khung mới (làm đúng 3 lệnh)

```bash
git fetch origin
git checkout develop && git reset --hard origin/develop
git checkout -b feature/<ten-ban>-<tinh-nang>-v2
```

- **Nhánh cũ tháng 9 của các bạn vẫn được giữ nguyên trên GitHub** (làm bằng chứng lịch sử commit — Câu 10). Không xóa, không làm gì thêm với nhánh cũ.
- Không dùng lại code UI cũ trực tiếp vì nó gọi vào tầng Drift đã bị xóa; chỉ tham khảo bố cục rồi viết lại trên khung mới.

## 3. Mấy thứ đã chốt, không được đổi

| Phạm vi | Quy tắc |
|---|---|
| `lib/features/main_nav/` | **Không ai được sửa.** Shell app, 4 tab, bottom nav đã chốt. |
| `lib/core/` | Design system dùng chung (màu, theme, widget). Muốn thêm widget mới → tạo file mới, không sửa file cũ. |
| `lib/data/firestore/firestore_collections.dart` | 5 collection + converter. Không tự thêm collection, không đổi tên. |
| `lib/data/firestore/models/` | Model `AppUser, Wallet, Category, Transaction, Budget` — hợp đồng dữ liệu cố định. |
| Repository pattern | Interface trừu tượng + impl Firestore + impl Mock cho test. Tên provider giữ cố định. |
| `lib/firebase_options.dart` | Cấu hình Firebase hiện tại — không đổi, không tạo project mới. |
| Thư mục làm việc | Member 2: `lib/features/transaction/` + `lib/features/category/`; Member 3: `lib/features/budget/` + `lib/features/analytics/`; Leader: `lib/features/wallet/`, `lib/features/auth/`, `lib/features/auction/`. |

Cần sửa gì trong bảng trên thì báo Leader, Leader sửa trên `develop` rồi cả nhóm `git pull`. **Đừng tự sửa riêng trên nhánh cá nhân.**

## 4. Code mẫu để làm theo

Kiến trúc 3 lớp bắt buộc:

```text
UI (màn hình) → Provider (Riverpod) → Repository (interface + Firestore + Mock) → Firestore
```

- **Model mẫu:** `lib/data/firestore/models/category.dart` (fromDocument / toDocument).
- **Repository mẫu:** `lib/features/wallet/data/repositories/firestore_wallet_repository.dart` + `mock_wallet_repository.dart`.
- **Provider mẫu:** `lib/features/wallet/providers/wallet_providers.dart`.
- **Tài liệu chi tiết:** `docs/Huong-Dan-Firestore-Cho-Member.md` (đọc từ đầu đến cuối trước khi viết code).

## 5. Chuyện Git — điểm lịch sử commit (Câu 10)

- Mỗi người tự commit bằng đúng tài khoản GitHub của mình:
  ```bash
  git config user.name "<Họ tên>"
  git config user.email "<email GitHub>"
  ```
- Commit message đúng format: `feat(scope): mô tả ngắn` — ví dụ `feat(transaction): thêm form ghi chi tiêu`.
- **Tối thiểu 1 commit/ngày** từ nay đến 30/10. Không gom 1 commit lớn vào cuối kỳ.
- Push nhánh cá nhân lên origin mỗi ngày. **Không push trực tiếp vào `develop` / `main`** — chỉ Leader merge.

## 6. Phân công và deadline

| Thành viên | Việc chính | Deadline |
|---|---|---|
| Member 2 (Hải Đăng) | Giao dịch Thu/Chi + Danh mục, nối Firestore thật | 29/10 |
| Member 3 | Ngân sách + Báo cáo biểu đồ (`fl_chart`) với dữ liệu thật | 29/10 |
| Leader (Minh) | Màn hình Phiên Đấu Giá (Câu 5), test, báo cáo, video | 29/10 |

Mốc chung:

- **29/10:** xong tính năng của từng người trên nhánh `-v2`.
- **30–31/10:** unit/widget test toàn bộ (Câu 8) + chạy kiểm thử cả app.
- **01/11:** quay video demo dưới 8 phút (bắt buộc có link trong báo cáo — thiếu là 0 điểm toàn bài).
- **02/11 trước 23:59:** nộp PDF trên Canvas.
- **04/11 trước 17:00:** nộp bản cứng phòng 2310 nhà A9 + ký danh sách nộp.

## 7. Tài liệu tham khảo

- `docs/Huong-Dan-Firestore-Cho-Member.md` — hướng dẫn Firebase/Firestore/Riverpod chi tiết.
- `docs/Schema-Va-Ban-Giao.md` — schema 5 collection + mô tả model.
- `lib/features/wallet/presentation/wallets_screen.dart` — màn hình mẫu đã hoàn thiện (ví tiền) để tham khảo style.
