# CasoHarvardFinal
Predicting Customer Churn at QWE Inc.

Este repositorio corresponde al análisis del caso Predicting Customer Churn at QWE Inc., desarrollado para el curso de Business Analytics – Pontificia Universidad Javeriana (2025-3).

Datos y archivos de réplica para el caso Predicting Customer Churn at QWE Inc. por Karol Juliana Riaño Ortiz, Daniel Parra Mora y Alejandra Herrera Jimenez.

---

## Resumen

El caso *Predicting Customer Churn at QWE Inc.* analiza cómo una empresa tecnológica puede aplicar **modelos predictivos y analítica avanzada** para anticipar la pérdida de clientes (*churn*) y diseñar estrategias de retención más efectivas.

**QWE Inc.**, proveedora de servicios digitales para pequeñas y medianas empresas, enfrentaba un aumento en la cancelación de suscripciones. Tradicionalmente, la empresa reaccionaba ofreciendo descuentos a quienes deseaban cancelar. Sin embargo, **Richard Wall**, VP de Servicio al Cliente, decidió implementar un enfoque proactivo: **predecir la probabilidad de que un cliente abandone la plataforma en los próximos dos meses**.

A partir de una muestra de 6.000 clientes, **V. J. Aggrawal** desarrolló un modelo basado en variables de antigüedad, satisfacción (CHI), casos de soporte y patrones de uso de la plataforma.

---

El presente trabajo incluye:
1. **Carga y exploración de datos**  
   - Lectura del archivo `DATA.xlsx`.  
   - Conversión a *data frame* y verificación de columnas.  

2. **Renombramiento y preparación de variables**  
   - Normalización de nombres de columnas para un manejo más simple.  
   - Creación de variable objetivo `churn_bin` con niveles `"Yes"` y `"No"`.  

3. **Selección de variables explicativas**  
   - Se incluyen indicadores de antigüedad, satisfacción, soporte y uso del sistema:  
     `customer_age_months`, `chi_month0`, `support_cases_month0`, `sp_month0`, `logins_change_0_1`, `views_change_0_1`, etc.  

4. **Depuración y creación del dataset modelado**  
   - Eliminación de observaciones con valores faltantes en variables clave.  

5. **Análisis descriptivo**  
   - Cálculo de estadísticos resumen (media, desviación estándar, cuartiles).  
   - Exportación de la tabla descriptiva en **CSV** y **Word (`tabla_descriptiva.docx`)**.  

6. **Modelo predictivo: regresión logística (Logit)**  
   - Estimación del modelo con `glm()` y enlace *logit*.  
   - Exportación de los coeficientes, errores estándar, valores p e intervalos de confianza.  
   - Tabla formateada en **Word (`tabla_regresion_logit.docx`)**, resaltando las variables significativas.  

7. **Evaluación del modelo**  
   - Cálculo del **Pseudo R² de McFadden** y del **AUC (curva ROC)**.  
   - Comparación de desempeño con dos umbrales:  
     - Estándar (0.5)  
     - Óptimo (criterio de Youden).  
   - Exportación de métricas clave: *Accuracy, Sensitivity, Specificity*.  
   - Generación de la **matriz de confusión** (`matriz_confusion_opt.csv`).  

8. **Visualización de resultados**  
   Se generan y exportan automáticamente los siguientes gráficos:
   - `ROC_curve.png` → Curva ROC y valor del AUC.  
   - `predicho_vs_real.png` → Probabilidad predicha vs churn real.  
   - `residuos_vs_pred.png` → Residuos de deviance vs probabilidad predicha.  
   - `hist_prob_por_clase.png` → Distribución de probabilidades por clase real.  

9. **Exportación de resultados finales**  
   - Dataset con predicciones (`data_with_predictions.csv`).  
   - Archivo resumen de métricas del modelo (`metricas_resumen_modelo.csv`).  

---

## 📁 Estructura del repositorio

### 📂 `Stores/`
Contiene la base de datos original del caso:
- `DATA.xls` → Base de datos con observaciones y variables utilizadas.

---

### 📂 `Scripts/`
Contiene el código de análisis y modelado:
- `Churn_Prediction.R` → Script principal con todas las etapas del proceso analítico.

---

### 📂 `Views/`
Contiene los gráficos generados automáticamente:
- `ROC_curve.png`  
- `predicho_vs_real.png`  
- `residuos_vs_pred.png`  
- `hist_prob_por_clase.png`  

---

### 📂 `Document/`
Incluye los informes y resultados exportados:
- `Analysis.pdf` → Informe analítico del caso.  
- `Predicting_Customer_Churn.pdf` → Documento original (Darden School of Business).  
- `data_with_predictions.csv` → Dataset con probabilidades y clases predichas.  
- `matriz_confusion_opt.csv` → Matriz de confusión y métricas por clase.  
- `metricas_resumen_modelo.csv` → Resumen general de desempeño.  
- `tabla_descriptiva.docx` → Estadísticos descriptivos de las variables.  
- `tabla_regresion_logit.docx` → Resultados del modelo logit con significancia estadística.
