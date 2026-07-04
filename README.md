# Argo-PRO

> 本包版本：LF-VERIFIED。所有脚本、配置和文档已统一为 Unix LF 换行。推送 GitHub 后，Raw 链接必须显示 `argox.sh` 约 5051 行、`CR=0`，否则不要执行一键部署。


Argo-PRO 是一个面向 Xray / Cloudflare Tunnel / Reality 的一键部署系统，已集成 VLESS 后量子加密、REALITY ML-DSA-65、TLS hybrid PQ curve、XHTTP、HTTPUpgrade 和模块化 Stage 1 自检工具。

生产安装入口仍然是 `argox.sh`；`argox-next.sh` 是模块化测试入口，用于部署前检测、协议构建验证和后续重构迁移。

---

## 1. 功能概览

已包含：

- Argo / Cloudflare Tunnel + VLESS + WS + PQC
- VLESS + Reality Vision + PQC
- VLESS + Reality gRPC + PQC
- VLESS + XHTTP CDN + PQC
- VLESS + XHTTP H3 Direct + TLS hybrid PQ curve
- VLESS + HTTPUpgrade CDN + PQC
- Hysteria2 + TLS hybrid PQ curve
- Trojan Direct + TLS hybrid PQ curve
- VLESS Encryption：`mlkem768x25519plus`
- REALITY ML-DSA-65：服务端 `mldsa65Seed`，客户端 `pqv=`
- TLS hybrid curve：`X25519MLKEM768,X25519`
- Reality 独立域名 / SNI，不再和普通 TLS 的 `TLS_SERVER` 混用
- 模块化协议 builder：`modules/`
- 自检入口：`argox-next.sh --doctor`
- 配置安全测试入口：`argox-next.sh --safe-apply-config`

---

## 2. 上传到 GitHub

### 2.1 解压最终包

```bash
unzip Argo-PRO-DEPLOYABLE.zip
cd Argo-PRO-DEPLOYABLE
```

### 2.2 本地基础检查

```bash
bash -n argox.sh
bash -n argox-next.sh
chmod +x argox.sh argox-next.sh scripts/*.sh tests/*.sh
./argox-next.sh --test-modules
./argox-next.sh --list-protocols
./argox-next.sh --build-sample > /tmp/argo-pro-sample.json
jq empty /tmp/argo-pro-sample.json
```

### 2.3 推送到你的仓库

目标仓库：

```text
https://github.com/hkzping999/Argo-PRO.git
```

首次推送或覆盖测试仓库：

```bash
git init
git config core.autocrlf false
git add --renormalize .
git commit -m "Deploy Argo-PRO final package"
git branch -M main
git remote add origin https://github.com/hkzping999/Argo-PRO.git
git push -u origin main --force-with-lease
```

如果提示 remote 已存在：

```bash
git remote set-url origin https://github.com/hkzping999/Argo-PRO.git
git push -u origin main --force-with-lease
```

### 2.4 推送后立刻检查 GitHub Raw 行数

这一步很重要，用来确认上传后没有丢失换行。

```bash
curl -fsSL https://raw.githubusercontent.com/hkzping999/Argo-PRO/main/argox.sh | wc -l
curl -fsSL https://raw.githubusercontent.com/hkzping999/Argo-PRO/main/argox-next.sh | wc -l
curl -fsSL https://raw.githubusercontent.com/hkzping999/Argo-PRO/main/config-pqc-strong.conf | wc -l
curl -fsSL https://raw.githubusercontent.com/hkzping999/Argo-PRO/main/SHA256SUMS.txt | wc -l
```

正常数量级应接近：

```text
5051
59
82
30+
```

如果只显示 1、2、几十行，说明文件换行仍然损坏，不能部署。


### 2.5 验证一键部署 Raw 链接

推送后建议运行：

```bash
./scripts/verify_raw_lf.sh https://raw.githubusercontent.com/hkzping999/Argo-PRO/main
```

`argox.sh` 应显示约 `LF=5051 CR=0`。只有这样，一键命令才适合使用：

```bash
bash <(wget -qO- https://raw.githubusercontent.com/hkzping999/Argo-PRO/main/argox.sh)
```

更稳的调试方式是先下载再语法检查：

