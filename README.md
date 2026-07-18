# AI Travel Agent Framework

> **中文** | [English](#english)

构建智能旅行助手的开源框架。

设计、定制和扩展 AI 驱动的本地导游，采用模块化技能、工作流和 Provider 架构。

---

## 快速开始

### 作为 AI Agent 使用

将本目录放入 Agent 的 `skills/` 文件夹，Agent 会自动读取 `SKILL.md`。

### 作为开发者

```bash
git clone https://github.com/King8848/AI-Local-Guide-Frameworl.git

# 1. 准备 TripData JSON（参见 schema/trip-data.json）
# 2. 注入 templates/demo.html
# 3. 生成完整旅行攻略页面
```

### 作为贡献者

1. Fork 仓库
2. 添加城市知识包：`knowledge/china/cities/{城市名}.md`
3. 提交 PR

---

## 项目结构

```
AI-Travel-Skill-Core/
├── LICENSE.md              # Apache License 2.0
├── LICENSE                 # Apache License 2.0（完整文本）
├── NOTICE                  # 第三方组件声明
├── README.md               # 本文件（中英双语）
├── .env.example            # 环境变量模板
├── .gitignore
├── SKILL.md                # Agent 入口文件
├── docs/
│   ├── architecture.md     # 系统架构设计
│   └── template-engine.md  # 模板引擎使用指南
├── references/
│   ├── workflow.md         # 用户交互工作流
│   ├── planner.md          # 行程规划引擎
│   ├── budget.md           # 预算引擎
│   ├── formatter.md        # 输出格式化
│   └── router.md           # 意图路由
├── providers/              # 可插拔的 Provider 接口
│   ├── README.md           # Provider 接口文档
│   ├── flyai-provider.md   # FlyAI 搜索适配器
│   └── openfreemap-provider.md # 免费地图瓦片
├── schema/
│   └── trip-data.json      # TripData JSON Schema
├── templates/
│   └── demo.html           # 简单 Demo 模板
├── examples/
│   └── sample-output.md    # 示例输出
└── knowledge/
    ├── README.md           # 知识库文档
    ├── china/              # 中国城市包
    │   ├── cities/
    │   │   ├── _template.md
    │   │   ├── 杭州.md
    │   │   └── 成都.md
    │   ├── food/
    │   ├── culture/
    │   ├── travel/
    │   └── avoid/
    ├── international/      # 国际城市包
    │   ├── _template.md
    │   └── tokyo.md
    └── common/
        ├── packing/
        ├── health/
        └── seasonal/
```

---

## 开源版 vs 商业版

本项目提供构建旅行助手的**开放底座**。

知识库包含**基础城市包**供演示使用。如需完整深度城市攻略、私有数据集和生产级集成，可获取定制版本。

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

[Apache License 2.0](LICENSE.md)

第三方组件声明：[NOTICE](NOTICE)

---

*最后更新：2026-07-19*

---

---

---

# English

> [中文](#ai-travel-agent-framework) | **English**

An open-source framework for building intelligent travel agents.

Design, customize, and extend AI-powered local guides with modular skills, workflows, and providers.

---

## Quick Start

### As an AI Agent

Drop this directory into your agent's `skills/` folder. The agent reads `SKILL.md` automatically.

### As a Developer

```bash
git clone https://github.com/King8848/AI-Local-Guide-Frameworl.git

# 1. Prepare TripData JSON (see schema/trip-data.json)
# 2. Inject into templates/demo.html
# 3. Generate a complete travel guide page
```

### As a Contributor

1. Fork the repo
2. Add a city pack: `knowledge/china/cities/{city}.md`
3. Submit a PR

---

## Project Structure

```
AI-Travel-Skill-Core/
├── LICENSE.md              # Apache License 2.0
├── LICENSE                 # Apache License 2.0 (full text)
├── NOTICE                  # Third-party notices
├── README.md               # This file (bilingual)
├── .env.example            # Environment variables template
├── .gitignore
├── SKILL.md                # Agent entry point
├── docs/
│   ├── architecture.md     # System architecture
│   └── template-engine.md  # Template engine guide
├── references/
│   ├── workflow.md         # User interaction workflow
│   ├── planner.md          # Trip planning engine
│   ├── budget.md           # Budget engine
│   ├── formatter.md        # Output formatter
│   └── router.md           # Intent router
├── providers/              # Pluggable provider interfaces
│   ├── README.md           # Provider interface docs
│   ├── flyai-provider.md   # FlyAI search adapter
│   └── openfreemap-provider.md # Free map tiles
├── schema/
│   └── trip-data.json      # TripData JSON Schema
├── templates/
│   └── demo.html           # Simple demo template
├── examples/
│   └── sample-output.md    # Example output
└── knowledge/
    ├── README.md           # Knowledge base docs
    ├── china/              # Chinese city packs
    │   ├── cities/
    │   │   ├── _template.md
    │   │   ├── 杭州.md
    │   │   └── 成都.md
    │   ├── food/
    │   ├── culture/
    │   ├── travel/
    │   └── avoid/
    ├── international/      # International city packs
    │   ├── _template.md
    │   └── tokyo.md
    └── common/
        ├── packing/
        ├── health/
        └── seasonal/
```

---

## Core vs Commercial

This project provides the **open foundation** for building travel agents.

The knowledge base includes **basic city packs** for demonstration. For full-depth city guides, proprietary datasets, and production-ready integrations — a custom version is available.

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

[Apache License 2.0](LICENSE.md)

Third-party notices: [NOTICE](NOTICE)

---

*Last updated: 2026-07-19*
