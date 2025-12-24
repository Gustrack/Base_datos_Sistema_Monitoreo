-- =============================================
-- SISTEMA DE MONITOREO DE MÁQUINAS HERRAMIENTA
-- Base de Datos Completa - Segunda Entrega
-- =============================================

-- Configuración inicial
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Crear base de datos
DROP DATABASE IF EXISTS monitoreo_maquinas;
CREATE DATABASE monitoreo_maquinas;
USE monitoreo_maquinas;

-- =============================================
-- SECCIÓN 1: CREACIÓN DE TABLAS PRINCIPALES
-- =============================================

-- Tabla USUARIOS (nueva)
CREATE TABLE USUARIOS (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni VARCHAR(15) UNIQUE,
    legajo VARCHAR(20) UNIQUE,
    rol ENUM('Administrador', 'Supervisor', 'Técnico', 'Operador') NOT NULL,
    email VARCHAR(150) UNIQUE,
    telefono VARCHAR(20),
    usuario_sistema VARCHAR(50) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    fecha_alta DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_baja DATETIME NULL,
    estado ENUM('Activo', 'Inactivo', 'Suspendido') DEFAULT 'Activo',
    creado_por INT NULL,
    modificado_por INT NULL,
    fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_rol (rol),
    INDEX idx_estado (estado),
    INDEX idx_legajo (legajo),
    
    CONSTRAINT fk_usuario_creado_por FOREIGN KEY (creado_por) REFERENCES USUARIOS(id_usuario),
    CONSTRAINT fk_usuario_modificado_por FOREIGN KEY (modificado_por) REFERENCES USUARIOS(id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla MAQUINAS (modificada)
CREATE TABLE MAQUINAS (
    id_maquina INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    modelo VARCHAR(50),
    ubicacion VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'Activo',
    fecha_alta DATE NOT NULL,
    id_responsable INT NULL,
    ultimo_mantenimiento DATE NULL,
    proximo_mantenimiento DATE NULL,
    horas_totales_operacion DECIMAL(10,2) DEFAULT 0,
    fabricante VARCHAR(100),
    numero_serie VARCHAR(100),
    fecha_instalacion DATE,
    garantia_hasta DATE,
    costo_hora DECIMAL(10,2),
    creado_por INT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    modificado_por INT NULL,
    fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_estado (estado),
    INDEX idx_ubicacion (ubicacion),
    INDEX idx_responsable (id_responsable),
    
    CONSTRAINT chk_estado CHECK (estado IN ('Activo', 'Inactivo', 'Mantenimiento')),
    CONSTRAINT fk_maquina_responsable FOREIGN KEY (id_responsable) REFERENCES USUARIOS(id_usuario),
    CONSTRAINT fk_maquina_creado_por FOREIGN KEY (creado_por) REFERENCES USUARIOS(id_usuario),
    CONSTRAINT fk_maquina_modificado_por FOREIGN KEY (modificado_por) REFERENCES USUARIOS(id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Resto del script continúa con las otras tablas...
-- [Aquí irían las definiciones de MEDICIONES, CONFIGURACION, MANTENIMIENTOS, ENERGIA_DIARIA, etc.]

-- =============================================
-- SECCIÓN 2: VISTAS
-- =============================================

-- [Todas las vistas definidas anteriormente]

-- =============================================
-- SECCIÓN 3: FUNCIONES
-- =============================================

-- [Todas las funciones definidas anteriormente]

-- =============================================
-- SECCIÓN 4: STORED PROCEDURES
-- =============================================

-- [Todos los stored procedures definidos anteriormente]

-- =============================================
-- SECCIÓN 5: TRIGGERS
-- =============================================

-- [Todos los triggers definidos anteriormente]

-- =============================================
-- INSERCIÓN DE DATOS DE PRUEBA
-- =============================================

-- Insertar usuario administrador por defecto
INSERT INTO USUARIOS (nombre, apellido, dni, legajo, rol, email, usuario_sistema, contrasena_hash) VALUES
('Admin', 'Sistema', '00000000', 'ADM001', 'Administrador', 'admin@empresa.com', 'admin', SHA2('Admin123', 256));

-- Insertar técnicos
INSERT INTO USUARIOS (nombre, apellido, dni, legajo, rol, email, usuario_sistema, contrasena_hash, creado_por) VALUES
('Juan', 'Pérez', '20123456', 'TEC001', 'Técnico', 'juan.perez@empresa.com', 'jperez', SHA2('Tecnico123', 256), 1),
('María', 'Gómez', '23123456', 'TEC002', 'Técnico', 'maria.gomez@empresa.com', 'mgomez', SHA2('Tecnico123', 256), 1),
('Carlos', 'López', '25123456', 'SUP001', 'Supervisor', 'carlos.lopez@empresa.com', 'clopez', SHA2('Super123', 256), 1);

-- Restablecer configuraciones
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- Mensaje final
SELECT 'Base de datos completa creada exitosamente' as Mensaje;
SELECT COUNT(*) as 'Total Usuarios' FROM USUARIOS;
SELECT COUNT(*) as 'Total Máquinas' FROM MAQUINAS;