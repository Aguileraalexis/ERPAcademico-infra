-- CREACIÓN DE USUARIO data_bot CON CONTRASENA ALEATORIA Y PERMISOS
-- create database erp_academico;
CREATE USER IF NOT EXISTS 'erp_academico_aws'@'%' IDENTIFIED BY 'z3:^m$wD6X11';
GRANT ALL PRIVILEGES ON erp_academico.* TO 'erp_academico_aws'@'%';

-- CREACIÓN DE BASE DE DATOS
USE erp_academico;

-- TABLAS PRINCIPALES
CREATE TABLE archivo (
    id INT AUTO_INCREMENT PRIMARY KEY,
	qr varchar(1024) not null,
    nombre varchar(250) not null,
    fecha DATE not null,
    link varchar(250) not null
);

CREATE TABLE persona (
    id int not null PRIMARY KEY,
    nombre VARCHAR(50) not null,
    tipo_documento_identidad ENUM('DNI', 'PAS', 'CE', 'RUC') not null,
    numero_documento_identidad VARCHAR(11) not null,
    primer_apellido VARCHAR(50) not null,
    segundo_apellido VARCHAR(50) not null,
    genero ENUM('M','F') not null,
    id_archivo_foto int null references archivo(id),
    fecha_nacimiento DATE not null
);

CREATE TABLE region (
    id CHAR(2) PRIMARY KEY,
    region VARCHAR(50)
);

CREATE TABLE provincia (
    id CHAR(4) PRIMARY KEY,
    provincia VARCHAR(50),
    id_region char(2) not null references region(id)
);

CREATE TABLE distrito (
    id CHAR(6) PRIMARY KEY,
    distrito VARCHAR(50),
    id_provincia char(4) not null references provincia(id)
);

CREATE TABLE persona_direccion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_persona int REFERENCES persona(id),
    direccion VARCHAR(250),
    id_distrito char(6) not null references distrito(id),
    indicacion VARCHAR(250)
);

CREATE TABLE persona_contacto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_persona int REFERENCES persona(id),
    contacto VARCHAR(250),
    tipo CHAR(2)
);

CREATE TABLE estudiante (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo char(11) not null,
    id_persona int references persona(id)
);

CREATE TABLE profesor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo CHAR(11) not null,
    id_persona int references persona(id)
);

CREATE TABLE asignatura (
    id CHAR(6) PRIMARY KEY,
    asignatura VARCHAR(100)
);

CREATE TABLE especialidad (
    id CHAR(6) PRIMARY KEY,
    especialidad VARCHAR(100)
);

CREATE TABLE periodo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(20),
    id_especialidad CHAR(6) references especialidad(id),
    fecha_inicio DATE,
    fecha_fin DATE
);

CREATE TABLE grupo_academico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    grupo_academico VARCHAR(100),
    id_periodo int references periodo(id)
);

CREATE TABLE curso (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_periodo int references periodo(id),
    id_grupo_academico int references grupo_academico(id),
    id_asignatura CHAR(6) references asignatura(id)
);

CREATE TABLE curso_estudiante (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante int not null references estudiante(id),
    id_curso int not null references curso(id)
);

CREATE TABLE curso_profesor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_curso int not null references curso(id),
    id_profesor int not null references profesor(id)
);

CREATE TABLE aula (
    id INT AUTO_INCREMENT PRIMARY KEY,
    aula VARCHAR(50),
    capacidad INT
);

CREATE TABLE horario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_curso int not null references curso(id),
    id_aula int not null references aula(id),
    dia_semana ENUM('L','M','R','J','V', 'S', 'D'),
    hora_inicio TIME,
    hora_fin TIME
);

CREATE TABLE asistencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_curso int not null references curso(id),
    fecha DATE not null
);

CREATE TABLE asistencia_estudiante (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante int not null references estudiante(id),
    id_asistencia int not null references asistencia(id),
    presente BOOLEAN
);

CREATE TABLE proceso_admision (
    id INT AUTO_INCREMENT PRIMARY KEY,
    proceso_admision varchar(250) not null,
    id_periodo int not null references periodo(id),
    tipo_proceso_admision char(1) not null,
    resolucion_aprobacion varchar(500) not null,
    id_archivo_resolucion_aprobacion int not null references archivo(id),
    fecha_inicio DATE not null,
    fecha_limite_inscripcion DATE not null,
    fecha_fin DATE not null
);

CREATE TABLE proceso_admision_estudiante (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante int not null references estudiante(id),
    id_proceso_admision int not null references proceso_admision(id),
    estado ENUM('PE', 'F1', 'F2', 'AP', 'RE', 'DE') not null, -- pendiente, fase 1, fase 2, aprobado, reprobado, descartado
    id_archivo_certificado_preinscripcion int null references archivo(id),
    id_archivo_certificado_matricula int null references archivo(id)
);

CREATE TABLE requisito_proceso_admision (
    id INT AUTO_INCREMENT PRIMARY KEY,
    requisito_proceso_admision varchar(250) not null,
    tipo_proceso_admision char(1) not null
);

CREATE TABLE requisito_proceso_admision_proceso_admision_estudiante (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_requisito_proceso_admision int not null references requisito_proceso_admision(id),
    id_proceso_admision_estudiante int not null references proceso_admision_estudiante(id),
    cumple boolean not null
);

CREATE TABLE examen_proceso_admision (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_proceso_admision int not null references proceso_admision(id),
    fecha DATE
);

CREATE TABLE examen_proceso_admision_grupo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    grupo varchar(50) not null,
    id_examen_proceso_admision int not null references examen_proceso_admision(id),
    id_aula int not null references aula(id)
);

CREATE TABLE examen_proceso_admision_grupo_estudiante (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_examen_proceso_admision_grupo int not null references examen_proceso_admision_grupo(id),
    id_estudiante int not null references estudiante(id),
    estado ENUM('PE', 'AP', 'RE', 'DE') not null -- pendiente, aprobado, reprobado, descartado
);

CREATE TABLE examen_proceso_admision_profesor_comision (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_examen_proceso_admision_grupo int not null references examen_proceso_admision_grupo(id),
    id_profesor int not null references profesor(id)
);

CREATE TABLE examen (
    id INT AUTO_INCREMENT PRIMARY KEY,
    examen varchar(50) not null,
	id_curso int not null references curso(id),
    fecha_entrega date not null
);

CREATE TABLE examen_estudiante (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante int not null references estudiante(id),
    id_examen int not null references examen(id),
    nota INT
);

CREATE TABLE concepto_pago (
    id INT AUTO_INCREMENT PRIMARY KEY,
    concepto_pago VARCHAR(250) not null
);

CREATE TABLE pago_estudiante (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante int not null references estudiante(id),
    id_concepto_pago int not null references concepto_pago(id),
    tipo_comprobante_pago ENUM('BOL', 'FAC', 'DEP', 'TRA') not null,
    numero_comprobante_pago int not null,
    monto decimal(6, 2) not null,
    fecha_pago date not null
);


