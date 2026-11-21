-- Buat bucket 'kosfinder-demo' terlebih dahulu di Storage Dashboard.
-- Public: ON (UNTUK FOTO DEMO NONPRIVAT SAJA)
-- File size limit: 5 MB; allowed MIME: image/jpeg, image/png
-- Di Authentication -> Settings/Providers aktifkan Anonymous Sign-Ins.
-- Tidak memerlukan public.profiles, role owner, atau tabel Worksheet 9.

-- Policy ini hanya mengizinkan pengguna Supabase yang sudah sign in
-- secara anonymous dan mengunggah pada folder auth.uid()-nya sendiri.
drop policy if exists "ws10_demo_upload_own_folder" on storage.objects;
create policy "ws10_demo_upload_own_folder"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'kosfinder-demo'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

-- Tidak membuat UPDATE/DELETE: aplikasi demo hanya menambah file baru.
-- Untuk penggunaan produksi: gunakan identitas nyata, kuota, antiabuse,
-- aturan penghapusan, dan pertimbangkan private bucket + signed URL.
