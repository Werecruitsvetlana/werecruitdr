-- Seguridad: solo el dueño del perfil de freelancer puede editarlo.
-- Ejecutar en Supabase > SQL Editor. Requiere que el portal use el enlace por correo (feLoadProfile).

ALTER TABLE public.freelancers ENABLE ROW LEVEL SECURITY;

-- 1) Ver las políticas actuales (revisar antes de borrar nada):
-- SELECT policyname, cmd, qual, with_check FROM pg_policies WHERE tablename = 'freelancers';

-- 2) Quitar cualquier política que permita UPDATE a todo el mundo (ajusta el nombre al que salga en el paso 1):
-- DROP POLICY IF EXISTS "<nombre de la política de update abierta>" ON public.freelancers;

-- 3) Solo puede actualizar quien inició sesión con el mismo email del perfil
CREATE POLICY "Freelancer edita su propio perfil" ON public.freelancers
  FOR UPDATE TO authenticated
  USING (lower(email) = lower(auth.jwt() ->> 'email'))
  WITH CHECK (lower(email) = lower(auth.jwt() ->> 'email'));

-- 4) OJO: si freelancers (o cualquier otra tabla) tiene una política tipo
--    FOR ALL USING (auth.role() = 'authenticated'), cualquier persona con cuenta
--    (candidatas, empresas o freelancers que entren por enlace) tendría acceso total.
--    Revísalo con:
-- SELECT tablename, policyname, cmd, qual FROM pg_policies
--  WHERE qual ILIKE '%authenticated%' OR qual = 'true';

-- 5) En Supabase > Authentication > URL Configuration, agrega como Redirect URL:
--    https://www.werecruitdr.com/?editar-freelancer=1
