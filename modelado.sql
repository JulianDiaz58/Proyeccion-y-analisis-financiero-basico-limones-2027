-- 1. Cargar tablas
CREATE OR REPLACE TABLE dim_lotes AS 
SELECT * FROM read_csv_auto('datos_sinteticos/dim_lotes.csv');

CREATE OR REPLACE TABLE dim_forecast_clima_precios_2027 AS 
SELECT * FROM read_csv_auto('datos_forecast/proyeccion_clima_precios_2027.csv');

CREATE OR REPLACE TABLE hecho_proyeccion_2027 AS 
SELECT * FROM read_csv_auto('datos_forecast/proyeccion_demandainsumos_2027.csv');

CREATE OR REPLACE TABLE hecho_proyeccion_rindes_2027 AS 
SELECT * FROM read_csv_auto('datos_forecast/proyeccion_rindes_2027.csv');


-- 2.  Análisis Financiero (P&L, Ingresos 65/35 y Costos por Finca/Tipo de Limón)
CREATE OR REPLACE VIEW vw_dashboard_financiero_2027 AS
WITH costos_acumulados AS (
    SELECT 
        lote_id,
        SUM(costo_total_lote_usd) AS costo_total_insumos_usd
    FROM hecho_proyeccion_2027
    GROUP BY lote_id
),
precio_promedio_mercado AS (
    SELECT 
        AVG(precio_limon_exportacion_usd_t_pred) AS px_exp_promedio,
        AVG(precio_limon_industria_usd_t_pred) AS px_ind_promedio
    FROM dim_forecast_clima_precios_2027
)
SELECT 
    r.lote_id,
    r.nombre_finca,
    r.variedad,
    r.superficie_ha,
    r.rinde_proyectado_t_ha,
    r.produccion_proyectada_t,
    c.costo_total_insumos_usd,
    
    -- Ingresos Proyectados (65% Exportación / 35% Industria)
    ROUND(r.produccion_proyectada_t * 0.65 * p.px_exp_promedio, 2) AS ingreso_exportacion_usd,
    ROUND(r.produccion_proyectada_t * 0.35 * p.px_ind_promedio, 2) AS ingreso_industria_usd,
    ROUND(
        (r.produccion_proyectada_t * 0.65 * p.px_exp_promedio) + 
        (r.produccion_proyectada_t * 0.35 * p.px_ind_promedio), 2
    ) AS ingreso_total_proyectado_usd,
    
    -- Margen Operativo Estimado
    ROUND(
        ((r.produccion_proyectada_t * 0.65 * p.px_exp_promedio) + 
         (r.produccion_proyectada_t * 0.35 * p.px_ind_promedio)) - c.costo_total_insumos_usd, 2
    ) AS margen_operativo_insumos_usd
FROM hecho_proyeccion_rindes_2027 r
JOIN costos_acumulados c ON r.lote_id = c.lote_id
CROSS JOIN precio_promedio_mercado p;


-- 3. Análisis Operativo y Climático Semanal (Estructura de Insumos vs Clima)
CREATE OR REPLACE VIEW vw_dashboard_operativo_semanal_2027 AS
SELECT 
    h.fecha,
    c.semana_anio,
    c.mes,
    h.lote_id,
    h.nombre_finca,
    c.lluvia_semanal_mm_pred,
    c.temperatura_media_c_pred,
    h.demanda_urea_kg_ha,
    h.demanda_fungicida_l_ha,
    h.demanda_gasoil_l_ha,
    h.costo_total_lote_usd,
    c.precio_limon_exportacion_usd_t_pred,
    c.precio_limon_industria_usd_t_pred
FROM hecho_proyeccion_2027 h
JOIN dim_forecast_clima_precios_2027 c ON h.fecha = c.fecha;