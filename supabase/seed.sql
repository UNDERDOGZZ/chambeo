INSERT INTO categories (name)
VALUES
  ('Limpieza'),
  ('Arreglos'),
  ('Mudanza'),
  ('Tutoría'),
  ('Mascotas')
ON CONFLICT (name) DO NOTHING;
