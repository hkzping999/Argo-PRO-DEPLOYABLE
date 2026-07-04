# Argo-PRO Raw LF Fix Files

这些文件已经统一为 Unix LF 换行，可用于替换 GitHub 仓库中的对应文件。

关键验证值：

```text
argox.sh                       LF=5051  CR=0
argox-next.sh                  LF=59    CR=0
config-pqc-strong.conf         LF=82    CR=0
scripts/verify_raw_lf.sh       LF=24    CR=0
```

推荐使用 GitHub 网页的 “Upload files” 覆盖替换，或者使用 git 命令提交。若必须粘贴，请从这些文件本身复制，不要从聊天窗口复制。

推送/替换后验证：

```bash
curl -fsSL https://raw.githubusercontent.com/hkzping999/Argo-PRO-DEPLOYABLE/main/argox.sh | wc -l
curl -fsSL https://raw.githubusercontent.com/hkzping999/Argo-PRO-DEPLOYABLE/main/argox-next.sh | wc -l
curl -fsSL https://raw.githubusercontent.com/hkzping999/Argo-PRO-DEPLOYABLE/main/config-pqc-strong.conf | wc -l
```

应接近：

```text
5051
59
82
```
