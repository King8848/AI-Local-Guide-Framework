
# Open Source Extraction Log

> 2026-07-19 — 商业版 (AI Local Friend) → 开源版 (AI Travel Skill Core) 抽离记录

---

## 目标

创建独立的开源版本 `AI Travel Skill Core`，目标受众：
1. AI Agent 开发者（即插即用旅行模块）
2. 旅游行业伙伴（TripData 标准协议 + 适配器接口）
3. Skill 作者（城市包贡献体系 + 模板引擎扩展）

**商业核心能力保留在 `E:\AI Projects\travel-skill-repo\`。**

---

## 执行步骤

### 1. 梳理原项目 `E:\AI Projects\travel-skill-repo\` 的全量内容

确认 34 个 references 文件 + 2 个 HTML 模板 + 知识库结构。

### 2. 识别抽离 / 排除边界

**可抽离（开源版）**：
- Skill 架构设计（Router/Planner/Formatter 模块化流程）
- 通用旅游规划框架（行程规划/路线组织/预算框架/偏好系统）
- TripData Schema（标准 JSON 协议）
- 简单 Demo HTML 模板（CSS 变量换肤）
- 知识包编写模板 + 城市示例

**必须排除（私有）**：
- 暗色玻璃态高级 HTML 模板（V2.0, 1192 行）
- Apple 风模板（533 行）
- 完整商业城市攻略库
- FlyAI API 适配器实现代码
- 大众点评/小红书调研工作流
- MapLibre GL + OpenFreeMap 完整集成细节
- ComfyUI 手绘地图流程
- Personal AI OS 接口体系
- 熟客纯吃模式 HTML 变体
- `scripts/inline-cdn.ps1`（私有工具）
- 两页布局/悬浮地图/预算嵌入详细规范

### 3. 创建目录

```
AI-Travel-Skill-Core/
├── LICENSE.md           # MIT
├── README.md            # 生态入口
├── SKILL.md             # Agent 入口
├── CONTRIBUTING.md      # 贡献指南
├── docs/
│   ├── architecture.md  # 系统架构
│   └── template-engine.md
├── references/
│   ├── router.md
│   ├── planner.md
│   ├── budget.md
│   ├── formatter.md
│   └── workflow.md
├── schema/
│   └── trip-data.json
├── templates/
│   └── demo.html         # 简单 Demo（CSS 变量）
├── examples/
│   └── sample-output.md
└── knowledge/
    ├── china/cities/
    │   ├── _template.md
    │   ├── 杭州.md
    │   └── 成都.md
    ├── international/
    │   ├── _template.md
    │   └── tokyo.md
    └── common/
        ├── travel/tips.md
        ├── health/general.md
        ├── packing/checklist.md
        └── seasonal/seasons.md
```

### 4. 关键设计决策

| 决策 | 原因 |
|------|------|
| TripData JSON Schema 用 JSON Schema draft-07 | 生态通用，可被任何工具校验 |
| 模板引擎用 `{{PLACEHOLDER}}` 语法 | 与主流模板引擎一致 |
| 知识包分国内/国际两个模板 | 国内用中文 markdown；国际用英文 |
| 开源版 README 面向三类受众 | 开发者 / 行业 / Skill 作者 |
| Demo 模板只含 CSS 变量 | 不绑定任何前端框架，零依赖 |
| 城市示例选杭州、成都、东京 | 覆盖：新一线/美食之都/国际城市 |
| SKILL.md 触发词中英文兼容 | 国际开发者也能用 |

### 5. 与原项目的单向依赖关系

```
AI Local Friend (商业版)
    │
    ├── 引用 AI Travel Skill Core 的 TripData Schema
    ├── 扩展高级适配器 + 深度知识库
    ├── 使用高级 HTML 模板（暗色/Apple 风）
    └── 保留私有工作流（浏览器调研/FlyAI/Map）
```

开源版 **绝不反向引用** 商业版的任何私有内容。商业版改进 TripData Schema 时应当同步更新开源版（如 Schema 变更）。

---

## 关键文件来源对照

| 开源版文件 | 原始来源 | 处理方式 |
|-----------|---------|---------|
| `references/router.md` | `travel-skill-repo/references/router.md` | 简化：移除多意图拆分、模糊匹配细节 |
| `references/planner.md` | `travel-skill-repo/references/planner.md` | 提取通用原则，移除城市等级系数表 |
| `references/budget.md` | `travel-skill-repo/references/budget.md` | 保留基础框架，移除具体价格基准 |
| `references/formatter.md` | `travel-skill-repo/references/formatter.md` | 新增 Markdown + TripData + HTML 三模式 |
| `references/workflow.md` | `travel-skill-repo/references/workflow.md` | 保留四拍格式，移除 Context Guard 私有引用 |
| `schema/trip-data.json` | 无（新建） | 新建完整 JSON Schema |
| `templates/demo.html` | 无（新建） | 新建简单 Demo（CSS 变量换肤） |
| `knowledge/china/cities/_template.md` | `travel-skill-repo/references/knowledge-base.md` 中模板部分 | 提取模板，移到独立 city pack 模板 |
| `knowledge/china/cities/杭州.md` | 无（新建） | 示例城市（验证模板可用性） |
| `knowledge/china/cities/成都.md` | 无（新建） | 示例城市 |
| `knowledge/international/tokyo.md` | 无（新建） | 国际城市示例 |

---

## 后续工作

- [ ] 推送到 GitHub（独立仓库）
- [ ] 补充 10+ 个社区城市包
- [ ] 添加 2-3 个适配器实现（天气、搜索）
- [ ] 翻译全项目为多语言
- [ ] 商业化转 MIT 许可证确认

---

*Logged: 2026-07-19*
