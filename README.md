# Mbenchmark
> Hell-Mode CPU Benchmark built with Flutter.

## 中文介绍
Mbenchmark 是一款基于 Flutter 开发的跨平台CPU跑分工具。
采用 Dart Isolate 多线程，同时执行四类计算任务：素数筛选、矩阵乘法、SHA256哈希、FFT快速傅里叶变换。

> ⚠️ 重要说明
> 本程序为**瞬时峰值跑分**，按下开始后立刻启动压力测试，采集设备当前实时算力。
> 设备静置冷却后测试，可以跑出最高峰值分数；
> 连续多次运行，芯片持续满载积热，系统触发温控降频，跑分分数会逐步下降，属于正常硬件现象，不是程序BUG。
> 支持4线程 / 8线程模式切换，内置中英文双语界面。

### 功能特性
- 4线程 / 8线程 多线程压力测试
- 混合计算负载：素数运算、矩阵、SHA256哈希、FFT傅里叶变换
- 实时进度显示，自动计算跑分得分
- 内置中文 / English 双语切换
- 轻量无广告

### 安装说明
前往 [Releases](https://github.com/你的仓库地址/releases) 下载签名版 APK，在安卓设备安装。
> 鸿蒙/华为设备安装时，系统会提示未知来源应用，临时授予权限即可完成安装。
> ⚠️ 测试时设备会明显发热，请勿长时间连续跑。

---

## English Introduction
Mbenchmark is a cross-platform CPU benchmark tool developed with Flutter.
It uses Dart Isolates for multi-threading, executing four types of computational workloads: prime number sieve, matrix multiplication, SHA256 hash, and FFT fast Fourier transform.

> ⚠️ Important Note
> This is an **instantaneous peak benchmark**. The stress test starts immediately once you click run, capturing the real-time computing performance of your device.
> Run the benchmark after the device has fully cooled to get peak scores.
> Repeated continuous runs will heat up the chip. Thermal throttling will reduce CPU frequency and scores gradually. This is normal hardware behavior, not a software bug.
> Supports 4-thread / 8-thread mode switching, with built-in Chinese & English UI.

### Features
- 4-thread / 8-thread multi-thread stress test
- Mixed workload: prime calculation, matrix multiplication, SHA256 hash, FFT
- Real-time progress indicator and automatic score calculation
- Built-in Chinese / English language switch
- Lightweight, no advertisements

### Installation
Download the signed APK from [Releases](https://github.com/your-repo-url/releases) and install it on your Android device.
> On HarmonyOS / Huawei devices, the system will warn about unknown-source applications. Grant temporary permission to install.
> ⚠️ The device will get hot during benchmarking. Avoid repeated long-time runs.

---

## License
MIT