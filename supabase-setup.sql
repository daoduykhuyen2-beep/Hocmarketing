-- ============================================================
--  THIẾT LẬP DATABASE CHO WEBSITE KHOÁ HỌC MARKETING
--  Cách dùng: Vào Supabase → SQL Editor → New query →
--  dán TOÀN BỘ file này vào → bấm RUN. Chạy 1 lần là đủ.
-- ============================================================

-- ----- 1) BẢNG DANH MỤC KHOÁ HỌC (categories) -----
create table if not exists public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  slug        text unique not null,
  description text default '',
  icon        text default '📚',            -- emoji icon hiển thị
  color       text default '#6366f1',       -- màu chủ đạo của thẻ
  drive_url   text default '',              -- link thư mục Google Drive
  course_count int,                          -- số khoá trong thư mục (có thể để trống)
  price        bigint,                        -- giá bán (VND), để trống = Miễn phí/Liên hệ
  original_price bigint,                      -- giá gốc (VND) để gạch ngang khuyến mãi
  sort_order  int  default 0,
  created_at  timestamptz default now()
);

-- Nếu bảng đã tạo từ trước, thêm cột mới (an toàn khi chạy lại):
alter table public.categories add column if not exists drive_url text default '';
alter table public.categories add column if not exists course_count int;
alter table public.categories add column if not exists price bigint;
alter table public.categories add column if not exists original_price bigint;

-- ----- 2) BẢNG BÀI GIẢNG (lessons) -----
create table if not exists public.lessons (
  id            uuid primary key default gen_random_uuid(),
  category_id   uuid references public.categories(id) on delete cascade,
  title         text not null,
  description   text default '',
  video_url     text default '',            -- link YouTube / Vimeo / Drive / MP4
  thumbnail_url text default '',            -- ảnh đại diện bài học
  duration      text default '',            -- ví dụ "12:30"
  is_free       boolean default true,
  sort_order    int  default 0,
  created_at    timestamptz default now()
);

create index if not exists lessons_category_idx on public.lessons(category_id);

-- ----- 3) BẬT ROW LEVEL SECURITY -----
alter table public.categories enable row level security;
alter table public.lessons    enable row level security;

-- Ai cũng ĐỌC được (khách xem web)
drop policy if exists "public read categories" on public.categories;
create policy "public read categories" on public.categories
  for select using (true);

drop policy if exists "public read lessons" on public.lessons;
create policy "public read lessons" on public.lessons
  for select using (true);

-- Chỉ người ĐÃ ĐĂNG NHẬP (admin) mới được thêm/sửa/xoá
drop policy if exists "auth write categories" on public.categories;
create policy "auth write categories" on public.categories
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "auth write lessons" on public.lessons;
create policy "auth write lessons" on public.lessons
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- ----- 4) STORAGE: BUCKET "media" LƯU ẢNH / VIDEO -----
insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do nothing;

-- Ai cũng xem được file trong bucket
drop policy if exists "public read media" on storage.objects;
create policy "public read media" on storage.objects
  for select using (bucket_id = 'media');

-- Chỉ admin đăng nhập mới upload / sửa / xoá file
drop policy if exists "auth upload media" on storage.objects;
create policy "auth upload media" on storage.objects
  for insert with check (bucket_id = 'media' and auth.role() = 'authenticated');

drop policy if exists "auth update media" on storage.objects;
create policy "auth update media" on storage.objects
  for update using (bucket_id = 'media' and auth.role() = 'authenticated');

drop policy if exists "auth delete media" on storage.objects;
create policy "auth delete media" on storage.objects
  for delete using (bucket_id = 'media' and auth.role() = 'authenticated');

