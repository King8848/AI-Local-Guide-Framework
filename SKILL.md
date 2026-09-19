---
name: ai-local-friend
display_name: "AI 地陪（AI Local Friend）"
description: "像当地朋友一样陪伴旅行的 AI 综合助手。采用 Router + Module + Knowledge + API 四层架构，整合 FlyAI 实时搜索、自适配交互地图、大众点评/小红书美食调研、旅行助手-CN 攻略写作、ComfyUI 手绘地图。"
tags: [travel, ai, router, open-source]
---

# AI 地陪（AI Local Friend）

## 产品定位

**每到一座陌生城市，都有一个懂这里的朋友陪你。**

AI Local Friend 不是旅游攻略生成器，不是旅游搜索引擎，不是导游，更不是客服。

它是一个**像当地朋友一样陪伴旅行的 AI 综合助手**。

### 🔴 Skill 范式：这是指令文档，不是可运行软件

**AI Local Friend 是一份 skill（技能包 / 指令文档），不跑后端、不维护数据库、不运行代码。**

| 维度 | 传统的软件应用 | AI Local Friend（skill） |
|------|--------------|------------------------|
| 运行环境 | 服务器 / 客户端 | AI Agent 自带的浏览器/CLI 工具 |
| 数据存储 | 自有数据库 / 缓存 | 零 — 全部依赖知识库 + 实时调用 |
| 代码运行 | Python/Node 服务端 | **零代码运行** — 只写调用指令 |
| 数据获取 | API 调用 / 爬虫 | Agent 的 `browser_navigate` / CLI |
| 维护者 | 运维团队 | 内容编辑（知识库）+ 指令调优 |

**这意味着**：

- "数据源" = **告诉 AI Agent 去哪找**，不是 API endpoint / 数据库连接
- "API 适配器" = **Agent 工具的使用说明书**，不是代码模块
- 所有 `references/api-adapters.md` 里写的"大众点评适配器""小红书适配器"，本质上都是：**"请用 browser_navigate 打开这个 URL，然后提取这些信息"**
- 拒绝需要 Python/Cookie/签名维护的爬虫方案（如 Spider_XHS）——与 skill 零依赖设计矛盾

**判断标准**：如果一个"数据源方案"需要用户安装软件、维护 Cookie、关注签名更新，那它就不适合这个 skill。

---

## 触发条件

- "帮我规划旅行"
- "XX城市有什么好玩的"
- "去XX吃什么"
- "XX天气如何"
- "附近有什么"
- "修改路线"
- "今天下雨"
- "一个人旅行"
- "预算XX"
- "去过很多次XX" / "主要去吃" / "不要推荐网红店"

### 自驾出行模式

当用户提到"自驾"、"开车去"、"停车"等信号时，激活**自驾出行模式**。此模式下：
- 必须计算并展示：高速费（0.45元/km）、油费、往返总交通成本
- 每个景点必须给出停车方案（停车场名称+费用+步行距离）
- 演唱会/大型活动：车停酒店不动，地铁去场馆（查末班车时间）
- 返程夜间驾驶必须提醒安全事项（至少停一次服务区休息）
- 详见 `references/self-driving-trip-planning.md`

### 跟团游行程单模式

当用户**发来一份旅行社跟团行程单文件**（.md/.pdf/.docx，含"一车一导""宿火车上""集合/散团点""购物点""自费耳麦/景交""经济型酒店"等字段）时，激活**跟团游行程单模式**。此模式下：

- **旅程由旅行社定，AI 只做"置景"，不做"重排"**——景点固定、集合/散团点固定、车程固定。不能像自驾/自由行那样改顺序、换景点、给停车方案。
- **先判定跟团 vs 自由行 vs 自驾**（切忌按用户"喜欢自驾"等既有偏好误套模式）：
  - 跟团：`一车一导`、`宿：火车上`、`集合/散团`、`购物点`、`自费耳麦+景交`、门票`减免梯度表`（60/65/70 岁）
  - 自由行：可重排路线 + 优化住宿/停车
  - 自驾：额外给高速费（0.45元/km）/油费/停车方案（见自驾模式）
- **从行程单提取关键字段**：行程天数/D1-Dn、每日含餐（早/午/晚 0 或 ✓）、住宿参考酒店、自费项（耳麦 130/景交 190）、购物点、门票免票梯度、车程时长、重要提示（预约/老人陪护/不可抗力）。
- **交付物（用户要求"可视化"时）**：基于官方行程做交互 HTML 置景——顶部概况卡 + 地图串 7 天景点线 + 每天一张"行动卡"（含景点/时间/vlog 镜头/美食）；不自编购物/自费顺序。
- 完整解析清单与"豫见山西"示例见 `references/group-tour-itinerary.md`

### 熟客纯吃模式

当用户触发「去过很多次 + 主要去吃 + 不玩」信号时，激活**熟客纯吃模式**。此模式下：
- 跳过城市介绍、景点推荐、酒店推荐（用户比你还熟）
- 100% 篇幅聚焦美食，**严格排除网红店**
- 输出结构：D1/D2 片区吃程 + 9 维度美食索引 + 预算 + 避坑
- 详见 `references/repeat-visitor-food-mode.md`

---

## 核心架构

采用 **Router + Module + Knowledge + API 四层解耦架构**。

```
用户输入
    │
    ▼
Intent Router（意图识别）
    │
    ├── travel_plan → Planner Engine
    ├── local_life → Local Friend Engine
    ├── food → Food Engine
    ├── companion → Travel Companion Engine
    ├── emotion → Emotion Engine
    └── budget → Budget Engine
    │
    ▼
Knowledge Layer（知识库检索）
    │
    ├── 开源知识库（本地/社区贡献）
    ├── 扩展知识库（预留接口）
    │
    ▼
API Layer（按需联网调用）
    │
    ├── WeatherProvider → QWeather / Open-Meteo
    ├── MapProvider → 高德地图 API（POI/周边/路线/停车场）
    ├── SearchProvider → FlyAI Adapter / Serper
    ├── POIProvider → Map Generator / 高德地图
    ├── ReviewProvider → 大众点评/小红书 Adapter
    └── TransportProvider → FlyAI search-train/flight
    │
    ▼
Formatter（统一输出）
    │
    ▼
最终回复用户
```

---

## 设计原则

| 层级 | 职责 | 禁止 |
|------|------|------|
| Router | 意图识别、模块调度 | 直接回答问题 |
| Module | 业务逻辑处理 | 直接调用 API、存储知识 |
| Knowledge | 知识存储与检索 | 负责推理 |
| API | 实时数据获取 | 负责业务逻辑 |
| Formatter | 统一输出格式 | 负责决策 |

---

## 模块列表

| 模块 | 文件 | 职责 |
|------|------|------|
| Router | `references/router.md` | 意图识别、模块路由 |
| Planner | `references/planner.md` | 行程规划（1/3/5/7 天） |
| Local Friend | `references/local-friend.md` | 本地生活、小众玩法、避坑 |
| Companion | `references/companion.md` | 实时陪伴、路线调整 |
| Food | `references/food.md` | 餐饮推荐（必须说明理由） |
| Budget | `references/budget.md` | 预算优化、高性价比方案 |
| Emotion | `references/emotion.md` | 情绪价值、鼓励、陪伴 |
| Formatter | `references/formatter.md` | 统一输出格式 |

---

## 知识库设计

```
knowledge/
├── china/
│   ├── cities/          # 城市文化、景点、避坑
│   ├── food/            # 地区特色美食
│   ├── culture/         # 本地文化、民俗
│   ├── travel/          # 旅行经验
│   └── avoid/           # 避坑指南
├── international/
│   ├── japan/
│   ├── korea/
│   ├── thailand/
│   ├── malaysia/
│   └── singapore/
└── common/
    ├── packing/         # 行李清单
    ├── health/          # 健康评估
    └── seasonal/        # 季节指南
```

