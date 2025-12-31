-- =============================================
-- SISTEMA DE MONITOREO DE MÁQUINAS HERRAMIENTA
-- Base de Datos: monitoreo_maquinas
-- Autor: [Gustavo Atala]
-- Fecha: [19/11/2025]
-- =============================================

-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS monitoreo_maquinas;
USE monitoreo_maquinas;

-- =============================================
-- TABLA: MAQUINAS
-- Almacena la información de las máquinas 

-- =============================================
CREATE TABLE MAQUINAS (
    id_maquina INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    modelo VARCHAR(50),
    ubicacion VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'Activo',
    fecha_alta DATE NOT NULL,
    
    -- Índices para mejorar performance en consultas frecuentes
    INDEX idx_estado (estado),
    INDEX idx_ubicacion (ubicacion),
    
    -- Restricciones de integridad
    CONSTRAINT chk_estado CHECK (estado IN ('Activo', 'Inactivo', 'Mantenimiento'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLA: MEDICIONES
-- Registra las mediciones eléctricas de las máquinas
-- =============================================
CREATE TABLE MEDICIONES (
    id_medicion BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_maquina INT NOT NULL,
    timestamp DATETIME NOT NULL,
    corriente_L1 DECIMAL(8,3),
    corriente_L2 DECIMAL(8,3),
    corriente_L3 DECIMAL(8,3),
    tension_L1 DECIMAL(8,2),
    tension_L2 DECIMAL(8,2),
    tension_L3 DECIMAL(8,2),
    potencia_activa DECIMAL(10,3),
    potencia_reactiva DECIMAL(10,3),
    
    -- Clave foránea hacia MAQUINAS
    CONSTRAINT fk_mediciones_maquina 
        FOREIGN KEY (id_maquina) 
        REFERENCES MAQUINAS(id_maquina)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Índices para consultas por máquina y tiempo
    INDEX idx_maquina_timestamp (id_maquina, timestamp),
    INDEX idx_timestamp (timestamp),
    
    -- Restricciones de valores positivos
    CONSTRAINT chk_corrientes_positivas CHECK (
        corriente_L1 >= 0 AND corriente_L2 >= 0 AND corriente_L3 >= 0
    ),
    CONSTRAINT chk_tensiones_positivas CHECK (
        tension_L1 >= 0 AND tension_L2 >= 0 AND tension_L3 >= 0
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLA: CONFIGURACION
-- Configuraciones específicas para cada máquina
-- =============================================
CREATE TABLE CONFIGURACION (
    id_config INT AUTO_INCREMENT PRIMARY KEY,
    id_maquina INT NOT NULL,
    parametro VARCHAR(50) NOT NULL,
    valor VARCHAR(100),
    fecha_config DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Clave foránea hacia MAQUINAS
    CONSTRAINT fk_config_maquina 
        FOREIGN KEY (id_maquina) 
        REFERENCES MAQUINAS(id_maquina)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Índice único para evitar configuraciones duplicadas por máquina y parámetro
    UNIQUE INDEX idx_maquina_parametro (id_maquina, parametro),
    
    -- Índice para búsquedas por parámetro
    INDEX idx_parametro (parametro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- INSERCIÓN DE DATOS DE EJEMPLO
-- =============================================

-- Insertar máquinas de ejemplo
INSERT INTO MAQUINAS (nombre, modelo, ubicacion, estado, fecha_alta) VALUES
('Torno CNC 001', 'TornoMaster 5000', 'Área de Torneado', 'Activo', '2024-01-15'),
('Fresadora 001', 'FresaPro 3000', 'Área de Fresado', 'Activo', '2024-01-20'),
('Centro Mecanizado', 'CenterMill 750', 'Línea Automatizada', 'Mantenimiento', '2024-02-10'),
('Rectificadora 001', 'RectiFine 200', 'Área de Acabado', 'Activo', '2024-02-28');

-- Insertar configuraciones por defecto
INSERT INTO CONFIGURACION (id_maquina, parametro, valor) VALUES
(1, 'frecuencia_muestreo', '60'), -- segundos
(1, 'umbral_corriente_max', '25.5'), -- Amperes
(1, 'umbral_tension_min', '210.0'), -- Volts
(2, 'frecuencia_muestreo', '30'),
(2, 'umbral_corriente_max', '18.0'),
(3, 'frecuencia_muestreo', '45'),
(4, 'frecuencia_muestreo', '60');

-- Insertar algunas mediciones de ejemplo
INSERT INTO MEDICIONES (id_maquina, timestamp, corriente_L1, corriente_L2, corriente_L3, tension_L1, tension_L2, tension_L3, potencia_activa, potencia_reactiva) VALUES
(1, '2024-03-20 08:00:00', 12.345, 12.123, 11.987, 220.5, 219.8, 221.2, 5.234, 1.123),
(1, '2024-03-20 08:01:00', 13.123, 12.876, 12.654, 219.7, 220.1, 220.8, 5.567, 1.234),
(2, '2024-03-20 08:00:00', 8.765, 8.543, 8.321, 221.0, 220.5, 220.9, 3.456, 0.876);

-- =============================================
-- VISTAS ÚTILES PARA CONSULTAS FRECUENTES
-- =============================================

-- Vista para mediciones recientes con información de máquina
CREATE VIEW VW_MEDICIONES_RECIENTES AS
SELECT 
    m.nombre as maquina,
    m.ubicacion,
    med.timestamp,
    med.corriente_L1,
    med.corriente_L2,
    med.corriente_L3,
    med.tension_L1,
    med.tension_L2,
    med.tension_L3,
    med.potencia_activa,
    med.potencia_reactiva
FROM MEDICIONES med
JOIN MAQUINAS m ON med.id_maquina = m.id_maquina
WHERE med.timestamp >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
ORDER BY med.timestamp DESC;

-- Vista para resumen diario de consumo por máquina
CREATE VIEW VW_RESUMEN_DIARIO AS
SELECT 
    m.nombre as maquina,
    DATE(med.timestamp) as fecha,
    AVG(med.potencia_activa) as potencia_promedio,
    MAX(med.potencia_activa) as potencia_maxima,
    SUM(med.potencia_activa) as energia_total
FROM MEDICIONES med
JOIN MAQUINAS m ON med.id_maquina = m.id_maquina
GROUP BY m.nombre, DATE(med.timestamp);

-- =============================================
-- MENSAJE FINAL
-- =============================================
SELECT 'Base de datos creada exitosamente' as Mensaje;
SELECT COUNT(*) as 'Total Máquinas' FROM MAQUINAS;
SELECT COUNT(*) as 'Total Mediciones' FROM MEDICIONES;