-- ----- 5) SEED 37 THƯ MỤC KHOÁ HỌC (tên đã tách giá, kèm giá bán) -----
insert into public.categories (name, slug, icon, color, drive_url, description, course_count, price, sort_order) values
  ('MEME SOUND','meme-sound','🔊','#f97316','https://drive.google.com/drive/folders/1riKUP3kG9MzXNpzA5kA3E9YTyk1YhQTx','',null,500000,1),
  ('AFFILIATE','affiliate','💰','#f59e0b','https://drive.google.com/drive/folders/1BdVdwJcb2m7HlCFSj1StR1d7SBCtsY-w','',5,null,2),
  ('AMAZON - EBAY - DROPSHIP','amazon-ebay-dropship','📦','#ff9900','https://drive.google.com/drive/folders/1KCxHPjJBsHKnbYDo-uXtcWO0YC-ey05J','',10,null,3),
  ('CANVA - CAPCUT','canva-capcut','🎨','#8b5cf6','https://drive.google.com/drive/folders/1KB_A77vHI42K16hg109sQPvAaYHyEwcZ','',6,null,4),
  ('CHAT GPT','chat-gpt','🤖','#10a37f','https://drive.google.com/drive/folders/13wXnoBRVrVJJd3EnHz94Sv9GMKz09Gvf','',15,null,5),
  ('CHAT BOT','chat-bot','💬','#06b6d4','https://drive.google.com/drive/folders/1S31g0kbGyBI5kBzolEZcYk9X0FyLP05j','',2,null,6),
  ('CHỨNG KHOÁN','chung-khoan','📈','#16a34a','https://drive.google.com/drive/folders/1heI1EshDcy77RbRrdKKmDnZAcGJiDspH','',9,null,7),
  ('CONTENT','content','✍️','#ec4899','https://drive.google.com/drive/folders/1yAcHDB1c2n5dc98NKhLANP08zTFoIFBi','',7,null,8),
  ('DROPSHIP LINH THẠCH MỚI NHẤT','dropship-linh-thach-moi-nhat','🛒','#0ea5e9','https://drive.google.com/drive/folders/1p9psQ4qb_MwCXVyzud83ODtediR9zlKU','',null,25000000,9),
  ('FACEBOOK','facebook','📘','#1877f2','https://drive.google.com/drive/folders/10vQ-N4ViZp3uHDQJygjTgaOYnCsWIl6c','',36,null,10),
  ('TÌM NGUỒN HÀNG','tim-nguon-hang','🔍','#14b8a6','https://drive.google.com/drive/folders/1igjZYrESkAUNtkT8jl67JaXtYH6mH1F7','',12,null,11),
  ('GOOGLE','google','🌐','#ea4335','https://drive.google.com/drive/folders/1CfLLmnKNuskdE1CKqM0ADswwRxCjeEX0','',8,null,12),
  ('HẠ GỤC KHÁCH HÀNG','ha-guc-khach-hang','🎯','#ef4444','https://drive.google.com/drive/folders/1ciKdQP9gyo_NSb7TUyWbERtpn96_hXa4','',3,null,13),
  ('ĐỈNH CAO CHỐT SALE','dinh-cao-chot-sale','🤝','#e11d48','https://drive.google.com/drive/folders/1F9Q89xFiqu62D363Ynjeb5QLaWg-vUka','',null,1000000,14),
  ('LÀM VIDEO BÁN HÀNG','lam-video-ban-hang','🎬','#f43f5e','https://drive.google.com/drive/folders/1XVKDElEUendGprQTtixJAilfIQ6mBsUT','',null,500000,15),
  ('LIVESTREAM BÁN HÀNG ONLINE','livestream-ban-hang-online','📹','#ef4444','https://drive.google.com/drive/folders/1jdaZfx9A71mmmmPQ5PrScNWZeOcniXYv','',null,10000000,16),
  ('KIẾM TIỀN YOUTUBE','kiem-tien-youtube','▶️','#ff0000','https://drive.google.com/drive/folders/15_yeVrA7azrftHyxUyR2AAq9JovaYnfi','',10,null,17),
  ('KINH DOANH','kinh-doanh','💼','#6366f1','https://drive.google.com/drive/folders/1Ls41NbYOsfxCURbKdiqEuNuqVT8kuF6C','',null,20000000,18),
  ('LAZADA FULL','lazada-full','🛍️','#0f146e','https://drive.google.com/drive/folders/1IdagTa2Ax9j0nLc_wrVixLdOt13VN1Sw','',null,4000000,19),
  ('MINH XIN CHÀO','minh-xin-chao','👋','#0d9488','https://drive.google.com/drive/folders/1TXbziTYvDY7ykp8b9bCCh3-5z56MJw9V','',null,10000000,20),
  ('NHẬP HÀNG TRUNG QUỐC (3 Phần)','nhap-hang-trung-quoc-3-phan','🏭','#dc2626','https://drive.google.com/drive/folders/1j8hEIV9pp9zokfZ_4qtPprZiTAnf2BfQ','',null,null,21),
  ('PHOTOSHOP - EDIT VIDEO','photoshop-edit-video','🖼️','#2563eb','https://drive.google.com/drive/folders/1BY2HjB2Um-a35R24HpMiW8JdVi3kFv0_','',7,null,22),
  ('HIGH LEVEL RAINMAKER','high-level-rainmaker','💎','#a855f7','https://drive.google.com/drive/folders/1S5tt1ZT1mRoJOi-ugS79V4GM7eFaGd8A','',null,null,23),
  ('SEO WEBSITE','seo-website','🔧','#22c55e','https://drive.google.com/drive/folders/1wOuvUZWb_fL3eVsGvUmXhIj2MGOtH8TR','',15,null,24),
  ('SHOPEE','shopee','🧡','#ee4d2d','https://drive.google.com/drive/folders/1BoBH70OQdTXzy5quf5A710i8STExvXQ4','',15,null,25),
  ('TIKTOK','tiktok','🎵','#111827','https://drive.google.com/drive/folders/1cEqe6TTpAKGk2FksZu1uXfWWhKLVigYe','',35,null,26),
  ('ZALO ADS','zalo-ads','📣','#0068ff','https://drive.google.com/drive/folders/1J7RSJhhh4_DcBE_rEsKXV9ENxyHyS0Vw','',null,5000000,27),
  ('CHU MINH HẠNH','chu-minh-hanh','👤','#7c3aed','https://drive.google.com/drive/folders/1bz13thUUaQiuXaafZh5V718yt4kieAlf','',6,null,28),
  ('LẬP TRÌNH','lap-trinh','💻','#334155','https://drive.google.com/drive/folders/1eAG9Vg86Vi4AfeeF-BX0wwmRhkSHxYsA','',null,null,29),
  ('NGÔ MINH TUẤN','ngo-minh-tuan','🧑‍🏫','#0891b2','https://drive.google.com/drive/folders/1r77kp8WGZwqpAA0PFN8t9ENfZApK8ZuX','',5,null,30),
  ('Excel','excel','📊','#217346','https://drive.google.com/drive/folders/1xK28cx0jbmSEFFoHv_dk4O_C9C5pheru','',null,null,31),
  ('NGOẠI NGỮ','ngoai-ngu','🗣️','#f59e0b','https://drive.google.com/drive/folders/1m3HW9PjPssyrWCOvXIb3qUc1QDqP-yiQ','',4,null,32),
  ('EMAIL MARKETING','email-marketing','📧','#3b82f6','https://drive.google.com/drive/folders/16ZIXbUc1AsVqXSQ4PzA_KNE80zJ_A6lC','',5,null,33),
  ('SINH TRẮC VÂN TAY','sinh-trac-van-tay','🖐️','#9333ea','https://drive.google.com/drive/folders/1Yo3p8xusaNIScMH-h4zgDWtRyCD5xxiu','',null,null,34),
  ('Instagram','instagram','📸','#e1306c','https://drive.google.com/drive/folders/1Dl7hK0mgv0gKggoshMmrvWHTGfUhTiyE','',null,null,35),
  ('SENDO','sendo','🏬','#e60012','https://drive.google.com/drive/folders/1Ry_-SoStsLDFk5v13grHCvX3hDr215K_','',null,null,36),
  ('Update mới','update-moi','🆕','#8b5cf6','https://drive.google.com/drive/folders/1W7owO00ovvua45DEtzVthxpQ0T-AmyEX','',null,null,37)
