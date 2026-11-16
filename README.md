# Uni-AdaFocus Jittor 复现

论文：[Uni-AdaFocus: Spatial-Temporal Dynamic Computation for Video Recognition](https://arxiv.org/abs/2412.11228)

官方仓库：https://github.com/LeapLabTHU/Uni-AdaFocus

项目目标：以 Uni-AdaFocus-TSM / Jester 为优先分支，复现论文方法，并在后续阶段完成 PyTorch 基准与 Jittor 实现的实验。

当前状态：Stage 0 工程准备（S0.1–S0.5 已建立本地骨架、官方源码索引、项目范围、资源核验与服务器部署方案；S0.6-A 提交前检查中）。尚未部署 AutoDL 环境，也未运行 PyTorch/Jittor 模型或训练。

官方源码保存在 `references/Uni-AdaFocus-official/`，作为独立克隆由本项目 Git 忽略；固定 Commit SHA 为 `8846488310fdd4a18412608006030643e794c36e`，详情见 `docs/UPSTREAM_SOURCE.md`。

结构概览：`references/` 保存上游参考；`docs/` 保存源码索引与实验协议；`environment/` 保存服务器检测及独立环境方案；`configs/`、`tests/`、`scripts/`、`experiments/` 分别预留配置、测试、工程脚本和实验记录；`jittor_impl/` 预留用户主导的核心实现。

后续阶段：在用户确认资源与实例后建立 PyTorch 基准，再完成 Jittor 推理、数值对齐、训练及跨框架实验分析。阶段门槛见 `docs/PROJECT_SCOPE.md`。
