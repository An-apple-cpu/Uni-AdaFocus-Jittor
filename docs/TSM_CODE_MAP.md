# TSM/Jester 源码索引

基线：官方仓库 `8846488310fdd4a18412608006030643e794c36e`。下表路径均相对于 `references/Uni-AdaFocus-official/Uni-AdaFocus-TSM with Experiments on Sth-Sth V1&V2 and Jester/`；行号为此 SHA 的源码行号。仅作静态审查。

## 结构与入口

`README.md` 为运行说明；`main.py` 为训练/常规评估；`test_early_exit_uni_adafocus_tsm.py` 为提前退出评估；`opts.py` 为参数；`archs/` 含 AdaFocus 和 MobileNetV2；`ops/` 含 TSN、TSM、数据集、变换、提前退出计算与工具；`tools/` 含数据预处理及标签工具（列出的标签生成脚本针对 Sth-Sth/Kinetics，并非 Jester）。

| 机制/用途 | 文件与位置 | 主要调用链及 PyTorch 算子 | 训练参数？ | 用户迁移核心？ | Jester 路径？ |
|---|---|---|---|---|---|
| A. TSM、ResNet 主干 | `archs/uni_adafocus_tsm.py:201`；`ops/models.py:106,110,113`；`ops/temporal_shift.py:11,27,97` | `main.main_worker`→`AdaFocus`→local `TSN`→torchvision ResNet50 + `TemporalShift`；张量切片/赋值、Conv2d | 是 | 是 | 训练/常规评估（README 指定 `--shift`） |
| B. Glance 全局特征 | `archs/uni_adafocus_tsm.py:190,225-226`；`ops/models.py:269,313`；`archs/mobilenet_v2.py:69,110` | global `TSN`/MobileNetV2→特征图、逐帧 logit；Conv2d/BN/池化/平均共识 | 是 | 是 | 训练/常规评估 |
| C. 空间策略 | `archs/uni_adafocus_tsm.py:138-175,213-217,238,258,294` | Glance 特征图 `detach`→`SpatialPolicy`；Conv3d/BN/Sigmoid | 是 | 是 | 训练/常规评估 |
| D. 动态裁剪 | `archs/uni_adafocus_tsm.py:15-30,239-249,262-275,295-301` | 策略动作→`get_patch_grid_scalexy`；`affine_grid`、`grid_sample`；训练时局部图像裁剪使用 `action_2.detach()`，另有随机裁剪分支；辅助特征图裁剪保留策略梯度 | 裁剪算子无；策略有 | 是 | 训练/常规评估 |
| E. 时间策略与采样 | `archs/uni_adafocus_tsm.py:38-67,70-88,91-135,218-235,253-257,287-292` | Glance 特征 `detach`→`TemporalPolicy`→`policy_sample_indices`→focus 帧；Conv2d/Softmax/cumsum/gather/floor/索引，`MCSampleFeature` 用 multinomial/scatter 建辅助 logit | 策略有；采样无 | 是 | 训练/常规评估；训练随机、评估确定性采样 |
| F. 融合与分类 | `archs/uni_adafocus_tsm.py:212,249,278-285,302-303`；`ops/models.py:83-104,269-316` | global/local TSN 分类，logit 相加；Linear、平均共识、张量加法 | 是 | 是 | 训练/常规评估 |
| G. 样本级提前退出 | `test_early_exit_uni_adafocus_tsm.py:297-310,333-354`；`archs/uni_adafocus_tsm_exit.py:303-305`；`ops/early_exit_uni_adafocus_tsm.py:8,56,136-186` | 独立脚本生成全局/融合两阶段 logit；由训练集 logit 定阈值，在验证集按 confidence/entropy 计算退出与 FLOPs；stack/softmax/sort/阈值比较 | 无新增参数；依赖已训练模型 | 是（若复现动态退出） | 仅独立评估脚本；常规 `main.py` 不启用 |
| H. 损失与辅助训练 | `main.py:360-375,389-394`；`archs/uni_adafocus_tsm.py:230-249,251-285,305-311` | 双裁剪分支的 target/global/local/temporal/spatial 交叉熵，尺寸动作正则；`CrossEntropyLoss`、MCSampleFeature、AMP GradScaler | 是 | 是 | 训练；常规评估不算这些辅助损失 |

## 训练与推理调用链

- 训练：`main.py:22-86` 解析参数、确定数据集并建 `AdaFocus` → `main.py:236-281` 建 `TSNDataSet`/DataLoader → `main.py:291-323` 调学习率、训练、验证及 checkpoint → `main.py:350-394` 前向、五类交叉熵加正则、反传和 SGD。数据列表为 `ops/dataset.py:15-28,97-105` 的 `目录 帧数 标签`，采样/加载在 `ops/dataset.py:109-287`。
- 常规推理：`main.py:283-285,430-450` → `AdaFocus.forward` 的非训练分支 `archs/uni_adafocus_tsm.py:287-303`，确定性选帧、策略裁剪、global/local logit 相加。
- 动态退出推理：`test_early_exit_uni_adafocus_tsm.py:297-310,333-354` → `archs/uni_adafocus_tsm_exit.py:225-305` → `ops/early_exit_uni_adafocus_tsm.py:136-186`。这段代码先生成两阶段 logit 再做阈值评估；未定位到训练中逐样本提前停止或在线省算的实现。

建议迁移顺序：数据/变换与 TSN/TSM 主干 → Glance/Local 前向及融合 → 空间策略与可微裁剪 → 时间策略、采样与辅助损失 → 独立提前退出评估。核心算法迁移由用户实施。
