-- Mi perfil: CV guardado + Mis postulaciones. Ejecutado en Supabase el 2026-11-11.
begin;

-- 1) CV en el perfil de la candidata (la política "Candidata edita su perfil" ya cubre estas columnas)
alter table public.perfiles_candidato
  add column if not exists cv_url text,
  add column if not exists cv_nombre text,
  add column if not exists cv_actualizado timestamptz;

-- 2) Postulaciones de la persona con sesión iniciada (email confirmado).
--    Solo las que vienen del portal público; estados simplificados, nunca muestra rechazos.
create or replace function public.mis_postulaciones()
returns table (titulo text, empresa text, estado text, fecha timestamptz)
language sql stable security definer set search_path = public
as $$
  with yo as (
    select lower(email) as e from auth.users
    where id = auth.uid() and email_confirmed_at is not null
  )
  select p.titulo, em.nombre,
         case cp.estado
           when 'contratado' then 'contratada'
           when 'enviado' then 'en_proceso'
           when 'en_entrevista' then 'en_proceso'
           when 'aprobado' then 'en_proceso'
           else 'recibida'
         end,
         cp.created_at
  from candidato_posicion cp
  join candidatos c on c.id = cp.candidato_id
  join posiciones p on p.id = cp.posicion_id
  left join empresas em on em.id = p.empresa_id
  join yo on lower(c.email) = yo.e
  where c.fuente in ('Portal público', 'Quick Apply', 'portal', 'Solicitud rápida')
  union all
  select vp.titulo, ep.nombre_empresa, 'recibida', av.created_at
  from aplicaciones_vacante av
  join vacantes_portal vp on vp.id = av.vacante_id
  left join empresas_portal ep on ep.id = vp.empresa_id
  join yo on lower(av.email) = yo.e
  order by 4 desc;
$$;

revoke all on function public.mis_postulaciones() from public, anon;
grant execute on function public.mis_postulaciones() to authenticated;

commit;