on conflict (slug) do nothing;

-- HOÀN TẤT ✅  (Thêm/sửa/xoá & chỉnh giá ngay trong admin.html)

-- ============================================================
--  PHẦN 2: HỆ THỐNG TÀI KHOẢN HỌC VIÊN + VÍ TIỀN + THANH TOÁN
--  (Chạy tiếp phần này trong cùng SQL Editor)
-- ============================================================

-- ----- 6) HỒ SƠ NGƯỜI DÙNG (profiles) -----
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  email      text,
  full_name  text default '',
  balance    bigint not null default 0,        -- số dư ví (VND)
  is_admin   boolean not null default false,   -- true = quản trị viên
  vip_until  timestamptz,                       -- VIP còn hạn tới khi nào
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;

-- Hàm kiểm tra admin (dùng nhiều nơi)
create or replace function public.is_admin(uid uuid)
returns boolean language sql security definer stable set search_path = public as $$
  select coalesce((select is_admin from public.profiles where id = uid), false);
$$;

-- Người dùng chỉ đọc hồ sơ của mình; admin đọc tất cả. KHÔNG cho update trực tiếp
-- (số dư/VIP chỉ thay đổi qua các hàm bảo mật bên dưới).
drop policy if exists "profile read" on public.profiles;
create policy "profile read" on public.profiles
  for select using (id = auth.uid() or public.is_admin(auth.uid()));