```bash
wget -O /tmp/argox.sh https://raw.githubusercontent.com/hkzping999/Argo-PRO/main/argox.sh
bash -n /tmp/argox.sh
bash /tmp/argox.sh
```

---

## 3. 服务器部署测试

推荐系统：Debian 11/12、Ubuntu 20.04/22.04/24.04。

### 3.1 安装基础依赖

```bash
apt update
apt install -y git curl wget unzip jq openssl socat ca-certificates
```

### 3.2 拉取项目

```bash
git clone https://github.com/hkzping999/Argo-PRO.git
cd Argo-PRO
chmod +x argox.sh argox-next.sh scripts/*.sh tests/*.sh
```

### 3.3 部署前自检

```bash
./argox-next.sh --test-modules
./argox-next.sh --list-protocols
./argox-next.sh --doctor
```

说明：如果服务器还没安装 Xray，`--doctor` 里的 Xray / `vlessenc` / `mldsa65` 可能显示 warning，这是正常的；正式安装时 `argox.sh` 会处理下载与安装。

---

## 4. 生产安装方式

### 4.1 交互安装

```bash
bash argox.sh
```

第一次测试推荐使用交互安装。

### 4.2 配置文件安装

编辑：

```bash
nano config-pqc-strong.conf
```

执行：

```bash
bash argox.sh -f config-pqc-strong.conf
```

---

## 5. 推荐测试顺序

### 5.1 第一轮：只测 Argo + VLESS + WS + PQC

```bash
INSTALL_PROTOCOLS='e' bash argox.sh -f config-pqc-strong.conf
```

这是最稳的主线协议，先确认它可用。

### 5.2 第二轮：测试 Argo WS + Reality Vision

```bash
INSTALL_PROTOCOLS='eb' \
REALITY_TARGET='www.microsoft.com:443' \
REALITY_SERVER_NAMES='www.microsoft.com' \
bash argox.sh -f config-pqc-strong.conf
```

### 5.3 第三轮：测试 HTTPUpgrade CDN

```bash
INSTALL_PROTOCOLS='em' bash argox.sh -f config-pqc-strong.conf
```

### 5.4 第四轮：测试 XHTTP CDN

```bash
INSTALL_PROTOCOLS='ei' bash argox.sh -f config-pqc-strong.conf
```

### 5.5 第五轮：测试 XHTTP H3 Direct

```bash
INSTALL_PROTOCOLS='j' TLS_SERVER='addons.mozilla.org' bash argox.sh -f config-pqc-strong.conf
```

---

## 6. 协议选择说明

`INSTALL_PROTOCOLS` 使用字母选择协议。常用组合：

```bash
# VLESS + WS + Argo + PQC
INSTALL_PROTOCOLS='e'

# VLESS + Reality Vision + PQC
INSTALL_PROTOCOLS='b'

# Argo WS + Reality Vision
INSTALL_PROTOCOLS='eb'

# Argo WS + HTTPUpgrade CDN
INSTALL_PROTOCOLS='em'

# Argo WS + XHTTP CDN
INSTALL_PROTOCOLS='ei'

# XHTTP H3 Direct
INSTALL_PROTOCOLS='j'
```

---

## 7. Reality 配置

Reality 已独立于普通 TLS：

```bash
REALITY_TARGET='www.microsoft.com:443'
REALITY_SERVER_NAMES='www.microsoft.com'
```

含义：

- `REALITY_TARGET`：写入 Xray `realitySettings.dest`，格式为 `host:port`
- `REALITY_SERVER_NAMES`：写入 Xray `realitySettings.serverNames`，通常只填域名

如果留空，安装时会提示输入；非交互或直接回车时会从预设域名池自动选择。

Reality 域名检测：

```bash
REALITY_CHECK_ON_INSTALL='y'
REALITY_CHECK_TIMEOUT='4'
```

检测失败只警告，不强制中断。

---

## 8. VLESS 后量子加密

默认启用：

```bash
ENABLE_VLESS_PQC='y'
VLESS_PQC_STRICT='y'
VLESS_PQC_REQUIRE_PREFIX='mlkem768x25519plus'
VLESS_PQC_DISABLE_0RTT='y'
VLESS_PQC_RESUME='600s'
```

作用：

- 调用 `xray vlessenc`
- 服务端写入 VLESS `decryption`
- 客户端链接写入 `encryption=`
- 默认要求 `mlkem768x25519plus`

