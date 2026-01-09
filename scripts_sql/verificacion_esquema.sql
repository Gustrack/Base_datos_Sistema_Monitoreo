-- =============================================
-- VERIFICACIÓN DE ESQUEMA - Sistema de Monitoreo
-- =============================================

USE monitoreo_maquinas;

-- 1. MOSTRAR TODAS LAS TABLAS CON INFORMACIÓN DETALLADA
SELECT 
    '=== TABLAS EXISTENTES ===' as Estado;
    
SELECT 
    TABLE_NAME as 'Tabla',
    TABLE_ROWS as 'Filas',
    TABLE_TYPE as 'Tipo',
    ENGINE as 'Motor',
    CREATE_TIME as 'Creada',
    TABLE_COLLATION as 'Collation'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'monitoreo_maquinas'
ORDER BY TABLE_NAME;

-- 2. VER ESTRUCTURA COMPLETA DE CADA TABLA
SELECT 
    '=== ESTRUCTURA DE TABLAS ===' as Estado;
    
SELECT 
    TABLE_NAME as 'Tabla',
    COLUMN_NAME as 'Columna',
    COLUMN_TYPE as 'Tipo',
    IS_NULLABLE as '¿Nulo?',
    COLUMN_DEFAULT as 'Valor por defecto',
    COLUMN_KEY as 'Clave',
    EXTRA as 'Extra'
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'monitoreo_maquinas'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- 3. VER CLAVES FORÁNEAS
SELECT 
    '=== CLAVES FORÁNEAS ===' as Estado;
    
SELECT 
    TABLE_NAME as 'Tabla',
    COLUMN_NAME as 'Columna',
    CONSTRAINT_NAME as 'Nombre Restricción',
    REFERENCED_TABLE_NAME as 'Tabla Referenciada',
    REFERENCED_COLUMN_NAME as 'Columna Referenciada'
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'monitoreo_maquinas'
    AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;

-- 4. VER ÍNDICES
SELECT 
    '=== ÍNDICES ===' as Estado;
    
SELECT 
    TABLE_NAME as 'Tabla',
    INDEX_NAME as 'Nombre Índice',
    COLUMN_NAME as 'Columna',
    INDEX_TYPE as 'Tipo',
    NON_UNIQUE as '¿No Único?'
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'monitoreo_maquinas'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- 5. VER VISTAS
SELECT 
    '=== VISTAS ===' as Estado;
    
SELECT 
    TABLE_NAME as 'Vista',
    VIEW_DEFINITION as 'Definición',
    IS_UPDATABLE as '¿Actualizable?'
FROM information_schema.VIEWS 
WHERE TABLE_SCHEMA = 'monitoreo_maquinas';

-- 6. VER PROCEDIMIENTOS Y FUNCIONES
SELECT 
    '=== PROCEDIMIENTOS ALMACENADOS ===' as Estado;
    
SELECT 
    ROUTINE_NAME as 'Nombre',
    ROUTINE_TYPE as 'Tipo',
    DATA_TYPE as 'Tipo Retorno',
    ROUTINE_DEFINITION as 'Definición'
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'monitoreo_maquinas'
ORDER BY ROUTINE_TYPE, ROUTINE_NAME;

-- 7. VER TRIGGERS
SELECT 
    '=== TRIGGERS ===' as Estado;
    
SELECT 
    TRIGGER_NAME as 'Nombre Trigger',
    EVENT_MANIPULATION as 'Evento',
    EVENT_OBJECT_TABLE as 'Tabla',
    ACTION_TIMING as 'Momento',
    ACTION_STATEMENT as 'Acción'
FROM information_schema.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'monitoreo_maquinas'
ORDER BY EVENT_OBJECT_TABLE, ACTION_TIMING;

-- 8. RESUMEN ESTADÍSTICO
SELECT 
    '=== RESUMEN ESTADÍSTICO ===' as Estado;
    
SELECT 
    'Tablas' as Elemento,
    COUNT(*) as Cantidad
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'monitoreo_maquinas'
    AND TABLE_TYPE = 'BASE TABLE'
    
UNION ALL

SELECT 
    'Vistas',
    COUNT(*)
FROM information_schema.VIEWS 
WHERE TABLE_SCHEMA = 'monitoreo_maquinas'
    
UNION ALL

SELECT 
    'Procedimientos',
    COUNT(*)
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'monitoreo_maquinas'
    AND ROUTINE_TYPE = 'PROCEDURE'
    
UNION ALL

SELECT 
    'Funciones',
    COUNT(*)
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'monitoreo_maquinas'
    AND ROUTINE_TYPE = 'FUNCTION'
    
UNION ALL

SELECT 
    'Triggers',
    COUNT(*)
FROM information_schema.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'monitoreo_maquinas';