# iPhone XR Ramdisk Boot

[中文](#中文) | [English](#english)

## 中文

脚本还不算完善，欢迎提交 PR 补充 payload 或适配更多设备。如果这个项目对你有帮助，欢迎点个 Star。

在 iPhone XR 上启动自定义 ramdisk，并通过 usbmux / SSH 进入 shell。

利用基础来自 [prdgmshift/usbliter8](https://github.com/prdgmshift/usbliter8)。`tools/usbliter8ctl` 用于从 pwned DFU 启动 `payload/iBSS.raw`，随后 `exploit.sh` 通过 `irecovery` 发送固件、DeviceTree、ramdisk、trustcache 和 kernelcache。

![SSH ramdisk shell](assets/ssh-ramdisk.png)

### 支持目标

- 设备：iPhone XR
- Board：`n841ap`
- 启动流程：pwned DFU -> iBSS -> Recovery -> ramdisk boot -> SSH

### 硬件要求

- PR2350-A 开发板
- iPhone XR
- USB 连接线
- macOS 或 Linux 主机

运行脚本前，先用 PR2350-A 配合 usbliter8 让设备进入 pwned DFU。

### 软件依赖

- `python3`
- Python 包：`pyusb`
- `irecovery`
- `iproxy`
- `idevice_id`
- `sshpass`
- `ssh`

macOS + Homebrew 可参考：

```bash
brew install libirecovery libimobiledevice usbmuxd sshpass
python3 -m pip install pyusb
```

如果系统不允许全局安装 Python 包，可以使用虚拟环境：

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install pyusb
```

### 文件结构

```text
exploit.sh                 主启动脚本
ssh_connect.sh             SSH 重连脚本
tools/usbliter8ctl         基于 usbliter8 USB 流程的本地 helper
payload/iBSS.raw           从 pwned DFU 加载的 raw iBSS
payload/*.img4             Firmware、DeviceTree、ramdisk、trustcache、kernelcache
assets/ssh-ramdisk.png     SSH 成功连接截图
```

### 使用方法

1. 安装依赖。

2. 连接 PR2350-A 开发板和 iPhone XR。

3. 使用 PR2350-A / usbliter8 流程让 iPhone XR 进入 pwned DFU。

4. 在项目目录运行：

```bash
chmod +x exploit.sh ssh_connect.sh tools/usbliter8ctl
./exploit.sh
```

脚本流程：

- 创建 `logs/`
- 检查必需 payload 文件
- 启动 `payload/iBSS.raw`
- 等待设备进入 Recovery
- 发送 firmware 镜像
- 发送 DeviceTree、ramdisk、trustcache、kernelcache
- 设置 boot-args
- 执行 `bootx`
- 启动本地 `iproxy 2222 22`
- 尝试以 `root` 登录 ramdisk SSH

默认 SSH 密码：

```text
alpine
```

启动后重连 SSH：

```bash
./ssh_connect.sh
```

手动连接：

```bash
iproxy 2222 22
ssh root@localhost -p 2222
```

### 环境变量覆盖

工具不在默认 PATH 时，可以用环境变量指定：

```bash
IRECOVERY=/path/to/irecovery \
PYTHON=/path/to/python3 \
USBLITER8CTL=tools/usbliter8ctl \
IPROXY=/path/to/iproxy \
SSHPASS=/path/to/sshpass \
./exploit.sh
```

### 常见问题

`usbliter8ctl` 提示设备不是 pwned 状态：重新执行 PR2350-A pwned DFU。

等待 Recovery 超时：重新插拔 USB，再执行 pwned DFU。

SSH 无法连接：等待几秒后运行：

```bash
./ssh_connect.sh
```

本地 `2222` 端口被占用：

```bash
pkill -f 'iproxy .*2222.*22'
```

### 致谢

本项目基于 [prdgmshift/usbliter8](https://github.com/prdgmshift/usbliter8)。

感谢 usbliter8 作者公开 A12/A13 SecureROM exploit 研究。

### 免责声明

本仓库仅用于安全研究、设备恢复研究，以及你拥有或已获得授权的设备。请在遵守当地法律法规的前提下使用。

## English

This script is still rough. PRs for more payloads or device support are welcome. If this project helps you, a Star would be appreciated.

Boot a custom ramdisk on iPhone XR and open a shell through usbmux / SSH.

This project is based on [prdgmshift/usbliter8](https://github.com/prdgmshift/usbliter8). `tools/usbliter8ctl` boots `payload/iBSS.raw` from pwned DFU, then `exploit.sh` sends the firmware, DeviceTree, ramdisk, trustcache, and kernelcache through `irecovery`.

### Target

- Device: iPhone XR
- Board: `n841ap`
- Boot flow: pwned DFU -> iBSS -> Recovery -> ramdisk boot -> SSH

### Hardware

- PR2350-A development board
- iPhone XR
- USB cables
- macOS or Linux host

Before running the script, use PR2350-A with the usbliter8 flow to put the device into pwned DFU.

### Requirements

- `python3`
- Python package: `pyusb`
- `irecovery`
- `iproxy`
- `idevice_id`
- `sshpass`
- `ssh`

macOS + Homebrew:

```bash
brew install libirecovery libimobiledevice usbmuxd sshpass
python3 -m pip install pyusb
```

If global Python package installation is blocked, use a virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install pyusb
```

### Files

```text
exploit.sh                 Main boot script
ssh_connect.sh             SSH reconnect script
tools/usbliter8ctl         Local helper based on the usbliter8 USB flow
payload/iBSS.raw           Raw iBSS loaded from pwned DFU
payload/*.img4             Firmware, DeviceTree, ramdisk, trustcache, kernelcache
assets/ssh-ramdisk.png     SSH success screenshot
```

### Usage

1. Install the requirements.

2. Connect the PR2350-A board and iPhone XR.

3. Use the PR2350-A / usbliter8 flow to enter pwned DFU.

4. Run from the project directory:

```bash
chmod +x exploit.sh ssh_connect.sh tools/usbliter8ctl
./exploit.sh
```

The script will:

- create `logs/`
- check required payload files
- boot `payload/iBSS.raw`
- wait for Recovery
- send firmware images
- send DeviceTree, ramdisk, trustcache, and kernelcache
- set boot-args
- run `bootx`
- start local `iproxy 2222 22`
- try to SSH into the ramdisk as `root`

Default SSH password:

```text
alpine
```

Reconnect after boot:

```bash
./ssh_connect.sh
```

Manual connection:

```bash
iproxy 2222 22
ssh root@localhost -p 2222
```

### Environment Overrides

If a tool is not in your PATH:

```bash
IRECOVERY=/path/to/irecovery \
PYTHON=/path/to/python3 \
USBLITER8CTL=tools/usbliter8ctl \
IPROXY=/path/to/iproxy \
SSHPASS=/path/to/sshpass \
./exploit.sh
```

### Troubleshooting

`usbliter8ctl` says the device is not pwned: repeat the PR2350-A pwned DFU step.

Recovery timeout: reconnect USB and run the pwned DFU step again.

SSH does not connect: wait a few seconds, then run:

```bash
./ssh_connect.sh
```

Local port `2222` is already in use:

```bash
pkill -f 'iproxy .*2222.*22'
```

### Credits

Based on [prdgmshift/usbliter8](https://github.com/prdgmshift/usbliter8).

Thanks to the usbliter8 author for publishing the A12/A13 SecureROM exploit research.

### Disclaimer

This repository is for security research, device recovery research, and devices you own or have permission to test. Use it responsibly and follow local laws.
