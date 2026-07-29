-- =============================================
-- PORTAL PÚBLICO — Nuevas funcionalidades
-- Ejecutar en Supabase SQL Editor
-- =============================================

-- =============================================
-- 1. PERFILES DE CANDIDATO (Quick Apply + Perfil público)
-- =============================================
CREATE TABLE public.perfiles_candidato (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  email text NOT NULL UNIQUE,
  password text NOT NULL,
  nombre text NOT NULL,
  apellido text,
  telefono text,
  ciudad text,
  linkedin text,
  foto_url text,
  titulo_profesional text,
  resumen text,
  habilidades text[],
  anos_experiencia integer,
  salario_esperado numeric,
  nivel text DEFAULT 'mid' CHECK (nivel IN ('junior', 'mid', 'senior', 'ejecutivo')),
  sector text,
  modalidad_preferida text,
  portafolio_url text,
  disponible boolean DEFAULT true,
  perfil_publico boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.perfiles_candidato ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Registro público perfiles" ON public.perfiles_candidato FOR INSERT WITH CHECK (true);
CREATE POLICY "Ver perfiles públicos" ON public.perfiles_candidato FOR SELECT USING (true);
CREATE POLICY "Actualizar perfil propio" ON public.perfiles_candidato FOR UPDATE USING (true);
CREATE POLICY "Admin total perfiles" ON public.perfiles_candidato FOR ALL USING (auth.role() = 'authenticated');

-- =============================================
-- 2. EMPRESAS PORTAL — Campos adicionales para página pública
-- =============================================
ALTER TABLE public.empresas_portal
  ADD COLUMN IF NOT EXISTS descripcion text,
  ADD COLUMN IF NOT EXISTS logo_url text,
  ADD COLUMN IF NOT EXISTS sitio_web text,
  ADD COLUMN IF NOT EXISTS ubicacion text,
  ADD COLUMN IF NOT EXISTS tamano text,
  ADD COLUMN IF NOT EXISTS beneficios text[],
  ADD COLUMN IF NOT EXISTS cultura text,
  ADD COLUMN IF NOT EXISTS fotos text[],
  ADD COLUMN IF NOT EXISTS perfil_publico boolean DEFAULT false;

-- =============================================
-- 3. BLOG / RECURSOS DE CARRERA
-- =============================================
CREATE TABLE public.blog_posts (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  titulo text NOT NULL,
  slug text NOT NULL UNIQUE,
  contenido text NOT NULL,
  extracto text,
  imagen_url text,
  categoria text DEFAULT 'consejos' CHECK (categoria IN ('consejos', 'mercado', 'tendencias', 'entrevistas', 'salarios')),
  autor text DEFAULT 'Svetlana Elias',
  publicado boolean DEFAULT false,
  fecha_publicacion date DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Blog público lectura" ON public.blog_posts FOR SELECT USING (publicado = true);
CREATE POLICY "Admin total blog" ON public.blog_posts FOR ALL USING (auth.role() = 'authenticated');

-- =============================================
-- 4. SKILL TESTS — Evaluaciones rápidas
-- =============================================
CREATE TABLE public.skill_tests (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  nombre text NOT NULL,
  descripcion text,
  categoria text,
  duracion_minutos integer DEFAULT 10,
  activo boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.skill_preguntas (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  test_id uuid REFERENCES public.skill_tests(id) ON DELETE CASCADE,
  pregunta text NOT NULL,
  opciones text[] NOT NULL,
  respuesta_correcta integer NOT NULL,
  orden integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.skill_resultados (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  test_id uuid REFERENCES public.skill_tests(id) ON DELETE CASCADE,
  perfil_id uuid REFERENCES public.perfiles_candidato(id) ON DELETE CASCADE,
  aplicacion_id uuid,
  puntaje integer NOT NULL,
  total_preguntas integer NOT NULL,
  porcentaje numeric NOT NULL,
  respuestas jsonb,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.skill_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skill_preguntas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skill_resultados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tests públicos lectura" ON public.skill_tests FOR SELECT USING (activo = true);
CREATE POLICY "Admin total tests" ON public.skill_tests FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Preguntas lectura" ON public.skill_preguntas FOR SELECT USING (true);
CREATE POLICY "Admin total preguntas" ON public.skill_preguntas FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Guardar resultados" ON public.skill_resultados FOR INSERT WITH CHECK (true);
CREATE POLICY "Ver resultados" ON public.skill_resultados FOR SELECT USING (true);
CREATE POLICY "Admin total resultados" ON public.skill_resultados FOR ALL USING (auth.role() = 'authenticated');

-- =============================================
-- 5. EXPERIENCIA LABORAL Y EDUCACIÓN (para perfil enriquecido)
-- =============================================
CREATE TABLE public.perfil_experiencia (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  perfil_id uuid REFERENCES public.perfiles_candidato(id) ON DELETE CASCADE,
  empresa text NOT NULL,
  cargo text NOT NULL,
  fecha_inicio date,
  fecha_fin date,
  actual boolean DEFAULT false,
  descripcion text,
  orden integer DEFAULT 0
);

CREATE TABLE public.perfil_educacion (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  perfil_id uuid REFERENCES public.perfiles_candidato(id) ON DELETE CASCADE,
  institucion text NOT NULL,
  titulo text NOT NULL,
  fecha_inicio date,
  fecha_fin date,
  descripcion text,
  orden integer DEFAULT 0
);

ALTER TABLE public.perfil_experiencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.perfil_educacion ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Experiencia pública" ON public.perfil_experiencia FOR SELECT USING (true);
CREATE POLICY "Insertar experiencia" ON public.perfil_experiencia FOR INSERT WITH CHECK (true);
CREATE POLICY "Actualizar experiencia" ON public.perfil_experiencia FOR UPDATE USING (true);
CREATE POLICY "Borrar experiencia" ON public.perfil_experiencia FOR DELETE USING (true);
CREATE POLICY "Admin experiencia" ON public.perfil_experiencia FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Educación pública" ON public.perfil_educacion FOR SELECT USING (true);
CREATE POLICY "Insertar educación" ON public.perfil_educacion FOR INSERT WITH CHECK (true);
CREATE POLICY "Actualizar educación" ON public.perfil_educacion FOR UPDATE USING (true);
CREATE POLICY "Borrar educación" ON public.perfil_educacion FOR DELETE USING (true);
CREATE POLICY "Admin educación" ON public.perfil_educacion FOR ALL USING (auth.role() = 'authenticated');
