




# 7) Ajustar modelo logit (glm con link logit) -----------------------------
# Construimos fórmula con las features detectadas
fmla <- as.formula(paste("churn_bin ~", paste(features_present, collapse = " + ")))
logit_mod <- glm(fmla, data = model_df, family = binomial(link = "logit"))
summary(logit_mod)


# Extraer coeficientes del modelo logit (limpio y como data.frame)
coef_tab <- broom::tidy(logit_mod, conf.int = TRUE) %>% as.data.frame()

# Renombrar columnas y redondear para mejor presentación
coef_tab <- coef_tab %>%
  rename(
    Variable = term,
    Estimacion = estimate,
    Error estandar = std.error,
    Valor z = statistic,
    Valor p = p.value,
    IC 2.5% = conf.low,
    IC 97.5% = conf.high
  ) %>%
  mutate(
across(where(is.numeric), ~round(., 4))  # redondear todos los números
  )
# Guardar tabla en CSV
data.table::fwrite(coef_tab, "tabla_regresion_logit.csv")

# Crear tabla formateada para Word
tabla_regresion_flex <- flextable(coef_tab) %>%
  autofit() %>%
  theme_vanilla() %>%
  bold(part = "header") %>%
  align(align = "center", part = "all") %>%
  fontsize(size = 10, part = "all") %>%
  color(i = ~ Valor p < 0.05, color = "red") %>%  # resalta en rojo las variables significativas
  set_caption("Tabla 2. Resultados del modelo Logit - Probabilidad de Churn")

# Crear documento Word con formato y guardar
doc_reg <- read_docx() %>%
  body_add_par("2. Resultados del modelo Logit", style = "heading 1") %>%
  body_add_par(" ", style = "Normal") %>%
  body_add_flextable(tabla_regresion_flex) %>%
  body_add_par("Fuente: elaboración propia con base en datos de QWE Inc.", style = "Normal")
print(doc_reg, target = "tabla_regresion_logit.docx")
# 9) Evaluación del modelo -------------------------------------------------
# Pseudo R2 de McFadden
pr2 <- pR2(logit_mod)
cat("Pseudo R2 (McFadden):\n")
print(pr2)

# Predicciones: probabilidades y clases (umbral 0.5)
model_df$pred_prob <- predict(logit_mod, type = "response")
model_df$pred_class_05 <- factor(ifelse(model_df$pred_prob >= 0.5, "Yes", "No"),
                                 levels = c("No","Yes"))

# Matriz de confusión con umbral 0.5
cm_05 <- confusionMatrix(model_df$pred_class_05, model_df$churn_bin, positive = "Yes")
print(cm_05)
capture.output(cm_05, file = "confusion_matrix_05.txt")

# ROC y AUC
roc_obj <- roc(response = as.numeric(model_df$churn_bin == "Yes"), predictor = model_df$pred_prob)
auc_val <- auc(roc_obj)
cat("AUC:", auc_val, "\n")
png("ROC_curve.png", width=800, height=600)
plot(roc_obj, main = paste0("ROC Curve - AUC = ", round(auc_val,4)))
dev.off()
# Umbral óptimo (Youden)
coords_youden <- coords(roc_obj, "best", best.method = "youden")
opt_thresh <- coords_youden[["threshold"]]  # extrae solo el número
cat("Umbral óptimo por Youden:", opt_thresh, "\n")

# Matriz de confusión con umbral óptimo
model_df$pred_class_opt <- factor(ifelse(model_df$pred_prob >= opt_thresh, "Yes", "No"), levels = c("No","Yes"))
cm_opt <- confusionMatrix(model_df$pred_class_opt, model_df$churn_bin, positive = "Yes")
# Extraer partes importantes de la matriz
matriz <- as.data.frame(cm_opt$table)
metricas <- as.data.frame(t(cm_opt$byClass))
resumen <- as.data.frame(t(cm_opt$overall))
# Guardar en CSV
write.xlsx(list("Matriz_Confusion" = matriz,
                "Metricas_Por_Clase" = metricas,
                "Resumen_General" = resumen),
           file = "matriz_confusion_opt.csv")
# 10) Gráficos para analizar errores y predicho vs real --------------------
# a) Predicho (prob) vs real (0/1)
p1 <- ggplot(model_df, aes(x = pred_prob, y = as.numeric(churn_bin == "Yes"))) +
  geom_jitter(height = 0.02, alpha = 0.5) +
  geom_smooth(method = "loess") +
  labs(x = "Probabilidad predicha", y = "Churn real (0/1)",
       title = "Probabilidad predicha vs Churn real") +
  theme_minimal()
ggsave("predicho_vs_real.png", p1, width = 8, height = 5)

# b) Residuos de deviance vs probabilidad predicha (busca patrones)
model_df$deviance_resid <- residuals(logit_mod, type = "deviance")
p2 <- ggplot(model_df, aes(x = pred_prob, y = deviance_resid)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "loess") +
  labs(x = "Probabilidad predicha", y = "Residuos de deviance",
       title = "Residuos vs Probabilidad predicha") +
  theme_minimal()
ggsave("residuos_vs_pred.png", p2, width = 8, height = 5)

# c) Histograma de probabilidades por clase real
p3 <- ggplot(model_df, aes(x = pred_prob, fill = churn_bin)) +
  geom_histogram(position = "identity", alpha = 0.5, bins = 30) +
  labs(title = "Distribución de probabilidades predichas por clase real",
       x = "Probabilidad predicha") +
  theme_minimal()
ggsave("hist_prob_por_clase.png", p3, width = 8, height = 5)

cat("Gráficos guardados: predicho_vs_real.png, residuos_vs_pred.png, hist_prob_por_clase.png, ROC_curve.png\n")

# 11) Guardar dataset con predicciones y métricas resumen ------------------
fwrite(model_df, "data_with_predictions.csv")

metrics <- data.frame(
  AUC = as.numeric(auc_val),
  McFadden_R2 = as.numeric(pr2["McFadden"]),
  Accuracy_05 = as.numeric(cm_05$overall["Accuracy"]),
  Sensitivity_05 = as.numeric(cm_05$byClass["Sensitivity"]),
  Specificity_05 = as.numeric(cm_05$byClass["Specificity"]),
  Accuracy_opt = as.numeric(cm_opt$overall["Accuracy"]),
  Sensitivity_opt = as.numeric(cm_opt$byClass["Sensitivity"]),
  Specificity_opt = as.numeric(cm_opt$byClass["Specificity"]),
  Optimal_Threshold = as.numeric(opt_thresh)
)
fwrite(metrics, "metricas_resumen_modelo.csv")
cat("Métricas guardadas en metricas_resumen_modelo.csv\n")

cat("Análisis completado. Revisa los archivos generados en la carpeta de trabajo.\n")
