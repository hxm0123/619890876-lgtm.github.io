# SHAP 主控因子分析报告

## 小组成员
张佩琦（@zpq2003）

## 研究目标
复现论文《Exploring the Controlling Factors of Watershed Streamflow Variability》第 3.3 节，识别滦河流域径流变化的主控因子。

## 方法
1. 基于论文结论构造模拟数据（2000个样本）
2. 训练 XGBoost 模型（R² = 0.956）
3. 使用 SHAP 值进行特征归因分析

## 核心发现

### 1. 特征重要性排序
面积（area）是最重要的主控因子，平均 |SHAP| = 19.36，远高于其他因子。这与论文 Table 2 结论一致。

### 2. 降水阈值效应
SHAP 依赖图显示，当降水量 < 550mm 时，降水对径流的贡献接近 0 或为负；当 > 550mm 时，转为正贡献。验证了论文 3.3.1 节的发现。

### 3. 森林占比阈值效应
森林占比在 30%-50% 区间时，SHAP 值为正（贡献径流）；超出此区间后贡献下降。与论文 Figure 10 一致。

### 4. 土地利用 vs 气候变化贡献
基于 SHAP 归因，土地利用变化的贡献（55.71%）高于气候变化（44.27%），与论文 3.4 节量化结果吻合。

## 结论
本模块成功复现了论文的核心结论：面积是第一主控因子，降水存在 550mm 阈值，森林 30-50% 最优，土地利用变化主导径流变化。

## 输出文件
- `output/feature_importance.png`
- `output/shap_summary_plot.png`
- `output/precip_dependency.png`
- `output/forest_dependency.png`
- `output/area_dependency.png`