---

## API 适配器设计

| 适配器 | 来源 | 调用方式 | 许可证 | 状态 |
|--------|------|---------|--------|------|
| **高德地图** | 高德 Web API | REST API 调用（PowerShell Invoke-WebRequest） | 高德开放平台 | ✅ 已实现（POI搜索/周边搜索/停车场/美食/酒店） |
| FlyAI | flyai-cli | CLI 调用 | MIT | ✅ 已实现 |
| JustOneAPI | REST API | REST API 调用 | Proprietary | ❌ 注册关门，token 拿不到 |
| 大众点评 | Hermes browser | browser_navigate + snapshot | MIT | ✅ 已实现（主要硬信号源） |
| 小红书 | Hermes browser | browser_navigate + snapshot | — | ⚠️ 主方案（反爬时降级到 FlyAI/Knowledge） |
| ComfyUI | comfy-cli + REST API | CLI + REST | MIT | ⏳ 待实现 (Phase 2) |

---

## 第三方能力集成原则

1. **保留各模块独立性** — FlyAI 保持独立项目
2. **不复制粘贴 Prompt** — 通过适配器调用 CLI 或知识内容
3. **使用统一接口封装** — Adapter Pattern
4. **保留原项目许可证与版权声明** — MIT
5. **AI 地陪负责统一调度** — 不直接暴露底层模块

---

## 启动时必读

**每次触发本技能，先读 `references/user-preferences.md`** — 其中记录了用户旅行风格、住宿选址、文案偏好和避坑清单。输出时必须与这些偏好对齐，不要凭通用经验猜测。

**同时读 `references/lessons-learned.md`** — 记录了历史踩坑（数据源超时、模板复用、坐标偏移、偏好理解等），每次开工前扫一遍，避免重复犯错。

---

## 🔴 上下文安全机制（Context Guard）

> **教训来源：2026-07-18 session `ff6cd1` — LongCat-2.0 在川西行程规划中丢失上下文，用户问"本地有什么美食"时回答了南昌美食。**

### 强制 Re-ground 规则

**每次回答用户消息、发起搜索、调用工具之前，必须先执行以下检查：**

```
1. 当前我服务的行程是什么？（城市/目的地/天数/人数）
2. 用户这句话在这个行程上下文中是什么意思？
3. 我的回答/搜索结果是否与行程上下文一致？
```

**不通过以上检查，禁止输出或调用工具。**

### 歧义词处理

以下词汇在旅行规划中有歧义，必须根据上下文解析：

| 歧义词 | 在旅行规划中的含义 | 错误理解 |
|--------|-------------------|---------|
| **本地** | = 目的地 / 当前行程所在城市 | ❌ 用户常驻城市（南昌） |
| **这边** | = 正在规划的行程区域 | ❌ 用户家乡 |
| **附近** | = 行程中当天的片区/酒店周边 | ❌ 用户家门口 |
| **回去** | = 返程交通 | ❌ 回家 |

### 上下文校验清单

每次回复前，在思考中自检：

- [ ] 我是否输出了 Re-ground？（告诉用户"我们在规划 XX 城市的 XX 天行程"）
- [ ] 我的回答是关于目的地城市的，不是用户家乡的？
- [ ] 我调用的 FlyAI 搜索关键词是针对目的地的，不是针对用户常驻地的？
- [ ] 搜索"本地美食"时，query 是否明确包含了目的地城市名？

### 模型选择

- **长对话旅行规划（3+ 轮交互）** → 优先使用 `deepseek-v4-pro`，上下文窗口大、稳定性高
- **LongCat-2.0** → 仅用于短对话测试（≤2 轮），或代码/文档类单次任务
- **如发现上下文漂移** → 立即 Re-ground，并在回复开头显式声明当前上下文

详见 `references/context-guard.md`

## 慢节奏规划模式（已验证有效）

用户不喜欢特种兵式打卡，以下是经用户确认的「慢节奏逛吃」模式：

**核心原则**：每天一个片区，步行可达，不跨区跑。景点只是散步的理由，重点是沿途吃、喝茶、看人间烟火。

**适用场景**：用户说"慢慢逛"、"逛逛"、"不赶时间"、"感受生活"时激活此模式。

**片区规划模板**：
| 天 | 选片逻辑 | 步行半径 |
|----|----------|----------|
| D1 | 住地所在片区（如住玉林就逛玉林） | < 5km |
| D2 | 距住地1-2个地铁站的文艺/潮流片区 | 地铁+步行 |
| D3 | 收尾日，含必去景点+住地附近收尾 | 灵活 |

**每日节奏**：
- 上午 9:30 起，睡到自然醒
- 中午 茶/咖啡 + 散步 > 坐下来正餐
- 下午 景点穿插美食
- 晚上 夜市/火锅收尾

---

## 用户交互规范

### 四拍格式

所有需要用户决策的提问统一遵循：**Re-ground → Simplify → Recommend → Options**

| 拍 | 做什么 | 为什么 |
|----|--------|--------|
| **Re-ground** | 告诉用户"你在哪" | 用户可能 20 分钟没看屏幕了 |
| **Simplify** | 用大白话说清在问什么 | 不用术语 |
| **Recommend** | 给一个明确推荐 + 理由 | 降低决策负担 |
| **Options** | 2–4 个可点击选项 | label 自解释 |

### 输出规范

- 先价值，后提问（先推荐旅行风格，再问天数/预算）
- 推荐理由必须说明（不是"推荐火锅"，而是"推荐原因：本地人多、排队少、价格合理"）
- 所有地址标注"建议出发前用高德确认"
- 统一 Markdown 格式：标题 + Emoji + 表格 + 列表

---

## MVP 边界

### V1 必须完成
- ✅ AI 地陪人格（Persona）
- ✅ 旅行规划（1/3/5/7 天）
- ✅ 本地生活推荐
- ✅ 旅行风格选择
- ✅ 实时陪伴
- ✅ 国际热门国家 Lite
- ✅ 联网能力（天气/地图/搜索/点评/交通）
- ✅ 基础知识库
- ✅ 统一输出格式
- ✅ 插件市场接口预留

---

## 插件市场接口（V1 预留）

```json
{
  "plugin_interface": {
    "name": "string",
    "version": "string",
    "author": "string",
    "description": "string",
    "triggers": ["string"],
    "on_trigger": "function(input)",
    "output_format": "markdown",
    "min_api_version": "1.0.0",
    "permissions": ["read_knowledge", "call_api", "write_cache"],
    "lifecycle": {
      "on_install": "function()",
      "on_uninstall": "function()",
      "on_enable": "function()",
      "on_disable": "function()",
      "on_update": "function(old_version, new_version)"
    },
    "security": {
      "sandbox": "isolated|shared",
      "network_access": "none|local_only|allowed_domains[]",
      "file_access": "none|read_only|read_write",
      "max_memory_mb": 128,
      "max_execution_time_ms": 30000,
      "allowed_apis": ["string"],
      "data_retention": "session_only|persistent|user_consent"
    }
  }
}
```

| 生命周期钩子 | 触发时机 |
|-------------|---------|
| `on_install` | 插件首次安装 |
| `on_uninstall` | 插件被移除 |
| `on_enable` | 插件被启用 |
| `on_disable` | 插件被禁用 |
| `on_update` | 插件版本升级 |

| 安全字段 | 说明 |
|---------|------|
| `sandbox` | isolated（独立沙箱）/ shared |
| `network_access` | none / local_only / allowed_domains |
| `file_access` | none / read_only / read_write |
| `max_memory_mb` | 最大内存 128MB |
| `max_execution_time_ms` | 单次最长 30s |
| `allowed_apis` | API 白名单 |
| `data_retention` | session_only / persistent / user_consent |

## 开源双轨策略（2026-07-19 验证）

