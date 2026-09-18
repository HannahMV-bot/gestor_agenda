# 📅 Gestor de Agenda

Aplicación multiplataforma desarrollada con **Flutter** para gestionar y organizar tareas personales.

El sistema utiliza una **API REST con FastAPI**, autenticación mediante **JWT** y **MongoDB** como base de datos.

---

## 🎯 Objetivo

Facilitar la gestión de tareas mediante una aplicación moderna, adaptable a dispositivos móviles y web.

---

## 🚀 Funcionalidades

### 🔐 Autenticación
- Registro de usuarios.
- Inicio de sesión.
- Autenticación mediante JWT.
- Recuperación de contraseña.
- Manejo y cierre de sesión.

### 📅 Gestión de tareas
- Crear, consultar, editar y eliminar tareas.
- Búsqueda de tareas.
- Filtros por estado y prioridad.
- Visualización de estadísticas.

### 👤 Perfil
- Visualización de información del usuario.
- Configuración de notificaciones.
- Modo oscuro.
- Cierre de sesión.

---

## 🛠️ Tecnologías

| Tecnología | Uso |
|---|---|
| Flutter | Aplicación frontend |
| Dart | Lenguaje de programación |
| FastAPI | API REST |
| Python | Backend |
| MongoDB | Base de datos |
| JWT | Autenticación |
| Git / GitHub | Control de versiones |

---

## 🏗️ Arquitectura

El proyecto implementa **Clean Architecture**, separando la aplicación en las capas:

```text
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   └── services/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── agenda/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

---

## 🔗 API REST

| Método | Endpoint | Función |
|---|---|---|
| POST | `/auth/register` | Registrar usuario |
| POST | `/auth/login` | Iniciar sesión |
| GET | `/tasks/` | Consultar tareas |
| POST | `/tasks/` | Crear tarea |
| PUT | `/tasks/{task_id}` | Actualizar tarea |
| DELETE | `/tasks/{task_id}` | Eliminar tarea |

---

## 🗄️ Base de datos

**MongoDB**

Base de datos:

```text
gestor_agenda
```

Colecciones:

```text
users
tasks
```

Las tareas se relacionan con el usuario autenticado mediante `user_id`.

---

## 🔄 GitFlow

```text
main
│
└── develop
    ├── feature/auth
    ├── feature/agenda
    └── feature/profile
```

- `main`: versión estable.
- `develop`: integración del desarrollo.
- `feature/auth`: autenticación.
- `feature/agenda`: gestión de tareas.
- `feature/profile`: perfil y sesión.

---

## ▶️ Ejecución local

### Flutter

```bash
flutter pub get
flutter run -d chrome
```

Para Android:

```bash
flutter run
```

### FastAPI

```powershell
cd backend
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API local:

```text
http://127.0.0.1:8000
```

Swagger local:

```text
http://127.0.0.1:8000/docs
```

---

## 🌐 Enlaces del proyecto

### 🖥️ Aplicación Web

https://web-ruby-omega-96.vercel.app/

### 🚀 API REST

https://gestor-agenda-five.vercel.app/

### 📖 Swagger

https://gestor-agenda-five.vercel.app/docs

### 📂 Repositorio GitHub

https://github.com/HannahMV-bot/gestor_agenda.git

---

## ☁️ Despliegue

- **Frontend:** Flutter Web desplegado en Vercel.
- **Backend:** FastAPI desplegado en Vercel.
- **Base de datos:** MongoDB Atlas.

La aplicación web consume la API REST desplegada para realizar las operaciones de autenticación y gestión de tareas.

---

## 📱 Plataformas

- 🖥️ Web
- 📱 Android

---

## 🔐 Seguridad

- Autenticación mediante JWT.
- Contraseñas almacenadas mediante hash.
- Protección de endpoints mediante token.
- Variables sensibles mediante `.env`.
- `.env` excluido del repositorio mediante `.gitignore`.

---

## 🧪 Validación

Se verificó el funcionamiento de:

- Registro e inicio de sesión.
- Autenticación JWT.
- Creación de tareas.
- Consulta de tareas.
- Edición de tareas.
- Eliminación de tareas.
- Comunicación Flutter–API.
- Conexión con MongoDB Atlas.
- Endpoints mediante Swagger.
- Análisis del código con `flutter analyze`.

---

## 📁 Estructura general

```text
gestor_agenda/
├── android/
├── backend/
│   ├── app/
│   ├── .env
│   ├── .gitignore
│   ├── main.py
│   └── requirements.txt
├── lib/
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   └── agenda/
│   └── main.dart
├── test/
├── web/
├── .gitignore
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

---

## 👩‍💻 Proyecto académico

**Gestor de Agenda**

Proyecto desarrollado con **Flutter, FastAPI, Python y MongoDB**, orientado a la gestión de tareas personales mediante una aplicación multiplataforma y una API REST.