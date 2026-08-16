Proyeccion campaña limonera 2027


 📊 Dashboard Interactivo (Tableau Public)
El análisis visual y financiero de la campaña se encuentra disponible de forma interactiva en Tableau Public.
> 🔗 **[Ver Dashboard Interactivo en Tableau Public](https://public.tableau.com/views/Proyeccioncampaalimonera2027/Dashboard1?:language=es-ES&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**


⚙️ Generación de Datos Sintéticos (datos_sinteticos.ipynb)
Se generaron datos sinteticos para realizar las proyecciones y el posterior analisis. El script (datos_sinteticos.ipynb) simula el histórico agronómico, climático, de insumos y de mercado para el sector citrícola entre 2010 y 2026 (865 semanas simuladas en 40 lotes, generando 34.600 registros operativos).

🛠️ Tecnologías Utilizadas
Pandas & NumPy: Estructuración de DataFrames, transformaciones y distribuciones estadísticas.
Faker: Inicialización de semillas y datos contextuales.
Random: Asignación estocástica de variables operativas.

📋 Módulos de Generación
1. Estructura Físico-Agronómica (df_lotes)
Lotes: 40 lotes distribuidos en 5 fincas (Finca 1 a Finca 5).
Atributos: Superficie (15–50 Ha), Variedad de Limón (Eureka, Lisbon, Genova), Edad del monte (5–25 años) y Rinde Histórico (Tn/Ha).
2. Serie Climatológica Semanal (df_clima)
Temporalidad: Registro semanal entre 2010-01-01 y 2026-08-01.
Estacionalidad de Precipitaciones:Verano/Primavera: Distribución Gamma (shape=3, scale=12). Transición (Otoño): Distribución Gamma (shape=1.5, scale=8).Invierno: Distribución Gamma (shape=0.5, scale=4); lluvias abundantes en meses calidos (similar a Tucuman)
Riesgo de Heladas: Detección de temperaturas < 5 grados C durante junio, julio y agosto.
3. Penalizaciones por Impacto Climático (df_rindes)
Factor Sequía: Penalización del 15% al 25% sobre el rinde si la lluvia anual es < 700mm.
Factor Helada: Penalización del 15% al 30% según la cantidad de semanas con eventos (heladas) registrados.
4. Precios de Mercado e Insumos (df_mercado)
Simulación Temporal: Inclusión de una tendencia de incremento de costos (+15% en el tiempo) y volatilidad estocástica.
Precios Simulados: Insumos (Urea, Fungicida, Gasoil) y Limón (Industria y Exportación en USD/Tn).
5. Registros Operativos y Costos Lote-Semana (df_operativo)
Demanda de Urea: Aplicación en meses de fertilización (Septiembre–Enero) proporcional al rinde histórico del lote.
Demanda de Fungicida: Aplicación condicionada por umbral de precipitaciones (> 35mm) entre Septiembre y Diciembre.
Consumo de Gasoil: Labores mecánicas incrementadas en ventana de cosecha y pulverizaciones.
Cálculo Financiero: Valorización semanal por Ha y totalización en USD por lote (costo_total_lote_usd).


💾 Datasets Exportados
El script genera 4 archivos CSV en el directorio raíz:
dim_lotes.csvdim_clima.csvdim_mercado.csvhecho_historico_operativo.csv


⚙️ Proyección y Forecasting de Variables (modelo_forecasting.ipynb)

🛠️ Este módulo toma la base histórica de datos sintéticos y realiza la proyección futura a un año (52 semanas) para la campaña 2026-2027.
Para el análisis predictivo se utiliza la librería Statsmodels mediante el algoritmo de suavizado exponencial Holt-Winters, junto con Pandas y NumPy para el procesamiento de series, la contención de valores atípicos
y el modelado estocástico.

📋 El proceso de pronóstico se desarrolla en cinco etapas secuenciales:

    1. Carga de Datos Históricos: Consume directamente los archivos CSV generados previamente en la carpeta de datos sintéticos correspondientes a clima, mercado y lotes.
    2. Modelado de Series Temporales: Aplica el modelo de suavizado exponencial con componente estacional aditivo de 52 semanas a las variables de lluvia semanal y temperatura media. Del mismo modo, proyecta las series 
    de precios de insumos (urea, fungicida y gasoil) y las cotizaciones del limón para exportación e industria.
    3. Ensamblado del Forecast Anual: Construye una ventana temporal futura de 52 semanas a partir de agosto de 2026 y aplica límites lógicos para asegurar que ninguna variable predictiva registre valores negativos.
    4. Proyección de Demanda Operativa y Costos: Recorre el calendario proyectado aplicando la lógica agronómica sobre los lotes. Modela la fertilización con urea entre septiembre y diciembre, la aplicación de 
    fungicida ante lluvias proyectadas superiores a 30 milímetros en meses cálidos, y ajusta los consumos de gasoil según las pasadas de maquinaria requeridas. Con estos volúmenes proyectados, calcula el gasto total en 
    dólares por lote y por hectárea.
    5.  Estimación de Rindes y Producción Total: Consolida las precipitaciones y semanas de helada estimadas para determinar el factor de impacto climático de la nueva campaña. Aplica dicho factor sobre el rinde histórico 
    de cada lote, calcula la producción total esperada en toneladas y genera la tabla final de proyección agrícola.

💾 El script concluye exportando los resultados en tres archivos dentro de la carpeta datos_forecast: hecho_proyeccion_2027.csv, dim_forecast_clima_precios_2027.csv y hecho_proyeccion_rindes_2027.csv.

