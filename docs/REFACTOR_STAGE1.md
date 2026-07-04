# Argo-PQC-Strong 架构重构 Stage 1

本阶段目标是把项目从单文件 `argox.sh` 逐步迁移到模块化架构，同时保持生产入口不变。

## 本阶段新增内容

- `argox-next.sh`：模块化内核入口，不替代旧安装器。
- `modules/core/`：日志、JSON、状态、运行时、校验工具。
- `modules/pqc/`：VLESS PQC、Reality ML-DSA-65、TLS hybrid curve。
- `modules/protocols/`：协议注册表与协议 inbound builder。
- `scripts/build_inbounds.sh`：根据协议 tag 生成 inbound JSON。
- `scripts/doctor.sh`：检测 jq、openssl、Xray、vlessenc、mldsa65、Reality SNI。
- `scripts/safe_apply_config.sh`：配置测试、备份、应用。

## 已模块化的协议

| tag | 状态 |
|---|---|
| `reality-vision` | 已模块化 |
| `reality-grpc` | 已模块化 |
| `vless-ws` | 已模块化 |
| `xhttp-h1.1-cdn` | 已模块化 |
| `xhttp-h3-direct` | 已模块化 |
| `httpupgrade-cdn` | 已模块化 |
| `hysteria2` | 已模块化 |
| `trojan-direct` | 已模块化 |

## 常用命令

```bash
./argox-next.sh --test-modules
./argox-next.sh --doctor
./argox-next.sh --list-protocols
./argox-next.sh --build-sample
```

生成指定协议：

```bash
./argox-next.sh --build-inbounds \
  --tags vless-ws,reality-vision,xhttp-h1.1-cdn \
  --env ./config-pqc-strong.conf \
  --out ./inbound.next.json
```

应用前先测试：

```bash
./argox-next.sh --safe-apply-config ./inbound.next.json /etc/argox/inbound.json /etc/argox/outbound.json
```

## 为什么保留旧 argox.sh

本阶段是“并行内核”模式：

1. 旧 `argox.sh` 继续负责安装、卸载、菜单、系统服务。
2. 新模块负责协议配置生成和校验。
3. 稳定后，再把旧脚本中协议 JSON 拼接部分替换为模块调用。

这样可以避免一次性重构导致安装器不可用。

## 下一阶段建议

Stage 2 应该迁移订阅导出层：

- `subscription/v2rayn.sh`
- `subscription/clash.sh`
- `subscription/singbox.sh`
- `subscription/nekoray.sh`

并统一处理：

- `encryption=`
- `pqv=`
- XHTTP opts
- HTTPUpgrade opts
- Reality opts
- TLS curve compatibility notes
