-- Seguridad freelancers — EJECUTADO en Supabase el 2026-11-11.
-- Antes existía "Freelancer puede actualizar su perfil" (UPDATE USING true): cualquiera podía editar cualquier perfil.

begin;
-- Quitar toda política de UPDATE abierta (qual = true) en freelancers
do $$ declare r record; begin
  for r in select policyname from pg_policies
           where schemaname = 'public' and tablename = 'freelancers' and cmd = 'UPDATE' and qual = 'true'
  loop execute format('drop policy %I on public.freelancers', r.policyname); end loop;
end $$;

-- Solo edita quien inició sesión (enlace por correo) con el mismo email del perfil
create policy "Freelancer edita su propio perfil" on public.freelancers
  for update to authenticated
  using (lower(email) = lower(auth.jwt() ->> 'email'))
  with check (lower(email) = lower(auth.jwt() ->> 'email'));

-- Que pueda cargar su perfil aunque todavía no esté aprobado
create policy "Freelancer ve su propio perfil" on public.freelancers
  for select to authenticated
  using (lower(email) = lower(auth.jwt() ->> 'email'));
commit;

-- Pendiente en Supabase > Authentication > URL Configuration > Redirect URLs:
--   https://www.werecruitdr.com/?editar-freelancer=1
