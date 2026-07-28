// ============================================================
//  SePay Webhook — Nạp tiền tự động
//  Deploy:  supabase functions deploy sepay-webhook --no-verify-jwt
//  Cấu hình trên SePay: URL = https://<project>.supabase.co/functions/v1/sepay-webhook
//  (Tuỳ chọn) đặt secret SEPAY_API_KEY để chống gọi giả:
//     supabase secrets set SEPAY_API_KEY=chuoi-bi-mat-cua-ban
// ============================================================
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    // 1) (Tuỳ chọn) kiểm tra API key SePay gửi kèm
    const expected = Deno.env.get("SEPAY_API_KEY");
    if (expected) {
      const auth = req.headers.get("authorization") || "";
      // SePay gửi dạng: "Apikey XXXX"
      const token = auth.replace(/^Apikey\s+/i, "").trim();
      if (token !== expected) {
        return json({ success: false, message: "Sai API key" }, 401);
      }
    }

    // 2) Đọc dữ liệu giao dịch từ SePay
    const body = await req.json().catch(() => ({}));
    // SePay có thể dùng các tên trường khác nhau tuỳ cấu hình:
    const content: string =
      (body.content ?? body.description ?? body.transferContent ?? body.memo ?? "") + "";
    const amount = Number(
      body.transferAmount ?? body.amount ?? body.transfer_amount ?? 0
    );

    // 3) Tách mã nạp (dạng NAP + chữ/số) từ nội dung chuyển khoản
    const m = content.toUpperCase().match(/NAP[A-Z0-9]+/);
    if (!m) {
      return json({ success: true, message: "Không tìm thấy mã nạp trong nội dung" });
    }
    const code = m[0];

    // 4) Gọi hàm cộng ví (dùng service role -> bỏ qua RLS)
    const url = Deno.env.get("SUPABASE_URL")!;
    const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const sb = createClient(url, key);
    const { data, error } = await sb.rpc("process_sepay", {
      p_code: code,
      p_amount: amount,
    });

    if (error) return json({ success: false, message: error.message }, 200);
    return json({ success: true, code, amount, result: data });
  } catch (e) {
    return json({ success: false, message: String(e) }, 200);
  }
});

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "content-type": "application/json" },
  });
}
