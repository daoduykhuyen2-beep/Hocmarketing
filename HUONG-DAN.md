# 🎓 Website Khoá Học Marketing — Hướng dẫn cài đặt

Website tĩnh (HTML/JS) + backend **Supabase** (đăng nhập admin, database, lưu ảnh/video).
Không cần biết lập trình vẫn cài được. Làm theo 6 bước dưới, khoảng **15–20 phút**.

---

## 📁 Các file trong bộ này

| File | Công dụng |
|------|-----------|
| `index.html` | Trang học viên — đăng ký, xem khoá, nạp tiền, mua khoá/VIP |
| `admin.html` | Trang quản trị — khoá học, bài giảng, học viên, gói VIP, giao dịch |
| `config.js` | Điền khoá Supabase + thông tin ngân hàng nhận nạp tiền |
| `supabase-setup.sql` | Câu lệnh tạo toàn bộ database — chạy 1 lần trên Supabase |
| `supabase/functions/sepay-webhook/index.ts` | Hàm nạp tiền tự động (deploy lên Supabase) |
| `HUONG-DAN.md` | File bạn đang đọc |

---

## Bước 1 — Tạo dự án Supabase (miễn phí)

1. Vào **https://supabase.com** → **Start your project** → đăng nhập (dùng GitHub cho nhanh).
2. Bấm **New project**. Đặt tên bất kỳ (VD: `khoa-hoc-marketing`).
3. Đặt **Database Password** (lưu lại phòng khi cần) → chọn Region gần VN (Singapore) → **Create new project**.
4. Chờ ~1 phút để dự án khởi tạo xong.

## Bước 2 — Tạo database

1. Trong dự án, cột trái chọn **SQL Editor** → **New query**.
2. Mở file `supabase-setup.sql`, copy **toàn bộ** nội dung, dán vào ô soạn thảo.
3. Bấm **Run** (hoặc Ctrl/Cmd + Enter). Thấy “Success” là xong.
   → Việc này tạo 2 bảng, phân quyền, tạo kho lưu file, và thêm sẵn 7 khoá học mẫu.

## Bước 3 — Lấy khoá kết nối & điền vào `config.js`

1. Cột trái → **Project Settings** (biểu tượng bánh răng) → **API**.
2. Copy 2 giá trị:
   - **Project URL** (dạng `https://xxxx.supabase.co`)
   - **anon public** key (chuỗi dài — **KHÔNG** lấy `service_role`).
3. Mở file `config.js`, dán vào đúng chỗ:

```js
window.APP_CONFIG = {
  SUPABASE_URL: "https://xxxx.supabase.co",   // ← Project URL
  SUPABASE_ANON_KEY: "eyJhbGciOi...",          // ← anon public key
  SITE_NAME: "Học Viện Marketing",
  SITE_TAGLINE: "Khoá học marketing thực chiến...",
  STORAGE_BUCKET: "media",
  BANK_CODE: "MB",                 // ngân hàng nhận nạp tiền (MB, VCB, ACB, TCB...)
  BANK_ACCOUNT: "0000000000",      // số tài khoản
  BANK_ACCOUNT_NAME: "NGUYEN VAN A", // tên chủ TK (HOA, không dấu)
  SUPPORT_ZALO: ""                 // link Zalo hỗ trợ (tuỳ chọn)
};
```
> `anon public` key được phép để lộ trong web tĩnh — quyền ghi và nội dung khoá học đã được khoá bằng RLS + hàm bảo mật, chỉ người **đã mua** mới xem được link video/Drive.

## Bước 4 — Tạo tài khoản admin & cấp quyền

