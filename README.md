# TutorTrack (Flutter + Node + MySQL)

MVP completo para seguimiento de tutorías. Incluye app Flutter (Material 3 + Riverpod + go_router) y backend REST con Node.js/Express + MySQL 8.

## Estructura
- `lib/` Flutter con features (auth, alumno, tutor), navegación go_router y provider global de sesión.
- `backend/` API REST Node.js + Express (JWT, RBAC, validación Zod, MySQL pool, logging morgan).
- `backend/sql/schema.sql` Esquema MySQL 8 con FKs, índices y triggers (límite de justificantes y alertas de ánimo).
- `.env.example` (backend) y `flutter.env.example` (baseUrl para `--dart-define`).

## Backend (Node.js + Express)
1. Instalar dependencias:
   ```bash
   cd backend
   npm install
   ```
2. Configurar `.env` a partir de `.env.example`:
   ```env
   PORT=4000
   DATABASE_URL=mysql://user:password@localhost:3306/tutortrack
   JWT_SECRET=super-secret-key
   CORS_ORIGIN=http://localhost:5173
   DB_SSL=false # en Aiven poner true
   ```
3. Levantar MySQL local:
   ```bash
   mysql -u root -p -e "CREATE DATABASE tutortrack CHARACTER SET utf8mb4;"
   mysql -u root -p tutortrack < sql/schema.sql
   ```
4. Ejecutar API local:
   ```bash
   npm run dev
   # healthcheck
   curl http://localhost:4000/health
   ```

### Despliegue en Render
- Crear servicio Web (Node) apuntando a este repo/carpeta `backend`.
- Variables de entorno: `PORT=10000` (Render asigna), `DATABASE_URL` con cadena MySQL remota (Aiven), `JWT_SECRET` seguro, `CORS_ORIGIN` con URL web/app, `DB_SSL=true` si Aiven requiere SSL.
- Comando de inicio: `npm start`.

### Conexión a MySQL Aiven (SSL)
- Aiven entrega cadena similar: `mysql://user:pass@host:port/dbname?ssl-mode=REQUIRED`.
- Establece `DATABASE_URL` con esa URL y agrega `DB_SSL=true` en `.env` Render.
- Si necesitas certs, coloca archivos en Render como secrets (no requerido con `rejectUnauthorized:false`).

## App Flutter
1. Instalar dependencias:
   ```bash
   flutter pub get
   ```
2. Correr con baseUrl del backend:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://localhost:4000
   ```
3. Build web/mobile igual cambiando `API_BASE_URL` al dominio de Render.

## Endpoints REST (resumen)
- `POST /auth/register` `{name,email,password,role(student|tutor)}` -> `{user,token}`
- `POST /auth/login` `{email,password}` -> `{user,token}`
- `POST /groups` (tutor) `{code,term}` -> crea grupo (código único)
- `POST /groups/join` (alumno) `{code}` -> valida un solo grupo por cuatrimestre
- `POST /students/mood` (alumno) `{emoji,note?}` -> 1 por día (unique index)
- `GET /students/mood` -> historial ánimo
- `POST /students/perceptions` `{subject,perception}` -> registro semanal
- `GET /students/perceptions`
- `POST /students/justifications` `{reason,evidenceUrl}` -> máximo 2 por term (trigger + backend)
- `GET /students/justifications`
- `GET /tutor/alerts` -> alertas automáticas (ánimo bajo via trigger; extensible)
- `GET /tutor/panel` -> resumen grupo
- `POST /tutor/justifications` `{id,status}` -> aprobar/rechazar

### Ejemplos cURL
```bash
# login
token=$(curl -s -X POST http://localhost:4000/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"tutor@demo.com","password":"<pwd>"}' | jq -r .token)

# crear grupo
token_tutor=$token
curl -X POST http://localhost:4000/groups \
  -H "Authorization: Bearer $token_tutor" \
  -H 'Content-Type: application/json' \
  -d '{"code":"SP02SV-24","term":"2024Q2"}'
```

## Base de datos
- Índices/Reglas clave:
  - `groups.code` UNIQUE.
  - `group_members` UNIQUE `(student_id, term)` asegura solo un grupo por cuatrimestre (trigger copia term del grupo).
  - `mood_entries` UNIQUE `(student_id, created_at)` limita un registro diario.
  - Trigger `trg_justifications_limit` bloquea más de 2 justificantes por alumno/term.
  - Trigger `trg_mood_alert` crea alerta automática cuando el emoji es 🙁 o 😢.
- Tablas extra para historial: `attendance`, `grades` (para futuras integraciones).
- Seed mínimo: 1 tutor, 1 alumno, 1 grupo (contraseña cifrada; actualiza si deseas usando bcryptjs).

## Flutter features incluidas
- Auth: login/registro por rol, persistencia en memoria (cambia a storage según necesidad).
- Alumno: unirse por código, ánimo diario, percepción semanal, justificantes (límite), historial, chat placeholder.
- Tutor: crear grupos, panel con alertas, detalle alumno básico, gestión de justificantes, reportes (botones placeholder para PDF/Excel).
- Navegación: go_router con redirecciones por sesión; Riverpod para sesión global.

## Conectar Flutter con backend desplegado
- Usar dominio de Render: `flutter run --dart-define=API_BASE_URL=https://<render-service>.onrender.com`
- Verificar CORS en backend (`CORS_ORIGIN`).

## Notas y próximos pasos sugeridos
- Persistir sesión en storage seguro (flutter_secure_storage) y refrescar tokens.
- Añadir colas/notificaciones push (FCM) o emails para alertas.
- Generar PDFs/Excels en backend (ej. pdfkit + exceljs) y exponer endpoints `/tutor/reports/pdf|xlsx`.
- Integrar websockets (Socket.io) para chat y panel en tiempo real.