> Commercial (闭源商业版) 与 Open Source (开源核心版) 的分离原则。

### 两个项目

| 项目 | 路径 | 定位 |
|------|------|------|
| **AI Local Friend (商业版)** | `E:\AI Projects\travel-skill-repo\` | 私家商业能力：高级 HTML 模板、私有知识库、深度适配器、实时数据集成 |
| **AI Travel Skill Core (开源版)** | `E:\AI Projects\AI-Travel-Skill-Core\` | 公开生态入口：架构设计、TripData Schema、基础模板、知识包模板 |

### 开源版能包含 / 必须排除

| 类别 | 开源版 (AI Travel Skill Core) | 商业版 (AI Local Friend) |
|------|------------------------------|--------------------------|
| ✅ Skill 架构设计（Router/Planner/Formatter 模块化流程） | ❌ |
| ✅ TripData Schema（JSON Schema 标准协议） | ❌ |
| ✅ 通用旅游规划框架（行程原则/预算框架/偏好系统） | ❌ |
| ✅ 简单 Demo HTML 模板（CSS变量换肤） | ❌ |
| ✅ 知识包编写模板 + 城市示例（杭州/成都/东京） | ❌ |
| ❌ | 高级 HTML 模板（暗色玻璃态/Apple风/动画效果） |
| ❌ | 双模板架构（1192行 V2.0 + 533行 Apple风） |
| ❌ | 完整商业城市攻略库（30+ 城市） |
| ❌ | FlyAI API 适配器实现细节 |
| ❌ | 大众点评/小红书调研流程 |
| ❌ | MapLibre GL + OpenFreeMap 完整集成 |
| ❌ | ComfyUI 手绘地图流程 |
| ❌ | Personal AI OS 接口体系 |
| ❌ | Personal AI OS 四级权限系统 |
| ❌ | 详细 HTML 输出规范（两页/悬浮地图/预算嵌入） |
| ❌ | 熟客纯吃模式变体 |

### 开源版 README 定位

面向三类受众：
1. **AI Agent 开发者** — 即插即用的旅行模块
2. **旅游行业伙伴** — TripData 标准协议 + 适配器接口
3. **Skill 作者** — 城市包贡献体系 + 模板引擎扩展

### 执行要点

1. 开源版独立仓库，独立 README/SKILL.md/文档/示例
2. 商业版引用开源版作为基础框架（单向依赖）
3. 开源版不包含任何私有数据或商业 UI 设计
4. 知识包模板国际标准（国内用markdown/国际用英文）
5. TripData Schema 是跨项目数据契约——两个版本的输出都必须符合它

详细操作记录见 `references/open-source-extraction.md`。

---
唯一 workspace：E:\AI Projects\travel-skill-repo\    ← git 仓库，项目代码
    ├── SKILL.md / README.md / LICENSE.md
    ├── references/（34 个 .md）
    ├── assets/
    │   ├── template.html          ← Apple 风模板（已追踪）
    │   └── lib/                   ← 第三方 JS 库本地回退（5文件/1MB）
    ├── template.html              ← V2.0 暗色模板（⚠️ 未追踪，需提交）
    ├── 新模板/
    │   ├── travel-control-template.html  ← 🆕 JSON 驱动控制中心模板（单文件，坐标转换已修复）
    │   ├── travel-handbook/              ← 卡片堆栈手册模板
    │   └── index.html                    ← 控制中心入口
    └── knowledge/（3 城起步）

框架文档：Obsidian 开源库 12-框架文档/
    E:\ObsidianRe\AI Local Friend (Open Source)\12-框架文档\
    ├── 00-README.md（索引）→ 产品圣经/白皮书/系统架构/工作流/...
    └── 共 13 份完整框架设计文档

开发参考：走 Obsidian，不动 workspace。
```
### 开发后同步清单

**每次 AI Local Friend 开发会话结束后，必须完成以下两项同步**。这是 07-18 session 最大的教训——07-17 开发了 28 个 skill 文件 + 19 个 Obsidian 笔记，但框架文档一个字没更新、log.md 一个字没写，隔天补录丢掉了大量细节。

### 1. 框架文档同步

检查 Obsidian 开源库 `12-框架文档/` 中 13 份文档是否反映最新状态：

| 文件 | 何时更新 | Obsidian 路径 |
|------|---------|--------------|
| 00-README.md | 整体索引 | `AI Local Friend (Open Source)/12-框架文档/` |
| 产品圣经.md | 产品定位/价值变更 | 同上 |
| 白皮书.md | 技术架构变更 | 同上 |
| 03-系统架构.md | 模块增删/架构调整 | 同上 |
| 04-工作流.md | 交互流程变更 | 同上 |
| prompt&skill框架.md | Prompt/Router 设计变更 | 同上 |
| 06-Hermes开发指南.md | 部署/配置变更 | 同上 |
| 07-知识库设计.md | 知识库结构调整 | 同上 |
| 08-API设计.md | 适配器接口变更 | 同上 |
| MVP.md | MVP 边界变更 | 同上 |
| 10-路线图.md | 里程碑完成/调整 | 同上 |

### 2. Personal AI OS 第二大脑同步

- `log.md`（`Personal AI OS/log.md`）append 本次会话的操作记录
- `Operating Manual.md` 更新项目速查 + 最近动态
- AI Memory 新增 Lessons（踩坑）/ Solutions（方案）/ Patterns（模式）/ Decisions（决策）

**原则**：当日事当日毕。隔天补录 = 丢失细节。

---

## 常见坑

