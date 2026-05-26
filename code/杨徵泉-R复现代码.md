# 滦河流域径流变化主控因子模型复现 

## 1. 复现环境（一键重建）

本项目使用 **renv** 进行环境管理，可在任意电脑上复现完全一致的运行环境。

### 复现步骤

1.  下载 / 克隆本项目到本地
2.  打开 R/RStudio，设置工作目录：
r
运行
```
setwd("D:/Desktop/reproducible-project")  # 请改为你本地的项目路径
```
3.  安装并加载 renv（若未安装）：
r
运行
```
install.packages("renv")
library(renv)
```
4.  一键恢复项目环境：
r
运行
```
renv::restore()
```
5.  出现提示时输入 `y` 确认，等待环境安装完成
----------
## 2. 完整代码复现步骤

环境恢复完成后，直接运行以下代码即可复现全部结果：
r
运行
```

# 加载依赖包
library(xgboost)
library(randomForest)
library(dplyr)
library(ggplot2)

# 固定随机种子（保证结果100%可重复）
set.seed(42)

# 1. 生成模拟数据（贴合论文变量与研究区特征）
n <- 200
data <- data.frame(
  Precipitation = runif(n, 400, 800),
  Temperature = runif(n, 1, 11),
  Cropland = runif(n, 0.1, 0.4),
  Forest = runif(n, 0.3, 0.6),
  Grassland = runif(n, 0.2, 0.5),
  Area = runif(n, 0.05, 1),
  Barren = runif(n, 0, 0.02)
)
data$Streamflow <- 0.8*data$Area + 0.5*data$Precipitation/100 - 0.3*data$Temperature + 
  ifelse(data$Forest>0.3 & data$Forest<0.5, 0.4, -0.2) + rnorm(n, 0, 0.1)

# 2. 构建模型并评估
train_idx <- sample(1:n, 0.7*n)
train_data <- data[train_idx, ]
test_data <- data[-train_idx, ]
xgb_model <- xgboost(data = as.matrix(train_data[,-8]), label = train_data$Streamflow, nrounds = 50, verbose = 0)
rf_model <- randomForest(Streamflow ~ ., data = train_data, ntree = 100)

# 3. 预测与评估
xgb_pred <- predict(xgb_model, as.matrix(test_data[,-8]))
rf_pred <- predict(rf_model, test_data)
xgb_r2 <- cor(xgb_pred, test_data$Streamflow)^2
rf_r2 <- cor(rf_pred, test_data$Streamflow)^2

# 4. 气候与土地利用贡献量化
climate_effect <- 0.5*test_data$Precipitation/100 - 0.3*test_data$Temperature
lu_effect <- ifelse(test_data$Forest>0.3&test_data$Forest<0.5, 0.4, -0.2)
climate_contrib <- sum(abs(climate_effect)) / (sum(abs(climate_effect)) + sum(abs(lu_effect)))
lu_contrib <- sum(abs(lu_effect)) / (sum(abs(climate_effect)) + sum(abs(lu_effect)))

# 5. 输出核心结果
cat("XGBoost R2 =", round(xgb_r2, 3), "\n")
cat("气候变化贡献占比：", round(climate_contrib*100, 2), "%\n")
cat("土地利用贡献占比：", round(lu_contrib*100, 2), "%\n")

# 6. 保存结果
write.csv(data, "滦河流域模拟数据.csv", row.names = FALSE)
write.csv(data.frame(XGBoost_pred = xgb_pred, RF_pred = rf_pred, Observed = test_data$Streamflow), "模型预测结果.csv", row.names = FALSE)

# 7. 设置工作目录
setwd("D:/Desktop/reproducible-project")

# 8. 加载包
library(xgboost)
library(dplyr)
library(ggplot2)

# 9. 读取 CSV 文件
data <- read.csv("滦河流域模拟数据.csv")
pred <- read.csv("模型预测结果.csv")

# 10. 训练模型
set.seed(42)
x <- as.matrix(data %>% select(-Streamflow))
y <- data$Streamflow
model <- xgboost(data = x, label = y, nrounds = 50, verbose = 0)

# 11. 变量重要性
imp <- xgb.importance(model = model)

# 12. 保存路径（保存到桌面）
path <- "~/Desktop/"

# 图1：变量重要性柱状图
p1 <- ggplot(imp, aes(x=reorder(Feature, Gain), y=Gain)) +
  geom_col(fill="steelblue") +
  coord_flip() +
  labs(title="径流主控因子重要性", x="因子", y="重要性") +
  theme_bw()
ggsave(paste0(path,"图1_变量重要性.png"), p1, width=8, height=5, dpi=300)

# 图2：预测值 vs 观测值
p2 <- ggplot(pred, aes(x=obs, y=pred)) +
  geom_point(color="darkred", alpha=0.6) +
  geom_abline(slope=1, intercept=0, linetype="dashed") +
  labs(title="模型预测效果", x="观测径流", y="预测径流") +
  theme_bw()
ggsave(paste0(path,"图2_预测vs观测.png"), p2, width=8, height=5, dpi=300)

# 图3：降水对径流的影响
p3 <- ggplot(data, aes(x=Precipitation, y=Streamflow)) +
  geom_point(alpha=0.5) +
  geom_smooth(method="lm", color="red") +
  labs(title="降水与径流关系", x="降水量", y="径流量") +
  theme_bw()
ggsave(paste0(path,"图3_降水影响.png"), p3, width=8, height=5, dpi=300)

# 图4：林地对径流的影响
p4 <- ggplot(data, aes(x=Forest, y=Streamflow)) +
  geom_point(alpha=0.5) +
  geom_smooth(method="loess", color="blue") +
  labs(title="林地占比与径流关系", x="林地占比", y="径流量") +
  theme_bw()
ggsave(paste0(path,"图4_林地影响.png"), p4, width=8, height=5, dpi=300)

cat("✅ 4 张图片已成功保存到桌面！")
```
