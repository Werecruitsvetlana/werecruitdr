// Mueve los CVs del bucket público 'archivos' (carpeta cvs/) al bucket privado 'cvs-privados'
// y actualiza cv_url en candidatos, aplicaciones_vacante y perfiles_candidato.
// Cómo usarlo: abre el portal interno con tu sesión de administradora, abre la consola del navegador (F12)
// y pega este archivo completo. Se puede repetir sin problema: salta los que ya están movidos.
(async () => {
  const sb = window.sb;
  const ok = (await sb.rpc('es_admin')).data;
  if (!ok) { console.error('Inicia sesión como administradora primero'); return; }
  const base = sb.storageUrl || (sb.supabaseUrl + '/storage/v1');
  let movidos = 0, saltados = 0, errores = 0, offset = 0;
  while (true) {
    const { data: lista, error } = await sb.storage.from('archivos').list('cvs', { limit: 100, offset });
    if (error) { console.error(error); break; }
    if (!lista.length) break;
    for (const f of lista) {
      if (!f.id) continue; // carpeta
      const path = 'cvs/' + f.name;
      try {
        const { data: ya } = await sb.storage.from('cvs-privados').list('cvs', { search: f.name, limit: 1 });
        if (ya && ya.some(x => x.name === f.name)) { saltados++; }
        else {
          const { data: blob, error: dErr } = await sb.storage.from('archivos').download(path);
          if (dErr) throw dErr;
          const { error: uErr } = await sb.storage.from('cvs-privados').upload(path, blob, { upsert: true, contentType: blob.type || 'application/pdf' });
          if (uErr) throw uErr;
        }
        const viejo = base + '/object/public/archivos/' + path;
        const nuevo = base + '/object/public/cvs-privados/' + path;
        for (const t of ['candidatos', 'aplicaciones_vacante', 'perfiles_candidato']) {
          const { error: e2 } = await sb.from(t).update({ cv_url: nuevo }).eq('cv_url', viejo);
          if (e2) console.warn(t, e2.message);
        }
        await sb.storage.from('archivos').remove([path]);
        movidos++;
      } catch (e) { errores++; console.error(f.name, e.message || e); }
    }
    offset += lista.length;
  }
  console.log(`Listo: ${movidos} movidos, ${saltados} ya estaban, ${errores} errores`);
})();
