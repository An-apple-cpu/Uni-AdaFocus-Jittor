# AutoDL 首次部署顺序（本地准备，尚未远程验证）

## 租赁前由用户确认

确认 GPU 型号/显存（如计划的 RTX 4090 24GB）、vCPU、RAM、系统盘与数据盘实际容量、Ubuntu 镜像、驱动及其 CUDA 支持、是否有 Toolkit/编译器、计费方式与预算、持久化目录和关机后保留规则。此前考虑的 30GB 系统盘/50GB 数据盘**尚未确认够用**；Jester 官方下载包为 22.8GB，解压与临时峰值未知（见 `docs/DATA_AND_WEIGHTS.md`）。租赁/付费实例由用户操作和批准。

## 连接与权限核验

用户从 AutoDL 控制台取得真实 SSH 主机、端口和认证方式，勿写入仓库。Windows PowerShell 示例（占位符，未连接）：`ssh -p <port> <user>@<host>`；先核对服务器指纹。VS Code 安装 Remote SSH 扩展后，使用 **Remote-SSH: Connect to Host**，在远程窗口打开项目目录，检查左下角远程标记和终端 `hostname; pwd`。连接配置与密钥留在用户本机安全位置。

VS Code 远程终端可用不等于 Codex 自动有远程执行权。让 Codex 在其**实际工具终端**执行只读 `hostname; pwd; git rev-parse --show-toplevel`，对照 SSH 终端的主机和项目路径；若 Codex 仍显示 Windows 路径，就只让它准备本地文件，不要求它执行远程操作。

## 首次启动的只读检查

在远程项目根目录执行 `bash environment/check_server.sh`；确认真实持久化挂载后再执行 `bash environment/check_server.sh <persistent-data-dir>`。若已经估算下载包、解压帧、权重、checkpoint、日志及临时空间的**峰值字节数**，可传第二参数进行实际可用量比较：`bash environment/check_server.sh <persistent-data-dir> <required-free-bytes>`。脚本不内置任意阈值，也不会创建目录。结果应同时核对 `df -hT`、`nvidia-smi`、`nvcc --version`、`python3 --version`、`gcc --version`；驱动显示的 CUDA 版本不是 Toolkit 版本。缺失命令如实记录。

确认系统盘、数据盘和关机持久化规则后，才确定项目、Jester 帧、权重、环境缓存和实验输出的实际位置。不要假定 `/root/autodl-tmp` 或任一固定路径总是持久化；不要将数据与权重放在临时目录。项目源码可由用户选择私有 Git 检出或安全传输；上游独立克隆须保持固定 SHA `8846488310fdd4a18412608006030643e794c36e`，且不修改参考源码。未授权不创建远程仓库或推送。

## 环境与测试

先依据 `environment/pytorch/README.md` 选择并建立独立 PyTorch 环境，记录安装和运行 `python environment/pytorch/smoke_test.py` 的真实结果；再依据 `environment/jittor/README.md` 核对编译链和 CUDA 方案，建立独立 Jittor 环境并运行 `python environment/jittor/smoke_test.py`。两个 smoke test 必须真实完成 GPU 张量、前向、反向和参数更新；失败日志照实保留。官方 PyTorch 基线是 Python 3.9/torch 1.12.1/torchvision 0.13.1；2.1.0/Python 3.10/cu121 仅为待验证候选。Jittor 版本组合待实例实测，安装前由用户确认。

## 记录、备份与关机

每次检测建唯一运行 ID；由用户确认安全且持久的位置后保存文本，例如 `bash environment/check_server.sh <persistent-data-dir> > <persistent-log-dir>/<run-id>-server.txt 2>&1`。记录检测日期、OS/内核、CPU/RAM、挂载容量、GPU/显存/驱动、驱动 CUDA、Toolkit `nvcc`、Python/pip/conda、项目 Git SHA；安装后补记 PyTorch/Jittor 精确版本和 smoke test 原始日志。无提交时项目 SHA 记“无提交”，不编造值。日志目录需事先存在，本页命令仅供后续参考，**均未在 AutoDL 执行**。

关机前用户核对重要代码、配置、唯一实验日志、checkpoint、数据来源/哈希及备份位置，按 AutoDL 实际持久化规则复制到用户控制的可靠存储并验证备份可读。不得覆盖已有成果；传输数据需遵守 Jester 许可。首次安装、下载和收费 GPU 使用均需用户确认，且不得把 smoke test 当作 Uni-AdaFocus 训练通过。
