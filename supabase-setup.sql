-- =========================================================
-- 簡單記帳：Supabase 初始化 SQL
-- 直接整段貼到 Supabase Dashboard → SQL Editor → Run
-- =========================================================

-- 1) 記帳資料
create table if not exists public.entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('income', 'expense')),
  amount numeric(14, 2) not null check (amount > 0),
  entry_date date not null,
  category text not null,
  title text not null,
  note text not null default '',
  created_at timestamptz not null default now()
);

create index if not exists entries_user_date_idx
  on public.entries(user_id, entry_date desc);

-- 2) 每個使用者自己的設定
create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  period_start date,
  period_end date,
  selected_month text,
  updated_at timestamptz not null default now(),
  constraint valid_period check (
    period_start is null
    or period_end is null
    or period_start <= period_end
  )
);

-- 3) 開啟 RLS
alter table public.entries enable row level security;
alter table public.user_settings enable row level security;

-- 4) entries：只允許本人讀寫自己的資料
drop policy if exists "entries_select_own" on public.entries;
create policy "entries_select_own"
on public.entries
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "entries_insert_own" on public.entries;
create policy "entries_insert_own"
on public.entries
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "entries_update_own" on public.entries;
create policy "entries_update_own"
on public.entries
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "entries_delete_own" on public.entries;
create policy "entries_delete_own"
on public.entries
for delete
to authenticated
using ((select auth.uid()) = user_id);

-- 5) user_settings：只允許本人讀寫自己的設定
drop policy if exists "settings_select_own" on public.user_settings;
create policy "settings_select_own"
on public.user_settings
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "settings_insert_own" on public.user_settings;
create policy "settings_insert_own"
on public.user_settings
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "settings_update_own" on public.user_settings;
create policy "settings_update_own"
on public.user_settings
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "settings_delete_own" on public.user_settings;
create policy "settings_delete_own"
on public.user_settings
for delete
to authenticated
using ((select auth.uid()) = user_id);

-- 6) 只授權登入者必要權限
grant select, insert, update, delete on public.entries to authenticated;
grant select, insert, update, delete on public.user_settings to authenticated;