1. Cột trái → **Authentication** → **Users** → **Add user** → **Create new user**.
2. Nhập **Email** + **Password** bạn muốn dùng để đăng nhập trang quản trị.
3. Tích **Auto Confirm User** (để đăng nhập được ngay) → **Create user**.
4. **QUAN TRỌNG — cấp quyền admin:** vào **SQL Editor** → New query → chạy (thay email của bạn):
   ```sql
   update public.profiles set is_admin = true where email = 'EMAIL_ADMIN_CUA_BAN';
   ```
   > Nếu chưa thấy dòng nào được cập nhật, hãy đăng nhập vào `admin.html` một lần (để hệ thống tạo hồ sơ), rồi chạy lại câu lệnh trên.

> Học viên **tự đăng ký** ngay trên trang chủ (`index.html`) — bạn không cần tạo tay. Chỉ tài khoản có `is_admin = true` mới vào được trang quản trị.

## Bước 5 — Chạy thử trên máy

- Cách nhanh: mở thẳng file `index.html` bằng trình duyệt. *(Lưu ý: một số trình duyệt chặn tải file lên khi mở kiểu này — nên dùng cách chạy server bên dưới cho chắc.)*
- Cách chuẩn (khuyên dùng), mở Terminal tại thư mục này:
  ```bash
  # Nếu có Python:
  python3 -m http.server 8000
  # rồi mở http://localhost:8000
  ```
- Vào `admin.html`, đăng nhập bằng tài khoản ở Bước 4 → thử thêm 1 bài giảng → mở `index.html` xem kết quả.

## Bước 6 — Đưa web lên mạng bằng GitHub Pages (miễn phí)

1. Tạo tài khoản **https://github.com** (nếu chưa có).
2. Bấm **New repository** → đặt tên (VD: `khoa-hoc`) → **Public** → **Create**.
3. Bấm **uploading an existing file** → kéo thả **tất cả file** trong thư mục này (index.html, admin.html, config.js, supabase-setup.sql, HUONG-DAN.md) → **Commit changes**.
4. Vào **Settings** của repo → **Pages** → mục *Build and deployment* → Source chọn **Deploy from a branch** → Branch **main** / **/(root)** → **Save**.
5. Chờ 1–2 phút, web sẽ chạy tại:
   - Trang chính: `https://<tên-github>.github.io/khoa-hoc/`
   - Trang quản trị: `https://<tên-github>.github.io/khoa-hoc/admin.html`

> **Quan trọng:** sau khi có địa chỉ web thật, quay lại Supabase → **Authentication → URL Configuration**, thêm địa chỉ đó vào **Site URL / Redirect URLs** để đăng nhập ổn định.

---

## 💳 HỆ THỐNG HỌC PHÍ (tài khoản học viên + ví + nạp tiền + VIP)

Website đã tích hợp sẵn một nền tảng học có thu phí hoàn chỉnh:

- **Học viên tự đăng ký** tài khoản ngay trên trang chủ.
- **Ví tiền**: mỗi học viên có số dư. Nạp tiền bằng **chuyển khoản QR (VietQR)**, hệ thống **tự cộng tiền qua SePay**.
- **Mua khoá lẻ** bằng số dư (trừ theo giá bạn đặt) **hoặc** mua **gói VIP** mở tất cả khoá theo thời gian.
- **Xem thử miễn phí**: bài giảng đánh dấu “Miễn phí” ai cũng xem được; phần còn lại **khoá cho tới khi mua** (chặn ở phía server, không thể xem lén).

### A. Bật email đăng ký nhanh (khuyến nghị)
Vào Supabase → **Authentication → Providers → Email** → **tắt** “Confirm email” nếu muốn học viên đăng nhập được ngay sau khi đăng ký (không phải xác nhận email). Bật lại nếu muốn chặt chẽ hơn.

### B. Điền thông tin ngân hàng nhận tiền
Mở `config.js`, điền `BANK_CODE`, `BANK_ACCOUNT`, `BANK_ACCOUNT_NAME`. Mã QR nạp tiền sẽ tự sinh theo đúng số tiền + nội dung (mã nạp) cho từng học viên.

