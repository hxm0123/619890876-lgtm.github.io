# 流域径流变化驱动因子分析 – SWAT + XGBoost + SHAP

[![R](https://img.shields.io/badge/R-%3E%3D4.0-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

本仓库提供了 **Ding et al. (2025)** 发表于 *Water Resources Research* 论文的完整 R 语言实现：

> 丁冰冰，余新晓，贾国栋. (2025). 基于水文模型与机器学习方法的流域径流变化控制因子研究. *Water Resources Research*, 61, e2024WR039734.  
> https://doi.org/10.1029/2024WR039734

我们将物理机制水文模型（SWAT）与 **XGBoost** 和 **随机森林** 机器学习方法相结合，使用 **SHAP** 进行模型可解释性分析，并定量区分气候变化与土地利用变化对径流变化的相对贡献。

代码内置了 **符合论文非线性关系和阈值效应的模拟数据集**，无需任何外部数据文件即可直接运行，完整复现论文核心分析流程。

---

## ✨ 主要功能

- ✅ 两种机器学习模型：XGBoost 与随机森林（基于 SWAT 模拟数据训练）
- ✅ 综合评估指标：R²、NSE、KGE、PBIAS
- ✅ SHAP 分析：特征重要性排序、依赖图、交互效应图（对应论文图 9–12）
- ✅ Pettitt 突变点检验 + 情景模拟归因（论文公式 9–11）
- ✅ **完全可复现** – 内置符合物理规律的数据生成器

---

## 📦 安装与使用

克隆仓库并在 R 环境中运行主脚本，所需 R 包会自动安装。

```bash
git clone https://github.com/yourusername/watershed-streamflow-ml.git
cd watershed-streamflow-ml
🚀 运行结果
执行脚本后将依次完成：

生成模拟数据：5 个子流域（ESBU），1985–2020 年，共 180 条样本

数据划分：每个子流域 70% 训练，30% 验证

训练 XGBoost 与随机森林模型

模型性能比较（R²、NSE、KGE、PBIAS）

SHAP 分析 – 自动生成图 9–12

Pettitt 突变检验 – 检测突变年份（1998）

情景模拟（L1C1, L2C2, L2C1, L1C2），量化气候与土地利用变化的贡献
SHAP 分析结果符合论文发现：

子流域面积 是最重要因子

降水 > 550 mm 对径流产生正贡献

森林 表现出抛物线效应（占比 30%–50% 时正贡献）

草地 占比超过 50% 时减少径流

土地利用变化在交互效应中占主导地位