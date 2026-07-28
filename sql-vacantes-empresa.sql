-- =============================================
-- PORTAL PÚBLICO — Vacantes de empresas externas
-- Ejecutar en Supabase SQL Editor
-- =============================================

-- Empresas que publican en el portal
CREATE TABLE public.empresas_portal (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  nombre_empresa text NOT NULL,
  contacto_nombre text NOT NULL,
  email text NOT NULL UNIQUE,
  telefono text,
  sector text,
  password text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Vacantes publicadas por empresas
CREATE TABLE public.vacantes_portal (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  empresa_id uuid REFERENCES public.empresas_portal(id) ON DELETE CASCADE,
  titulo text NOT NULL,
  descripcion text,
  requisitos text,
  sector text,
  modalidad text DEFAULT 'Presencial' CHECK (modalidad IN ('Presencial', 'Remoto', 'Híbrido')),
  ubicacion text,
  salario_min numeric,
  salario_max numeric,
  dias_publicacion integer DEFAULT 7,
  estado text DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aprobada', 'rechazada', 'expirada')),
  fecha_aprobacion date,
  fecha_expiracion date,
  created_at timestamptz DEFAULT now()
);

-- Aplicaciones a vacantes del portal
CREATE TABLE public.aplicaciones_vacante (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  vacante_id uuid REFERENCES public.vacantes_portal(id) ON DELETE CASCADE,
  nombre text NOT NULL,
  apellido text,
  email text NOT NULL,
  telefono text,
  linkedin text,
  experiencia integer,
  salario_esperado numeric,
  motivacion text,
  cv_url text,
  created_at timestamptz DEFAULT now()
);

-- RLS
ALTER TABLE public.empresas_portal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vacantes_portal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.aplicaciones_vacante ENABLE ROW LEVEL SECURITY;

-- Empresas: cualquiera puede registrarse, autenticados ven todo
CREATE POLICY "Registro público empresas" ON public.empresas_portal FOR INSERT WITH CHECK (true);
CREATE POLICY "Lectura pública empresas" ON public.empresas_portal FOR SELECT USING (true);
CREATE POLICY "Admin total empresas" ON public.empresas_portal FOR ALL USING (auth.role() = 'authenticated');

-- Vacantes: público ve aprobadas, cualquiera inserta, autenticados manejan todo
CREATE POLICY "Ver vacantes aprobadas" ON public.vacantes_portal FOR SELECT USING (true);
CREATE POLICY "Empresas publican vacantes" ON public.vacantes_portal FOR INSERT WITH CHECK (true);
CREATE POLICY "Admin total vacantes" ON public.vacantes_portal FOR ALL USING (auth.role() = 'authenticated');

-- Aplicaciones: cualquiera aplica, autenticados ven todo
CREATE POLICY "Candidatos aplican" ON public.aplicaciones_vacante FOR INSERT WITH CHECK (true);
CREATE POLICY "Ver aplicaciones" ON public.aplicaciones_vacante FOR SELECT USING (true);
CREATE POLICY "Admin total aplicaciones" ON public.aplicaciones_vacante FOR ALL USING (auth.role() = 'authenticated');