### C. Bật NẠP TIỀN TỰ ĐỘNG bằng SePay (khớp biến động số dư)
1. Đăng ký **https://sepay.vn** → liên kết tài khoản ngân hàng bạn dùng để nhận tiền.
2. Cài **Supabase CLI** trên máy (xem docs.supabase.com/guides/cli), rồi tại thư mục dự án chạy:
   ```bash
   supabase login
   supabase link --project-ref <PROJECT_REF>     # REF nằm trong Project Settings
   supabase functions deploy sepay-webhook --no-verify-jwt
   # (tuỳ chọn) đặt mã bí mật chống gọi giả:
   supabase secrets set SEPAY_API_KEY=chuoi-bi-mat-tuy-y
   ```
   `SUPABASE_URL` và `SUPABASE_SERVICE_ROLE_KEY` đã có sẵn cho Edge Function, không cần khai báo.
3. Vào **SePay → Cấu hình Webhook**, dán URL:
   `https://<PROJECT_REF>.supabase.co/functions/v1/sepay-webhook`
   (nếu có đặt `SEPAY_API_KEY`, khai báo cùng giá trị ở phần Authorization dạng `Apikey <chuỗi>`).
4. Xong! Khi học viên chuyển khoản đúng nội dung (mã `NAP...`), SePay báo về webhook và **ví được cộng tự động**.

> **Không dùng SePay cũng được:** vào admin → tab **Nạp tiền**, mỗi yêu cầu nạp có nút **“Duyệt (cộng tiền)”** để bạn xác nhận thủ công sau khi thấy tiền về.

### D. Quản lý trong trang admin
- **Tab Học viên**: xem danh sách, số dư, VIP; nút **Cộng tiền** để chỉnh số dư tay.
- **Tab Gói VIP**: thêm/sửa/xoá gói (tên, giá, số ngày — để trống = trọn đời). Đã có sẵn 3 gói mẫu: 1 tháng / 3 tháng / trọn đời.
- **Tab Nạp tiền**: duyệt yêu cầu nạp đang chờ + xem lịch sử giao dịch.
- **Đặt bài xem thử**: trong tab Bài giảng, tick **“Bài học miễn phí”** cho vài bài đầu mỗi khoá.

### E. Học viên dùng thế nào
Đăng ký → bấm **Nạp tiền** (quét QR chuyển khoản) → số dư tăng → vào khoá bấm **Mua khoá** (hoặc **Nâng cấp VIP**) → nội dung mở khoá ngay. Xem lại trong **Khoá học của tôi**.

---

## 📁 Về 37 thư mục khoá học của bạn

Website đã được nạp sẵn **37 thư mục** (ChatGPT, Facebook, TikTok, Zalo Ads, Shopee, SEO...) lấy từ link Google Drive bạn cung cấp:

- Trang chủ hiện tất cả 37 mục dạng thẻ, kèm số khoá (VD: “15 khoá”).
- **Bấm vào một thẻ → mở trang khoá học ngay trong web**, hiển thị **lưới video nhúng từ Google Drive** (bấm video nào xem video đó), kèm nút “Mở trong Drive”.
- Website chạy ngay ở **chế độ DEMO** (mở `index.html` là thấy đủ 37 mục) kể cả khi bạn chưa cài Supabase.
- Trong trang quản trị bạn có thể: đổi tên/icon/màu/thứ tự, sửa link Drive, đổi số khoá, thêm mục mới, hoặc xoá mục.

### ⚠️ BẮT BUỘC để video hiện được: đặt quyền chia sẻ thư mục

Lưới video chỉ hiện khi thư mục Drive để chế độ công khai:

1. Vào Google Drive → chuột phải vào thư mục → **Chia sẻ (Share)**.
2. Mục *Quyền truy cập chung* → chọn **“Bất kỳ ai có đường liên kết” (Anyone with the link)** → vai trò **Người xem (Viewer)**.
3. Làm cho từng thư mục trong 37 mục (hoặc chia sẻ thư mục cha chứa tất cả).

> Nếu khung video trống → gần như chắc chắn thư mục đó chưa mở quyền “Anyone with the link”.

