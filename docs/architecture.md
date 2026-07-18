# System Architecture

> AI Travel Skill Core — 系统架构设计文档

---

## 1. 设计理念

### 核心原则

1. **模块化** — 每个功能独立，可拆卸、可替换
2. **协议驱动** — TripData Schema 统一数据交换
3. **开放扩展** — 社区可贡献 City Pack、Adapters、Templates
4. **零依赖** — 不绑定任何特定平台或 AI Agent

### 架构分层

```
┌─────────────────────────────────────────┐
│  Skill Entry (SKILL.md)                 │  ← Agent 入口
├─────────────────────────────────────────┤
│  Intent Router                          │  → 意图识别、分发
├─────────────────────────────────────────┤
│  Engine Layer                           │
│  ┌─────────┐ ┌────────┐ ┌───────────┐  │
│  │ Planner │ │ Budget │ │ Formatter │  │  → 业务逻辑
│  └─────────┘ └────────┘ └───────────┘  │
├─────────────────────────────────────────┤
│  Adapter Layer                          │  → 外部服务适配
│  ┌───────┐ ┌─────┐ ┌───────────────┐   │
│  │Weather│ │ Map │ │ Search (FlyAI)│   │
│  └───────┘ └─────┘ └───────────────┘   │
├─────────────────────────────────────────┤
│  Knowledge Layer                        │  → 知识库
│  City Packs │ Tips │ Common Know-how   │
├─────────────────────────────────────────┤
│  Output Layer                           │  → 输出格式
│  Markdown │ TripData JSON │ HTML        │
└─────────────────────────────────────────┘
```

---

## 2. 模块详解

### 2.1 Intent Router

**职责**：识别用户意图，路由到正确模块

| 输入 | 处理 | 输出 |
|------|------|------|
| 用户自然语言 | 关键词匹配 → 意图表 | 目标模块 + 上下文 |

**设计要点**：
- 可扩展的意图表
- 支持多意图拆分
- 上下文传递能力强

### 2.2 Planner Engine

**职责**：生成完整行程方案

| 子能力 | 说明 |
|--------|------|
| 景点组织 | 一天一区域，远近搭配 |
| 时间调度 | 考虑营业时间、休息节奏 |
| 路线优化 | 减少折返，交通便利 |
| 天气应对 | 户外点标记，备选室内 |

### 2.3 Budget Engine

**职责**：预算分析 + 三档方案

| 能力 | 说明 |
|------|------|
| 城市等级感知 | 自动识别消费水平 |
| 比例拆分 | 住宿/餐饮/交通/门票/备用 |
| 三档场景 | 保守/基准/乐观 |

### 2.4 Formatter

**职责**：统一输出格式

| 格式 | 用途 |
|------|------|
| Markdown | 对话回复 |
| TripData JSON | 结构化数据，前端消费 |
| HTML | 完整攻略页 |

---

## 3. 数据流

```
用户: "帮我规划杭州3天，预算3000"
          │
          ▼
    ┌──────────┐
    │  Router  │ → 意图: travel_plan + budget
    └────┬─────┘
         │
         ├──→ Planner Engine
         │      │
         │      ├──→ Knowledge: 杭州城市包
         │      ├──→ Planner: 行程规划 → route[]
         │      └──→ Output: TripData
         │
         └──→ Budget Engine
                │
                ├──→ 输入: 3000元, 3天, T2等级
                ├──→ 预算拆分 + 三档场景
                └──→ Output: budget{}
          │
          ▼
    ┌──────────┐
    │ Formatter│ → Markdown + TripData JSON
    └──────────┘
          │
          ▼
      用户回复
```

---

## 4. 适配器层（Adapter Layer）

### 适配器接口

```json
{
  "adapter_interface": {
    "name": "string",
    "type": "weather|map|search|transport",
    "capabilities": ["string"],
    "input_schema": {},
    "output_schema": {},
    "fallback_strategy": "cache|skip|alternative"
  }
}
```

### 标准适配器

| 适配器 | 能力 | 来源 |
|--------|------|------|
| Weather | 天气预报 | 任何天气 API |
| Map | 路线/POI | 任何地图服务 |
| Search | 酒店/机票/景点 | FlyAI 或类似 |
| Transport | 实时公交/地铁 | 任何公交数据 |

### 降级策略

```
主适配器失败 → 备用适配器 → 本地知识库 → 缓存 → 告知用户
```

---

## 5. TripData Schema

核心数据协议，任何前端都可消费。

详见 `schema/trip-data.json`。

**设计原则**：
- 自描述（字段注释完整）
- 渐进增强（基础字段必需，高级字段可选）
- 前端友好（可直接渲染）

---

## 6. 知识库设计

### 结构

```
knowledge/
├── china/
│   ├── cities/          # 城市知识包
│   ├── food/            # 地区美食
│   ├── culture/         # 本地文化
│   ├── travel/          # 旅行经验
│   └── avoid/           # 避坑指南
├── international/       # 国际
└── common/              # 通用
    ├── packing/         # 行李清单
    ├── health/          # 健康
    └── seasonal/        # 季节
```

### 贡献方式

1. Fork 仓库
2. 按 `knowledge/_template.md` 编写城市包
3. 提交 PR
4. 审核通过后合并

---

## 7. 模板引擎

### 接口

```html
<!-- 占位符语法 -->
{{CITY}}           ← 城市名
{{DAYS}}           ← 天数
{{DAYS_LOOP_START}} ← 循环开始
  {{DAY_NUM}}      ← 当天序号
  {{ACTIVITIES_LOOP}}
    {{TIME}}       ← 时间
    {{NAME}}       ← 活动名
  {{/ACTIVITIES_LOOP}}
{{/DAYS_LOOP_END}}
```

### 自定义主题

开发者可创建自己的 HTML 模板，只要包含必需的占位符即可。

---

## 8. 生态扩展

### 插件市场接口（预留）

```json
{
  "plugin_interface": {
    "name": "string",
    "version": "string",
    "author": "string",
    "triggers": ["string"],
    "permissions": ["read_knowledge"],
    "sandbox": "isolated"
  }
}
```

### 协作方向

- 🏙️ 城市包贡献（任何城市）
- 🔌 适配器贡献（任何数据源）
- 🎨 模板贡献（任何风格）
- 📐 Schema 扩展建议
- 🌐 多语言翻译

---

## 9. 路线图

| 版本 | 目标 |
|------|------|
| v0.1 | ✅ 核心架构 + 基础文档 |
| v0.2 | 社区城市包（10+ 城市） |
| v0.3 | 2-3 个适配器实现 |
| v0.4 | 插件接口稳定 |
| v0.5 | 多语言支持 |
| v1.0 | 生产就绪 |

---

*Last updated: 2026-07-19*
