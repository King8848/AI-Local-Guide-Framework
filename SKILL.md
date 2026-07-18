---
name: ai-travel-skill-core
display_name: "AI Travel Agent Framework"
description: "Open-source framework for building intelligent travel agents — modular skills, workflows, and extensible providers"
version: 0.1.0
license: Apache-2.0
tags: [travel, planning, skill, open-source, agent]
---

# AI Travel Agent Framework

> Modular, extensible open-source framework for building AI travel agents.

---

## Trigger Conditions

Use this skill when user says:

- "帮我规划旅行" / "我要去XX" / "plan a trip"
- "XX有什么好吃的" / "推荐餐厅" / "what to eat"
- "今天下雨" / "修改路线" / "改变计划"
- "预算XX" / "穷游" / "how much does it cost"
- "一个人旅行" / "摄影" / "travel alone"
- "附近有什么" / "现在去哪" / "nearby attractions"

---

## Architecture

```
User Input
    │
    ▼
Intent Router
    │
    ├── travel_plan → Planner Engine
    ├── food        → Food Module
    ├── companion   → Companion Engine
    ├── budget       → Budget Engine
    └── adjust      → Planner + Companion
    │
    ▼
Knowledge Layer (city packs / tips)
    │
    ▼
Output Formatter
    │
    ▼
Response (Markdown or HTML)
```

---

## Modules

| Module | Reference | Responsibility |
|--------|-----------|---------------|
| Router | `references/router.md` | Intent recognition & routing |
| Planner | `references/planner.md` | Trip planning (1/3/5/7 days) |
| Budget | `references/budget.md` | Budget analysis & optimization |
| Formatter | `references/formatter.md` | Unified output format |

---

## Workflow: 4-Step Format

All user-facing questions follow: **Re-ground → Simplify → Recommend → Options**

| Step | Action | Why |
|------|--------|-----|
| Re-ground | Tell user where they are | User may not remember context |
| Simplify | Plain language | No jargon |
| Recommend | Give 1 clear recommendation + reason | Reduce decision fatigue |
| Options | 2-4 clickable choices | Labels self-explanatory |

---

## TripData Output

All trip plans follow `schema/trip-data.json`:

```json
{
  "city": "杭州",
  "days": 3,
  "route": [...],
  "food": [...],
  "budget": {...},
  "tips": [...]
}
```

---

## Template Engine

Use `templates/demo.html` as starting point. Inject TripData via `{{PLACEHOLDER}}` syntax.

---

## Knowledge Base

Community-driven city packs under `knowledge/`. Use the template:

```markdown
# [City Name] 知识包
> 📍 [Province]

## 🏙️ 城市灵魂
[City: one-line positioning]

## 📋 城市速览
| Item | Content |
|------|---------|
| 建议游玩时间 | 浅体验 X-X 天 / 深度体验 X-X 天 |
| 💰 消费档次 | 经济型 XXXX-XXXX / 舒适型 XXXX-XXXX |

## 🍖 地区特色美食
| 维度 | 内容 |
|------|------|
| ☕ 早餐 | ... |
| 🥘 硬菜 | ... |

## 🏛️ 经典景区
## 🍜 推荐的店
## 💡 避坑指南
```

---

## Boundaries

### V1 Includes
- ✅ Trip planning (1-7 days)
- ✅ City knowledge packs
- ✅ Budget framework
- ✅ Standard output format
- ✅ Simple template engine
- ✅ Adapter interface (spec only)

### V1 Excludes
- ❌ Real-time booking (hotel/flight)
- ❌ Real-time price data
- ❌ Social/community features
- ❌ AI image generation

---

## Privacy

- Local storage default
- Cloud sync only with user consent
- Users can export/delete data at any time

---

## Support Files

- `references/workflow.md` — Full interaction workflow
- `references/planner.md` — Planner Engine details
- `references/budget.md` — Budget Engine details
- `references/formatter.md` — Output formatter details
- `references/router.md` — Intent router details
- `schema/trip-data.json` — JSON Schema
- `templates/demo.html` — HTML template
- `examples/sample-output.md` — Example output

---

*Last updated: 2026-07-19*