如果客户端或服务器 Xray 太旧，可以临时改成：

```bash
VLESS_PQC_STRICT='n'
```

或者关闭：

```bash
ENABLE_VLESS_PQC='n'
```

---

## 9. REALITY ML-DSA-65

默认配置：

```bash
ENABLE_REALITY_MLDSA65='y'
REALITY_MLDSA65_STRICT='n'
```

支持时会自动调用：

```bash
xray mldsa65
```

然后：

- 服务端写入 `mldsa65Seed`
- 客户端 Reality 链接追加 `pqv=`

如果当前 Xray 不支持，默认只警告并回退；要强制要求，可设：

```bash
REALITY_MLDSA65_STRICT='y'
```

---

## 10. TLS hybrid PQ curve

默认启用：

```bash
ENABLE_TLS_PQC_CURVE='y'
TLS_CURVE_PREFERENCES='X25519MLKEM768,X25519'
```

只用于 `security=tls` 的协议，例如：

- Hysteria2
- Trojan Direct
- XHTTP H3 Direct

不会写入 Reality。

---

## 11. 模块化工具

### 11.1 测试模块语法

```bash
./argox-next.sh --test-modules
```

### 11.2 查看协议注册表

```bash
./argox-next.sh --list-protocols
```

### 11.3 构建样例 inbound

```bash
./argox-next.sh --build-sample > inbound.sample.json
jq '.inbounds | length' inbound.sample.json
```

### 11.4 按 tag 构建 inbound

```bash
./argox-next.sh \
  --build-inbounds \
  --tags vless-ws,reality-vision,httpupgrade-cdn \
  --env ./config-pqc-strong.conf \
  --out ./inbound.next.json
```

### 11.5 安全应用配置

```bash
./argox-next.sh --safe-apply-config ./inbound.next.json
```

也可以指定目标文件：

```bash
./argox-next.sh --safe-apply-config ./inbound.next.json /etc/argox/inbound.json /etc/argox/outbound.json
```

它会执行：

1. JSON 校验；
2. `xray run -test`；
3. 备份旧配置；
4. 写入新配置。

---

## 12. 目录结构

```text
.
├── argox.sh                       # 生产安装入口
├── argox-next.sh                  # 模块化测试入口
├── config-pqc-strong.conf         # 非交互配置
├── modules/                       # 模块化内核
│   ├── core/
│   ├── pqc/
│   └── protocols/
├── scripts/                       # doctor / build / safe apply
├── tests/                         # 样例测试
├── docs/                          # 重构说明
├── .github/workflows/sanity.yml   # GitHub Actions 基础检查
├── .gitattributes                 # 固定 LF 换行，避免脚本上传损坏
├── SHA256SUMS.txt                 # 包内校验
└── README.md
```

---

## 13. 常见问题

### Q1：到底用哪个入口安装？

生产安装用：

```bash
bash argox.sh
```

`argox-next.sh` 只用于模块检测、构建样例和安全应用配置。

### Q2：GitHub 上传后脚本变成一两行怎么办？

本包已包含 `.gitattributes`，并建议推送前执行：

```bash
git config core.autocrlf false
git add --renormalize .
```

推送后必须用 `curl raw | wc -l` 检查行数。

### Q3：Reality 安装成功但连不上怎么办？

优先换稳定 Reality 域名：

```bash
REALITY_TARGET='www.microsoft.com:443'
REALITY_SERVER_NAMES='www.microsoft.com'
```

同时检查客户端链接里的：

- `pbk=`
- `sni=`
- `sid=`
- `flow=`
- `encryption=`
- `pqv=`

### Q4：旧客户端不支持 VLESS PQC 怎么办？

临时设：

```bash
VLESS_PQC_STRICT='n'
```

或关闭：

```bash
ENABLE_VLESS_PQC='n'
```

---

## 14. 最小部署命令汇总

```bash
git clone https://github.com/hkzping999/Argo-PRO.git
cd Argo-PRO
chmod +x argox.sh argox-next.sh scripts/*.sh tests/*.sh
./argox-next.sh --test-modules
./argox-next.sh --doctor
INSTALL_PROTOCOLS='e' bash argox.sh -f config-pqc-strong.conf
```
