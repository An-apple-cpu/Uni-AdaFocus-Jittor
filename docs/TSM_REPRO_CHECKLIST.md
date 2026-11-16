# TSM/Jester 复现清单

基线 SHA：`8846488310fdd4a18412608006030643e794c36e`。路径均相对于官方 TSM/Jester 目录。状态为静态源码核验，未运行命令。

## 官方入口与命令

官方 `README.md:131-145` 的 Jester 训练命令（Linux shell，原样参数）：

```bash
CUDA_VISIBLE_DEVICES=0,1,2,3 python main.py jester RGB \
  --dist-url 'tcp://127.0.0.1:12345' --dist-backend 'nccl' --multiprocessing-distributed --world-size 1 --rank 0 \
  --root_log LOG_DIR --root_model LOG_DIR \
  --arch resnet50 --num_glance_segments 8 --num_input_focus_segments 36 --num_focus_segments 12 \
  --gd 20 -j 16 --lr_steps 0 0 --lr_type cos --epochs 50 \
  --batch-size 64 --lr 0.02 --wd 1e-3 --dropout 0.5 --consensus_type=avg --eval-freq=1 \
  --shift --shift_div=8 --shift_place=blockres --npb --print-freq=50 \
  --patch_size 128 --stn_hidden_dim 128 --temporal_hidden_dim 64 \
  --global_lr_ratio 0.5 --stn_lr_ratio 0.20 --temporal_lr_ratio 0.20 --temperature 1.0 --norm_ratio 0.25
```

常规评估：README `:148-150` 指示在训练命令后加 `--evaluate --resume PATH_TO_CKPT`；以 Jester 权重代入 `--resume ckpt/jester_p128_8and12.pth.tar` 是**依据 README 文件名推导的示例**，并非 README 单独给出的 Jester 完整评估命令。提前退出评估：README `:164-183` 指示使用 `test_early_exit_uni_adafocus_tsm.py`，但给出的完整示例是 **Something-Something V1**；把 Jester 训练参数移至该脚本并加 `--evaluate --resume ckpt/jester_p128_8and12.pth.tar` 也仅是代码/文档推导，尚待实测。

## 数据、权重、依赖

- `ops/dataset_config.py:8,75-85,99-114`：`ROOT_DATASET='/home/data'`；Jester 帧根目录为 `/home/data/jester/20bn-jester-v1`，训练/验证列表为 `/home/data/jester/{train,val}_videofolder.txt`，图片名 `00001.jpg` 格式；类别文件为相对当前工作目录的 `jester/category.txt`。`ops/dataset.py:15-28,63-69,97-105,222-285` 期望列表每行为 `视频子目录 帧数 整数标签`，过滤不足 3 帧的视频；图片按视频子目录加载。README `:10-12` 指向 TSM 数据准备说明，但本仓库未提供 Jester 数据及这些列表/类别文件。
- README `:148-161` 给出 Google Drive 文件夹 `https://drive.google.com/drive/folders/1tFbZd2ZYt55_QYxZDHvAwT4nNaKTHCbB?usp=drive_link`，Jester checkpoint 名 `jester_p128_8and12.pth.tar`；**未验证可下载性或内容**。`main.py:171-186` 评估用 `torch.load`/`state_dict`，恢复训练另加载 epoch、optimizer、scaler。默认 `--pretrain imagenet`（`opts.py:23`）：全局 MobileNetV2 从 `../ckpt/mobilenetv2_1.0-f2a8633.pth.tar` 加载（`archs/mobilenet_v2.py:132-138`），局部 ResNet50 通过 torchvision pretrained 接口（`ops/models.py:106-114`）；这两项权重获取/路径另需准备。
- README `:3-7` 明列 Python 3.9、PyTorch 1.12.1、torchvision 0.13.1。源码另导入 tensorboardX、Pillow、NumPy（`main.py:14`、`ops/dataset.py:9-12`）；未在目标 README 中找到这些包的精确版本。`tools/` 的视频工具另用 tqdm，非 Jester 主路径。

## AutoDL 待验证及单卡 24GB 风险

1. README 的 `CUDA_VISIBLE_DEVICES=0,1,2,3` 与 multiprocessing/NCCL 是四卡示例；`main.py:51-78,100-115` 按 GPU 数启动进程并按卡分 batch/workers。单卡 24GB 能否容纳 batch 64、双局部分支和 `MCSampleFeature(sample_times=128)` **未实测**，改 batch 可能影响学习率/指标。
2. `main.py:529-533` 的 `reduce_tensor` 无条件调用 `dist.all_reduce`，验证路径 `main.py:450-451` 使用它；单卡不初始化进程组的运行方式有静态可见风险。提前退出脚本 `:321-330` 也无条件用分布式 gather。
3. `ops/dataset_config.py:76` 的 `jester/category.txt` 依赖运行目录，`ROOT_DATASET` 硬编码 `/home/data`；`archs/mobilenet_v2.py:135-137` 的 `../ckpt/` 权重路径也依赖运行目录。需核对真实文件位置，不能仅凭链接假定资源可用。
4. `main.py:130-139,350-394` 使用 CUDA 专用 `.cuda()`、`torch.cuda.amp` 和 GradScaler；单卡/软件版本兼容性待 AutoDL 实测。源码使用旧 torchvision 预训练布尔接口，跨版本兼容性未验证。
5. `test_early_exit_uni_adafocus_tsm.py:297-310` 对训练集和验证集都生成 logit，可能增加时间/内存；其 Jester 运行命令、退出阈值/FLOPs 结果均未实测。

未确认：Jester 数据及权重的实际可用性、单卡 24GB 可行 batch、PyTorch 基准精度、提前退出脚本在 Jester 上的运行结果。未定位到目标分支独立的 Jester 标签生成脚本，也未定位到训练阶段的样本级提前退出。