-- Tự tạo hồ sơ khi có người đăng ký
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id, email) values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ----- 7) GÓI VIP (packages) -----
create table if not exists public.packages (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  price         bigint not null,
  duration_days int,                 -- null = trọn đời
  description   text default '',
  sort_order    int default 0,
  active        boolean default true,
  created_at    timestamptz default now()
);
alter table public.packages enable row level security;
drop policy if exists "packages read" on public.packages;
create policy "packages read" on public.packages
  for select using (active or public.is_admin(auth.uid()));
drop policy if exists "packages admin" on public.packages;
create policy "packages admin" on public.packages
  for all using (public.is_admin(auth.uid())) with check (public.is_admin(auth.uid()));

-- ----- 8) SỞ HỮU KHOÁ (enrollments) -----
create table if not exists public.enrollments (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users(id) on delete cascade,
  category_id uuid references public.categories(id) on delete cascade,
  created_at  timestamptz default now(),
  unique(user_id, category_id)
);
alter table public.enrollments enable row level security;
drop policy if exists "enroll read" on public.enrollments;
create policy "enroll read" on public.enrollments
  for select using (user_id = auth.uid() or public.is_admin(auth.uid()));

-- ----- 9) SỔ GIAO DỊCH VÍ (wallet_tx) -----
create table if not exists public.wallet_tx (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade,
  amount     bigint not null,        -- + nạp, - mua
  type       text not null,          -- topup | purchase_course | purchase_vip | admin_credit
  note       text default '',
  created_at timestamptz default now()
);
alter table public.wallet_tx enable row level security;
drop policy if exists "tx read" on public.wallet_tx;
create policy "tx read" on public.wallet_tx
  for select using (user_id = auth.uid() or public.is_admin(auth.uid()));

-- ----- 10) YÊU CẦU NẠP TIỀN (topup_requests) -----
create table if not exists public.topup_requests (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid references auth.users(id) on delete cascade,
  amount       bigint not null,
  code         text unique not null,   -- mã ghi trong nội dung chuyển khoản
  status       text not null default 'pending',  -- pending | completed | cancelled
  created_at   timestamptz default now(),
  completed_at timestamptz
);
alter table public.topup_requests enable row level security;
drop policy if exists "topup read" on public.topup_requests;
create policy "topup read" on public.topup_requests
  for select using (user_id = auth.uid() or public.is_admin(auth.uid()));

-- ----- 11) CHẶN NỘI DUNG: chỉ lộ link Drive/video khi ĐÃ MUA -----
-- Khoá bảng gốc: chỉ admin đọc trực tiếp; khách xem qua view an toàn (không có link).
drop policy if exists "public read categories" on public.categories;
drop policy if exists "auth write categories" on public.categories;
drop policy if exists "cat admin all" on public.categories;
create policy "cat admin all" on public.categories
  for all using (public.is_admin(auth.uid())) with check (public.is_admin(auth.uid()));

drop policy if exists "public read lessons" on public.lessons;
drop policy if exists "auth write lessons" on public.lessons;
drop policy if exists "les admin all" on public.lessons;
create policy "les admin all" on public.lessons
  for all using (public.is_admin(auth.uid())) with check (public.is_admin(auth.uid()));

-- View danh mục công khai (KHÔNG chứa drive_url)
create or replace view public.catalog as
  select id, name, slug, description, icon, color, course_count, price, original_price,
         sort_order, (coalesce(drive_url,'') <> '') as has_drive
  from public.categories;
grant select on public.catalog to anon, authenticated;

-- View bài giảng công khai (KHÔNG chứa video_url)
create or replace view public.lessons_catalog as
  select id, category_id, title, description, thumbnail_url, duration, is_free, sort_order
  from public.lessons;
grant select on public.lessons_catalog to anon, authenticated;

