# 第三方许可证审计报告

> 审计日期：2026-07-20
> 审计范围：`E:\AI Projects\travel-skill-repo\` 完整工作目录

## 一、项目中的第三方代码

### assets/lib/ — JavaScript 库本地回退（5 文件，共 ~1MB）

| 文件 | 版本 | License | 版权持有者 | 允许重新分发 | 需保留版权声明 |
|------|------|---------|-----------|------------|--------------|
| `leaflet.js` | 1.9.4 | BSD-2-Clause | © 2010-2023 Vladimir Agafonkin, CloudMade | ✅ | ✅ |
| `leaflet.css` | 1.9.4 | BSD-2-Clause | © 2010-2023 Vladimir Agafonkin, CloudMade | ✅ | ✅ |
| `maplibre-gl.js` | 4.7.1 | BSD-3-Clause | © MapLibre contributors | ✅ | ✅ |
| `maplibre-gl.css` | 4.7.1 | BSD-3-Clause | © MapLibre contributors | ✅ | ✅ |
| `leaflet-maplibre-gl.js` | 0.0.22 | MIT (推断) | © MapLibre contributors | ✅ | ✅ |

**合规状态**：✅ 所有文件头部已包含原始版权注释。
- `leaflet.js` 第 1 行：`/* @preserve ... (c) 2010-2023 Vladimir Agafonkin, (c) 2010-2011 CloudMade */`
- `maplibre-gl.js` 第 1-3 行：`@license 3-Clause BSD ... https://github.com/maplibre/maplibre-gl-js/blob/v4.7.1/LICENSE.txt`

### openfreemap/ — 地图瓦片服务完整源码（155 文件，~2.2MB）

| 属性 | 值 |
|------|-----|
| 来源 | `https://github.com/hyperknot/openfreemap.git` |
| License | MIT |
| 版权持有者 | © 2023 Zsolt Ero |
| 用途 | HTML 模板引用其公开瓦片服务 `tiles.openfreemap.org` |
| 是否需要分发源码 | **否** — HTML 只需 URL 引用，不需要服务端代码 |

**合规状态**：⚠️ 该目录是完整 git clone，不应提交到本仓库。
- **建议**：加入 `.gitignore`，在 `README.md` 中以链接形式引用（`https://github.com/hyperknot/openfreemap`）

### 地图样式 — CDN 运行时加载

| 样式 | License (代码) | License (设计) | 来源 |
|------|---------------|---------------|------|
| Liberty | BSD-3-Clause | CC BY 4.0 | `openmaptiles/osm-liberty` fork from Mapbox Open Styles |
| Positron | BSD-3-Clause | CC BY 4.0 | `openmaptiles/positron-gl-style` derived from CartoDB (CC BY 3.0) |

**合规状态**：✅ 运行时通过 CDN 加载，不包含在分发中。CC BY 4.0 要求在合适位置署名，建议在 HTML 水印或 README 中添加 `地图样式 © OpenMapTiles (CC BY 4.0)`。

### 地图数据 — OpenStreetMap

| 数据 | License | 要求 |
|------|---------|------|
| OpenStreetMap 地图数据 | ODbL 1.0 | 署名 `© OpenStreetMap contributors` |

**合规状态**：✅ MapLibre GL / OpenFreeMap 自动在底图显示 attribution。

### 字体 — Google Fonts (CDN)

| 字体 | License |
|------|---------|
| Noto Sans SC | SIL Open Font License 1.1 |

**合规状态**：✅ 运行时通过 `fonts.googleapis.com` CDN 加载，SIL OFL 允许嵌入网页。

## 二、不在项目中的运行时依赖（用户自行安装）

| 工具 | License | 调用方式 | 项目中的存在形式 |
|------|---------|---------|----------------|
| FlyAI CLI | MIT | `flyai search-hotel ...` | `references/flyai-adapter.md`（调用说明） |
| Serper API | 商业 | AgentKey 代理调用 | `references/api-adapters.md`（调用说明） |

这些工具是**运行时依赖**，不属于项目分发包。用户需自行安装。项目仅包含调用文档。

## 三、已弃用/移除的依赖

| 组件 | 状态 | 说明 |
|------|------|------|
| TripMap (opencli) | ❌ 已弃用 | `references/tripmap-adapter.md` 标注已弃用，无源码残留 |
| JustOneAPI | ❌ 不可用 | 注册已关门，token 拿不到。文档仅供参考 |
| Spider_XHS | ❌ 不采用 | 需要 Python+Cookie 维护，与 skill 零依赖设计矛盾 |

## 四、Git 追踪状态

| 路径 | 状态 | 建议 |
|------|------|------|
| `openfreemap/` | 未追踪 | 🔴 加入 `.gitignore`，不改分发 |
| `assets/lib/` | 未追踪 | 🟡 提交（合法本地回退）+ `LICENSE.md` 加声明 |
| `template.html` | 未追踪 | 🔴 必须提交（核心交付物） |
| `15天上海深度游攻略.html` | 未追踪 | 🟡 移至 `examples/` 目录或移除 |
| `assets/map-template.html` | 未追踪 | 🟡 与 template.html 去重后决定 |
| `assets/test-cdn.html` | 未追踪 | 🟢 移除或移至 `tests/` |

## 五、推荐 LICENSE.md 补充内容

```markdown
## 第三方依赖声明

本项目的 HTML 模板引用了以下第三方库（运行时通过 CDN 加载，
`assets/lib/` 提供离线回退副本）：

| 库 | 版本 | License | 版权 |
|----|------|---------|------|
| Leaflet | 1.9.4 | BSD-2-Clause | © 2010-2023 Vladimir Agafonkin, CloudMade |
| MapLibre GL JS | 4.7.1 | BSD-3-Clause | © MapLibre contributors |
| maplibre-gl-leaflet | 0.0.22 | MIT | © MapLibre contributors |
| OpenFreeMap 瓦片服务 | — | MIT | © 2023 Zsolt Ero |
| Liberty/Positron 样式 | — | BSD-3 + CC BY 4.0 | © OpenMapTiles |
| Noto Sans SC 字体 | — | SIL OFL 1.1 | © Google |

地图数据 © OpenStreetMap contributors (ODbL)

运行时依赖（需用户自行安装）：
- FlyAI CLI (MIT) — 酒店/机票/景点搜索
```

## 六、待办事项（优先级排序）

1. 🔴 `template.html` CDN 从 unpkg 改为 jsdelivr
2. 🔴 `template.html` 提交到 git
3. 🔴 `openfreemap/` 加入 `.gitignore`
4. 🟡 `LICENSE.md` 添加第三方声明章节
5. 🟡 `assets/lib/` 提交到 git
6. 🟢 双模板统一为一份数据契约