### 🚀 (Tuỳ chọn) Bật NHẬP TỰ ĐỘNG từng video phát liền trên web

Nếu bạn muốn mình (Claude) tự đọc và nhập **từng video** vào web để phát trực tiếp (không dùng khung nhúng), hãy **chia sẻ 37 thư mục tới email `daoduykhuyen2@gmail.com`** (vai trò Viewer). Sau khi chia sẻ xong, quay lại nói với mình “đã share rồi” — mình sẽ quét toàn bộ và nhập tự động vào trang.

---

## 🎬 Cách thêm video cho bài giảng

Trong trang quản trị, ô **Link video** nhận nhiều dạng — chỉ cần dán link:

- **YouTube**: `https://www.youtube.com/watch?v=abc123` (nên dùng — nhẹ, không tốn dung lượng)
- **Google Drive**: mở video → Share → *Anyone with the link* → dán link `.../file/d/.../view`
- **Vimeo**: `https://vimeo.com/123456`
- **File MP4**: dán link .mp4 trực tiếp, hoặc bấm **⬆ File** để tải file lên Supabase.

> Storage miễn phí ~1GB. Video dài nên để trên YouTube/Drive rồi dán link, sẽ tiết kiệm và mượt hơn.

---

## 🛠 Quản lý hằng ngày

Tất cả làm trong `admin.html`:
- **Tab Khoá học**: thêm/sửa/xoá danh mục — đổi **tên**, icon, màu, link Drive, số khoá, **giá bán**, **giá gốc** (gạch ngang khuyến mãi), thứ tự.
- **Tab Bài giảng**: thêm/sửa/xoá bài, chọn khoá học, **dán link video hoặc tải video lên trực tiếp**, tải ảnh thumbnail, đặt Miễn phí, sắp thứ tự.
- Sửa xong là hiện ngay trên web chính (khách chỉ cần tải lại trang).

### 💵 Chỉnh giá tiền khoá học
Trong ô sửa khoá học có 2 trường giá:
- **Giá bán (VND)**: nhập số, VD `500000` → web hiện “500.000đ”. Nhập `0` → hiện “Miễn phí”. Để **trống** → hiện “Liên hệ”.
- **Giá gốc (VND)**: nhập số **cao hơn** giá bán → web tự gạch ngang giá gốc kiểu khuyến mãi (VD giá gốc 1.000.000đ, giá bán 500.000đ).

> Các khoá có sẵn số tiền trong tên (VD “ZALO ADS 5TR”, “KINH DOANH 20TR”) đã được **tự điền giá sẵn** và tách tên cho gọn.

### ⬆️ Tải video lên trực tiếp
Trong ô **Link video** của bài giảng, bấm nút **⬆ File** để tải video từ máy lên (tối đa 500MB/video, lưu trên Supabase Storage — bản miễn phí ~1GB). Video dài nên để trên Google Drive/YouTube rồi dán link để nhẹ và mượt hơn.

Khi cần đăng bản mới của giao diện: sửa file → upload lại lên GitHub (repo → Add file → Upload files → ghi đè).

---

## ❓ Sự cố thường gặp

| Hiện tượng | Cách xử lý |
|-----------|-----------|
| Trang admin báo “Chưa cấu hình Supabase” | Kiểm tra lại `config.js` đã dán đúng URL & anon key chưa, lưu file, tải lại trang |
| Đăng nhập báo “Sai email hoặc mật khẩu” | Tạo lại user ở Bước 4, nhớ tích **Auto Confirm User** |
| Thêm bài giảng báo lỗi quyền (permission/RLS) | Đảm bảo đã chạy `supabase-setup.sql` và bạn **đã đăng nhập** |
| Video không phát | Kiểm tra link đúng dạng; video Drive phải để chế độ *Anyone with the link* |
| Upload file báo lỗi | Mở web qua `http://localhost` hoặc GitHub Pages (không mở bằng `file://`) |

Chúc bạn ra mắt học viện marketing thành công! 🚀
