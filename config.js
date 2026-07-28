// ============================================================
//  CẤU HÌNH WEBSITE KHOÁ HỌC
//  → Điền các giá trị bên dưới rồi lưu lại. Xem HUONG-DAN.md.
// ============================================================

window.APP_CONFIG = {
  // --- SUPABASE (Project Settings → API) ---
  SUPABASE_URL: "DÁN_PROJECT_URL_VÀO_ĐÂY",         // vd: https://abcxyz.supabase.co
  SUPABASE_ANON_KEY: "DÁN_ANON_PUBLIC_KEY_VÀO_ĐÂY", // KHÔNG dùng service_role

  // --- THƯƠNG HIỆU ---
  SITE_NAME: "Học Viện Marketing",
  SITE_TAGLINE: "Khoá học marketing thực chiến — từ ChatGPT đến bán hàng livestream",
  STORAGE_BUCKET: "media",

  // --- NGÂN HÀNG NHẬN NẠP TIỀN (tạo mã QR VietQR tự động) ---
  // BANK_CODE dùng mã ngắn của VietQR: MB, VCB, ACB, TCB, TPB, VPB, BIDV, VIB, MSB, OCB...
  BANK_CODE: "MB",
  BANK_ACCOUNT: "0000000000",          // số tài khoản nhận tiền
  BANK_ACCOUNT_NAME: "NGUYEN VAN A",   // tên chủ tài khoản (viết HOA không dấu)

  // Liên hệ hỗ trợ (hiện ở trang nạp tiền)
  SUPPORT_ZALO: ""                     // vd: https://zalo.me/0900000000 (để trống nếu chưa có)
};