-- Hàm kiểm tra quyền truy cập khoá
create or replace function public.has_access(uid uuid, cat uuid)
returns boolean language sql security definer stable set search_path = public as $$
  select case
    when uid is null then false
    when exists(select 1 from public.profiles p where p.id = uid and p.vip_until is not null and p.vip_until > now()) then true
    when exists(select 1 from public.enrollments e where e.user_id = uid and e.category_id = cat) then true
    when coalesce((select price from public.categories where id = cat), 1) = 0 then true
    else false end;
$$;

-- Lấy link Drive (chỉ khi đã mua / VIP / khoá miễn phí)
create or replace function public.get_drive_url(cat uuid)
returns text language plpgsql security definer stable set search_path = public as $$
declare d text;
begin
  if not public.has_access(auth.uid(), cat) then return null; end if;
  select drive_url into d from public.categories where id = cat;
  return d;
end $$;

-- Lấy link video (bài miễn phí ai cũng xem; còn lại phải có quyền)
create or replace function public.get_video(lesson uuid)
returns text language plpgsql security definer stable set search_path = public as $$
declare v text; f boolean; c uuid;
begin
  select video_url, is_free, category_id into v, f, c from public.lessons where id = lesson;
  if f then return v; end if;
  if public.has_access(auth.uid(), c) then return v; end if;
  return null;
end $$;

-- ----- 12) HÀM THANH TOÁN -----
-- Mua 1 khoá bằng số dư
create or replace function public.purchase_course(cat uuid)
returns json language plpgsql security definer set search_path = public as $$
declare u uuid; p bigint; bal bigint; nm text;
begin
  u := auth.uid();
  if u is null then return json_build_object('ok',false,'message','Bạn chưa đăng nhập'); end if;
  if exists(select 1 from public.enrollments where user_id=u and category_id=cat) then
    return json_build_object('ok',true,'message','Bạn đã sở hữu khoá này'); end if;
  select price, name into p, nm from public.categories where id=cat;
  if p is null then return json_build_object('ok',false,'message','Khoá này không bán trực tiếp, vui lòng liên hệ'); end if;
  if p = 0 then
    insert into public.enrollments(user_id,category_id) values (u,cat) on conflict do nothing;
    return json_build_object('ok',true,'message','Đã mở khoá miễn phí'); end if;
  select balance into bal from public.profiles where id=u for update;
  if bal < p then return json_build_object('ok',false,'message','Số dư không đủ, vui lòng nạp thêm','need',p-bal); end if;
  update public.profiles set balance = balance - p where id=u;
  insert into public.enrollments(user_id,category_id) values (u,cat) on conflict do nothing;
  insert into public.wallet_tx(user_id,amount,type,note) values (u,-p,'purchase_course',nm);
  return json_build_object('ok',true,'message','Mua khoá thành công','balance',bal-p);
end $$;

-- Mua gói VIP
create or replace function public.purchase_vip(pkg uuid)
returns json language plpgsql security definer set search_path = public as $$
declare u uuid; pr bigint; dur int; bal bigint; base timestamptz; newv timestamptz; nm text;
begin
  u := auth.uid();
  if u is null then return json_build_object('ok',false,'message','Bạn chưa đăng nhập'); end if;
  select price,duration_days,name into pr,dur,nm from public.packages where id=pkg and active;
  if pr is null then return json_build_object('ok',false,'message','Gói không tồn tại'); end if;
  select balance into bal from public.profiles where id=u for update;
  if bal < pr then return json_build_object('ok',false,'message','Số dư không đủ, vui lòng nạp thêm','need',pr-bal); end if;
  select greatest(now(), coalesce(vip_until, now())) into base from public.profiles where id=u;
  if dur is null then newv := now() + interval '100 years'; else newv := base + (dur || ' days')::interval; end if;
  update public.profiles set balance=balance-pr, vip_until=newv where id=u;
  insert into public.wallet_tx(user_id,amount,type,note) values (u,-pr,'purchase_vip',nm);
  return json_build_object('ok',true,'message','Kích hoạt VIP thành công','vip_until',newv,'balance',bal-pr);
end $$;

