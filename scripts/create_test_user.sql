-- Crear usuario de prueba (solo si no existe)
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'demo@puntos.com') THEN
      INSERT INTO auth.users (id, email, encrypted_password, aud, role)
      VALUES (
        gen_random_uuid(),
        'demo@puntos.com',
        crypt('demo1234', gen_salt('bf')),
        'authenticated',
        'authenticated'
      );
   END IF;
END $$;

-- Crear perfil en tabla users
INSERT INTO public.users (id_usuario, nombre, email, rol)
SELECT id, 'Demo Educador', email, 'educador'
FROM auth.users
WHERE email = 'demo@puntos.com'
AND NOT EXISTS (
    SELECT 1 FROM public.users WHERE email = 'demo@puntos.com'
);
