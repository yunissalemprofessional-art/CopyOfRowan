-- Run this in the Supabase SQL Editor (Project > SQL Editor > New query)
-- for a new/blank Supabase project backing this dashboard.

-- ============================================================
-- app_state table — key/value sync store used by sync.js and
-- gym.html's cloud sync (goals, stack, water, finance, gym).
-- ============================================================
create table if not exists public.app_state (
  key text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;

drop policy if exists "anon select" on public.app_state;
drop policy if exists "anon insert" on public.app_state;
drop policy if exists "anon update" on public.app_state;

create policy "anon select" on public.app_state
  for select to anon using (true);

create policy "anon insert" on public.app_state
  for insert to anon with check (true);

create policy "anon update" on public.app_state
  for update to anon using (true) with check (true);

-- After running the above, also enable Realtime for app_state:
-- Database > Replication > toggle "app_state" on.

-- ============================================================
-- progress-photos storage bucket — gym.html progress photos,
-- uploaded via uploadPhotoToStorage() instead of stored as
-- base64 in the app_state JSONB row.
-- ============================================================
insert into storage.buckets (id, name, public)
values ('progress-photos', 'progress-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "anon upload progress-photos" on storage.objects;
drop policy if exists "anon read progress-photos"   on storage.objects;
drop policy if exists "anon delete progress-photos" on storage.objects;

create policy "anon upload progress-photos"
  on storage.objects for insert with check (bucket_id = 'progress-photos');

create policy "anon read progress-photos"
  on storage.objects for select using (bucket_id = 'progress-photos');

create policy "anon delete progress-photos"
  on storage.objects for delete using (bucket_id = 'progress-photos');