-- Tạo yêu cầu nạp tiền -> trả về mã ghi trong nội dung chuyển khoản
create or replace function public.create_topup(amt bigint)
returns json language plpgsql security definer set search_path = public as $$
declare u uuid; c text;
begin
  u := auth.uid();
  if u is null then return json_build_object('ok',false,'message','Bạn chưa đăng nhập'); end if;
  if amt < 10000 then return json_build_object('ok',false,'message','Số tiền tối thiểu 10.000đ'); end if;
  c := 'NAP' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
  insert into public.topup_requests(user_id,amount,code) values (u,amt,c);
  return json_build_object('ok',true,'code',c,'amount',amt);
end $$;

-- Xử lý biến động số dư từ SePay (chỉ webhook gọi bằng service role)
create or replace function public.process_sepay(p_code text, p_amount bigint)
returns json language plpgsql security definer set search_path = public as $$
declare r public.topup_requests;
begin
  select * into r from public.topup_requests where code=p_code and status='pending' for update;
  if not found then return json_build_object('ok',false,'message','Không tìm thấy mã nạp'); end if;
  if p_amount < r.amount then return json_build_object('ok',false,'message','Số tiền chưa đủ'); end if;
  update public.topup_requests set status='completed', completed_at=now() where id=r.id;
  update public.profiles set balance = balance + p_amount where id=r.user_id;
  insert into public.wallet_tx(user_id,amount,type,note) values (r.user_id,p_amount,'topup','Nạp SePay '||p_code);
  return json_build_object('ok',true);
end $$;

-- Admin cộng tiền tay
create or replace function public.admin_credit(target uuid, amt bigint, note text default '')
returns json language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin(auth.uid()) then return json_build_object('ok',false,'message','Không có quyền'); end if;
  update public.profiles set balance=balance+amt where id=target;
  insert into public.wallet_tx(user_id,amount,type,note) values (target,amt,'admin_credit',coalesce(nullif(note,''),'Admin cộng tiền'));
  return json_build_object('ok',true);
end $$;

-- Admin duyệt 1 yêu cầu nạp (dự phòng khi không dùng SePay)
create or replace function public.admin_confirm_topup(tid uuid)
returns json language plpgsql security definer set search_path = public as $$
declare r public.topup_requests;
begin
  if not public.is_admin(auth.uid()) then return json_build_object('ok',false,'message','Không có quyền'); end if;
  select * into r from public.topup_requests where id=tid and status='pending' for update;
  if not found then return json_build_object('ok',false,'message','Không tìm thấy yêu cầu'); end if;
  update public.topup_requests set status='completed', completed_at=now() where id=tid;
  update public.profiles set balance=balance+r.amount where id=r.user_id;
  insert into public.wallet_tx(user_id,amount,type,note) values (r.user_id,r.amount,'topup','Nạp (admin duyệt) '||r.code);
  return json_build_object('ok',true);
end $$;

-- Quyền gọi hàm
grant execute on function public.has_access(uuid,uuid) to anon, authenticated;
grant execute on function public.get_drive_url(uuid) to anon, authenticated;
grant execute on function public.get_video(uuid) to anon, authenticated;
grant execute on function public.purchase_course(uuid) to authenticated;
grant execute on function public.purchase_vip(uuid) to authenticated;
grant execute on function public.create_topup(bigint) to authenticated;
grant execute on function public.admin_credit(uuid,bigint,text) to authenticated;
grant execute on function public.admin_confirm_topup(uuid) to authenticated;
revoke execute on function public.process_sepay(text,bigint) from public, anon, authenticated;
grant  execute on function public.process_sepay(text,bigint) to service_role;

-- ----- 13) SEED GÓI VIP MẪU -----
insert into public.packages (name, price, duration_days, description, sort_order)
select * from (values
  ('VIP 1 Tháng',   199000,  30,  'Mở tất cả khoá học trong 30 ngày', 1),
  ('VIP 3 Tháng',   499000,  90,  'Mở tất cả khoá học trong 90 ngày (tiết kiệm hơn)', 2),
  ('VIP Trọn Đời', 1990000,  null,'Mở tất cả khoá học vĩnh viễn + cập nhật mới', 3)
) as v(name,price,duration_days,description,sort_order)
where not exists (select 1 from public.packages);

-- HOÀN TẤT PHẦN 2 ✅
-- ⚠️ NHỚ: sau khi tạo tài khoản admin, chạy:
--   update public.profiles set is_admin = true where email = 'EMAIL_ADMIN_CUA_BAN';
