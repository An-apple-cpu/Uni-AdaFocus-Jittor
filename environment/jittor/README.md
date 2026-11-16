# Jittor 独立环境方案（尚未在 AutoDL 验证）

[Jittor 官方安装页](https://cg.cs.tsinghua.edu.cn/jittor/download/)列出 Linux Python、g++、可选 nvcc 与 cuDNN 开发库要求。GPU 安装必须在实例上核对 GPU 架构、驱动、CUDA Toolkit（`nvcc`）、编译器、Python、cuDNN 和 Jittor 版本；`nvidia-smi` 的 CUDA 数字仅代表驱动报告能力。**没有锁定或验证 RTX 4090 的 Jittor 版本组合**。

推荐顺序：运行只读检测；核对[官方安装说明](https://cg.cs.tsinghua.edu.cn/jittor/download/)及实例环境；用户确认版本/安装方式和可用空间；再创建与 PyTorch 分离的环境、执行安装、运行 smoke test。下面是**人工选择步骤，不是自动安装脚本**：

```bash
conda create -n unia-jt python=<confirmed-python-version>
conda activate unia-jt
# 确认 Jittor 版本、编译器和 CUDA 方案后，按官方文档人工执行安装命令。
python environment/jittor/smoke_test.py
```

不要默认升级驱动、覆盖 AutoDL 镜像或执行自动 CUDA 安装。保存实际 `python -m pip freeze`、`nvcc --version`、编译日志与 smoke test 输出。Jittor 的 GPU 首次编译可能使用额外缓存空间；容量待实例检测。
