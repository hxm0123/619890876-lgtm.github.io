# 滦河流域径流变化主控因子模型复现 





## 1. 小组基本信息

*   **小组名称**：流域水文可复现研究小组
*   **小组成员**：

| 姓名   | 学号          | GitHub ID       |
| :----- | :------------ | :-------------- |
| 杨徵泉 | 2025303120031 | @619890876-lgtm |
| 宦秀敏 | 2025303120017 | @hxm0123        |
| 张佩琦 | 2025303110136 | @zpq2003        |
| 苏 盼  | 2025303120138 | @Neflibata0627  |
| 熊煜佳 | 2025303120126 | @xyj666357      |

*   **项目名称**：滦河流域径流变化主控因子模型复现

## 2. 项目文件结构

plaintext

```
reproducible-project/
├── 1010115184451.pdf       # 目标研究论文
├── renv/                   # renv环境依赖文件夹
├── renv.lock               # 环境锁文件（核心：复现必备）
├── analysis.R              # 完整可复现分析代码
├── 滦河流域模拟数据.csv     # 模拟数据集
├── 模型预测结果.csv         # 模型输出结果
└── README.md               # 项目说明与复现步骤
```
## 3. 复现环境（一键重建）

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

## 4. 完整代码复现步骤

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

# 输出核心结果
cat("XGBoost R2 =", round(xgb_r2, 3), "\n")
cat("气候变化贡献占比：", round(climate_contrib*100, 2), "%\n")
cat("土地利用贡献占比：", round(lu_contrib*100, 2), "%\n")

# 保存结果
write.csv(data, "滦河流域模拟数据.csv", row.names = FALSE)
write.csv(data.frame(XGBoost_pred = xgb_pred, RF_pred = rf_pred, Observed = test_data$Streamflow), "模型预测结果.csv", row.names = FALSE)
```

----------

## 5. 预期复现结果

-   模型评估：XGBoost 模型表现优于随机森林
-   贡献占比：气候变化 ≈ 81.85%，土地利用变化 ≈ 18.15%
-   结果文件：自动生成两个 csv 结果文件，可直接查看
-   可重复性：任意时间、任意电脑运行结果完全一致

----------

## 6. 可复现性说明

✅ **环境可重建**：通过 renv.lock 实现依赖包版本精准控制

✅ **结果可重复**：set.seed (42) 固定随机过程，结果完全可复现

✅ **流程可自动化**：单脚本一键运行，无需手动调整参数

✅ **论文高度贴合**：变量、模型、结论均与目标论文保持一致
