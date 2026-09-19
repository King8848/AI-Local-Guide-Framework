# AI Local Friend · 旅行 AI 助手

> **中文** | [English](#english)

一个 **AI Agent 技能包（Skill）** —— 让 AI 像"当地朋友"一样陪你旅行。

把它放进 Agent 的 `skills/` 目录，它就会帮你：规划行程、找本地人才去的地方、按维度推荐美食、规划怎么拍、自动避坑。

不是攻略生成器，不是导游，更不是客服。**每到一座陌生城市，都有一个懂这里的朋友陪你。**

---

## 它解决什么问题

"去成都吃火锅，去杭州游西湖" —— 随便一个 AI 都能告诉你这些。

但如果你带着爸妈去、不想排队、想找本地人真正去的地方、还要控制预算呢？现有的旅行 AI 就卡住了。它们只会套模板，不会真的替你想。

这个 Skill 就是为了解决这个问题。

---

## 能做什么

- 🗓️ **行程规划** —— 1 / 3 / 5 / 7 天，按片区、按节奏，不是流水账
- 🍜 **美食推荐** —— 9 维度（早餐 / 面食 / 硬菜 / 夜市 / 酒水 / 糕点 / 时令 / 伴手礼 / 文化）
- 📸 **拍照指导** —— 出片点位 + 最佳时段 + 穿搭 + pose
- 🎬 **Vlog 运镜** —— 手机 / 相机的运镜方案与叙事线
- 🗺️ **可交互地图** —— POI 串线，一点跳转高德 / Apple 导航
- 💡 **避坑指南** —— 购物点、骗局、消费陷阱、长车程应对
- 🧠 **上下文守护** —— 拒绝"答非所问"，始终记得你在哪座城市

---

## 里面有什么

| 模块 | 内容 | 规模 |
|------|------|------|
| 📜 `SKILL.md` | 技能入口：架构、触发条件、交互规范 | 1 |
| 🧠 `references/` | 方法论文档：路由 / 规划 / 拍照 / 运镜 / 数据源 / 踩坑记录 | 34 |
| 🎨 `templates/` | 控制中心式攻略页模板（JSON 驱动，可交互地图） | 1 |
| 🚀 `examples/` | 跑起来长什么样的示例输出 | 1 |
| 🗺️ `knowledge/` | 54 座城市深度攻略（按省份组织） | 54 |
| 📖 `docs/` | 架构与模板引擎文档 | 2 |

---

## 快速开始

### 1. 放进 Agent

把本目录整个放进你的 Agent 的 `skills/` 文件夹，Agent 会自动读取 `SKILL.md`。

### 2. 直接生成一个攻略页

1. 打开 `templates/template.html`
2. 替换 `<script id="trip-data">` 里的 JSON（参考 examples 里的示例）
3. 改封面图，浏览器打开 —— 一张属于你的旅行控制中心就有了

### 3. 引用城市知识

在对话里说"帮我规划杭州三日游"，Agent 会读取 `knowledge/02-华东/浙江/杭州攻略.md`。

---

## 目录结构

    AIlocalfriend/
    ├── SKILL.md               # 技能入口
    ├── README.md              # 本文件（中英双语）
    ├── LICENSE                # Apache License 2.0
    ├── NOTICE                 # 第三方组件声明
    ├── CONTRIBUTING.md        # 贡献指南
    ├── .env.example           # 环境变量模板
    ├── references/            # 34 份方法论文档
    ├── scripts/               # 辅助脚本
    ├── templates/             # HTML 攻略模板
    ├── examples/              # 示例输出
    ├── knowledge/             # 54 城攻略（01-直辖市 … 09-特别行政区）
    └── docs/                  # 架构 / 模板引擎文档

---

## 许可

[Apache License 2.0](LICENSE) · 第三方组件声明见 [NOTICE](NOTICE)

---

*最后更新：2026-08-27*

---

# English

> [中文](#ai-local-friend--旅行-ai-助手) | **English**

An **AI Agent Skill** that turns your AI into a local friend who travels with you.

Drop it into your agent's `skills/` folder, and it will plan your trip, find places locals actually go, recommend food by dimension, plan your shots, and steer you away from tourist traps.

Not a guide generator. Not a tour guide. Not customer service. **Wherever you go, a friend who knows the city is right there with you.**

---

## What it solves

"Go to Chengdu for hot pot. Go to Hangzhou for West Lake." Any AI can say that.

But what if you are traveling with your parents, do not want to queue, want places locals actually go, and have a budget to stick to? Most travel AI stops working there. It only follows templates. It does not think for you.

This Skill exists to fix that.

---

## What it does

- 🗓️ **Trip planning** — 1 / 3 / 5 / 7 days, by district and by pace
- 🍜 **Food** — 9 dimensions (breakfast / noodles / mains / night market / drinks / pastry / seasonal / souvenirs / culture)
- 📸 **Photography** — spots + best time + outfits + poses
- 🎬 **Vlog** — camera moves and a narrative line for phone or camera
- 🗺️ **Interactive map** — POIs chained into a route, one tap to navigate
- 💡 **Trap avoidance** — shops, scams, tourist traps, long drives
- 🧠 **Context guard** — never answers about the wrong city

---

## What is inside

| Module | Content | Scale |
|--------|---------|-------|
| 📜 `SKILL.md` | Skill entry: architecture, triggers, interaction rules | 1 |
| 🧠 `references/` | Methodology docs: routing / planning / shooting / data sources / lessons | 34 |
| 🎨 `templates/` | Control-center guide template (JSON-driven, interactive map) | 1 |
| 🚀 `examples/` | A sample output to see what it looks like | 1 |
| 🗺️ `knowledge/` | 54 deep city guides (organized by province) | 54 |
| 📖 `docs/` | Architecture and template-engine docs | 2 |

---

## Quick start

### 1. Drop it into your agent

Put this folder into your agent's `skills/` directory. The agent reads `SKILL.md` automatically.

### 2. Generate a guide page

1. Open `templates/template.html`
2. Replace the JSON inside `script id="trip-data"`
3. Update the cover image and open it in a browser

### 3. Ask for a city

Say "plan me 3 days in Hangzhou" and the agent reads `knowledge/02-华东/浙江/杭州攻略.md`.

---

## License

[Apache License 2.0](LICENSE) · third-party notices in [NOTICE](NOTICE)

---

*Last updated: 2026-08-27*
