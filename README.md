# AI Travel Agent Framework

An open-source framework for building intelligent travel agents.

Design, customize, and extend AI-powered local guides with modular skills, workflows, and providers.

---

## Quick Start

### As an AI Agent

Drop this directory into your agent's `skills/` folder. The agent reads `SKILL.md` automatically.

### As a Developer

```bash
git clone https://github.com/your-org/AI-Travel-Skill-Core.git

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
├── README.md               # This file
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

| Component | Open Source | Commercial |
|-----------|:-----------:|:----------:|
| Skill architecture (Router/Planner/Formatter) | ✅ | ✅ |
| TripData Schema | ✅ | ✅ |
| Provider interface | ✅ | ✅ |
| Demo template | ✅ | ✅ |
| Knowledge base structure | ✅ | ✅ |
| City packs (community) | ✅ | ✅ |
| Advanced templates | ❌ | ✅ |
| Private knowledge base  | ❌ | ✅ |
| Dianping/XHS scraping integration | ❌ | ✅ |
| FlyAI full integration | ❌ | ✅ |
| Real-time price / inventory | ❌ | ✅ |
| Production pipeline| ❌ | ✅ |
| Advanced prompts / commercial workflows | ❌ | ✅ |

**Advanced templates, proprietary datasets, private workflows, and commercial integrations are maintained separately.**

For commercial inquiries: WeChat `Hoyeye-Z`

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
