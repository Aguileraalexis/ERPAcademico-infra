-- ERP Académico - esquema inicial

CREATE TABLE proceso_admision (
    id              CHAR(36)     NOT NULL PRIMARY KEY,
    proceso_admision VARCHAR(200) NOT NULL,
    fecha_inicio    DATE         NOT NULL,
    fecha_fin       DATE         NOT NULL,
    borrador        TINYINT(1)   NOT NULL DEFAULT 1
);

CREATE TABLE direccion (
    id                  CHAR(36)   NOT NULL PRIMARY KEY,
    calle               VARCHAR(100),
    numero_calle        VARCHAR(20),
    numero_departamento VARCHAR(20),
    id_distrito         VARCHAR(20)
);

CREATE TABLE persona (
    id                       CHAR(36)   NOT NULL PRIMARY KEY,
    nombres                  VARCHAR(50) NOT NULL,
    primer_apellido          VARCHAR(50) NOT NULL,
    segundo_apellido         VARCHAR(50),
    documento_identidad      VARCHAR(11) NOT NULL,
    tipo_documento_identidad CHAR(1)    NOT NULL,
    id_direccion_principal   CHAR(36),
    CONSTRAINT chk_tipo_doc CHECK (tipo_documento_identidad IN ('D','X','P','R')),
    CONSTRAINT fk_persona_direccion
        FOREIGN KEY (id_direccion_principal) REFERENCES direccion(id)
);

CREATE TABLE contacto (
    id            CHAR(36)     NOT NULL PRIMARY KEY,
    id_persona    CHAR(36)     NOT NULL,
    tipo_contacto CHAR(2)      NOT NULL,
    valor         VARCHAR(250) NOT NULL,
    CONSTRAINT chk_tipo_contacto CHECK (tipo_contacto IN ('CE','TF','WS','FB','X','TG','OT')),
    CONSTRAINT fk_contacto_persona
        FOREIGN KEY (id_persona) REFERENCES persona(id)
);

CREATE TABLE estudiante (
    id               CHAR(36)    NOT NULL PRIMARY KEY,
    id_persona       CHAR(36)    NOT NULL,
    numero_estudiante VARCHAR(50) NOT NULL,
    CONSTRAINT fk_estudiante_persona
        FOREIGN KEY (id_persona) REFERENCES persona(id)
);

CREATE TABLE proceso_admision_estudiante (
    id                  CHAR(36)   NOT NULL PRIMARY KEY,
    id_estudiante       CHAR(36)   NOT NULL,
    id_proceso_admision CHAR(36)   NOT NULL,
    estado              CHAR(2)    NOT NULL COMMENT 'RG=Registrado, F1=Fase 1, F2=Fase 2, MT=Matriculado, DC=Descartado',
    CONSTRAINT chk_estado_admision CHECK (estado IN ('RG','F1','F2','MT','DC')),
    CONSTRAINT fk_admision_estudiante
        FOREIGN KEY (id_estudiante) REFERENCES estudiante(id),
    CONSTRAINT fk_admision_proceso
        FOREIGN KEY (id_proceso_admision) REFERENCES proceso_admision(id)
);

CREATE TABLE proceso_admision_examen (
    id                   CHAR(36)  NOT NULL PRIMARY KEY,
    id_proceso_admision  CHAR(36)  NOT NULL,
    fecha                DATE      NOT NULL,
    borrador             TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_proceso_admision_examen
        FOREIGN KEY (id_proceso_admision) REFERENCES proceso_admision(id)
);

CREATE TABLE proceso_admision_examen_estudiante (
    id                  CHAR(36)  NOT NULL PRIMARY KEY,
    id_estudiante       CHAR(36)  NOT NULL,
    id_proceso_admision_examen  CHAR(36)  NOT NULL,
    estado              CHAR(2)   NOT NULL COMMENT 'PE=Pendiente, RP=Aprobado, DS=Reprobado, DC=Descartado',
    resultado              int   NULL,
    valoracion              int   NULL,
    CONSTRAINT chk_estado_examen CHECK (estado IN ('PE','RP','DS','DC')),
    CONSTRAINT fk_examen_estudiante
        FOREIGN KEY (id_estudiante) REFERENCES estudiante(id),
    CONSTRAINT fk_examen_admision
        FOREIGN KEY (id_proceso_admision_examen) REFERENCES proceso_admision_examen(id)
);
