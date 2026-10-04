-- Jalankan di Supabase > SQL Editor

create table sesi (
  id uuid primary key default gen_random_uuid(),
  kode text unique not null,
  judul text not null,
  aktif boolean default true,
  dibuat timestamptz default now()
);

create table absensi (
  id uuid primary key default gen_random_uuid(),
  sesi_id uuid references sesi(id) on delete cascade,
  nim text not null,
  nama text not null,
  waktu timestamptz default now(),
  unique (sesi_id, nim)   -- satu NIM hanya bisa absen sekali per sesi
);

alter table sesi enable row level security;
alter table absensi enable row level security;

-- Mahasiswa (anon): boleh baca sesi & mengisi absensi
create policy "anon baca sesi" on sesi for select to anon using (true);
create policy "anon isi absensi" on absensi for insert to anon
  with check (exists (select 1 from sesi s where s.id = sesi_id and s.aktif));

-- Dosen (login): akses penuh
create policy "dosen kelola sesi" on sesi for all to authenticated using (true) with check (true);
create policy "dosen kelola absensi" on absensi for all to authenticated using (true) with check (true);
