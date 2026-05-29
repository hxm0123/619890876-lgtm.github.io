# ------------------------------------------------------------------
# 1. 加载必要的库
# ------------------------------------------------------------------
# 如果未安装，请取消下面这行的注释并运行：
install.packages(c("xgboost", "shapviz", "dplyr", "ggplot2"))

library(xgboost)
library(shapviz)
library(dplyr)
library(ggplot2)

# ------------------------------------------------------------------
# 2. 数据准备
# ------------------------------------------------------------------
# 读取数据
df <- read.csv("D:/R/Rworkdir/滦河流域模拟数据.csv")

# 查看数据结构，确保读取正确
head(df)

# 定义特征 (X) 和目标变量 (y)
# 目标变量 y 是 "Streamflow" (径流)
y <- df$Streamflow

# 特征 X 是除去 "Streamflow" 列之外的所有列
X <- df %>% select(-Streamflow) %>% as.matrix()

# 将数据转换为 XGBoost 模型专用的格式 (DMatrix)
dtrain <- xgb.DMatrix(data = X, label = y)

# ------------------------------------------------------------------
# 3. 训练 XGBoost 模型
#    (使用文档中提到的最优参数，或默认参数)
# ------------------------------------------------------------------
set.seed(123) # 设置随机种子，保证结果可重现

# 训练模型
fit <- xgb.train(
  params = list(
    objective = "reg:squarederror", # 回归任务
    eta = 0.01,                    # 学习率
    max_depth = 6,                 # 树的最大深度
    subsample = 0.8,             # 样本采样比例
    colsample_bytree = 0.8       # 特征采样比例
  ),
  data = dtrain,
  nrounds = 500,                 # 迭代次数
  verbose = 0                    # 不输出训练过程信息
)

# ------------------------------------------------------------------
# 4. 计算 SHAP 值
# ------------------------------------------------------------------
# 使用 shapviz 包计算 SHAP 值
# approximate = TRUE 使用快速近似算法，适合大数据集
sv <- shapviz(fit, X_pred = X, approximate = TRUE)

# ------------------------------------------------------------------
# 5. 绘制图7a: 全局特征重要性 (Global Feature Importance)
# ------------------------------------------------------------------
p_importance <- sv_importance(sv) +
  theme_minimal() +
  labs(title = "图7a: 特征重要性排序 (SHAP Value Sum)",
       x = "平均 |SHAP 值| (特征重要性)",
       y = "特征名称")

print(p_importance)

# ------------------------------------------------------------------
# 6. 绘制图7b: SHAP 依赖关系图 (Dependency Plots)
#     展示关键变量（降水、草地、耕地）与径流的非线性关系
# ------------------------------------------------------------------

# 6.1 降水 vs 径流响应
p_precip <- sv_dependence(sv, v = "Precipitation", alpha = 0.6, size = 1) +
  theme_minimal() +
  labs(title = "图7b (左): 降水对径流的边际效应",
       x = "降水量 (mm)",
       y = "SHAP 值 (对径流的贡献)")

# 6.2 草地面积 vs 径流响应
p_grass <- sv_dependence(sv, v = "Grassland", alpha = 0.6, size = 1) +
  theme_minimal() +
  labs(title = "图7b (中): 草地面积对径流的边际效应",
       x = "草地占比",
       y = "SHAP 值 (对径流的贡献)")

# 6.3 耕地面积 vs 径流响应
p_crop <- sv_dependence(sv, v = "Cropland", alpha = 0.6, size = 1) +
  theme_minimal() +
  labs(title = "图7b (右): 耕地面积对径流的边际效应",
       x = "耕地占比",
       y = "SHAP 值 (对径流的贡献)")
# 展示图表
print(p_precip)
print(p_grass)
print(p_crop)

# ------------------------------------------------------------------
# 7. 绘制图7c: 单样本预测解释 (Force Plot)
#     展示预测值最高和最低的两个样本
# ------------------------------------------------------------------

# 获取 SHAP 值的详细数据
shap_values <- sv$shap_values

# 找到径流最大值和最小值的索引
max_idx <- which.max(y)
min_idx <- which.min(y)

# 7.1 最大径流样本的解释 (正值)
p_force_max <- sv_force(sv, row_id = max_idx) +
  labs(title = paste0("图7c (上): 子流域 #", max_idx, " (高径流) 预测解释"))

# 7.2 最小径流样本的解释 (负值/低值)
p_force_min <- sv_force(sv, row_id = min_idx) +
  labs(title = paste0("图7c (下): 子流域 #", min_idx, " (低径流) 预测解释"))

print(p_force_max)
print(p_force_min)

#8 保存图片
ggsave("force_plot_max.png", p_force_max, width = 8, height = 6, dpi = 300)