| 场景 | 教训 |
|------|------|
| **🔴 用户发来旅行社跟团行程单（2026-08-27 豫见山西）** | 跟团游 ≠ 自驾/自由行。识别信号：`一车一导`/`宿：火车上`/`集合散团点`/`购物点`/`自费耳麦130+景交190`/`经济型酒店`/门票`减免梯度表`。**跟团只能"置景"官方行程**（固定景点/车程，不能重排、不能改集合散团点、不能给停车方案）；只有自由行/自驾才可重排优化+停车。切忌按用户"喜欢自驾"偏好误套自驾模式。处理流程见 `references/group-tour-itinerary.md`。 |
| **🔴 上下文丢失：旅游规划中回答成家乡美食（2026-07-18 ff6cd1）** | **最严重的产品事故。** LongCat-2.0 在川西 7 天行程规划长对话中，用户问"本地有什么美食"→模型搜索并推荐了南昌美食。根因：①未强制 Re-ground；②"本地"歧义（目的地 vs 家乡）；③user-preferences 中 九龙湖/南昌 信息污染；④LongCat 长上下文不稳定。修复：新增 `🔴 上下文安全机制` 章节 + `references/context-guard.md` + user-preferences 免责声明。 |
| **🔴 开发后忘记同步框架文档和第二大脑** | 最严重的工作流缺陷。每次开发会话后必须检查 `开发后同步清单`。07-17 开发 28 文件却零记录，隔天补录已丢失大量细节。 |
| **🔴 项目目录散落多处** | 统一 workspace=`E:\\AI Projects\\travel-skill-repo\\`，框架文档放 Obsidian，删重复目录。三目录（ai-local-friend/skill + AI Local-skill + travel-skill-repo）合并为一个。 |
| 开源文档中出现"Pro版"/"付费"等字眼 | 禁止商业词汇，用"扩展能力（预留接口）"替代 |
| HTML 地图加载不出来 | **模板已用 `jsdelivr`，不要手写 `unpkg` 链接**。2026-07-18 完整验证结论：① MapLibre GL + OpenFreeMap Liberty 矢量瓦片（`tiles.openfreemap.org/styles/liberty`）✅ 国内可用，是首选方案；② `@maplibre/maplibre-gl-leaflet@0.0.22` 桥接库 ✅ 在 jsdelivr 上可用；③ 本地回退：库文件已下载到 `assets/lib/`（5 文件 1MB），CDN 不可用时用相对路径引用；④ 备选：Leaflet + OSM 栅格瓦片（`tile.osm.org`）。不用 CartoDB/ArcGIS（全超时）、不用 `unpkg.com`（被墙）。详见 `references/html-design-spec.md`。 |
| 小红书数据获取路径决策 | **数据源只有三个**：① Hermes 浏览器抓小红书（主方案，有反爬风险）② 大众点评浏览器（硬信号主力，反爬弱）③ 知识库兜底。JustOneAPI 已确认注册关门、token 拿不到，不可依赖。GitHub 上的 Spider_XHS 等爬虫工具需要 Python+Cookie+签名维护，与 skill 的零依赖设计矛盾，不推荐接入。降级链：`大众点评 → 小红书浏览器 → FlyAI ai-search → 知识库` |
| **🔴 项目本质理解偏差（2026-07-18）** | **最基础的概念错误。** 把 skill 当成"软件应用"来讨论——问"数据来源怎么做""没有API推荐怎么做"。实际上 skill 是一份**指令文档**，告诉 AI Agent "去哪个网页找信息"，不需要代码、数据库、后端。"数据源"= Agent 自带浏览器工具能访问的网页。任何需要安装/维护/登录的方案（爬虫、API token）都不适合。修复：新增 `🔴 Skill 范式` 章节。 |
| FlyAI 酒店价格被掩盖 | FlyAI `search-hotel` 在「体验模式」下返回 `¥2xx` 而非真实价格。适合做参考行程，必须在输出中提示用户出发前在飞猪/携程确认真实价格 |
| FlyAI 餐饮搜索偏差 | FlyAI `keyword-search` 搜索餐厅/美食时返回酒店套餐商品而非餐饮结果。**中文餐饮搜索请改用 `Serper/search`（`hl: "zh-cn"`）或浏览器抓取**，FlyAI 仅适合机票/酒店/火车票/景点类搜索 |
| Serper 中文搜索 | 搜索中文目的地攻略/餐饮时，`Serper/search` + `hl: "zh-cn"` 是最可靠的搜索路径，优于 FlyAI keyword-search |
| FlyAI 目的地混淆 | `search-hotel --dest-name "新都桥"` 可能返回康定城区的结果。不要强行纠正，在输出中标注"地址仅供参考，建议出发前用高德确认" |
| PowerShell `start` 不可用 | PowerShell 中 `start` 是 `Start-Process` 的别名，但常被 profile 错误干扰。打开本地 HTML 文件用 `Invoke-Item "路径"`，或直接用 `browser_navigate` |
| `flyai -f json` 报错 | `flyai` 不支持 `-f` 参数，直接运行命令即可返回 JSON |
| 模型选择不当导致质量下降 | LongCat 做文档/框架，DeepSeek 做代码/技术校验；遇到不合适的立即暂停切换 |
| 商业库直接修改开源代码 | 通过适配器/桥接层，不直接修改 |
| 双向链接导致商业内容暴露 | 开源不链接到私有库，单向依赖 |
| **🔴 偏好理解极化（2026-07-18）** | **把"不想天天吃甜"读成了"只吃辣"**。偏好是光谱不是开关：辣 60-70%/本帮原味 20-30%/偶尔甜点 10%。任何"不喜欢 X"≠"只要 Y"，中间地带永远存在。不确定时直接问用户是"完全排斥"还是"频率降低"。 |
| **🔴 拍照是核心需求不是附加项（2026-07-19）** | 用户明确说"想拍照+玩好+吃好"三者并列。**摄影是和美食、游玩同等重要的核心需求**，不能事后补充。必须在规划阶段就作为独立维度嵌入：每天至少规划 1-2 个出片点位，精确到**几点去、穿什么、怎么摆 pose**。如果行程写完发现没提拍照，说明规划失败了。详见 `references/photography-pose-guide.md`。 |
| **🔴 FlyAI 环境变量 = `FLYAI_API_KEY`（2026-07-19）** | FlyAI CLI 读取的环境变量是 `$env:FLYAI_API_KEY`，不是 `FLIGGY_KEY`。验证方法：`$env:FLYAI_API_KEY="sk-xxx"; flyai search-train ...` 解锁后价格从 `¥4xx` 变为 `¥468.00`（精确到配置）。配置位置：`%APPDATA%\\flyai\\.env` 或 PowerShell 临时变量。 |
| **🔴 攻略输出格式：默认 MD，不要 HTML（2026-07-19）** | 用户明确说"生成 md 文件就行，不用 HTML 文件"。旅行规划类交付物默认输出 `.md` 文件，不主动生成 HTML 模板。除非用户明确说"做成交互 HTML"或"生成可以发给手机的页面"。 |
| **🔴 按年龄层细化拍照建议（2026-07-19）** | 用户年龄段 "00后-10后" 的女生，拍照风格偏好自然/生活化，明确说"不拍写真"。Pose 建议应围绕：牵手背影、回眸、比ye、靠墙侧脸、逆光剪影等**生活化抓拍**，不要建议商业写真的"托腮看镜头""侧卧露出腰部"等摆拍。穿搭建议棉麻/碎花/草帽等日系/法式元素。 |
| **🔴 晚间活动偏好：轻度散步不是重度夜生活（2026-07-19）** | 用户说"晚上去逛逛吃东西一般般"= 晚间安排**轻度活动**即可。不需要每晚安排 Livehouse/酒吧/KTV。适合：台东夜市闲逛、海边散步、咖啡馆小坐。与"年轻人夜生活"偏好一样需要平衡。 |
| **🔴 海边活动排除游泳（2026-07-19）** | 用户明确说"不游泳但会海边"。海边行程规划：踩水踏浪、礁石拍照、沙滩漫步、悬崖散步。**不下海**，不安排海水浴场游泳时间，不推荐泳衣等装备。 |
| **🔴 住宿同性合住假设（2026-07-19）** | 问多人出行住宿时默认"要不要分开住"是错误的。正确默认：同性朋友 98% 合住一间，情侣 100% 合住。**按一间房算预算**，除非用户明确说"要分开住"。 |
| **🔴 多起点汇合规划模式（2026-07-19）** | 多人从不同城市出发到同一目的地汇合时，需要：① 用 FlyAI search-train 分别查各出发地到目的地的车次；② 优先选两地都能傍晚/晚间同时到达的车次组合；③ 汇合点建议选目的地火车站附近方便碰头，不另设汇合驿站；④ 住宿按"到达当晚就能入住一间房"规划。 |
| **🔴 把推荐=引导性消费（2026-07-18）** | **最大理念偏差。** 用户说"不引导性消费"≠不做推荐。AI Local Friend 的核心价值就是"推荐的店"+"推荐有理由"+"本地人视角"（排队王、本地人密度）。曾因怕推荐把餐厅信息退化成纯数据表，被纠正。推荐是天职，不是包装"客观"。 |
| **强化：FlyAI 分场景使用（2026-07-18）** | FlyAI `keyword-search` 搜索餐厅时返回酒店商品——**餐饮不用 FlyAI**。FlixAI **应该用**在：`search-hotel`（酒店价格）、`search-poi`（景点门票）、`search-flight`（机票）、`search-train`（火车票）。餐饮用 `Serper/search`（`hl:"zh_cn"`）+ 大众点评/小红书浏览器。**价格展示**：三源对比（FlyAI+Hostelworld+公开数据），始终给 min/max 区间不让单点估算。 |
| **🔴 MapLibre GL bridge 库加载失败（2026-07-18）** | ⚠️ **已过时！** 2026-07-18 二次验证：`@maplibre/maplibre-gl-leaflet@0.0.22` 在 jsdelivr 上 **加载正常**。之前的"bridge 加载失败"诊断是误判——真正原因是用 `unpkg.com` 被墙导致所有库都加载失败，不是 bridge 本身的问题。**降级策略只在 CDN 整体不可用时才触发**（离线/内网），此时用 `assets/lib/` 本地副本。判断标准：`browser_console` 清理 → 如果 Leaflet 本身（`typeof L`）都 undefined，说明 CDN 整体挂了，不是 bridge 问题。 |
| **🔴 HTML 地图白屏 → 不要丢掉模板重写（2026-07-18）** | **最大时间浪费。** HTML 地图加载不出时，第一反应是"模板有问题，自己写一个"。实际上 `template.html` 已经用了 `jsdelivr`（正确），问题出在手写代码时用了 `unpkg`。正确做法：① 先 diff 自己的 HTML 和模板的 CDN 链接；② `browser_console` 诊断是哪层加载失败；③ 修复（3 行 patch）≠ 重写（380 行）。通用法则：**任何"模板坏了"的判断，先 diff 定位差异行号，禁止"感觉不对就重写"。** |
| **HTML 发给手机 → 内联 CDN 为单文件（2026-07-18）** | 手机打开 HTML 时 CDN 可能不可用或慢。方案：用 `scripts/inline-cdn.ps1` 把 5 个外部 JS/CSS 全部内联到 HTML 中，生成一个 ~1MB 的完全自包含文件。微信/QQ/AirDrop 发送即可在手机浏览器打开。执行：`powershell -File scripts/inline-cdn.ps1 -TargetHtml "path/to/file.html" -LibDir "assets/lib/"`。注意：地图瓦片仍需网络（服务端渲染），无法内联。 |
| **🔴 navMenu.show CSS 作用域缺陷（2026-07-20）** | `#navMenu.show { display: block }` 写在 `@media (max-width: 768px)` 内，导致桌面端点击 🧭 图标时 JS 加了 `.show` class 但菜单不显示。**修复**：在桌面端 CSS（`@media` 外）单独加 `#navMenu { display: none; } #navMenu.show { display: block; }`。同理，所有移动端新增元素若有 `.show`/`.active` 类切换逻辑，必须在桌面端 CSS 也定义对应规则。 |
| **🔴 预算 UI 退化（2026-07-20）** | 多次 patch 同步后，预算「自定义试算」区从 `display:grid;grid-template-columns:1fr 1fr 1fr` 退化为 `display:flex;flex-wrap:wrap`，下拉框变窄、滑块变短、视觉不统一。**修复**：恢复 grid 三列等宽布局，select 加 `width:100%`，input[type=range] 加 `width:100%;accent-color:var(--accent)`，label 加 `display:block;font-size:.75em;color:var(--text-dim);margin-bottom:4px`。 |
| **🔴 项目未用 Git（2026-07-20）** | 用户指出「你做这个项目没开 git」。`travel-skill-repo` 项目从未初始化 git，所有改动无版本追踪，无法回滚。**修复**：`cd "E:\AI Projects\travel-skill-repo"; git init; git add .; git commit -m "init"`。之后每次功能改动都 commit，重大变更前 branch。 |
| **🔴 移动端优化严格隔离原则（2026-07-20）** | 用户明确要求「只改手机端，不动 template.html」「只改 15dayShangHaiTrip.html」「认可后才同步 git/模板」。**规则**：① 所有移动端 CSS 严格限制在 `@media (max-width: 768px)` 内；② 桌面端在 `@media` 外用 `display:none` 隐藏移动专有元素（`.map-tier-btn`/`#mapBubble`/`#navMenu`）；③ JS 通过 `isMobile()` 分叉——桌面走原逻辑，移动走新逻辑；④ 不碰桌面端按钮文字、`floatMapBtn` 显示逻辑、`minimizeMap` 等已有函数；⑤ 改动只在 `15dayShangHaiTrip.html` 验证，用户确认后才同步到 `template.html` 和 git。 |
| **🔴 模板 CDN 矛盾（2026-07-20 审计发现）** | `html-design-spec.md` 和常见坑都写「用 jsdelivr，不用 unpkg」，但 **`template.html`（V2.0 暗色模板）第 9-10 行仍用 `unpkg.com`**。只有 `assets/template.html`（Apple 风模板）用了 `jsdelivr`。每次基于 V2.0 模板生成新城市攻略，需要手动把 CDN 从 unpkg 改为 jsdelivr。**必须修复**：`template.html` 的 CDN 链接替换为 `cdn.jsdelivr.net`。 |
| **🔴 悬浮窗地图+导航菜单（2026-07-20 实现）** | 移动端地图从全屏 bottom sheet 改为小米悬浮窗式：3档缩放（□ 按钮循环 35vh/55vh/78vh）、顶栏拖拽（touch+mouse）、最小化成浮球（− 按钮）、浮球吸边（松手自动吸附 左/右边缘）、点击浮球恢复。新增导航菜单系统：点地图 POI 标记→弹气泡「🧭 导航到这里」→弹出菜单（高德/百度/腾讯/Apple Maps/Google Maps/geo:系统选择/复制地址）。时间线每个地址旁加 🧭 图标触发同样的导航菜单。`geo:` 协议兜底支持任意已装地图App。两个模板（`template.html` + `15dayShangHaiTrip.html`）同步。 |
| **🔴 范围失控：改多了用户没要求的部分（2026-07-21）** | **最大工作态度偏差。** 用户说"地图左上角固定图标依旧未删除"，我只删除 `map-content` 就够了。但实际上顺手删了 `map-attribution`、CSS 里的 `.map-label/.map-coord/.map-city`/响应式 `-label` 规则的引用——用户多次提醒"只改要求改的，其他部分不用动"。正确做法：① 每次接到修改需求，先字面解读——用户说了什么就改什么，不多删不多加；② 代码中有"看似相关"的元素（如 CSS 中残留的类名）不影响功能时不要主动清理，用户没要求就当不存在；③ 如果觉得某些代码应该清理，先问"这个要删吗？"而非擅自删除。这个错误在 session 中至少犯了 3 次，每次都让失望。 |
| **🔴 patch 锚点误匹配：JS 插入 CSS `<style>` 块（2026-07-21）** | 用 `patch` 工具往 HTML 插入 JS 代码时，`old_string` 锚点（如 `/* ==== DAY CARDS ==== */`）在 CSS 上下文中匹配，导致新 JS 被插入到 `<style>` 标签内而非 `<script>` 中。结果：CSS 块内含 `function`/`const` 语法，整个样式表失效。**预防**：① 插入 JS 代码时，确保 `old_string` anchor 在 `<script>` 上下文中唯一；② 更安全：用 `write_file` 写 Python 脚本做 `str.replace()`，完全避免 V4A 工具的锚点漂移问题；③ 插入后立刻 grep 检查 `<style>` 块内是否出现 `function` 或 `const` 关键字。 |
| **🔴 V4A patch 工具在 HTML 文件中反复转义失败（2026-07-20）** | 当 `patch` 工具的 `new_string`/`old_string` 包含 `\"` 或 `\\` 时，频繁报 `Escape-drift detected` 或 `No match found`。根因：patch 工具对 HTML 中的双引号实体内联转义规则与 JSON 序列化不一致。**解决方案**：涉及 HTML 文件（含大量 `\"` 的 JS 模板字符串）的大段替换，直接用 Python 脚本 `open(path).read()` → `str.replace()` → `open(path,'w').write()` 三步走，不走 patch 工具。小段替换（纯 CSS、无转义字符）仍可用 patch。判断标准：如果替换内容超过 10 行且含 `\"` → 直接写 Python 脚本。 |\n| **🔴 HTML 旅行产品设计规范（2026-07-20）** | 新增 `references/html-travel-product-design.md` — 执行导向的 HTML 旅行产品交互设计规范。核心原则：首页=控制中心、Day卡片=行动卡、地图强联动、减玻璃强层级、变量集中管理。包含控制中心组件结构、今日卡片渐变、行动按钮模式、模板变量规范。 | `template.html` 的 `calcFullBudget` 和 `renderBudgetTab` 函数体内有 `*{{DAYS}}` 和 `住宿 {{DAYS}}晚`，这些是合法占位符但直接打开模板会导致 JS 错误（`{{DAYS}}` 不是合法 JS）。验证模板效果前必须先替换占位符（`{{DAYS}}`→数字、`{{CITY}}`→城市名）。测试数据注入脚本：`python -c "c=open('template.html').read(); c=c.replace('{{DAYS}}','2').replace('{{CITY}}','测试'); ... open('template.html','w').write(c)"`。验证完后 `git checkout template.html` 恢复。 | 用户要求"只优化移动端、不修改原界面"。实际执行中错误地把 `toggleMap()` 替换成了依赖 `mapBubble` 的全局版本、在 `@media` 外用 `display:none !important` 隐藏了桌面端地图按钮。**正确做法**：① 所有 CSS 改动严格限制在 `@media (max-width: 768px)` 内，桌面端在 `@media` 外用 `display:none` 隐藏移动专有元素（`.map-tier-btn`/`#mapBubble`/`#navMenu`），移动端在 `@media` 内用 `display:X !important` 覆盖；② JS 函数通过 `function isMobile(){return window.innerWidth<=768}` 分叉——桌面走原逻辑（`floatMapBtn`），移动走新逻辑（`mapBubble`）；③ 绝对不碰桌面端按钮文字、`floatMapBtn` 显示逻辑、`minimizeMap` 等已有函数；④ **关键 CSS 作用域教训**：移动端新增的元素若有 `.show` 类切换逻辑（如 `#navMenu.show{display:block}`），必须同时在桌面端 CSS（`@media` 外）定义 `.show` 规则，否则 JS 加了 class 也不会显示。改动清单：CSS 只加不改原规则；HTML 只加新元素不删旧元素；JS 只在函数体内加 `if(isMobile())` 分支。 |
| **🔴 双模板架构 + 数据契约不兼容（2026-07-20 审计发现）** | 项目存在两套完全不同的模板：① `template.html`（V2.0 暗色玻璃态，1192行，数据契约 `dayRoutes`+`daysData`+`guideModules`）② `assets/template.html`（Apple 风浅色，533行，数据契约 `HOTEL`+`DAYS[]`）。数据结构不同，无法用同一份数据生成两种风格。预算/清单标签页的 HTML 硬编码在 JS 函数体内（`renderBudgetTab`/`renderChecklistTab`），非纯数据注入。**这意味着 AI 每次生成攻略必须手工写预算表格和清单 HTML，无法脚本化批量灌入。** 详见 `references/html-design-spec.md` 已知问题章节。 |
| **🔴 Git 追踪缺口 + 许可证合规（2026-07-20 审计）** | `git status` 显示以下文件全部未追踪：① `template.html`（核心交付物！）② `assets/lib/`（5 个第三方 JS 库，1MB）③ `openfreemap/`（完整 clone，155文件/2.2MB）。`openfreemap/` 不应提交到本仓库（应放入 `.gitignore` 并改为 README 引用链接）。`assets/lib/` 是合法本地回退但缺版权声明——Leaflet BSD-2、MapLibre GL BSD-3、maplibre-gl-leaflet MIT 均要求保留版权声明。`LICENSE.md` 需添加第三方依赖声明章节。详见 `references/license-audit.md`。 |
| **🔴 入口页面遗漏模板（2026-07-20）** | 创建根目录 `index.html` 入口页时，只写了 `template.html` 链接，漏了 `assets/map-template.html`。正确做法：创建入口页前先 `search_files(pattern="*.html", target="files")` 扫描所有 `.html` 文件（含子目录），全部加入链接列表。本项目至少有两个模板：`template.html`（暗色攻略，1192行）+ `assets/map-template.html`（亮色地图，533行）。每个项目的入口页都应列出所有可独立访问的 HTML，不能假设只有一个。 |
| **HTML 输出规范：四标签页+悬浮地图（2026-07-18）** | 交互 HTML 分四个标签页——「旅行行程」：15天逐日行程（AI Local Friend 推荐人格）；「城市旅游攻略」：9 模块城市百科；「💰 预算」：住宿/景点/餐饮/交通表格 + 自定义试算器（min/max区间+多源对比）；「📋 清单」：行前勾选+避坑+骗局+APP。布局：左目录(可拖拽)+中内容+悬浮地图窗口(可拖拽/缩放/最小化)。无右栏、无左下角常驻面板。地图联动：点击段标题→flyTo POI，点击天→路线连线+POI标记。详细规范见 `references/html-design-spec.md`。 |
| **🔴 FlyAI 推广者模式：代理持有 Key，开源项目零暴露（2026-07-19）** | 作为飞猪推广者集成 API 到开源项目时，采用**代理模式**：开源项目只写调用逻辑 + `.env.example` 模板，代理服务持有 `FLYAI_API_KEY`。两种路径：用户自备 Key 填 `.env`，或通过推广者的 `FLYAI_PROXY_URL` 调用。**Key 禁止硬编码在代码/前端/CLI 公开示例中**。收益来源：酒店 + 度假商品佣金（交通类不参与）。推广流程：申请入驻 → 获取 Key → 配置至 Skill → 用户购买 → 佣金归因 → 提现。详见 `references/flyai-affiliate-proxy.md`。 |
| **🔴 高德 API Key 安全（2026-07-23）** | 高德地图 Web API 的 key 是用户个人凭证，**禁止硬编码在开源项目/前端代码中**。调用方式：PowerShell 中直接拼入 URL 参数（仅限本地 skill 内部使用）。如需在 HTML 模板中使用高德 JS API，必须通过代理模式或让用户自备 key 填入 `.env`。 |
| **🔴 演唱会/活动停车策略（2026-07-23）** | 自驾看演唱会的停车核心策略：**车停酒店不动，地铁去场馆**。原因：①场馆周边散场堵车 30-60 分钟；②停车场爆满找不到位；③散场后找车+出停车场+上高速至少多花1小时。必须提前查地铁末班车时间（如南京10号线 23:22），如果散场晚于末班车则提前约网约车。 |
| **🔴 「模板太繁琐」≠ 砍功能（2026-08-27）** | 用户说某模板/HTML「太长太繁琐」时，**不要理解成"砍掉功能做精简版"**。用户真实意思是：代码层面别那么重（Tailwind 运行时、天气动画等），但**功能结构必须保留**——tab 分页（找东西方便）、地图、POI 导航、清单勾选，这些正是"用起来方便、找也方便"。曾把「旅行控制中心」大模板砍成长滚动精简页，被用户批「**你这个精简的太难用了**」。正确做法：保留 tab + 地图 + 清单结构，只替换真正繁琐的实现（纯 CSS 替 Tailwind browser、OpenFreeMap 替 CartoCDN）。用户说"用起来方便、找也方便" = 要分页/导航，不是长滚动。**动手前先问「是复刻原模板功能、只是代码更干净」还是「砍功能」，别自作主张精简。** |
| **🔴 tab 重映射必须核对「标签 ↔ 渲染函数」（2026-08-27）** | 复用控制中心模板改 tab（行程/清单/预算/指南 → 行程/美食/费用/Vlog）时，标签文字和它调用的 render 函数极易错位。曾把「Vlog」标签指向预算 donut、「费用」标签指向 Vlog 运镜，被用户当场发现「**vlog 的内容和费用的内容搞反了**」。改 tab 要动**四处**——① button 标签+图标 ② 内容 div ③ `switchTab()` 数组与 render 调用 ④ render 函数体；漏一处/映射错一处就错位。改完**必须逐一点开每个 tab 核对**：显示内容 == 标签语义。 |

