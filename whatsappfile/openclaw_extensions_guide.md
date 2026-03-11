# OpenClaw 拓展（Extensions/Plugins）使用速查

## 1) 插件是什么
OpenClaw 插件（extensions/plugins）是给系统加功能的小模块，可扩展：
- 新工具（tools）
- 新命令（CLI / 自动命令）
- 新渠道（如某些聊天渠道）
- Gateway RPC / 后台服务

---

## 2) 最快上手（插件）
### 查看已加载插件
```bash
openclaw plugins list
```

### 安装官方插件（示例）
```bash
openclaw plugins install @openclaw/voice-call
```

### 启用 / 禁用插件
```bash
openclaw plugins enable <plugin-id>
openclaw plugins disable <plugin-id>
```

### 查看插件详情
```bash
openclaw plugins info <plugin-id>
```

### 更新插件
```bash
openclaw plugins update <plugin-id>
openclaw plugins update --all
```

### 改完配置后重启网关（重要）
```bash
openclaw gateway restart
```

---

## 3) 常见配置位置（openclaw.json）
```json
{
  "plugins": {
    "enabled": true,
    "allow": ["voice-call"],
    "deny": ["untrusted-plugin"],
    "load": { "paths": ["~/Projects/my-extensions"] },
    "entries": {
      "voice-call": {
        "enabled": true,
        "config": { "provider": "twilio" }
      }
    }
  }
}
```

说明：
- `allow`：白名单（推荐）
- `deny`：黑名单（deny 优先）
- `entries.<id>.config`：每个插件自己的配置

---

## 4) 安全建议（很重要）
- 只装你信任的插件（插件在网关进程内运行）
- 推荐用 `plugins.allow` 做白名单
- 配置变更后一定重启 Gateway
- 不要给插件不必要的高权限

---

## 5) 技能市场 ClawHub（给 OpenClaw 装 Skills）
> 这是“Skills”，不是“Plugins”，但很多人会一起用。

### 安装 clawhub CLI
```bash
npm i -g clawhub
# 或
pnpm add -g clawhub
```

### 搜索/安装/更新技能
```bash
clawhub search "calendar"
clawhub install <skill-slug>
clawhub update --all
```

默认安装到当前目录 `./skills`，OpenClaw 会在新会话加载。

---

## 6) Chrome 扩展（浏览器接管）
如果你要让 OpenClaw 控制你当前 Chrome 标签页：

### 安装扩展文件
```bash
openclaw browser extension install
openclaw browser extension path
```

然后在 Chrome：
1. 打开 `chrome://extensions`
2. 开启开发者模式
3. Load unpacked 选择上面 path
4. 固定扩展图标

### 使用
- 点击扩展图标 attach 当前 tab（徽标 ON）
- 再点一次 detach

注意：这是高权限能力，建议用独立浏览器 profile。

---

## 7) 我给你的推荐实践（简版）
1. 先 `openclaw plugins list`
2. 只安装 1 个你真需要的插件
3. 配 `plugins.allow` 白名单
4. `openclaw gateway restart`
5. 用 `openclaw status` 验证

---

## 8) 常用命令清单（可直接复制）
```bash
openclaw plugins list
openclaw plugins install @openclaw/voice-call
openclaw plugins enable voice-call
openclaw plugins info voice-call
openclaw plugins update --all
openclaw plugins doctor
openclaw gateway restart
openclaw status
```
