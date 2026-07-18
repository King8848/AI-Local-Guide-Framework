# AI Travel Agent Framework

> **中文** | [English](#english)

你肯定受够了那些千篇一律的旅行攻略。

"去成都吃火锅，去杭州游西湖" —— 随便一个 AI 都能告诉你这些。但如果你带着爸妈去，不想排队，想找本地人真正去的地方，还要控制预算呢？现有的旅行 AI 就卡住了。它们只会套模板，不会真的替你想。

这个框架就是为了解决这个问题：**让你 5 分钟搭一个真正懂你的本地 AI 旅行助手**。

它跑在本地，不泄露隐私。改个 JSON 就能出完整攻略页。够简单，够灵活，而且完全属于你。

---

## 先看效果

用这份框架生成的攻略页：

- 📅 按天组织的行程，不是流水账
- 🗺️ 交互式地图，POI 一点就开
- 💰 预算试算器，输入人数自动算
- 🍜 按维度整理的美食推荐（不只是"必吃榜"）
- 💡 避坑指南，告诉你哪些是游客陷阱

> 👉 Demo 城市：[杭州](knowledge/china/cities/杭州.md) · [成都](knowledge/china/cities/成都.md) · [东京](knowledge/international/tokyo.md)

---

## 快速开始

### 作为 AI Agent 使用

把本目录放进 Agent 的 `skills/` 文件夹，Agent 会自动读取 `SKILL.md`。

### 作为开发者

```bash
git clone https://github.com/King8848/AI-Local-Guide-Frameworl.git
```

然后：
1. 准备一份 TripData JSON（参见 [schema/trip-data.json](schema/trip-data.json)）
2. 注入 [templates/demo.html](templates/demo.html)
3. 打开浏览器，看到你的专属攻略页

### 作为贡献者

1. Fork 仓库
2. 添加城市知识包：`knowledge/china/cities/{城市名}.md`
3. 提交 PR

---

## 项目结构

```
AI-Travel-Skill-Core/
├── LICENSE                   # Apache License 2.0
├── NOTICE                    # 第三方组件声明
├── README.md                 # 本文件（中英双语）
├── .env.example              # 环境变量模板
├── .gitignore
├── SKILL.md                  # Agent 入口文件
├── docs/
│   ├── architecture.md       # 系统架构设计
│   └── template-engine.md    # 模板引擎使用指南
├── references/
│   ├── workflow.md           # 用户交互工作流
│   ├── planner.md            # 行程规划引擎
│   ├── budget.md             # 预算引擎
│   ├── formatter.md          # 输出格式化
│   └── router.md             # 意图路由
├── providers/                # 可插拔的 Provider 接口
│   ├── README.md             # Provider 接口文档
│   ├── flyai-provider.md     # FlyAI 搜索适配器
│   └── openfreemap-provider.md # 免费地图瓦片
├── schema/
│   └── trip-data.json        # TripData JSON Schema
├── templates/
│   └── demo.html             # 简单 Demo 模板
├── examples/
│   └── sample-output.md      # 示例输出
└── knowledge/
    ├── README.md             # 知识库文档
    ├── china/                # 中国城市包
    │   ├── cities/
    │   │   ├── _template.md
    │   │   ├── 杭州.md
    │   │   └── 成都.md
    │   ├── food/
    │   ├── culture/
    │   ├── travel/
    │   └── avoid/
    ├── international/        # 国际城市包
    │   ├── _template.md
    │   └── tokyo.md
    └── common/
        ├── packing/
        ├── health/
        └── seasonal/
```

---

## 开源版 vs 定制版

这份框架是**开源基础**，帮你快速搭自己的旅行 Agent。

开源版包含：
- ✅ AI Travel Skill 基础框架
- ✅ 可扩展的 Workflow 与 Provider 接口
- ✅ 示例模板与 Demo 城市
- ✅ 可自由扩展的旅行规划流程

如果你想要更完整、更私人的旅行体验，可以试试**定制版**。

### 定制版（Commercial Edition）

定制化旅行路线以及可视化交互地图

https://github.com/user-attachments/assets/292ace86-6e5c-4889-a7b8-3cb161de3638

预算清单以及当地城市避坑指南、常见骗局、必备APP

https://github.com/user-attachments/assets/18a7430b-4a94-4f97-a0fd-4f30f02d99ee

主页（旅游路线及可交互式地图）

<img width="1917" height="942" alt="image" src="https://github.com/user-attachments/assets/5ac641bf-a2de-46b0-8c76-67daafda78e6" />

城市旅游攻略

<img width="1896" height="930" alt="image" src="https://github.com/user-attachments/assets/c15db90d-0f99-40a2-8ea0-049a925e4d86" />

预算

<img width="1919" height="935" alt="image" src="https://github.com/user-attachments/assets/87d68d26-9ed9-458d-80f2-49b38b0932b2" />

旅行清单
<img width="1913" height="936" alt="image" src="https://github.com/user-attachments/assets/9ae13543-5ba3-416f-87bb-09c57de1eaeb" />

定制版的核心是**一人一规划** —— 根据你的需求生成专属方案，不是套模板。

| 功能 | 开源版 | 定制版 |
|------|:------:|:------:|
| 基础 AI 旅行规划 | ✅ | ✅ |
| Demo 城市示例 | ✅ | ❌（按需求生成） |
| 专属旅行规划 | ❌ | ✅ |
| 本地人玩法推荐 | ❌ | ✅ |
| 小众景点与特色美食 | ❌ | ✅ |
| 个性化路线优化 | ❌ | ✅ |
| 行程预算优化 | ❌ | ✅ |
| 高级交互式旅行页面 | 基础版 | ✅ |
| 持续更新城市知识库 | ❌ | ✅ |

定制版更适合：
- 情侣旅行
- 家庭亲子游
- 自驾旅行
- 深度旅行
- 首次前往陌生城市
- 希望体验当地文化与本地玩法的旅行者

📩 如需专属旅游规划或商业合作，欢迎联系作者。

**WeChat：Hoyeye-Z**

---

## 核心能力

| 能力 | 说明 |
|------|------|
| 🧩 模块化架构 | Router → Planner → Formatter 流水线 |
| 📐 TripData Schema | 统一 JSON 数据协议 |
| 🎨 模板引擎 | 主题无关的 HTML 输出 |
| 🌐 知识库 | 社区驱动的城市知识包 |
| 🔌 Provider 接口 | 可插拔的天气/地图/搜索 |
| 📦 零依赖 | 适配任何 AI Agent 平台 |

你可以完全在本地运行这个框架 —— 数据不出本机，没有大数据监控，不用担心隐私泄露。

---

## 路线图

- [x] 核心架构设计
- [x] TripData Schema v1
- [x] 基础工作流与模块
- [x] Provider 接口设计
- [ ] 社区城市包（10+ 城市）
- [ ] 2-3 个 Provider 实现
- [ ] 插件接口稳定
- [ ] 多语言支持

接下来最让我兴奋的是**社区城市包** —— 当足够多的人贡献自己城市的知识库，这个框架才能真正"懂旅行"。如果你来自某个城市，欢迎贡献一份城市包，哪怕只是几家你私藏的店。

---

## 贡献

欢迎：
- 🏙️ 城市知识包贡献
- 🔌 Provider 实现
- 🎨 模板主题
- 📐 Schema 扩展
- 📖 文档改进

详见 [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 许可

[Apache License 2.0](LICENSE)

第三方组件声明：[NOTICE](NOTICE)

---

*最后更新：2026-07-19*

---

# English

> [中文](#ai-travel-agent-framework) | **English**

You've seen the same travel advice a thousand times.

"Go to Chengdu for hot pot. Go to杭州 for West Lake." Any AI can tell you that. But what if you're traveling with your parents, don't want to wait in line, need places locals actually go, and have a budget to stick to? That's where most travel AI stops working. It can only follow templates. It doesn't actually think for you.

This framework exists to fix that: **build a local AI travel assistant that actually gets you, in about 5 minutes.**

It runs locally. Your data stays on your machine. Change a JSON file, get a full travel guide page. Simple enough to start, flexible enough to make yours.

---

## See what it looks like

A travel guide built with this framework:

- 📅 Day-by-day itinerary, not a timeline dump
- 🗺️ Interactive map, tap a POI to see details
- 💰 Budget calculator, enter your group size and it computes automatically
- 🍜 Food recommendations organized by dimension (not just "must-eat lists")
- 💡 Trap avoidance tips — what to skip and why

> 👉 Demo cities: [Hangzhou](knowledge/china/cities/杭州.md) · [Chengdu](knowledge/china/cities/成都.md) · [Tokyo](knowledge/international/tokyo.md)

---

## Quick start

### As an AI Agent

Drop this directory into your agent's `skills/` folder. The agent reads `SKILL.md` automatically.

### As a developer

```bash
git clone https://github.com/King8848/AI-Local-Guide-Frameworl.git
```

Then:
1. Prepare a TripData JSON (see [schema/trip-data.json](schema/trip-data.json))
2. Inject it into [templates/demo.html](templates/demo.html)
3. Open the browser. There's your guide.

### As a contributor

1. Fork the repo
2. Add a city pack: `knowledge/china/cities/{city}.md`
3. Submit a PR

---

## Project structure

```
AI-Travel-Skill-Core/
├── LICENSE                   # Apache License 2.0
├── NOTICE                    # Third-party notices
├── README.md                 # This file (bilingual)
├── .env.example              # Environment variables template
├── .gitignore
├── SKILL.md                  # Agent entry point
├── docs/
│   ├── architecture.md       # System architecture
│   └── template-engine.md    # Template engine guide
├── references/
│   ├── workflow.md           # User interaction workflow
│   ├── planner.md            # Trip planning engine
│   ├── budget.md             # Budget engine
│   ├── formatter.md          # Output formatter
│   └── router.md             # Intent router
├── providers/                # Pluggable provider interfaces
│   ├── README.md             # Provider interface docs
│   ├── flyai-provider.md     # FlyAI search adapter
│   └── openfreemap-provider.md # Free map tiles
├── schema/
│   └── trip-data.json        # TripData JSON Schema
├── templates/
│   └── demo.html             # Simple demo template
├── examples/
│   └── sample-output.md      # Example output
└── knowledge/
    ├── README.md             # Knowledge base docs
    ├── china/                # Chinese city packs
    │   ├── cities/
    │   │   ├── _template.md
    │   │   ├── 杭州.md
    │   │   └── 成都.md
    │   ├── food/
    │   ├── culture/
    │   ├── travel/
    │   └── avoid/
    ├── international/        # International city packs
    │   ├── _template.md
    │   └── tokyo.md
    └── common/
        ├── packing/
        ├── health/
        └── seasonal/
```

---

## Open source vs custom

This framework is the **open foundation** for building travel agents.

The open-source edition includes:
- ✅ AI Travel Skill basic framework
- ✅ Extensible Workflow & Provider interfaces
- ✅ Demo templates & sample cities
- ✅ Freely extensible trip planning pipeline

For a more complete, personal travel experience, there's the **custom edition**.

### Custom edition (Commercial)

The custom edition focuses on **one person, one plan** — generating a tailored travel solution based on your needs, rather than applying a fixed template.

| Feature | Open Source | Custom |
|---------|:------:|:------:|
| Basic AI trip planning | ✅ | ✅ |
| Demo city examples | ✅ | ❌ (generated on demand) |
| Personalized travel planning | ❌ | ✅ |
| Local insider recommendations | ❌ | ✅ |
| Hidden gems & specialty food | ❌ | ✅ |
| Personalized route optimization | ❌ | ✅ |
| Budget optimization | ❌ | ✅ |
| Advanced interactive travel page | Basic | ✅ |
| Continuously updated city knowledge | ❌ | ✅ |

The custom edition is ideal for:
- Couple travel
- Family trips with kids
- Self-driving road trips
- Deep travel experiences
- First-time visitors to unfamiliar cities
- Travelers seeking local culture & authentic experiences

📩 For custom travel planning or business collaboration, feel free to reach out.

**WeChat：Hoyeye-Z**

---

## Capabilities

| Capability | Description |
|------------|-------------|
| 🧩 Modular Architecture | Router → Planner → Formatter pipeline |
| 📐 TripData Schema | Unified JSON data protocol |
| 🎨 Template Engine | Theme-agnostic HTML output |
| 🌐 Knowledge Base | Community-driven city packs |
| 🔌 Provider Interface | Pluggable weather/map/search |
| 📦 Zero Dependencies | Works with any AI agent platform |

You can run this framework entirely locally — data never leaves your machine, no big data surveillance, no privacy concerns.

---

## Roadmap

- [x] Core architecture design
- [x] TripData Schema v1
- [x] Basic workflow & modules
- [x] Provider interface design
- [ ] Community city packs (10+ cities)
- [ ] 2-3 provider implementations
- [ ] Plugin interface stable
- [ ] Multi-language support

What I'm most excited about next is **community city packs** — when enough people contribute knowledge about their own cities, the framework actually starts to "get" travel. If you're from somewhere, consider contributing a city pack. Even if it's just a few shops you love.

---

## Contributing

We welcome:
- 🏙️ City packs
- 🔌 Provider implementations
- 🎨 Template themes
- 📐 Schema extensions
- 📖 Documentation

See [CONTRIBUTING.md](CONTRIBUTING.md)

---

## License

[Apache License 2.0](LICENSE)

Third-party notices: [NOTICE](NOTICE)

---

*Last updated: 2026-07-19*
