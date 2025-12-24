-- =============================================
-- SCRIPT DE DATOS DE PRUEBA
-- Para probar vistas, funciones y procedures
-- =============================================

USE monitoreo_maquinas;

-- Insertar máquinas adicionales
INSERT INTO MAQUINAS (nombre, modelo, ubicacion, estado, fecha_alta, id_responsable, creado_por) VALUES
('Torno CNC 002', 'TornoMaster 5000', 'Área de Torneado', 'Activo', '2024-03-01', 2, 1),
('Fresadora 002', 'FresaPro 3000', 'Área de Fresado', 'Activo', '2024-03-05', 2, 1),
('Prensa Hidráulica', 'PressForce 100T', 'Área de Estampado', 'Activo', '2024-03-10', 3, 1);

-- Insertar configuraciones adicionales
INSERT INTO CONFIGURACION (id_maquina, parametro, valor, modificado_por) VALUES
(5, 'frecuencia_muestreo', '60', 1),
(5, 'umbral_corriente_max', '30.0', 1),
(6, 'frecuencia_muestreo', '45', 1),
(6, 'umbral_tension_min', '215.0', 1),
(7, 'frecuencia_muestreo', '120', 1);

-- Insertar mantenimientos programados
INSERT INTO MANTENIMIENTOS (id_maquina, id_tecnico, tipo, descripcion, fecha_programada, estado, creado_por) VALUES
(1, 2, 'Preventivo', 'Cambio de aceite y filtros', '2024-04-15 08:00:00', 'Programado', 1),
(2, 3, 'Calibración', 'Calibración de ejes XYZ', '2024-04-10 09:00:00', 'Programado', 1),
(3, 2, 'Correctivo', 'Reparación del husillo principal', '2024-04-05 10:00:00', 'En Progreso', 1);

-- Generar datos de mediciones para pruebas
-- [Script para generar datos sintéticos de mediciones]

-- Llamar a procedures de ejemplo
CALL sp_GenerarReporteMensual(3, 2024);

-- Probar funciones
SELECT 
    nombre,
    fn_CalcularDisponibilidad(id_maquina, '2024-03-01', '2024-03-31') as disponibilidad_marzo,
    fn_ObtenerConsumoPeriodo(id_maquina, '2024-03-01', '2024-03-31') as consumo_marzo_kwh
FROM MAQUINAS
WHERE estado = 'Activo';

-- Mostrar vistas
SELECT * FROM VW_MANTENIMIENTOS_PENDIENTES;
SELECT * FROM VW_EFICIENCIA_ENERGETICA LIMIT 10;

SELECT 'Datos de prueba insertados correctamente' as Mensaje;