---

## 支持文件

所有参考文件位于 `references/`：

- `persona.md` — AI 人设与行为准则
- `planner.md` — Planner Engine（行程规划）
- `local-friend.md` — Local Friend Engine（本地生活）
- `companion.md` — Travel Companion Engine（实时陪伴）
- `food.md` — Food Engine（美食推荐）
- `budget.md` — Budget Engine（预算优化，含 T1-T4 城市等级差异化）
- `emotion.md` — Emotion Engine（情绪价值）
- `formatter.md` — Formatter（统一输出规范）
- `workflow.md` — 用户交互工作流（四拍格式）
- `knowledge-base.md` — 知识库设计
- `api-adapters.md` — API 适配器层（含错误处理/超时/降级/熔断/健康检查）
- `integration-analysis.md` — 四组件整合分析
- `flyai-adapter.md` — FlyAI 适配器
- `map-generator.md` — 🆕 自适配交互地图生成器
- `dianping-adapter.md` — 大众点评适配器
- `xhs-adapter.md` — 小红书适配器
- `flight-search.md` — FlyAI 机票搜索详细参数
- `hotel-search.md` — FlyAI 酒店搜索详细参数
- `poi-search.md` — FlyAI 景点搜索详细参数
- `train-search.md` — FlyAI 火车票搜索详细参数
- `keyword-search.md` — FlyAI 关键词搜索详细参数
- `ai-search.md` — FlyAI AI 语义搜索详细参数
- `travel-planning-workflow.md` — 8 步分析流程
- `dianping-research.md` — 大众点评调研流程
- `xhs-research.md` — 小红书调研流程
- `dressing-guide.md` — 穿衣建议
- `city-guide-template.md` — 33 板块城市攻略模板
- `food-section-template.md` — 9 维度美食板块模板
- `packing-list.md` — 行李清单
- `seasonal-guide.md` — 季节与目的地特殊提示
- `health-assessment.md` — 健康状况与旅行适配
- `user-preferences.md` — 用户偏好与写作规范
- `context-guard.md` — 🆕 上下文安全机制（事故复现+预防模式+校验清单）
- `justoneapi.md` — 🆕 JustOneAPI 适配器（小红书/抖音/B站等30+平台 REST API，替代浏览器直连）
- `batch-workflow.md` — 批量操作流程
- `data-source-validation.md` — 🆕 数据源链路验证记录（2026-07-18 实测结果）
- `long-duration-planning.md` — 🆕 长途旅行规划模式（7天+）
- `html-design-spec.md` — HTML 攻略输出规范（两页布局/地图/价格区间）
- `i18n-framework.md` — 🆕 国际化框架（中英双语切换，国内零改动）
- `code-quality-linter-results.md` — 代码质量审计记录（openfreemap clone）
- `photography-pose-guide.md` — 🆕 拍照需求处理模式（风格识别→点位匹配→穿搭→pose细化→融入行程）
- `repeat-visitor-food-mode.md` — 🆕 熟客纯吃模式（去过多次、只要吃、不要网红店）
- `open-source-extraction.md` — 🆕 开源双轨策略抽离记录（2026-07-19）
- `license-audit.md` — 🆕 第三方许可证审计报告（2026-07-20）
- `flyai-affiliate-proxy.md` — 🆕 FlyAI 推广者代理架构（2026-07-19）
- `html-travel-product-design.md` — 🆕 HTML 旅行产品交互设计规范（控制中心/行动卡/减玻璃/模板化）
- `amap-api-guide.md` — 🆕 高德地图 API 集成指南（POI搜索/周边搜索/酒店美食停车场查询/照片URL）
- `self-driving-trip-planning.md` — 自驾出行规划（停车策略/高速费/油费/夜间驾驶安全/演唱会停车）
- `public-apis-integration.md` — Public-APIs 仓库可用 API 集成参考（天气/地图/摄影/路线）
- `self-driving-concert-template.md` — 🆕 自驾+活动组合规划模板（信息收集清单/时间线锚定/停车策略/返程倒推）
- `vlog-camera-guide.md` — 🆕 Vlog 相机拍摄指南（通用运镜/按场景分类/拍照模式/后期建议）
- `rainy-day-plan.md` — 🆕 雨天备案标准模板（户外→室内替换/雨中更好场景/各城市室内替代）
- `weather-based-outfit.md` — 🆕 穿衣建议天气联动模板（温度分档/天气特殊处理/拍照颜色搭配）
- `packing-list-scenarios.md` — 🆕 行李清单场景化模板（自驾/高铁/飞机/演唱会额外物品）
- `highway-service-guide.md` — 🆕 高速服务区自动规划模板（休息频率/服务区选择/查询方法）
- `data-source-attribution.md` — 数据来源标注规范
- `flyai-cli-guide.md` — FlyAI CLI 使用指南
- `self-driving-planning.md` — 自驾出行规划（停车策略/高速费/油费/夜间驾驶安全）
- `group-tour-itinerary.md` — 🆕 跟团游行程单处理（判定跟团vs自由行vs自驾、关键字段提取、豫见山西示例）

