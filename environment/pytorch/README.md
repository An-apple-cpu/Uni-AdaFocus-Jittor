# PyTorch 独立环境方案（尚未在 AutoDL 验证）

官方 TSM/Jester README 基线：Python 3.9、PyTorch 1.12.1、torchvision 0.13.1。不能据此认定该旧组合适用于拟租 RTX 4090。**候选而非已验证配置**：Python 3.10、PyTorch 2.1.0、torchvision 0.16.0、cu121；来源：[PyTorch 历史版本安装页](https://pytorch.org/get-started/previous-versions/)。正式选择须结合实例驱动、镜像及源码兼容性实测，不自动覆盖基础镜像或驱动。

在完成 `check_server.sh` 和用户确认后，另建独立环境（示例使用 conda；未安装时先由用户选择环境管理方式）：

```bash
conda create -n unia-pt python=3.10
conda activate unia-pt
# 仅在用户确认上述候选和驱动兼容后执行：
python -m pip install torch==2.1.0 torchvision==0.16.0 --index-url https://download.pytorch.org/whl/cu121
python environment/pytorch/smoke_test.py
```

项目额外依赖如 tensorboardX、Pillow、NumPy 的版本待源码兼容检查后单独固定；本示例不宣称可直接运行官方模型。记录安装命令、`pip freeze`、`torch.__version__`、`torch.version.cuda` 和 smoke test 原始输出。
