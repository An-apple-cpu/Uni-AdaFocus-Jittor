# Jester 数据与权重可用性（S0.4）

核验日期：2026-11-16。目标为 TwentyBN/Qualcomm **Jester v1（20bn-jester-v1）**，不是其他同名数据集；官方源码固定于 `8846488310fdd4a18412608006030643e794c36e`。本轮仅查看公开页面、源码和少量 HEAD 响应；**没有下载数据或权重，也没有验证任何大文件下载成功**。

状态词：**已实际验证可获取**＝文件内容成功取得并核对；**页面可访问但未验证文件下载**＝仅发布页可读；**需要用户授权**＝许可接受/账号步骤应由用户完成；**链接失效**＝有明确失效证据；**尚未确认**＝当前证据无法判定。此次没有资源达到“已实际验证可获取”，也没有足够证据把链接判为“失效”。

## 资源表

| 资源、用途 | 原始来源与下载方式 | 格式与容量 | 许可、可访问情况 | 风险与下一步 |
|---|---|---|---|---|
| Jester v1 图像数据；训练/验证 | [Qualcomm Jester 页面](https://www.qualcomm.com/developer/software/jester-dataset)、[下载页](https://www.qualcomm.com/developer/software/jester-dataset/downloads)列出 [00](https://apigwx-aws.qualcomm.com/qsc/public/v1/api/download/software/dataset/AIDataset/Jester/20bnjester-v1-00)、[01](https://apigwx-aws.qualcomm.com/qsc/public/v1/api/download/software/dataset/AIDataset/Jester/20bnjester-v1-01)、[02](https://apigwx-aws.qualcomm.com/qsc/public/v1/api/download/software/dataset/AIDataset/Jester/20bnjester-v1-02) 三段；按[官方提取说明](https://www.qualcomm.com/content/dam/qcomm-martech/dm-assets/documents/qualcomm-ai-research-jester-download-instructions-v2.pdf)拼接/解包 | 分段 TGZ，内部是编号目录和 `00001.jpg` 起的 JPG 帧；**下载总量 22.8 GB**（发布方）；解压容量待确认 | **页面可访问但未验证文件下载；需要用户接受研究许可**。本环境对 00 段 HEAD 得 403；不能据此判定永久失效 | 用户按 Qualcomm 条款取得资源并验证所有分段、哈希/大小及解包空间；不从非授权镜像转存 |
| Jester v1 标签/划分元数据；生成三份列表 | 同一[下载页](https://www.qualcomm.com/developer/software/jester-dataset/downloads)列出[标签包](https://apigwx-aws.qualcomm.com/qsc/public/v1/api/download/software/dataset/AIDataset/Jester/jester-labels) | 标签包内部文件名、格式、容量和哈希**待确认** | **页面可访问但未验证文件下载；需要用户接受研究许可**。本环境标签端点 HEAD 得 403 | 用户取得后核对 train/validation 与类别映射，再按固定划分生成列表；不得随机重划 |
| Uni-AdaFocus Jester checkpoint；E01 基准 | [官方 TSM/Jester README](https://github.com/LeapLabTHU/Uni-AdaFocus/tree/main/Uni-AdaFocus-TSM%20with%20Experiments%20on%20Sth-Sth%20V1%26V2%20and%20Jester)给出 [Google Drive 文件夹](https://drive.google.com/drive/folders/1tFbZd2ZYt55_QYxZDHvAwT4nNaKTHCbB?usp=drive_link)与 `jester_p128_8and12.pth.tar` | PyTorch checkpoint；文件大小、哈希**未提供/未核实** | **尚未确认**：本环境访问文件夹超时，未看到文件列表或直链 | 用户在可访问环境核对目标文件名、大小、下载权限/配额，下载后算哈希；页面地址不等于文件可下载 |
| MobileNetV2 ImageNet 初始权重；从头训练所需 | 源码 `archs/mobilenet_v2.py:132-138` 期望 `../ckpt/mobilenetv2_1.0-f2a8633.pth.tar`；上游实现 [tonylins MobileNetV2.py](https://github.com/tonylins/pytorch-mobilenet-v2/blob/master/MobileNetV2.py) 给出 [Dropbox 链接](https://www.dropbox.com/s/47tyzpofuuyyv1b/mobilenetv2_1.0-f2a8633.pth.tar?dl=1) | `torch.load` 的 state_dict；准确大小、哈希待核实 | **尚未确认**：原始代码页面可读，Dropbox HEAD 在本环境超时 | 核对原文件与本地模型结构匹配；不得用 torchvision MobileNetV2 权重无证替代 |
| ResNet50 ImageNet 初始权重；从头训练所需 | `ops/models.py:106-114` 调 `torchvision.models.resnet50(True)`；[torchvision 0.13 文档](https://docs.pytorch.org/vision/0.13/models/generated/torchvision.models.resnet50.html)列出权重 API；[PyTorch 源码](https://github.com/pytorch/vision/blob/main/torchvision/models/resnet.py)给出 V1 的 [权重地址](https://download.pytorch.org/models/resnet50-0676ba61.pth) | PyTorch state_dict；当前源码元数据约 97.8 MB，实际文件大小/哈希未核实 | **页面可访问但未验证文件下载**；本轮未请求完整文件 | 在指定 torchvision 版本确认 `True` 对应权重枚举；新旧接口差异不得静默改变初始化 |

Qualcomm 的[研究许可](https://www.qualcomm.com/content/dam/qcomm-martech/dm-assets/documents/jester_something_something_exercise_research_license_final_qti_28jul2022.pdf)限制内部非营利研究使用，禁止向第三方发布、转移或披露许可数据。因此不能假定可公开分享原始帧或包含其内容的处理后数据；拟公开任何派生数据前须由用户核对许可。账号/注册是否是当前下载流程的硬性要求尚未核实；许可接受应由用户本人或有权代表机构的人完成。

## 标签、划分与样本数

[Qualcomm 数据页](https://www.qualcomm.com/developer/software/jester-dataset)给出总 148,092、训练 118,562、验证 14,787、无标签测试 14,743、27 类。发布方提供的是已从原视频按 12 FPS 提取的 100px 高 JPG 帧，不需要据此重新下载原视频；每个视频为一个编号目录。发布页称分段每片最多 1 GB，而[提取 PDF](https://www.qualcomm.com/content/dam/qcomm-martech/dm-assets/documents/qualcomm-ai-research-jester-download-instructions-v2.pdf)称最多 10 GB，两处不一致；以实际分段文件为准，不据此估算每片大小。

锁定源码 `ops/dataset_config.py:75-85,99-114` 要求 `jester/category.txt`（相对于启动工作目录）、`ROOT_DATASET/jester/train_videofolder.txt`、`val_videofolder.txt` 和 `ROOT_DATASET/jester/20bn-jester-v1/`；`ROOT_DATASET` 当前写死为 `/home/data`。`ops/dataset.py:15-28,63-69,97-105` 要求列表每行 `视频目录 帧数 整数类别 ID`，图片名 `{:05d}.jpg`，不足 3 帧的记录被过滤。`category.txt` 每行一个类名，行序须与整数 ID 完全一致；官方代码按列表中的整数直接训练，不会自动校正映射。

[TSM 数据准备说明](https://github.com/mit-han-lab/temporal-shift-module#data-preparation)说明抽帧、生成列表、配置路径；其 [`gen_label_sthv2.py`](https://github.com/mit-han-lab/temporal-shift-module/blob/master/tools/gen_label_sthv2.py) 注释提及 `jester-v1`，但实际默认读取 Something-Something V2 的 JSON 和帧目录，**不能原样用于当前 Jester 标签包**。目标 Uni-AdaFocus 目录未找到 Jester 专用生成器或现成列表。需要从 Qualcomm 原始标签包确认类名顺序、视频 ID、train/validation 成员，再按帧目录统计帧数生成；包内容尚未取得，因此映射和是否可可靠生成仍**待确认**。

## 存储判断与获取顺序

已核实的下载体积只有数据包总量 **22.8 GB**。解压后 JPG 总量、标签包、Jester checkpoint、MobileNet 权重、训练 checkpoint/日志和临时处理空间均无可靠实测容量；不能给出精确总需求。若 50 GB 数据盘同时放完整下载包与解压帧，下载包已占约 22.8 GB，剩余约 27.2 GB，**明显存在空间不足风险，是否必然不足待解压体积验证**。30 GB 系统盘还需容纳环境、缓存和可能的权重，余量未测。先确认许可/下载通道和实际分段大小，再在服务器分配空间前确认解压后与临时峰值；不在 50 GB 上盲目开始全量下载。

获取优先级：①用户确认 Qualcomm 许可及官方数据/标签通道；②核对标签包和固定划分；③核对 Jester checkpoint 文件与哈希，供官方基准；④若要从头训练，再核对 MobileNetV2 和 torchvision ResNet50 初始权重。完整 Jester checkpoint 的评估与随机初始化后训练是不同流程，不能把前者可用当作后者初始权重已备齐。

若官方通道不可用，先联系[Qualcomm 页面所列支持渠道](https://www.qualcomm.com/developer/software/jester-dataset)或调查其合法授权渠道；本轮未找到可确认许可相同、划分相同的可信镜像。官方代码另支持 Something-Something V1/V2、UCF101、HMDB51、Kinetics（`ops/dataset_config.py:99-102`），但改数据集会改变类别、划分与指标可比性，**不得自行切换主路线**。
