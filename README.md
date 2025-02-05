# Disable NeuVector nvprotect

NeuVector 有一个名为 nvprotect 的内部保护机制，用于限制用户对 NeuVector pod 的访问权限。

如果需要关闭，可以通过接口进行关闭，此处提供脚本，支持关闭 Controller、Scanner、Enforcer 的 nvprotect。

使用方法：

```bash
git clone https://github.com/warnerchen/disable-nvprotect.git
cd disable-nvprotect
chmod +x disable-nvprotect.sh

# 关闭 nvprotect
# 关闭 enforcer 即可同时关闭 scanner 的 nvprotect
./disable-nvprotect.sh off controller|enforcer

# 开启 nvprotect
./disable-nvprotect.sh on controller|enforcer
```
