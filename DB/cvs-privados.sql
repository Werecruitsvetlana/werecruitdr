-- CVs privados. Bucket nuevo 'cvs-privados' (no público). 'archivos' se queda público para fotos y portafolios de freelancers.
-- Quién puede LEER un CV: la administradora, la persona dueña del CV (por su email o su perfil) y la empresa dueña de la vacante.
-- Quién puede SUBIR: cualquiera desde el portal, solo en la carpeta cvs/.
begin;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('cvs-privados', 'cvs-privados', false, 5242880,
        array['application/pdf','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document'])
on conflict (id) do nothing;

create policy "CVs: subir desde el portal" on storage.objects
  for insert to anon, authenticated
  with check (bucket_id = 'cvs-privados' and name like 'cvs/%');

create policy "CVs: admin total" on storage.objects
  for all to authenticated
  using (bucket_id = 'cvs-privados' and es_admin())
  with check (bucket_id = 'cvs-privados' and es_admin());

create policy "CVs: leer el propio o el de mi vacante" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'cvs-privados' and (
      -- dueña del CV por su perfil
      exists (select 1 from public.perfiles_candidato pc
              where pc.auth_uid = auth.uid() and pc.cv_url like '%/' || name)
      -- dueña del CV por el email con el que aplicó
      or exists (select 1 from public.candidatos c
              where lower(c.email) = lower(auth.jwt() ->> 'email') and c.cv_url like '%/' || name)
      or exists (select 1 from public.aplicaciones_vacante av
              where lower(av.email) = lower(auth.jwt() ->> 'email') and av.cv_url like '%/' || name)
      -- empresa dueña de la vacante a la que aplicaron
      or exists (select 1 from public.aplicaciones_vacante av
              join public.vacantes_portal v on v.id = av.vacante_id
              join public.empresas_portal e on e.id = v.empresa_id
              where e.auth_uid = auth.uid() and av.cv_url like '%/' || name)
    )
  );

commit;

-- DESPUÉS de mover los CVs viejos (DB/mover-cvs.js), cerrar la lectura pública de la carpeta cvs/ en 'archivos':
-- drop policy "Archivos son públicos para leer" on storage.objects;
-- create policy "Archivos: públicos salvo CVs" on storage.objects for select to anon, authenticated
--   using (bucket_id = 'archivos' and name not like 'cvs/%');
-- (el bucket 'archivos' sigue marcado como público, así que esta política solo frena listados; lo importante es que la carpeta cvs/ quede vacía)
