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
-- CREACIÓN DE TABLAS PRINCIPALES
-- =============================================

-- TABLA: USUARIOS 
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

-- TABLA: MAQUINAS 
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



-- =============================================
-- OTRAS TABLAS
-- =============================================
-- Van las definiciones de MANTENIMIENTOS, MEDICIONES, ENERGIA_DIARIA, MEDICIONES, CONFIGURACION, AUDITORIA DE CONFIGURACIONES


-- TABLA: MANTENIMIENTOS
CREATE TABLE MANTENIMIENTOS (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_maquina INT NOT NULL,
    id_tecnico INT NOT NULL,
    tipo ENUM('Preventivo', 'Correctivo', 'Predictivo', 'Calibración') NOT NULL,
    descripcion TEXT NOT NULL,
    tareas TEXT, -- Checklist de tareas a realizar
    fecha_programada DATETIME NOT NULL,
    fecha_inicio DATETIME NULL,
    fecha_fin DATETIME NULL,
    duracion_minutos INT NULL,
    estado ENUM('Programado', 'En Progreso', 'Completado', 'Cancelado', 'Pospuesto') DEFAULT 'Programado',
    resultado ENUM('Exitoso', 'Fallido', 'Parcial', 'Requiere Nueva Visita') NULL,
    observaciones TEXT,
    piezas_reemplazadas TEXT,
    costo_estimado DECIMAL(10,2),
    costo_real DECIMAL(10,2),
    
    -- Auditoría
    creado_por INT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    modificado_por INT NULL,
    fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Claves foráneas
    CONSTRAINT fk_mantenimiento_maquina FOREIGN KEY (id_maquina) 
        REFERENCES MAQUINAS(id_maquina) ON DELETE CASCADE,
    CONSTRAINT fk_mantenimiento_tecnico FOREIGN KEY (id_tecnico) 
        REFERENCES USUARIOS(id_usuario) ON DELETE RESTRICT,
    CONSTRAINT fk_mantenimiento_creado_por FOREIGN KEY (creado_por) 
        REFERENCES USUARIOS(id_usuario),
    CONSTRAINT fk_mantenimiento_modificado_por FOREIGN KEY (modificado_por) 
        REFERENCES USUARIOS(id_usuario),
    
    -- Índices
    INDEX idx_tipo (tipo),
    INDEX idx_estado (estado),
    INDEX idx_fecha_programada (fecha_programada),
    INDEX idx_maquina_estado (id_maquina, estado),
    
    -- Constraints adicionales
    CONSTRAINT chk_fechas_mantenimiento CHECK (fecha_fin IS NULL OR fecha_inicio IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT chk_costo_positivo CHECK (costo_estimado >= 0 AND (costo_real IS NULL OR costo_real >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- TABLA: MEDICIONES
CREATE TABLE IF NOT EXISTS MEDICIONES (
    id_medicion INT AUTO_INCREMENT PRIMARY KEY,
    id_maquina INT NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Mediciones eléctricas
    corriente_L1 DECIMAL(8,3) COMMENT 'Amperes - Fase L1',
    corriente_L2 DECIMAL(8,3) COMMENT 'Amperes - Fase L2',
    corriente_L3 DECIMAL(8,3) COMMENT 'Amperes - Fase L3',
    tension_L1 DECIMAL(8,2) COMMENT 'Volts - Fase L1',
    tension_L2 DECIMAL(8,2) COMMENT 'Volts - Fase L2',
    tension_L3 DECIMAL(8,2) COMMENT 'Volts - Fase L3',
    potencia_activa DECIMAL(10,3) COMMENT 'kW - Potencia activa',
    potencia_reactiva DECIMAL(10,3) COMMENT 'kVAR - Potencia reactiva',
    
    -- Estado operativo al momento de medición
    estado_operativo_registrado VARCHAR(30) COMMENT 'Estado de la máquina al momento de medición',
    
    -- Auditoría
    fuente_dato ENUM('Sensor', 'Manual', 'Sistema') DEFAULT 'Sensor',
    creado_por INT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Índices
    INDEX idx_maquina_fecha (id_maquina, timestamp),
    INDEX idx_timestamp (timestamp),
    INDEX idx_estado_registrado (estado_operativo_registrado),
    
    -- Claves foráneas
    CONSTRAINT fk_medicion_maquina 
        FOREIGN KEY (id_maquina) 
        REFERENCES MAQUINAS(id_maquina) 
        ON DELETE CASCADE,
        
    CONSTRAINT fk_medicion_creado_por 
        FOREIGN KEY (creado_por) 
        REFERENCES USUARIOS(id_usuario) 
        ON DELETE SET NULL
        
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Registro de mediciones en tiempo real de las máquinas';


-- TABLA: ENERGIA_DIARIA
CREATE TABLE ENERGIA_DIARIA (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_maquina INT NOT NULL,
    fecha DATE NOT NULL,
    -- Totales del día
    energia_total_kwh DECIMAL(15,3) NOT NULL DEFAULT 0,
    energia_reactiva_total_kvarh DECIMAL(15,3) NOT NULL DEFAULT 0,
    -- Promedios
    corriente_promedio_L1 DECIMAL(8,3),
    corriente_promedio_L2 DECIMAL(8,3),
    corriente_promedio_L3 DECIMAL(8,3),
    tension_promedio_L1 DECIMAL(8,2),
    tension_promedio_L2 DECIMAL(8,2),
    tension_promedio_L3 DECIMAL(8,2),
    -- Picos
    corriente_maxima DECIMAL(8,3),
    potencia_maxima_kw DECIMAL(10,3),
    -- Tiempos
    horas_operacion DECIMAL(5,2) DEFAULT 0,
    horas_standby DECIMAL(5,2) DEFAULT 0,
    horas_detenido DECIMAL(5,2) DEFAULT 0,
    -- Factores de calidad
    factor_potencia_promedio DECIMAL(4,3),
    desbalance_corriente DECIMAL(5,2),
    -- Auditoría
    fecha_calculo DATETIME DEFAULT CURRENT_TIMESTAMP,
    calculado_por INT NULL,
    
    -- Claves foráneas
    CONSTRAINT fk_energia_maquina FOREIGN KEY (id_maquina) 
        REFERENCES MAQUINAS(id_maquina) ON DELETE CASCADE,
    CONSTRAINT fk_energia_calculado_por FOREIGN KEY (calculado_por) 
        REFERENCES USUARIOS(id_usuario),
    
    -- Índices únicos
    UNIQUE INDEX idx_unique_maquina_fecha (id_maquina, fecha),
    
    -- Índices para consultas
    INDEX idx_fecha (fecha),
    INDEX idx_maquina (id_maquina),
    
    -- Constraints
    CONSTRAINT chk_energia_positiva CHECK (energia_total_kwh >= 0),
    CONSTRAINT chk_horas_positivas CHECK (horas_operacion >= 0 AND horas_standby >= 0 AND horas_detenido >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- TABLA: CONFIGURACION 
CREATE TABLE CONFIGURACION (
    id_config INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Ámbito de la configuración
    ambito ENUM('Sistema', 'Máquina', 'Usuario', 'Aplicación', 'Reporte') DEFAULT 'Sistema' NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    subcategoria VARCHAR(50) NULL,
    
    -- Identificación
    id_maquina INT NULL,
    id_usuario INT NULL,
    
    -- Parámetro y valor
    parametro VARCHAR(100) NOT NULL,
    valor TEXT NULL,
    tipo_valor ENUM('Texto', 'Numérico', 'Booleano', 'JSON', 'Fecha', 'Lista') DEFAULT 'Texto' NOT NULL,
    unidad VARCHAR(20) NULL,
    
    -- Descripción y estado
    descripcion TEXT NOT NULL,
    estado ENUM('Activo', 'Inactivo', 'Experimental', 'Obsoleto') DEFAULT 'Activo' NOT NULL,
    
    -- Auditoría
    modificado_por INT NOT NULL,
    fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Índices
    INDEX idx_ambito_categoria (ambito, categoria),
    INDEX idx_parametro (parametro),
    INDEX idx_maquina_parametro (id_maquina, parametro),
    UNIQUE INDEX uq_parametro_ambito (ambito, categoria, parametro, id_maquina, id_usuario),
    
    -- Claves foráneas
    CONSTRAINT fk_config_maquina FOREIGN KEY (id_maquina) 
        REFERENCES MAQUINAS(id_maquina) ON DELETE CASCADE,
        
    CONSTRAINT fk_config_usuario FOREIGN KEY (id_usuario) 
        REFERENCES USUARIOS(id_usuario) ON DELETE CASCADE,
        
    CONSTRAINT fk_config_modificado_por FOREIGN KEY (modificado_por) 
        REFERENCES USUARIOS(id_usuario)
        
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT 'Tabla de configuración del sistema';


-- TABLA: AUDITORIA DE CONFIGURACIONES
CREATE TABLE AUDITORIA_CONFIG (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    
    -- QUÉ se cambió
    id_config INT NOT NULL,
    tabla_origen VARCHAR(50) DEFAULT 'CONFIGURACION',
    operacion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    
    -- QUIÉN lo cambió
    id_usuario INT NOT NULL,
    id_maquina INT NULL,
    
    -- QUÉ cambió exactamente
    parametro VARCHAR(100) NOT NULL,
    campo_modificado VARCHAR(50),
    valor_anterior JSON,  -- JSON para manejar cualquier tipo de dato
    valor_nuevo JSON,
    cambios_detallados JSON COMMENT 'JSON con todos los campos modificados',
    
    -- DÓNDE y CÓMO
    ip_origen VARCHAR(45),
    user_agent VARCHAR(500),
    endpoint_api VARCHAR(255) COMMENT 'Endpoint de API si aplica',
    metodo_http VARCHAR(10) COMMENT 'GET, POST, PUT, DELETE',
    
    -- POR QUÉ (contexto)
    motivo_cambio VARCHAR(500),
    ticket_soporte VARCHAR(50),
    referente_cambio VARCHAR(100) COMMENT 'Ej: "Alarma #123", "Revisión mensual"',
    
    -- CUÁNDO
    fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_efectiva DATETIME COMMENT 'Fecha en que el cambio debe surtir efecto',
    
    -- VERIFICACIÓN
    checksum VARCHAR(64) COMMENT 'SHA-256 para integridad de datos',
    verificada_por INT NULL,
    fecha_verificacion DATETIME NULL,
    
    -- Índices para búsquedas rápidas
    INDEX idx_parametro_fecha (parametro, fecha_modificacion),
    INDEX idx_usuario_fecha (id_usuario, fecha_modificacion),
    INDEX idx_operacion_fecha (operacion, fecha_modificacion),
    INDEX idx_maquina_fecha (id_maquina, fecha_modificacion),
    INDEX idx_ticket (ticket_soporte),
    INDEX idx_checksum (checksum),
    
    -- Claves foráneas
    FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario),
    FOREIGN KEY (id_maquina) REFERENCES MAQUINAS(id_maquina),
    FOREIGN KEY (verificada_por) REFERENCES USUARIOS(id_usuario),
    
    -- Constraints
    CONSTRAINT chk_valores_no_vacios CHECK (
        (valor_anterior IS NOT NULL OR valor_nuevo IS NOT NULL)
    )
    
) ENGINE=InnoDB COMMENT='Auditoría detallada de cambios de configuración';


-- =============================================
-- MODIFICACIONES A TABLAS EXISTENTES
-- =============================================

-- Mejoras a Tabla MAQUINAS
ALTER TABLE MAQUINAS
CHANGE COLUMN estado estado_operativo ENUM ('Activo','Inactivo','Mantenimiento','Reparación') DEFAULT 'Activo' NOT NULL,
DROP INDEX idx_estado,
ADD INDEX idx_estado_operativo (estado_operativo),
DROP CHECK chk_estado,
ADD CONSTRAINT chk_estado_operativo CHECK (estado_operativo IN ('Activo', 'Inactivo', 'Mantenimiento','Reparación'));

--  Mejoras a Tabla Mantenimientos
ALTER TABLE MANTENIMIENTOS
CHANGE COLUMN estado estado_mantenimiento ENUM ('Programado', 'En Progreso', 'Completado', 'Cancelado', 'Pospuesto') DEFAULT 'Programado',
DROP INDEX idx_estado,
ADD INDEX idx_estado_mantenimiento (estado_mantenimiento);



-- =============================================
-- SECCIÓN 2: VISTAS
-- =============================================

-- VISTA: VW_MANTENIMIENTOS_PENDIENTES
CREATE VIEW VW_MANTENIMIENTOS_PENDIENTES AS
SELECT 
    m.nombre as maquina,
    m.ubicacion,
    mt.tipo,
    mt.descripcion,
    mt.fecha_programada,
    DATEDIFF(mt.fecha_programada, CURDATE()) as dias_restantes,
    u.nombre as tecnico_asignado,
    mt.estado_mantenimiento
FROM MANTENIMIENTOS mt
JOIN MAQUINAS m ON mt.id_maquina = m.id_maquina
LEFT JOIN USUARIOS u ON mt.id_tecnico = u.id_usuario
WHERE mt.estado_mantenimiento IN ('Programado', 'Pospuesto')
ORDER BY mt.fecha_programada ASC;


-- VISTA: VW_EFICIENCIA_ENERGETICA
CREATE VIEW VW_EFICIENCIA_ENERGETICA AS
SELECT 
    ma.nombre as maquina,
    ma.ubicacion,
    ed.fecha,
    ed.energia_total_kwh,
    ed.horas_operacion,
    ROUND(ed.energia_total_kwh / NULLIF(ed.horas_operacion, 0), 3) as consumo_horario_promedio,
    ed.factor_potencia_promedio,
    CASE 
        WHEN ed.factor_potencia_promedio < 0.85 THEN 'Bajo - Requiere Corrección'
        WHEN ed.factor_potencia_promedio < 0.9 THEN 'Aceptable'
        WHEN ed.factor_potencia_promedio < 0.95 THEN 'Bueno'
        ELSE 'Excelente'
    END as calidad_factor_potencia,
    ed.desbalance_corriente,
    CASE
        WHEN ed.desbalance_corriente > 10 THEN 'Crítico'
        WHEN ed.desbalance_corriente > 5 THEN 'Alto'
        WHEN ed.desbalance_corriente > 2 THEN 'Moderado'
        ELSE 'Normal'
    END as nivel_desbalance
FROM ENERGIA_DIARIA ed
JOIN MAQUINAS ma ON ed.id_maquina = ma.id_maquina
WHERE ed.fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);


-- VISTA: VW_HISTORIAL_MAQUINA
CREATE VIEW VW_HISTORIAL_MAQUINA AS
SELECT 
    'Medición' as tipo_registro,
    m.nombre as maquina,
    m.estado_operativo,  -- ← estado actual de la máquina
    med.timestamp as fecha_hora,
    DATE(med.timestamp) as fecha,
    TIME(med.timestamp) as hora,
    CONCAT(
        'Corriente L1: ', COALESCE(FORMAT(med.corriente_L1, 1), 'N/A'), 'A, ',
        'Potencia: ', COALESCE(FORMAT(med.potencia_activa, 1), 'N/A'), 'kW'
    ) as detalle,
    med.corriente_L1,
    med.potencia_activa,
    NULL as tecnico,
    NULL as resultado_mantenimiento,
    med.id_maquina,
    med.estado_operativo_registrado as estado_al_momento
FROM MEDICIONES med
JOIN MAQUINAS m ON med.id_maquina = m.id_maquina

UNION ALL

SELECT 
    'Mantenimiento' as tipo_registro,
    m.nombre as maquina,
    m.estado_operativo,  -- ← estado actual de la máquina
    COALESCE(mt.fecha_fin, mt.fecha_inicio, mt.fecha_programada) as fecha_hora,
    DATE(COALESCE(mt.fecha_fin, mt.fecha_inicio, mt.fecha_programada)) as fecha,
    TIME(COALESCE(mt.fecha_fin, mt.fecha_inicio, mt.fecha_programada)) as hora,
    CONCAT(
        mt.tipo, ': ', 
        LEFT(mt.descripcion, 100),
        CASE 
            WHEN mt.piezas_reemplazadas IS NOT NULL 
            THEN CONCAT(' [Piezas: ', LEFT(mt.piezas_reemplazadas, 50), ']')
            ELSE ''
        END
    ) as detalle,
    NULL as corriente_L1,
    NULL as potencia_activa,
    CONCAT(u.nombre, ' ', u.apellido) as tecnico,
    mt.resultado as resultado_mantenimiento,
    mt.id_maquina,
    NULL as estado_al_momento
FROM MANTENIMIENTOS mt
JOIN MAQUINAS m ON mt.id_maquina = m.id_maquina
LEFT JOIN USUARIOS u ON mt.id_tecnico = u.id_usuario
WHERE mt.estado_mantenimiento = 'Completado'  -- ← estado_mantenimiento

ORDER BY fecha_hora DESC;


-- VISTA: VW_AUDITORIA_USUARIOS (Cambios recientes por usuario)
CREATE OR REPLACE VIEW VW_AUDITORIA_USUARIOS AS
SELECT 
    u.id_usuario,
    u.nombre,
    u.apellido,
    u.rol,
    u.estado as estado_usuario,
    
    -- Estadísticas básicas
    COUNT(a.id_auditoria) as total_cambios,
    
    -- Por tipo de operación
    SUM(CASE WHEN a.operacion = 'INSERT' THEN 1 ELSE 0 END) as inserciones,
    SUM(CASE WHEN a.operacion = 'UPDATE' THEN 1 ELSE 0 END) as actualizaciones,
    SUM(CASE WHEN a.operacion = 'DELETE' THEN 1 ELSE 0 END) as eliminaciones,
    
    -- Fechas
    MIN(a.fecha_modificacion) as primera_modificacion,
    MAX(a.fecha_modificacion) as ultima_modificacion,
    DATEDIFF(NOW(), MIN(a.fecha_modificacion)) as dias_desde_primer_cambio,
    
    -- Parámetros modificados
    COUNT(DISTINCT a.parametro) as parametros_diferentes_modificados,
    GROUP_CONCAT(DISTINCT a.parametro ORDER BY a.parametro SEPARATOR ', ') as lista_parametros,
    
    -- Máquinas afectadas
    COUNT(DISTINCT a.id_maquina) as maquinas_diferentes_afectadas,
    GROUP_CONCAT(DISTINCT m.nombre ORDER BY m.nombre SEPARATOR ', ') as lista_maquinas,
    
    -- Frecuencia
    ROUND(COUNT(a.id_auditoria) / NULLIF(DATEDIFF(NOW(), MIN(a.fecha_modificacion)), 0), 2) as cambios_por_dia,
    
    -- Contexto
    COUNT(DISTINCT a.motivo_cambio) as motivos_diferentes,
    COUNT(DISTINCT a.ticket_soporte) as tickets_involucrados
    
FROM AUDITORIA_CONFIG a
JOIN USUARIOS u ON a.id_usuario = u.id_usuario
LEFT JOIN MAQUINAS m ON a.id_maquina = m.id_maquina
GROUP BY u.id_usuario, u.nombre, u.apellido, u.rol, u.estado
ORDER BY total_cambios DESC;


-- VISTA: VW_AUDITORIA_CRITICA (Cambios críticos_umbrales de seguridad)
CREATE VIEW VW_AUDITORIA_CRITICA AS
SELECT 
    a.*,
    m.nombre as maquina,
    CONCAT(u.nombre, ' ', u.apellido) as usuario
FROM AUDITORIA_CONFIG a
LEFT JOIN MAQUINAS m ON a.id_maquina = m.id_maquina
JOIN USUARIOS u ON a.id_usuario = u.id_usuario
WHERE a.parametro IN (
    'corriente_maxima', 'temperatura_maxima', 'velocidad_maxima',
    'presion_maxima', 'umbral_vibracion'
)
ORDER BY a.fecha_modificacion DESC;



-- =============================================
-- SECCIÓN 3: FUNCIONES
-- =============================================

DROP FUNCTION IF EXISTS fn_CalcularDisponibilidad;
-- Función: fn_CalcularDisponibilidad
DELIMITER //
CREATE FUNCTION fn_CalcularDisponibilidad(
    p_id_maquina INT,
    p_fecha_inicio DATE,
    p_fecha_fin DATE
) RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_horas DECIMAL(10,2);
    DECLARE horas_indisponible DECIMAL(10,2);
    DECLARE disponibilidad DECIMAL(5,2);
    
    -- Total de horas en el período
    SET total_horas = TIMESTAMPDIFF(HOUR, p_fecha_inicio, p_fecha_fin) + 24;
    
    -- Horas en mantenimiento correctivo en el período
    SELECT COALESCE(SUM(duracion_minutos/60), 0)
    INTO horas_indisponible
    FROM MANTENIMIENTOS
    WHERE id_maquina = p_id_maquina
        AND tipo = 'Correctivo'
        AND estado_mantenimiento = 'Completado'
        AND fecha_inicio >= p_fecha_inicio
        AND fecha_fin <= p_fecha_fin;
    
    -- Cálculo de disponibilidad
    IF total_horas > 0 THEN
        SET disponibilidad = ((total_horas - horas_indisponible) / total_horas) * 100;
    ELSE
        SET disponibilidad = 100;
    END IF;
    
    RETURN ROUND(disponibilidad, 2);
END //
DELIMITER ;


DROP FUNCTION IF EXISTS fn_ObtenerConsumoPeriodo;
-- Función: fn_ObtenerConsumoPeriodo
DELIMITER //
CREATE FUNCTION fn_ObtenerConsumoPeriodo(
    p_id_maquina INT,
    p_fecha_inicio DATE,
    p_fecha_fin DATE
) RETURNS DECIMAL(15,3)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE consumo_total DECIMAL(15,3);
    
    SELECT COALESCE(SUM(energia_total_kwh), 0)
    INTO consumo_total
    FROM ENERGIA_DIARIA
    WHERE id_maquina = p_id_maquina
        AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    RETURN consumo_total;
END //
DELIMITER ;

-- =============================================
-- SECCIÓN 4: STORED PROCEDURES
-- =============================================


-- PROCEDURE: Generar Reporte Mensual
DELIMITER //
CREATE PROCEDURE sp_GenerarReporteMensual(
    IN p_mes INT,
    IN p_anio INT
)
BEGIN
    -- Crear tabla temporal para resultados
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_reporte_mensual (
        maquina VARCHAR(50),
        ubicacion VARCHAR(100),
        energia_total_kwh DECIMAL(15,3),
        costo_energia DECIMAL(10,2),
        horas_operacion DECIMAL(10,2),
        mantenimientos INT,
        disponibilidad DECIMAL(5,2)
    );
    
    -- Limpiar tabla temporal
    DELETE FROM tmp_reporte_mensual;
    
    -- Insertar datos calculados
    INSERT INTO tmp_reporte_mensual
    SELECT 
        m.nombre,
        m.ubicacion,
        COALESCE(SUM(ed.energia_total_kwh), 0) as energia_total,
        COALESCE(SUM(ed.energia_total_kwh * 280.54), 0) as costo_energia, -- Costo actualizado: $280.54/kWh
        COALESCE(SUM(ed.horas_operacion), 0) as horas_operacion,
        COUNT(DISTINCT mt.id_mantenimiento) as mantenimientos,
        fn_CalcularDisponibilidad(m.id_maquina, 
            DATE_FORMAT(CONCAT(p_anio, '-', p_mes, '-01'), '%Y-%m-%d'),
            LAST_DAY(CONCAT(p_anio, '-', p_mes, '-01'))
        ) as disponibilidad
    FROM MAQUINAS m
    LEFT JOIN ENERGIA_DIARIA ed ON m.id_maquina = ed.id_maquina
        AND MONTH(ed.fecha) = p_mes 
        AND YEAR(ed.fecha) = p_anio
    LEFT JOIN MANTENIMIENTOS mt ON m.id_maquina = mt.id_maquina
        AND MONTH(mt.fecha_programada) = p_mes 
        AND YEAR(mt.fecha_programada) = p_anio
        AND mt.estado_mantenimiento = 'Completado'
    GROUP BY m.id_maquina, m.nombre, m.ubicacion;
    
    -- Seleccionar resultados
    SELECT * FROM tmp_reporte_mensual;
    
    -- Totales generales
    SELECT 
        COUNT(*) as total_maquinas,
        SUM(energia_total_kwh) as energia_total_general,
        SUM(costo_energia) as costo_total,

        AVG(disponibilidad) as disponibilidad_promedio
    FROM tmp_reporte_mensual;
    
    -- Limpiar tabla temporal
    DROP TEMPORARY TABLE IF EXISTS tmp_reporte_mensual;
END //
DELIMITER ;


-- PROCEDURE: Actualizar Energia Diaria 
DELIMITER //
CREATE PROCEDURE sp_ActualizarEnergiaDiaria(
    IN p_fecha DATE,
    IN p_id_usuario INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_maquina INT;
    DECLARE cur_maquinas CURSOR FOR SELECT id_maquina FROM MAQUINAS WHERE estado_operativo = 'Activo';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_maquinas;
    
    loop_maquinas: LOOP
        FETCH cur_maquinas INTO v_id_maquina;
        IF done THEN
            LEAVE loop_maquinas;
        END IF;
        
        -- Calcular y actualizar/insertar energía diaria
        INSERT INTO ENERGIA_DIARIA (
            id_maquina, fecha, energia_total_kwh, energia_reactiva_total_kvarh,
            corriente_promedio_L1, corriente_promedio_L2, corriente_promedio_L3,
            tension_promedio_L1, tension_promedio_L2, tension_promedio_L3,
            corriente_maxima, potencia_maxima_kw, horas_operacion,
            factor_potencia_promedio, desbalance_corriente, calculado_por
        )
        SELECT 
            v_id_maquina,
            p_fecha,
            COALESCE(SUM(potencia_activa * (1/3600)), 0), -- kW * hora
            COALESCE(SUM(potencia_reactiva * (1/3600)), 0), -- kVAR * hora
            AVG(corriente_L1),
            AVG(corriente_L2),
            AVG(corriente_L3),
            AVG(tension_L1),
            AVG(tension_L2),
            AVG(tension_L3),
            MAX(GREATEST(corriente_L1, corriente_L2, corriente_L3)),
            MAX(potencia_activa),
            COUNT(CASE WHEN potencia_activa > 0.1 THEN 1 END) / 60.0, -- horas
            AVG(potencia_activa / SQRT(POWER(potencia_activa, 2) + POWER(potencia_reactiva, 2))),
            STDDEV(corriente_L1) / NULLIF(AVG(corriente_L1), 0) * 100,
            p_id_usuario
        FROM MEDICIONES
        WHERE id_maquina = v_id_maquina
            AND DATE(timestamp) = p_fecha
        ON DUPLICATE KEY UPDATE
            energia_total_kwh = VALUES(energia_total_kwh),
            energia_reactiva_total_kvarh = VALUES(energia_reactiva_total_kvarh),
            corriente_promedio_L1 = VALUES(corriente_promedio_L1),
            corriente_promedio_L2 = VALUES(corriente_promedio_L2),
            corriente_promedio_L3 = VALUES(corriente_promedio_L3),
            tension_promedio_L1 = VALUES(tension_promedio_L1),
            tension_promedio_L2 = VALUES(tension_promedio_L2),
            tension_promedio_L3 = VALUES(tension_promedio_L3),
            corriente_maxima = VALUES(corriente_maxima),
            potencia_maxima_kw = VALUES(potencia_maxima_kw),
            horas_operacion = VALUES(horas_operacion),
            factor_potencia_promedio = VALUES(factor_potencia_promedio),
            desbalance_corriente = VALUES(desbalance_corriente),
            calculado_por = VALUES(calculado_por),
            fecha_calculo = CURRENT_TIMESTAMP;
        
    END LOOP loop_maquinas;
    
    CLOSE cur_maquinas;
END //
DELIMITER ;


-- PROCEDURE: Reporte de Auditoría Mensual
DELIMITER //
CREATE PROCEDURE sp_ReporteAuditoriaMensual(IN p_mes INT, IN p_anio INT)
BEGIN
    SELECT 
        '=== RESUMEN MENSUAL DE CAMBIOS ===' as Titulo;
    
    SELECT 
        a.parametro,
        COUNT(*) as cambios,
        GROUP_CONCAT(DISTINCT 
            CONCAT(u.nombre, ' (', u.rol, ')')
        ) as usuarios,
        MIN(a.fecha_modificacion) as primer_cambio,
        MAX(a.fecha_modificacion) as ultimo_cambio
    FROM AUDITORIA_CONFIG a
    JOIN USUARIOS u ON a.modificado_por = u.id_usuario
    WHERE MONTH(a.fecha_modificacion) = p_mes
        AND YEAR(a.fecha_modificacion) = p_anio
    GROUP BY a.parametro
    ORDER BY cambios DESC;
    
    SELECT 
        '=== CAMBIOS POR USUARIO ===' as Titulo;
    
    SELECT 
        u.nombre,
        u.apellido,
        u.rol,
        COUNT(*) as cambios_realizados,
        GROUP_CONCAT(DISTINCT a.parametro) as parametros_modificados
    FROM AUDITORIA_CONFIG a
    JOIN USUARIOS u ON a.modificado_por = u.id_usuario
    WHERE MONTH(a.fecha_modificacion) = p_mes
        AND YEAR(a.fecha_modificacion) = p_anio
    GROUP BY u.id_usuario
    ORDER BY cambios_realizados DESC;
END //
DELIMITER ;


-- =============================================
-- SECCIÓN 5: TRIGGERS
-- =============================================

-- TRIGGER: TRG_AuditariaCompletaConfig

DELIMITER //

CREATE TRIGGER TRG_AuditoriaCompletaConfig
AFTER UPDATE ON CONFIGURACION
FOR EACH ROW
BEGIN
    DECLARE v_cambios JSON DEFAULT JSON_OBJECT();
    DECLARE v_ip VARCHAR(45);
    DECLARE v_user_agent VARCHAR(500);
    
    -- Obtener información del contexto (si está disponible)
    -- En aplicaciones reales, esto viene de variables de sesión
    SET v_ip = COALESCE(@session_ip, 'Sistema');
    SET v_user_agent = COALESCE(@session_user_agent, 'Trigger');
    
    -- Identificar qué campos cambiaron
    IF OLD.valor != NEW.valor THEN
        SET v_cambios = JSON_SET(v_cambios, '$.valor', JSON_OBJECT(
            'anterior', OLD.valor,
            'nuevo', NEW.valor
        ));
    END IF;
    
    IF OLD.estado != NEW.estado THEN
        SET v_cambios = JSON_SET(v_cambios, '$.estado', JSON_OBJECT(
            'anterior', OLD.estado,
            'nuevo', NEW.estado
        ));
    END IF;
    
    IF OLD.descripcion != NEW.descripcion THEN
        SET v_cambios = JSON_SET(v_cambios, '$.descripcion', JSON_OBJECT(
            'anterior', OLD.descripcion,
            'nuevo', NEW.descripcion
        ));
    END IF;
    
    -- Solo registrar si hubo cambios
    IF JSON_LENGTH(v_cambios) > 0 THEN
        INSERT INTO AUDITORIA_CONFIG (
            id_config, operacion, id_usuario, id_maquina,
            parametro, valor_anterior, valor_nuevo, cambios_detallados,
            ip_origen, user_agent, motivo_cambio,
            checksum
        ) VALUES (
            NEW.id_config, 'UPDATE', NEW.modificado_por, NEW.id_maquina,
            NEW.parametro, 
            JSON_OBJECT('valor', OLD.valor, 'estado', OLD.estado),
            JSON_OBJECT('valor', NEW.valor, 'estado', NEW.estado),
            v_cambios,
            v_ip, v_user_agent, COALESCE(@session_motivo, 'Modificación rutinaria'),
            SHA2(CONCAT(
                NEW.id_config, NEW.parametro, 
                COALESCE(NEW.valor, ''), NOW()
            ), 256)
        );
    END IF;
END //

DELIMITER ;


-- TRIGGER: TRG_AuditarCambiosConfig
DELIMITER //
CREATE TRIGGER TRG_AuditarCambiosConfig
BEFORE UPDATE ON CONFIGURACION
FOR EACH ROW
BEGIN
    -- Insertar en tabla de auditoría si cambia el valor
    IF OLD.valor != NEW.valor THEN
        INSERT INTO AUDITORIA_CONFIG (
            id_config, id_maquina, parametro, 
            valor_anterior, valor_nuevo, 
            modificado_por, fecha_modificacion
        ) VALUES (
            OLD.id_config, OLD.id_maquina, OLD.parametro,
            OLD.valor, NEW.valor,
            NEW.modificado_por, NOW()
        );
    END IF;
END //
DELIMITER ;


-- TRIGGER: TRG_ActualizarUltimoMantenimiento
DELIMITER //
CREATE TRIGGER TRG_ActualizarUltimoMantenimiento
AFTER UPDATE ON MANTENIMIENTOS
FOR EACH ROW
BEGIN
    IF NEW.estado_mantenimiento = 'Completado' AND OLD.estado_mantenimiento != 'Completado' THEN
        -- Actualizar último mantenimiento
        UPDATE MAQUINAS 
        SET ultimo_mantenimiento = NEW.fecha_fin
        WHERE id_maquina = NEW.id_maquina;
        
        -- Calcular próximo mantenimiento (30 días después)
        UPDATE MAQUINAS 
        SET proximo_mantenimiento = DATE_ADD(NEW.fecha_fin, INTERVAL 30 DAY)
        WHERE id_maquina = NEW.id_maquina;
    END IF;
END //
DELIMITER ;


-- TRIGGER: TRG_ValidarMediciones
DELIMITER //
CREATE TRIGGER TRG_ValidarMediciones
BEFORE INSERT ON MEDICIONES
FOR EACH ROW
BEGIN
    DECLARE umbral_max_corriente DECIMAL(8,3);
    DECLARE umbral_min_tension DECIMAL(8,2);
    
    -- Obtener umbrales de configuración
    SELECT 
        MAX(CASE WHEN parametro = 'umbral_corriente_max' THEN valor END),
        MAX(CASE WHEN parametro = 'umbral_tension_min' THEN valor END)
    INTO umbral_max_corriente, umbral_min_tension
    FROM CONFIGURACION
    WHERE id_maquina = NEW.id_maquina;
    
    -- Validar corrientes
    IF NEW.corriente_L1 > umbral_max_corriente OR 
       NEW.corriente_L2 > umbral_max_corriente OR 
       NEW.corriente_L3 > umbral_max_corriente THEN
        -- Podría registrar una alarma aquí
        SET NEW.corriente_L1 = LEAST(NEW.corriente_L1, umbral_max_corriente);
        SET NEW.corriente_L2 = LEAST(NEW.corriente_L2, umbral_max_corriente);
        SET NEW.corriente_L3 = LEAST(NEW.corriente_L3, umbral_max_corriente);
    END IF;
    
    -- Validar tensiones mínimas
    IF NEW.tension_L1 < umbral_min_tension OR 
       NEW.tension_L2 < umbral_min_tension OR 
       NEW.tension_L3 < umbral_min_tension THEN
        -- Podría registrar una alarma aquí
        SET NEW.tension_L1 = GREATEST(NEW.tension_L1, umbral_min_tension);
        SET NEW.tension_L2 = GREATEST(NEW.tension_L2, umbral_min_tension);
        SET NEW.tension_L3 = GREATEST(NEW.tension_L3, umbral_min_tension);
    END IF;
END //
DELIMITER ;



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