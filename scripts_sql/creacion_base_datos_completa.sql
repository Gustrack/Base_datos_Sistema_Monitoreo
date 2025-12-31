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

-- Resto del script con las otras tablas
-- [Van las definiciones de MEDICIONES, CONFIGURACION, MANTENIMIENTOS, ENERGIA_DIARIA, etc.]
-- =============================================
-- OTRAS TABLAS
-- =============================================
-- Tabla Mantenimientos
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

-- Tabla Energia Diaria
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

-- =============================================
-- MODIFICACIONES A TABLAS EXISTENTES
-- =============================================
-- Mejoras a Tabla MAQUINAS
ALTER TABLE MAQUINAS
ADD COLUMN id_responsable INT NULL AFTER fecha_alta,
ADD COLUMN ultimo_mantenimiento DATE NULL,
ADD COLUMN proximo_mantenimiento DATE NULL,
ADD COLUMN horas_totales_operacion DECIMAL(10,2) DEFAULT 0,
ADD COLUMN fabricante VARCHAR(100),
ADD COLUMN numero_serie VARCHAR(100),
ADD COLUMN fecha_instalacion DATE,
ADD COLUMN garantia_hasta DATE,
ADD COLUMN costo_hora DECIMAL(10,2),
ADD COLUMN creado_por INT NOT NULL,
ADD COLUMN fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN modificado_por INT NULL,
ADD COLUMN fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD CONSTRAINT fk_maquina_responsable FOREIGN KEY (id_responsable) REFERENCES USUARIOS(id_usuario),
ADD CONSTRAINT fk_maquina_creado_por FOREIGN KEY (creado_por) REFERENCES USUARIOS(id_usuario),
ADD CONSTRAINT fk_maquina_modificado_por FOREIGN KEY (modificado_por) REFERENCES USUARIOS(id_usuario);

--Mejoras a Tabla CONFIGURACION
ALTER TABLE CONFIGURACION
ADD COLUMN modificado_por INT NOT NULL,
ADD COLUMN fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD CONSTRAINT fk_config_modificado_por FOREIGN KEY (modificado_por) REFERENCES USUARIOS(id_usuario);

-- =============================================
-- SECCIÓN 2: VISTAS
-- =============================================

-- Vista: VW_MANTENIMIENTOS_PENDIENTES
CREATE VIEW VW_MANTENIMIENTOS_PENDIENTES AS
SELECT 
    m.nombre as maquina,
    m.ubicacion,
    mt.tipo,
    mt.descripcion,
    mt.fecha_programada,
    DATEDIFF(mt.fecha_programada, CURDATE()) as dias_restantes,
    u.nombre as tecnico_asignado,
    mt.estado
FROM MANTENIMIENTOS mt
JOIN MAQUINAS m ON mt.id_maquina = m.id_maquina
LEFT JOIN USUARIOS u ON mt.id_tecnico = u.id_usuario
WHERE mt.estado IN ('Programado', 'Pospuesto')
ORDER BY mt.fecha_programada ASC;

-- Vista: VW_EFICIENCIA_ENERGETICA
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

-- Vista: VW_HISTORIAL_MAQUINA
CREATE VIEW VW_HISTORIAL_MAQUINA AS
SELECT 
    'Medición' as tipo_registro,
    m.nombre as maquina,
    med.timestamp as fecha_hora,
    CONCAT('Corriente L1: ', med.corriente_L1, 'A') as detalle,
    NULL as tecnico,
    NULL as resultado
FROM MEDICIONES med
JOIN MAQUINAS m ON med.id_maquina = m.id_maquina

UNION ALL

SELECT 
    'Mantenimiento' as tipo_registro,
    m.nombre as maquina,
    mt.fecha_fin as fecha_hora,
    mt.descripcion as detalle,
    u.nombre as tecnico,
    mt.resultado
FROM MANTENIMIENTOS mt
JOIN MAQUINAS m ON mt.id_maquina = m.id_maquina
JOIN USUARIOS u ON mt.id_tecnico = u.id_usuario
WHERE mt.estado = 'Completado'

ORDER BY fecha_hora DESC;

-- =============================================
-- SECCIÓN 3: FUNCIONES
-- =============================================

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
        AND estado = 'Completado'
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

-- Procedure: sp_GenerarReporteMensual
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
        COALESCE(SUM(ed.energia_total_kwh * 0.15), 0) as costo_energia, -- Supuesto: $0.15/kWh
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
        AND mt.estado = 'Completado'
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

-- Procedure: sp_ActualizarEnergiaDiaria
DELIMITER //
CREATE PROCEDURE sp_ActualizarEnergiaDiaria(
    IN p_fecha DATE,
    IN p_id_usuario INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_maquina INT;
    DECLARE cur_maquinas CURSOR FOR SELECT id_maquina FROM MAQUINAS WHERE estado = 'Activo';
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

-- =============================================
-- SECCIÓN 5: TRIGGERS
-- =============================================

-- Trigger: TRG_AuditarCambiosConfig
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

-- Trigger: TRG_ActualizarUltimoMantenimiento
DELIMITER //
CREATE TRIGGER TRG_ActualizarUltimoMantenimiento
AFTER UPDATE ON MANTENIMIENTOS
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Completado' AND OLD.estado != 'Completado' THEN
        -- Actualizar último mantenimiento
        UPDATE MAQUINAS 
        SET ultimo_mantenimiento = NEW.fecha_fin
        WHERE id_maquina = NEW.id_maquina;
        
        -- Calcular próximo mantenimiento (ejemplo: 30 días después)
        UPDATE MAQUINAS 
        SET proximo_mantenimiento = DATE_ADD(NEW.fecha_fin, INTERVAL 30 DAY)
        WHERE id_maquina = NEW.id_maquina;
    END IF;
END //
DELIMITER ;

-- Trigger: TRG_ValidarMediciones
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