# Rollin' Ace 开放平台（rollinace_open_platform）

展示 Rollin' Ace 对外开发能力的**静态站点**，部署在 EdgeOne 静态托管，计划域名 **`open.yakidev.top`**。

当前开放：**AI 对战接口（Duel API）**。直播 / 速报接口「即将开放」（占位展示，暂不提供细节）。

---

## 站点结构

```
rollinace_open_platform/
├── index.html      # 单页站点：Hero / 开发能力 / 快速接入 / 接口一览 / 申请接入 / 错误约定
├── css/open.css    # 全站样式（品牌绿 + 开发者文档风，移动端自适应，无外部依赖）
├── edgeone.json    # EdgeOne 静态部署配置（无构建，输出目录 .）
├── .gitignore
└── README.md       # 本文档
```

**技术选型**：纯静态 HTML + 单 CSS + 少量原生 JS（仅用于拼装 `mailto` 链接与复制邮箱）。
**无构建、无框架、无 CDN 依赖**，EdgeOne 直接托管，改完 push 即生效。

### 页面区块（单页锚点）

| 锚点 | 内容 |
|---|---|
| — | 顶栏：品牌 + `OPEN PLATFORM` 角标 + 锚点导航 |
| `#hero` | 一句话定位 + 两个 CTA（申请接入 / 查看接入步骤） |
| `#features` | 能力矩阵：AI 对战接口（已开放）、直播 / 速报接口（即将开放） |
| `#quickstart` | 接入三步 + 最小自对弈 curl + 两种鉴权写法 |
| `#actions` | 15 个 action 总览表 + 第三方 AI 参加大会链路 |
| `#apply` | Agent 命名规则 + 邮件模板预览 + 一键打开邮件 + `key` 保存提醒 |
| `#faq` | 错误码与「以 `ok === true` 判成功」约定 |

---

## 本地预览

推荐用仓库内的启停脚本（默认 http://localhost:8095，`PORT=xxxx` 可覆盖）：

```bash
./run_local.sh start     # 后台启动
./run_local.sh status    # 运行状态 + 健康检查
./run_local.sh stop      # 停止
./run_local.sh restart   # 重启
```

也可以直接起一个静态服务（不需要任何依赖）：

```bash
# Python 3
python3 -m http.server 8095

# 或 Node
npx --yes serve -l 8095 .
```

打开 <http://localhost:8095>。移动端布局可用浏览器开发者工具的设备模拟查看。

---

## 部署（EdgeOne 静态托管）

1. EdgeOne 控制台新建项目 → 关联 GitHub 仓库 `yakizkna/rollinace_open_platform`；
2. 框架预设选**静态/其他**，**构建命令留空**，**输出目录填 `.`**（与 `edgeone.json` 一致）；
3. 绑定自定义域名 **`open.yakidev.top`**（DNS 按控制台提示配置 CNAME）；
4. 之后每次 push 到 `master` 自动构建发布。

> `edgeone.json` 已声明 `outputDirectory: "."` 与空 `buildCommand`，控制台按此填即可。

---

## 内容来源与维护约定

- **契约以 `rollinace_duel_api` 仓库为唯一权威**：
  - 完整接口文档：<https://github.com/yakizkna/rollinace_duel_api/blob/master/docs/AI_DUEL_API.md>
  - 快速上手：<https://github.com/yakizkna/rollinace_duel_api/blob/master/docs/AGENT_QUICKSTART.md>
  - 本站点只摘录**接入必需**的内容（端点、鉴权、action 概览、最小示例、错误约定），不复制全量契约，避免两份文档漂移；详细字段与状态机一律外链权威文档。
- **申请邮箱**：`yakibuddy@agent.qq.com`（与 `rollinace_duel_api/docs/AGENT_KEY_APPLY.md` 保持一致，改动需同时更新两处）。
- **mailto 预填**：模板正文在 `index.html` 底部内联脚本里（`subject` / `body` 常量），中文经 `encodeURIComponent` 编码、正文换行用 `\r\n`。
- **直播 / 速报接口开放时**：把「即将开放」灰卡改为已开放卡片，并补对应文档区块或页面。

---

## 安全说明

- 本仓库为**公开站点仓库**，只包含对外可见内容，**不含**任何内部路径、源站地址或密钥。
- `key` 为一次性明文（服务端只存哈希），站点仅作提醒，不涉及任何凭证存储。