所有脚本位于 `scripts/`：

- `inline-cdn.ps1` — 🆕 CDN 内联脚本：将 HTML 中所有外部 JS/CSS 引用替换为内联内容，生成移动端可用的单文件。用法：`powershell -File inline-cdn.ps1 -TargetHtml "file.html" -LibDir "assets/lib/"`

---

## 开发效率原则

遇到「重写还是修复」的选择时，直接判断哪个成本低速度快质量高就做。

- **优先修复**（patch/补全）而非重写（write 全量）
- 除非修复的锚点定位成本超过重写
- 本项目 07-18 session 验证：15 个文件全部补全/修复，零重写

| 版本 | 日期 | 变更 |
|------|------|------|
| V1.33 | 2026-07-23 | **JSON 驱动控制中心模板**：新增 `新模板/travel-control-template.html`——基于旅行控制中心的单文件模板，数据完全 JSON 驱动（`<script id="trip-data">` 块），AI 只需替换 JSON 即可生成个性化旅行页面。修复 POI 导航坐标问题：新增 WGS-84→GCJ-02/BD-09 坐标转换函数，高德/腾讯用 GCJ-02、百度用 BD-09、Apple 用原始 WGS-84。模板顶部有完整 HTML 注释文档说明使用方法。 |
| V1.32 | 2026-07-23 | **通用模板体系**：新增 6 个标准模板——`self-driving-concert-template.md`（自驾+活动组合规划）、`vlog-camera-guide.md`（Vlog 相机拍摄指南）、`rainy-day-plan.md`（雨天备案）、`weather-based-outfit.md`（穿衣建议天气联动）、`packing-list-scenarios.md`（行李清单场景化）、`highway-service-guide.md`（高速服务区自动规划）。每个模板都带「信息收集清单」，确保规划时不漏问。 |
| V1.31 | 2026-07-23 | **高德地图 API 集成**：新增 `references/amap-api-guide.md` — 完整的高德 Web API 使用指南（关键词搜索/周边搜索/POI详情/照片URL/PowerShell 调用模板）。API 适配器表新增高德地图（POI搜索/周边搜索/停车场/美食/酒店）。实战验证：南京奥体中心 20+ 景点、20+ 餐厅、15+ 停车场、20+ 酒店实时查询。 |
| V1.30 | 2026-07-23 | **自驾出行模式**：新增触发词"自驾/开车去/停车"→激活自驾模式。新增 `references/self-driving-trip-planning.md`（停车策略/高速费计算/油费估算/夜间驾驶安全/演唱会停车专项）。新增 `references/public-apis-integration.md`（从 GitHub public-apis 仓库筛选出的旅行可用 API：Open-Meteo/Sunrise-Sunset/openrouteservice/Remove.bg 等）。常见坑新增「演唱会/活动停车策略」。 |
| V1.29 | 2026-07-21 | **工作态度纠正**：用户多次提醒"只改要求改的，其他部分不用动"。新增常见坑「🔴 范围失控」——先字面解读需求，不多删不多加，清理残留代码前先问用户。 |
| V1.28 | 2026-07-21 | **初级模板全面迁移**：地图引擎从 Leaflet+高德栅格 → MapLibre GL+OpenFreeMap Liberty，POI 与旅行进度联动（已完成绿色/未探索白色，opacity 0.95 小点点）。新增"极简 POI 风格"+"setData 实时刷新"模式。`references/map-integration.md` 新增极简 POI 章节。用户确认"只保留小点点，去掉 emoji/标签"。 |
| V1.27 | 2026-07-21 | **精简轻量版模板上线**：新增 `新模板/初级模板.html`（Leaflet + 时间线行程 + 天气卡 + 进度追踪），长沙 2 天纯吃攻略首用。`html-design-spec.md` 新增「模板复制指南」+「通用模块」章节。`html-travel-product-design.md` 新增模板体系表格（完整功能/精简轻量/适配版）。天气模块（Open-Meteo + 城市名 + 实时时间）确认为通用能力。 |
| V1.26 | 2026-07-19 | **FlyAI 推广者代理模式**：新增常见坑「推广者模式：代理持有 Key，开源项目零暴露」+ `references/flyai-affiliate-proxy.md`。开源版集成飞猪 API 时采用代理模式，Key 仅限服务端/CLI 使用，禁止暴露于前端代码。 |
| V1.22 | 2026-07-20 | 移动端响应式设计：新增 3 断点响应式系统（≤768px 手机 / 769–1024px 平板 / >1024px 桌面）。侧边栏→左滑抽屉，地图→底部全屏，标签栏→横向滚动。template.html + 15dayShangHaiTrip.html 均已同步。html-design-spec.md 新增完整移动端响应式设计章节（CSS 完整片段 + HTML 骨架 + JS 抽屉函数 + 验证清单）。 |
| V1.21 | 2026-07-20 | 入口页遗漏模板与扫描规范：新增常见坑。修复 index.html 遗漏 assets/map-template.html。创建入口页前必须 search_files(pattern="*.html") 扫描全部。 |
| V1.20 | 2026-07-19 | **入口页面设计规范**：新增 `references/html-design-spec.md` 入口页面章节，涵盖 `file://` 兼容性验证、CDN graceful degradation、双主题共存模式（不取消另一个）、触发条件。修复根目录缺少 `index.html` 的问题。 |
| V1.19 | 2026-07-19 | **开源双轨策略**：商业版 (AI Local Friend) 与开源版 (AI Travel Skill Core) 分离。新增开源双轨策略章节。TripData Schema 作为跨项目数据契约。详细抽离记录见 `references/open-source-extraction.md`。 |
| V1.18 | 2026-07-20 | **第三方审计 + 架构文档**：新增常见坑「模板 CDN 矛盾」「双模板架构」「Git 追踪缺口+许可证合规」。项目结构章节更新（两套模板并存、assets/lib/）。新增 `references/license-audit.md` 第三方许可证审计。`html-design-spec.md` 新增「已知问题」章节（数据分离度、CDN 修复待办、规模化瓶颈）。 |
| V1.15 | 2026-07-18 | **CDN + HTML 地图实战修正**：SKILL.md 常见坑「HTML 地图加载不出来」修正 — CDN 改用 `jsdelivr`（`unpkg` 国内被墙），方案优先级重排（Leaflet+OSM > MapLibre GL+OpenFreeMap > 高德）。新增「MapLibre GL bridge 库加载失败」坑 + 降级策略。新增「熟客纯吃 HTML：3 标签页变体」坑。`repeat-visitor-food-mode.md` 补全 HTML 输出变体章节（CDN/地图库/结构/验证步骤）。 |
| V1.13 | 2026-07-18 | **UI 交互收尾**：侧边栏 header 按钮组重构（header-actions flex 布局替代绝对定位）、PDF 导出功能(@media print + exportPDF)、html-design-spec 补全（打印/国际化/按钮组）。session 完整闭合：上海攻略从 markdown 到交互 HTML 全流程。 |
| V1.11 | 2026-07-18 | **UI 全面升级**：模板 V2.0（暗色玻璃态+圆润卡片+微动效）。`user-preferences.md` 补全夜生活/年轻人偏好、移除城市特定引用、添加「推荐的店」措辞规范。`html-design-spec.md` V3→V4：设计语言规范（Noto Sans SC/阴影系统/动画/自定义控件）。水印左下角淡雅文字。 |
| V1.10 | 2026-07-18 | **地图方案修正**：Leaflet+CartoDB 栅格瓦片在国内全部超时，替换为 MapLibre GL + OpenFreeMap 矢量瓦片（Liberty 风格）。更新 `references/html-design-spec.md`（V1→V2）：悬浮地图交互模式、POI 点击飞行、路线连线、预算嵌入底栏、最小化按钮跟随。两页名改「旅行行程」「城市旅游攻略」。常见坑地图条目纠正。 |
| V1.9 | 2026-07-18 | **三大理解偏差修正**：① 偏好理解极化 — "不想天天吃甜"≠"只吃辣"，偏好是光谱不是开关；② 年轻人夜生活 — 22:00收工太早；③ 推荐≠引导性消费 — AI Local Friend 的核心就是推荐有理由+本地人视角。新增 `html-design-spec.md`（两页布局/地图/价格区间规范）。常见坑去重 + 强化 FlyAI 分场景指南。 |
| V1.8 | 2026-07-18 | **长途旅行规划模式**：新增 `references/long-duration-pl.md` — 7天+行程的三段式模板（市区深度+周边短途+离岛收尾）、换片区住宿决策、中间休整日规则。常见坑新增 `FlyAI 餐饮搜索偏差`（keyword-search 搜索餐厅返酒店商品，需改用 Serper/search）和 `Serper 中文搜索`。15天上海+长三角攻略实战验证。 |
| V1.7 | 2026-07-18 | **架构清理**：移除 trip-map-builder 依赖，替换为自适配交互地图生成器。地图底板切换 OSM 栅格 → OpenFreeMap 矢量瓦片（MapLibre GL）。POIProvider 改为 Map Generator。**数据源决策**：JustOneAPI 确认注册关门（token 拿不到），小红书回归浏览器方案为主，降级链：大众点评 → 小红书浏览器 → FlyAI → 知识库。Spider_XHS 等爬虫工具与 skill 零依赖设计矛盾，不推荐。 |
| V1.6 | 2026-07-18 | **上下文安全机制**：ff6cd1 事故修复。新增 `🔴 上下文安全机制` 章节（强制 Re-ground、歧义词表、上下文校验清单、模型选择指导）+ 新增 `references/context-guard.md`（事故复现+预防模式）+ `user-preferences.md` 增补免责声明。常见坑首条新增。 |
| V1.5 | 2026-07-18 | 整合分析：四组件能力矩阵 + Phase 1-3 整合方案。新增 `integration-analysis.md`（FlyAI/旅行助手-CN/ComfyUI 能力矩阵+8步分析绑定+数据流设计）。适配器表增加 ComfyUI + 状态列。 |
| V1.4 | 2026-07-18 | 项目目录大统一：三目录合为 workspace `travel-skill-repo`，框架文档全迁 Obsidian `12-框架文档/`，删重复。新增项目结构章节、开发效率原则、常见坑新增目录散落教训。 |
| V1.3 | 2026-07-18 | Review 技术债清零：补 9 个 FlyAI/TripMap 参考文件、API 适配器错误处理(超时/降级/熔断)、预算城市四级差异化(T1-T4)、插件接口生命周期+安全字段 |
| V1.2 | 2026-07-18 | 新增开发后同步清单（框架文档 + 第二大脑），防止高强度开发后遗忘记录 |
| V1.1 | 2026-07-17 | 开源纯净性规则强化，商业语言清零，CDN 修复 |

---

*Skill version: 1.32*