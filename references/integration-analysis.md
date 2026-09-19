# 四组件整合分析

> 2026-07-18 产出。分析 FlyAI、trip-map-builder、旅行助手-CN、ComfyUI 四个组件的能力边界和整合方案。

## 能力矩阵

| 能力 | FlyAI | trip-map-builder | 旅行助手-CN | ComfyUI/web-map |
|------|:---:|:---:|:---:|:---:|
| 实时航班/酒店搜索 | ✅ 核心 | ❌ | ❌ | ❌ |
| 实时价格/预订链接 | ✅ 核心 | ❌ | ❌ | ❌ |
| AI 语义行程规划 | ✅ ai-search | ❌ | ❌ | ❌ |
| 行程地图 HTML | ❌ | ✅ Leaflet 模板 | ❌ | ✅ web-map 模板 |
| 大众点评/小红书调研 | ❌ | ✅ OpenCLI+CDP | ❌ | ❌ |
| 33 板块攻略写作 | ❌ | ❌ | ✅ 核心 | ❌ |
| 9 维美食深度 | ❌ | ❌ (仅点评信号) | ✅ 核心 | ❌ |
| 行李/健康/穿衣清单 | ❌ | ❌ | ✅ 核心 | ❌ |
| 批量城市操作 | ❌ | ❌ | ✅ 核心 | ❌ |
| Obsidian 输出 | ❌ | ❌ | ✅ 核心 | ❌ |
| 手绘地图生图 | ❌ | ❌ | ❌ | ✅ ComfyUI |

## 当前整合状态

ai-local-friend (V1.4) 已整合：
- ✅ FlyAI → flyai-adapter (航班/酒店/景点实时搜索)
- ✅ trip-map-builder → tripmap-adapter (行程地图 HTML 生成)
- ✅ 大众点评 → dianping-adapter (美食调研)
- ✅ 小红书 → xhs-adapter (美食调研)

**未整合**：
- ❌ 旅行助手-CN 的 33 板块攻略写作
- ❌ 旅行助手-CN 的 9 维度美食方法论
- ❌ 旅行助手-CN 的行前准备（行李/健康/穿衣/季节）
- ❌ ComfyUI 手绘地图生图

## 整合方案（三阶段）

### Phase 1：吸收旅行助手-CN 方法论（核心）

新增模块：
- **Guide Writer Engine** — 33 板块模板 + 9 维美食差异化 + Obsidian 写入
- **Preparation Engine** — 行李清单 + 健康评估 + 穿衣指南 + 季节指南
- 增强 **Food Engine** — 叠加 9 维度分类框架（早餐/面食/硬菜/夜市/酒水/甜点/时令/伴手礼/文化）

迁移参考文件（7 个）：
- packing-list.md, health-assessment.md, seasonal-guide.md
- dressing-guide.md, city-guide-template.md, food-section-template.md
- city-food-differentiation.md

### Phase 2：ComfyUI 生图串联（锦上添花）

- 新增 ComfyUI Adapter，调用已有城市手绘地图工作流
- 输出从"对话+地图+攻略"升级为"对话+地图+攻略+手绘图"

### Phase 3：批量操作增强

- 旅行助手-CN 的批量城市流程对接到 ai-local-friend 的 delegate_task

## 8 步分析与 FlyAI 绑定

旅行助手-CN 的 8 步分析可直接绑定 FlyAI 实时 API：

| 分析步骤 | FlyAI 命令 | 知识库 |
|---------|-----------|--------|
| 天气 | (联网搜索) | seasonal-guide.md |
| 景点 | `search-poi --city-name --category` | — |
| 交通 | `search-flight` / `search-train` | — |
| 住宿 | `search-hotel` / `ai-search` | — |
| 美食 | `keyword-search` + 9 维框架 | city-food-differentiation.md |
| 治安 | (联网搜索) | — |
| 地区特点 | — | health-assessment.md |
| 行李 | — | packing-list.md |

## 完整数据流（以"三亚5天"为例）

```
用户: "帮我规划三亚5天旅行"
  ↓
Router → travel_plan
  ↓
信息收集（4拍提问：人数/预算/偏好/健康）
  ↓
8步并行搜索：
  ├─ FlyAI search-flight 南昌→三亚
  ├─ FlyAI search-hotel 三亚海景
  ├─ FlyAI search-poi 三亚沙滩海岛
  ├─ FlyAI ai-search "三亚5天预算3000"
  ├─ 知识库 health-assessment → 7月防暑
  └─ 知识库 packing-list → 个性化行李
  ↓
路线规划（trip-map-builder 方法论）
  ↓
美食调研（dianping + xhs adapters → 9维分类）
  ↓
四路输出：
  ├─ 对话总结（四拍格式）
  ├─ 交互地图 HTML
  ├─ Obsidian 攻略（33板块 + 9维美食）
  └─ 手绘地图 PNG（ComfyUI）
```

## 不改的独立组件

- FlyAI skill — 通用飞猪搜索工具，独立维护
- trip-map-builder skill — 独立行程地图工具，独立维护
- 旅行助手-CN skill — 保留为独立 skill，ai-local-friend 只吸收方法论
- ComfyUI skill — 通用生图能力，不动
