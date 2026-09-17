# 📅 Gestor de Agenda

Aplicación multiplataforma desarrollada con **Flutter** para la gestión y organización de tareas personales.

El sistema permite registrar usuarios, iniciar sesión y administrar tareas mediante una API REST desarrollada con **FastAPI** y una base de datos **MongoDB**.

---

## 🎯 Objetivo

Desarrollar una aplicación que permita a los usuarios gestionar y organizar sus tareas de forma sencilla mediante una interfaz moderna y adaptable a dispositivos móviles y escritorio.

---

## 🚀 Funcionalidades

### 🔐 Autenticación

- Registro de usuarios.
- Inicio de sesión.
- Autenticación mediante JWT.
- Recuperación de contraseña.
- Manejo de sesión.
- Cierre de sesión.

### 📅 Gestión de tareas

- Crear tareas.
- Consultar tareas.
- Editar tareas.
- Eliminar tareas.
- Buscar tareas.
- Filtrar por estado y prioridad.
- Visualizar estadísticas.

### 👤 Perfil

- Visualización de información del usuario.
- Configuración de notificaciones.
- Modo oscuro.
- Cierre de sesión.

---

## 🛠️ Tecnologías

| Tecnología | Uso |
|---|---|
| Flutter | Frontend |
| Dart | Lenguaje |
| FastAPI | Backend / API REST |
| Python | Backend |
| MongoDB | Base de datos |
| JWT | Autenticación |
| Git | Control de versiones |
| GitHub | Repositorio |

---

## 🏗️ Arquitectura

El proyecto utiliza **Clean Architecture**, separando las responsabilidades en diferentes capas:

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

La aplicación Flutter se comunica con el backend mediante una API REST desarrollada con FastAPI.

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

La aplicación utiliza **MongoDB** como sistema de gestión de base de datos.

Base de datos:

```text
gestor_agenda
```

Colecciones:

```text
users
tasks
```

Las tareas están asociadas al usuario mediante el campo `user_id`.

---

## 🔄 GitFlow

El proyecto utiliza una estructura basada en GitFlow:

```text
main
│
└── develop
    ├── feature/auth
    ├── feature/agenda
    └── feature/profile
```

### Ramas principales

- `main`: contiene la versión estable del proyecto.
- `develop`: rama utilizada para la integración del desarrollo.
- `feature/auth`: desarrollo de autenticación.
- `feature/agenda`: desarrollo de la gestión de tareas.
- `feature/profile`: desarrollo del perfil y manejo de sesión.

---

## ▶️ Ejecución del proyecto

### 📱 Flutter

Instalar las dependencias:

```bash
flutter pub get
```

Ejecutar la aplicación en navegador:

```bash
flutter run -d chrome
```

Para ejecutar en Android:

```bash
flutter run
```

---

### ⚙️ FastAPI

Ingresar a la carpeta del backend:

```powershell
cd backend
```

Activar el entorno virtual:

```powershell
.\venv\Scripts\Activate.ps1
```

Instalar las dependencias:

```powershell
pip install -r requirements.txt
```

Ejecutar el servidor:

```powershell
uvicorn app.main:app --reload
```

La API estará disponible localmente en:

```text
http://127.0.0.1:8000
```

### 📖 Swagger

La documentación interactiva de la API se encuentra en:

```text
http://127.0.0.1:8000/docs
```

---

## 🌐 Enlaces del proyecto

### 📂 Repositorio GitHub

https://github.com/HannahMV-bot/gestor_agenda.git

### 🚀 API desplegada

https://gestor-agenda-five.vercel.app/

### 📖 Documentación Swagger

https://gestor-agenda-five.vercel.app/docs

---

## 📱 Plataformas

La aplicación está preparada para ejecutarse en:

- 🖥️ Web
- 📱 Android

---

## 🔐 Seguridad

El proyecto implementa diferentes mecanismos de seguridad:

- Autenticación mediante **JWT**.
- Contraseñas protegidas mediante **hash**.
- Validación de usuarios mediante autenticación.
- Protección de los endpoints de tareas mediante token.
- Las tareas se relacionan con el usuario autenticado.
- Variables sensibles almacenadas mediante variables de entorno.
- El archivo `.env` está excluido del repositorio mediante `.gitignore`.

---

## 📁 Estructura general del proyecto

```text
gestor_agenda/
│
├── android/
│
├── backend/
│   ├── app/
│   │   ├── models/
│   │   ├── schemas/
│   │   ├── routes/
│   │   ├── services/
│   │   └── tasks/
│   │
│   ├── .env
│   ├── .gitignore
│   ├── main.py
│   └── requirements.txt
│
├── lib/
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   └── agenda/
│   └── main.dart
│
├── test/
├── web/
├── .gitignore
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

---

## 🧪 Validación del proyecto

Durante el desarrollo se realizaron pruebas de:

- Registro de usuarios.
- Inicio de sesión.
- Generación y validación de tokens JWT.
- Creación de tareas.
- Consulta de tareas.
- Actualización de tareas.
- Eliminación de tareas.
- Validación de autenticación.
- Conexión con MongoDB Atlas.
- Comunicación entre Flutter y la API REST.
- Pruebas de la API mediante Swagger.
- Verificación de código mediante `flutter analyze`.

---

## ☁️ Despliegue

El backend de la aplicación se encuentra desplegado en **Vercel**.

La aplicación utiliza una API REST para realizar las operaciones de autenticación y gestión de tareas.

### Backend

```text
https://gestor-agenda-five.vercel.app/
```

### Swagger

```text
https://gestor-agenda-five.vercel.app/docs
```

### Repositorio

```text
https://github.com/HannahMV-bot/gestor_agenda.git
```

---

## 🔧 Variables de entorno

Para ejecutar el backend localmente se deben configurar las variables de entorno necesarias en el archivo `.env`.

Ejemplo:

```env
MONGODB_URI=tu_cadena_de_conexion
SECRET_KEY=tu_clave_secreta
```

> **Importante:** No se deben publicar credenciales, contraseñas ni claves secretas en el repositorio.

---

## 👩‍💻 Proyecto académico

### 📅 Gestor de Agenda

Proyecto académico desarrollado utilizando:

- **Flutter**
- **Dart**
- **FastAPI**
- **Python**
- **MongoDB**
- **JWT**
- **Git**
- **GitHub**

El proyecto tiene como finalidad permitir la gestión y organización de tareas personales mediante una aplicación multiplataforma conectada a una API REST.