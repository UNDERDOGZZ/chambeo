# Supabase Setup

Guía mínima para crear el proyecto Supabase y preparar el entorno para el MVP.

## 1) Crear proyecto
1. Ve a https://app.supabase.com y crea un proyecto.
2. Anota el **Project URL** y la **Anon public key**.
3. (Opcional) Configura la región y el nombre del proyecto.

## 2) Configurar base de datos
1. Abre el SQL Editor en el dashboard de Supabase.
2. Ejecuta en orden:
   - `schema.sql`
   - `seed.sql`
   - `triggers.sql`
   - `policies.sql`

## 3) Variables de entorno en Flutter
1. Copia el archivo de ejemplo:
   ```bash
   cp app/.env.example app/.env
   ```
2. Completa los valores:
   ```
   SUPABASE_URL=tu_project_url
   SUPABASE_ANON_KEY=tu_anon_key
   ```

## 4) Edge Functions
> Necesitarás Supabase CLI instalada y autenticada.

1. Login en Supabase CLI:
   ```bash
   supabase login
   ```
2. Vincula el proyecto:
   ```bash
   supabase link --project-ref <project-ref>
   ```
3. Despliega la función:
   ```bash
   supabase functions deploy accept_offer
   ```

## 5) Realtime
Asegúrate de tener Realtime habilitado para las tablas que lo requieran (mensajes). Esto se configurará en la consola cuando lleguemos a esa tarea.
