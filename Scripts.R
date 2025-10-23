









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
