# HTML 攻略输出规范（V4）

> 来源：2026-07-18 上海 15 天攻略完整迭代验证
> 通用模板：`E:\AI Projects\travel-skill-repo\template.html` — 替换 `{{CITY}}` + 填三个数据数组即可
> 模板版本：V2.0（暗色玻璃态 + 圆润卡片 + 微动效）

## 设计语言

| 元素 | 规范 |
|------|------|
| 字体 | Noto Sans SC（Google Fonts），更好的中英文渲染 |
| 卡片 | `backdrop-filter: blur` 玻璃态，圆角 `12px` |
| 阴影 | 4 级阴影系统（sm/md/lg/xl）|
| 背景 | 微妙径向渐变纹理（`radial-gradient` 暖色光晕）|
| 动画 | `fadeInUp` 卡片入场（逐级延迟）、`pulse` 时间线圆点脉冲 |
| 滑块 | 自定义 `<input type="range">` 样式（accent-color 配色）|
| 勾选框 | 自定义方形 + 绿色填充 + 白色对勾 |
| 水印 | 左下角淡雅小字：AI生成仅供参考 + AI Local Friend 出品 |

## 布局：两栏 + 悬浮地图

- **左栏**（220px 可拖拽）：行程目录（跟随标签页切换）
- **中栏**（自适应）：四个标签页
- **悬浮地图**：右下角浮窗，可拖拽/缩放/最小化。最小化时圆形按钮跟随窗口位置
- **无右栏**、**无左下角常驻面板**

## 四标签页设计

| 标签 | 名字 | 内容 | 风格 |
|------|------|------|------|
| ✈️ | 旅行行程 | 15 天逐日行程 | AI Local Friend：推荐有理由、慢节奏、夜生活 |
| 📖 | 城市旅游攻略 | 9 个模块城市百科 | 旅行助手-CN：表格对比、完整地址/本地人密度 |
| 💰 | 预算 | 住宿/景点/餐饮/交通表格 + 自定义试算器 | min/max 区间，多源对比 |
| 📋 | 清单 | 行前勾选清单 + 避坑 + 骗局 + APP | 可勾选、有对策 |

## 切页行为

```js
function switchTab(t){
  // ... tab切换逻辑 ...
  if(t!=='follow') toggleMap(false); // 切到非行程页 → 地图隐藏
  renderContent();
}
```

**地图只存在于「旅行行程」页**，切换到城市攻略/预算/清单时自动消失，视觉不遮挡。

## 地图：MapLibre GL + OpenFreeMap 矢量瓦片

🔴 **不要用 Leaflet + 栅格瓦片** — CartoDB/OSM/ArcGIS 国内全部不稳定。

正确方案：
- 库：`maplibre-gl@4.7.1` + `@maplibre/maplibre-gl-leaflet@0.0.22` via `cdn.jsdelivr.net`
- 瓦片：`https://tiles.openfreemap.org/styles/liberty`（矢量 .pbf，免费无需 key，✅ 2026-07-18 实测国内可用）
- 备选：高德瓦片 `webrd01.is.autonavi.com`（零配置最快）

### 国内 CDN 注意事项

| CDN | 国内可用 | 备注 |
|-----|---------|------|
| `unpkg.com` | ❌ 被墙 | **不要用** |
| `cdn.jsdelivr.net` | ✅ | 全部库均通过此 CDN 加载 |

### 本地化回退方案

当 CDN 不可用（离线/内网环境），可将库文件下载到 `assets/lib/`：

```
assets/lib/
├── leaflet.css          (15 KB)
├── leaflet.js           (148 KB)
├── maplibre-gl.css      (65 KB)
├── maplibre-gl.js       (803 KB)
└── leaflet-maplibre-gl.js (10 KB)
```

HTML 引用改为相对路径：

```html
<link rel="stylesheet" href="assets/lib/leaflet.css">
<script src="assets/lib/leaflet.js"></script>
<link href="assets/lib/maplibre-gl.css" rel="stylesheet">
<script src="assets/lib/maplibre-gl.js"></script>
<script src="assets/lib/leaflet-maplibre-gl.js"></script>
```

> 💡 `assets/lib/` 已于 2026-07-18 下载完毕，5 个文件共约 1 MB，可直接复制到任何生成目录使用。

## 移动端悬浮窗地图（2026-07-20 V2 实现）

> 替代 V1 的全屏 bottom sheet 方案（100vw×70vh 过于粗暴）。改为小米悬浮窗式，支持 3 档缩放 + 拖拽 + 最小化浮球 + 吸边。

### 操作逻辑

| 按钮 | 作用 | 行为 |
|------|------|------|
| 📍 | 定位 | `maplibregl.GeolocateControl` 获取用户位置 |
| □ | 缩放 | 循环 3 档：35vh(紧凑) → 55vh(标准) → 78vh(展开) → 35vh |
| − | 最小化 | 窗口隐藏，48px 浮球 🗺️ 出现 |
| × | 关闭 | 等于最小化（隐藏窗口，显示浮球） |

### 3 档高度

```css
#floatMap { height: 55vh !important; }         /* 默认标准 */
#floatMap.tier-compact { height: 35vh !important; }
#floatMap.tier-expanded { height: 78vh !important; }
```

JS 通过 `MAP_TIERS=['','tier-compact','tier-expanded']` 和 `mapTierIdx` 循环切换 class。

### 拖拽（桌面 + 手机）

顶栏 `#floatMapHeader` 绑定 `mousedown` + `touchstart`，`mousemove` + `touchmove` 更新 `left/top`，`mouseup` + `touchend` 恢复 transition。

```javascript
hdr.addEventListener('touchstart', start, {passive: false});
```

关键：`passive: false` 允许 `preventDefault()` 防止页面滚动。

### 最小化浮球 + 吸边

```css
#mapBubble {
  width: 48px; height: 48px; border-radius: 50%;
  background: var(--accent);
  transition: left 0.3s cubic-bezier(0.22,0.61,0.36,1);
}
#mapBubble.snap-left { left: 0 !important; border-radius: 0 50% 50% 0; }
#mapBubble.snap-right { left: calc(100vw - 48px) !important; border-radius: 50% 0 0 50%; }
```

浮球可拖拽到任意位置，松手后自动吸边：
- 松手位置 < 屏幕一半 → 吸左边缘（`snap-left`）
- 松手位置 ≥ 屏幕一半 → 吸右边缘（`snap-right`）
- 吸边后半圆形状，露出 48px 可点击区域

浮球点击恢复地图窗口。如果手指移动 < 3px 才触发恢复（拖动 > 3px 说明是拖拽操作）。

## 导航菜单系统（2026-07-20 实现）

> 替代旧的 `map-jump` 快捷栏（高德/百度/腾讯底部固定链接）。改为 POI 气泡 + 时间线 🧭 图标触发，支持任意已装地图 App。

### 触发入口

| 入口 | 位置 | 触发方式 |
|------|------|---------|
| 地图 POI 标记 | 点击地图上彩色圆点 | 弹气泡「🧭 导航到这里」按钮 → 点击弹出菜单 |
| 时间线 🧭 图标 | 每个行程地址右边 | 点击直接弹出菜单 |

### 菜单结构

```
┌─────────────────────────┐
│ 📍 导航到「静安寺」       │
├─────────────────────────┤
│ 🚗 高德地图   iosamap:// │  ← uri.amap.com/navigation
│ 🗺️ 百度地图   baidumap://│  ← api.map.baidu.com/direction
│ 🗺️ 腾讯地图   qqmap://  │  ← apis.map.qq.com/uri/v1/routeplan
│ 🍎 Apple Maps (仅iOS)   │  ← maps.apple.com
│ ⚪ Google Maps          │  ← google.com/maps/dir
│ ─────────────────────── │
│ 📱 其他地图App... 系统选择│  ← geo:lat,lng?q=name
│ 📋 复制地址             │  ← navigator.clipboard.writeText()
└─────────────────────────┘
```

### 关键技术决策

- **`geo:` 协议作为万能兜底**：`geo:lat,lng?q=名称` 会触发系统弹出 "用哪个地图打开" — 支持华为花瓣地图、高德地图极速版等任何已装地图 App，不需要逐个适配
- **Apple Maps 仅 iOS 显示**：通过 `/iPhone|iPad|iPod/.test(navigator.userAgent)` 检测，Android 端隐藏
- **菜单居中弹出**：`left:50%; top:50%; transform:translate(-50%,-50%)`，点击菜单外任意位置自动关闭
- **复制地址兜底**：当所有地图都不可用时（如桌面端无地图 App），至少可以复制地址文字

### HTML 结构

```html
<div id="navMenu">
  <div class="nav-title" id="navMenuTitle">📍 导航到此处</div>
  <a class="nav-item" id="nav-amap" href="#" target="_blank">
    <span>🚗</span><span class="nav-label">高德地图</span>
  </a>
  <!-- ... 其余 nav-item ... -->
  <button class="nav-item" onclick="copyAddress()">
    <span>📋</span><span class="nav-label">复制地址</span>
  </button>
</div>
```

### JS 实现要点

```javascript
let navTarget = {lat:0, lng:0, name:''};

function showNavMenu(lat, lng, name) {
  navTarget = {lat, lng, name};
  // 动态构建各 App URL...
  document.getElementById('nav-amap').href =
    `https://uri.amap.com/navigation?to=${lng},${lat},${encodeURIComponent(name)}&mode=car&callnative=1`;
  document.getElementById('nav-geo').href =
    `geo:${lat},${lng}?q=${encodeURIComponent(name)}`;
  menu.classList.add('show');
  // 点击外部自动关闭
  setTimeout(() => document.addEventListener('click', closeNavOnOutside), 100);
}
```

### POI 气泡

```javascript
function showPOIPopup(lng, lat, name, day, poiIdx) {
  navTarget = {lat, lng, name};
  new maplibregl.Popup({offset:[0,-10], closeButton:true, closeOnClick:true})
    .setLngLat([lng, lat])
    .setHTML(`<strong>${name}</strong><br>
      <button class="map-poi-nav-btn" onclick="...showNavMenu(...)">
        🧭 导航到这里
      </button>`)
    .addTo(map);
}
```

## 🧭 时间线导航图标

### 渲染位置

每个行程段的时间线中，地址名称（`.t-title`）右侧：

```
🕐 09:00  📍 老盛兴汤包馆(愚园路) 🧭     ← 🧭 点击弹出导航菜单
          └─ 本地人扎堆，生煎+小笼一站式
```

### 渲染逻辑

```javascript
// 在 renderContent() 的 .t-title 中：
${s.poi != null
  ? `<span class="nav-icon"
      onclick="event.stopPropagation();openNavForSeg(${d.d},${s.poi})"
      title="导航">🧭</span>`
  : ''}
```

- 只有当 `segs[].poi` 不为 null（即地址有对应地图坐标）时才显示 🧭 图标
- `event.stopPropagation()` 防止触发行程段的 `flyToPOI` 
- `openNavForSeg(day, poiIdx)` 查找 `dayRoutes` 中的坐标，调用 `showNavMenu()`

### 🧭 图标样式

```css
.nav-icon {
  display: inline-block;
  margin-left: 6px;
  padding: 1px 6px;
  font-size: 0.85em;
  cursor: pointer;
  border-radius: 6px;
  background: var(--hover);
  border: 1px solid var(--border);
  color: var(--blue);
  vertical-align: middle;
}
.nav-icon:hover, .nav-icon:active {
  background: var(--blue-soft);
  border-color: var(--blue);
}
```

数据结构：
- `dayRoutes[].coords`：路线 GeoJSON LineString
- `dayRoutes[].pois[]`：每段对应 {lng, lat, t: "名称"}
- `daysData[].segs[].poi`：指向 pois 的索引

| 用户操作 | 地图行为 |
|---------|---------|
| 点击天标题 | 展开行程 + 高亮当天路线(彩色连线) + 显示当天 POI 标记 + fitBounds |
| 点击段标题 | `flyToPOI(d, poiIdx)` → flyTo 到具体坐标(zoom 15) |
| 双击高亮天 | 取消高亮，隐藏路线和 POI |

## 预算计算器

位置：仅在「💰 预算」标签页。

| 控件 | 类型 | 说明 |
|------|------|------|
| 🏨 住宿 | `<select>` + data-hi | 经济型¥100-200 / 舒适型¥170-300 / 高端型¥300-500 |
| 🍜 餐饮 | `<select>` + data-hi | 节俭¥70-90 / 舒适¥100-150 / 吃好¥180-250 |
| 🌙 夜生活 | `<input type="range">` 0-15 | 每次 ¥90 基准 × min/max 系数 |

输出：`¥{min} - ¥{max}` 区间 + `✅ 在舒适档内` 或 `⚠️ 超出` 提示。

### 自定义试算器 CSS 布局

```html
<div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;align-items:end">
  <div>
    <label style="display:block;font-size:.75em;color:var(--text-dim);margin-bottom:4px;font-weight:500">住宿</label>
    <select style="width:100%;padding:8px 10px;...">...</select>
  </div>
  <div>
    <label style="display:block;font-size:.75em;color:var(--text-dim);margin-bottom:4px;font-weight:500">餐饮</label>
    <select style="width:100%;padding:8px 10px;...">...</select>
  </div>
  <div>
    <label style="display:block;font-size:.75em;color:var(--text-dim);margin-bottom:4px;font-weight:500">夜生活 <span style="color:var(--accent);font-weight:600">8次</span></label>
    <input type="range" style="width:100%;margin:0" ...>
  </div>
</div>
```

**关键点**：3 列 `1fr` 网格确保等宽，`display:block` 标签在控件上方，`width:100%` 确保 select 和 range 填满列宽。不要用 `flex` + `gap` + `flex-wrap`（会导致宽度不一致）。

## 清单交互

```css
.checklist li { cursor: pointer; }
.checklist li.done { text-decoration: line-through; opacity: 0.5; }
.checklist li::before { content: '☐ '; }
.checklist li.done::before { content: '☑ '; color: var(--green); }
```

点击 `<li>` → `this.classList.toggle('done')`，无需 JS 函数。

## 价格展示原则

- 始终 min/max 区间
- 三源对比：FlyAI + Hostelworld + 公开数据
- 标注来源（HW=Hostelworld / FY=FlyAI / 公开=公共信息）

## 餐厅推荐原则

- 推荐理由必须写 — AI Local Friend 的核心价值
- 用「推荐的店」— 更中性准确
- 推荐≠引导消费。推荐有理由、本地视角是天职

## 模板复制指南

### 完整功能版（template.html）

1. 复制 `E:\\AI Projects\\travel-skill-repo\\template.html`
2. 替换 `{{CITY}}` `{{DAYS}}` `{{MONTH}}` `{{CENTER_LNG}}` `{{CENTER_LAT}}`
3. 填充 `dayRoutes` + `daysData` + `guideModules` 三个数组
4. 自定义 `renderBudgetTab()` 和 `renderChecklistTab()` 内的表格

### 精简轻量版（新模板/初级模板.html）

> 2026-07-21 上线，长沙 2 天纯吃攻略首用。

适用场景：熟客纯吃攻略、快速交付、轻量部署、单文件分享。

1. 复制 `E:\\AI Projects\\travel-skill-repo\\新模板\\初级模板.html`
2. 替换 `TRIP.meta` 城市信息（city/province/coord/title/subtitle/tags/startDate/watermark）
3. 填充 `TRIP.days[]` 数组，每项包含 `label/date/title/color/budget/summary/locs[]`
4. `locs[]` 每项必填：`n`(名称) + `lat`/`lng`(坐标) + `t`(分类key) + `tm`(时间) + `d`(描述) + `p`(价格)
5. 可选：`addr`/`hours`/`tel`/`alt`(备选标记)

```javascript
// locs[] 分类 key 对照 TRIP.categories
// bf=早餐, lu=午餐, sn=小吃, di=晚餐, dr=酒水, sight=景点, hotel=住宿, shop=购物
```

### 适配版（新模板/电脑端&手机端适配版.html）

适用场景：长文档、桌面+移动双端均需要良好体验、侧边栏目录导航。

1. 复制 `E:\\AI Projects\\travel-skill-repo\\新模板\\电脑端&手机端适配版.html`
2. 数据契约同完整版（`dayRoutes` + `daysData` + `guideModules`）
3. 额外包含侧边栏目录 + 标签页 + 三断点响应式 + 多主题系统

## 模板选择指南

| 场景 | 推荐模板 | 理由 |
|------|---------|------|
| 熟客纯吃、快速交付、微信分享 | **精简轻量版** | Leaflet 加载快，时间线直观，天气卡+住宿清单+进度追踪齐全 |
| 多日深度游、完整体验、预算规划 | **完整功能版** | 四标签页 + 预算试算器 + 悬浮地图 + POI 联动，功能最全 |
| 长文档、桌面+移动双端、目录导航 | **适配版** | 侧边栏目录 + 标签页切换 + 三断点响应式 + 多主题 |

## 通用模块（所有模板均可复用）

以下模块与模板解耦，任意模板均可独立集成：

| 模块 | 实现方式 | 依赖 |
|------|---------|------|
| **实时天气卡** | Open-Meteo API，`TRIP.meta.coord` 经纬度请求，30 分钟本地缓存 | 无 key，免费，国内可访问 |
| **城市名+实时时间** | `TRIP.meta.city` 渲染 + `new Date()` 本地时间（HH:MM 等宽数字） | 无依赖 |
| **进度追踪** | `localStorage` 持久化，标记已打卡地点 | 浏览器原生 storage |
| **预算打卡累加** | 勾选地点时自动累加价格到「已花费」 | 依赖 `progress` 状态对象 |
| **高德导航跳转** | `https://uri.amap.com/marker?position=lng,lat&name=...` | 浏览器 |
| **Leaflet 圆形标记** | `L.circleMarker` + `flyTo` + `bindPopup` | Leaflet 1.9.4 |

## PDF 导出（打印）

按钮：侧边栏 header `.header-actions` 按钮组第一项「导出PDF」。

```js
function exportPDF(){
  const prevTab=currentTab;
  currentTab='follow';
  renderContent();
  document.querySelectorAll('.day-body').forEach(b=>b.classList.add('open'));
  document.documentElement.setAttribute('data-theme','light');
  setTimeout(()=>{ window.print(); /* 后恢复状态 */ },300);
}
```

打印 CSS（`@media print`）：
- 隐藏：侧边栏、标签栏、悬浮地图、地图按钮、水印、header-actions
- 展开所有 `.day-body`：`max-height: none !important`
- 卡片白色背景 + 细边框，无阴影和动画
- A4 横向（`@page { margin: 1.5cm; size: A4; }`）

## 国际化框架（i18n）

模板内置中英双语切换。详见 `references/i18n-framework.md`。

核心要素：
- `lang='zh'` 状态变量，`uiLabels` 对象含 zh/en 两套 UI 标签
- `t(obj)` helper：字符串原样返回，对象按 `lang` 取值
- `toggleLang()`：切换语言 + 更新全部 UI 元素（标签页/地图控件/水印/跳转链接）
- 语言按钮：侧边栏 `.header-actions` 第二项，中文模式显示 `EN`，英文模式显示 `中`
- 国内路线零改动（数据全是字符串），国际路线改为 `{zh:"...",en:"..."}` 对象

## 侧边栏 Header 按钮组

三个功能按钮置于侧边栏顶部右侧，`flex` 水平排列在 `.header-actions` 容器内：

```css
.header-actions {
  display: flex; gap: 2px; background: var(--hover);
  border-radius: 10px; padding: 3px; flex-shrink: 0;
}
.header-actions button {
  padding: 5px 10px; border: none; background: transparent;
  color: var(--text-dim); font-size: 0.68em; border-radius: 7px;
}
.header-actions button:first-child { color: var(--accent); font-weight: 600; }
```

三个按钮（按序）：导出PDF | 语言(EN/中) | 主题。第一个高亮突出。不再使用绝对定位。

## 移动端响应式设计（2026-07-20 实现）

> **优先级：手机用户居多，移动端体验优先于桌面端。**

### 断点策略

| 断点 | 宽度 | 适用设备 | 核心行为 |
|------|------|---------|---------|
| 手机 | ≤768px | iPhone / Android | 侧边栏→抽屉 | 地图→底部全屏 | 标签栏→横向滚动 | 网格→单列 |
| 平板 | 769–1024px | iPad / 折叠屏展开 | 侧边栏缩至200px | 地图缩至420×360 | 内容内边距调优 |
| 桌面 | >1024px | 笔记本 / 显示器 | 原始布局不变（侧边栏240px + 内容 + 悬浮地图） |

### 手机端（≤768px）详细规范

#### 侧边栏 → 左滑抽屉

```css
#sidebar {
  position: fixed;
  left: -100%;           /* 默认隐藏在屏幕外 */
  width: 280px;
  z-index: 10000;
  transition: left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 4px 0 24px rgba(0,0,0,0.5);
}
#sidebar.open { left: 0; }
```

- 新增 `#mobile-topbar`：☰ 汉堡按钮 + 标题 + 主题切换（桌面端 `display:none`，手机端 `display:flex`）
- 新增 `#sidebar-overlay`：半透明遮罩层，点击关闭抽屉
- JS：`toggleSidebar(force)` 函数，控制 `.open` / `.show` class

#### 浮动地图 → 底部全屏

```css
#floatMap {
  width: 100vw !important;
  height: 70vh !important;
  right: 0 !important; left: 0 !important;
  bottom: 0 !important; top: auto !important;
  border-radius: 16px 16px 0 0;
  resize: none;
}
```

- 地图按钮缩至 48×48px，圆角 14px
- 底部位置从 24px 调整为 16px

#### 标签栏 → 横向滚动

```css
#tab-bar {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
}
.tab-btn {
  padding: 12px 14px;    /* 缩小内边距 */
  font-size: 0.82em;
  white-space: nowrap;    /* 不折行 */
  flex-shrink: 0;         /* 不压缩 */
}
```

#### 内容区域

- `#content`：padding 从 `28px 32px` → `16px 14px 100px`（底部留白给地图按钮）
- `.section-title`：字号 `1.35em` → `1.15em`
- `.data-table`：字号 `0.78em`，单元格 padding `6px 8px`
- `.day-header`：padding `14px 20px` → `12px 14px`
- `.day-body.open`：padding `16px 20px 20px` → `12px 14px 16px`

#### 时间线

- `padding-left`：28px → 22px
- 连接线 `left`：8px → 6px
- 时间/标题/描述字号各缩小一级

#### 网格布局

```css
.section > div[style*="grid-template-columns"] {
  grid-template-columns: 1fr !important;
}
```

预算卡片、清单卡片全部转单列。

### 平板端（769–1024px）详细规范

| 属性 | 桌面端 | 平板端 |
|------|--------|--------|
| `--sidebar-w` | 240px | 200px |
| `#content` padding | 28px 32px | 20px 20px |
| `.tab-btn` padding | 14px 20px | 12px 16px |
| `.tab-btn` font-size | 0.88em | 0.84em |
| `#floatMap` width | 580px | 420px |
| `#floatMap` height | 480px | 360px |
| 网格列 | repeat(auto-fill, minmax(340px,1fr)) | repeat(auto-fill, minmax(280px,1fr)) |

### 实现位置

移动端 CSS 放在 `<style>` 标签内，`@media print` 之前。在 `template.html` 和所有生成的攻略 HTML 中都必须包含。

### 移动端 HTML 骨架

每个 HTML 攻略文件必须包含以下三个元素（在 `<div id="app">` 内，侧边栏之前）：

```html
<div id="mobile-topbar" style="display:none">
  <button class="hamburger" onclick="toggleSidebar()">☰</button>
  <h3 id="mobile-title">城市名 N天深度游</h3>
  <div class="header-actions" style="background:transparent;padding:0">
    <button onclick="toggleTheme()" style="font-size:1em">🌙</button>
  </div>
</div>
<div id="sidebar-overlay" class="sidebar-overlay" onclick="toggleSidebar(false)"></div>
```

以及 JS 函数：

```javascript
function toggleSidebar(force) {
  const sb = document.getElementById('sidebar'),
        ov = document.getElementById('sidebar-overlay');
  const shouldOpen = force !== undefined ? force : !sb.classList.contains('open');
  sb.classList.toggle('open', shouldOpen);
  ov.classList.toggle('show', shouldOpen);
}
```

### 验证方法

1. 在 Chrome DevTools → Device Toolbar 选择 iPhone 14 Pro (393×852)
2. 确认侧边栏默认隐藏，☰ 按钮可见
3. 点击 ☰ → 侧边栏从左侧滑出 + 遮罩层显示
4. 点击遮罩层 → 侧边栏关闭
5. 点击地图按钮 → 地图从底部全屏弹出（70vh，圆角顶部）
6. 左右滑动标签栏 → 横向滚动正常
7. 展开天卡片 → 时间线字号/间距适配手机屏幕

## 已知问题（2026-07-20 审计）

### 🔴 模板 CDN 矛盾

**规范说 jsdelivr，但 V2.0 模板仍用 unpkg。**

| 模板 | CDN | 状态 |
|------|-----|------|
| `template.html`（V2.0 暗色） | `unpkg.com` ❌ 被墙 | **需修复**：替换为 `cdn.jsdelivr.net` |
| `assets/template.html`（Apple 风） | `cdn.jsdelivr.net` ✅ | 正确 |

每次基于 V2.0 模板生成新城市攻略，需手动把第 9-10 行从 unpkg 改为 jsdelivr。

### 🔴 双模板架构 + 数据契约不兼容

项目存在两套完全不同的 HTML 模板：

| 属性 | `template.html` (V2.0) | `assets/template.html` (Apple风) |
|------|----------------------|--------------------------------|
| 行数 | 1192 | 533 |
| 设计 | 暗色玻璃态 | 浅色 Apple 风 |
| 布局 | 侧边栏 + 内容 + 悬浮地图 | 顶部 sticky 地图 + 标签栏 + 内容 |
| 数据契约 | `dayRoutes[]` + `daysData[]` + `guideModules[]` | `HOTEL` + `DAYS[]` |
| 地图库 | MapLibre GL (裸) | Leaflet + MapLibre GL bridge |
| **当前用途** | 主力（上海攻略） | 备用模板 |

两份模板的数据结构不同，无法用同一份数据生成两种风格。切换模板意味着重写全部数据数组。

### 🟡 数据分离度 ~60%（非纯数据注入）

| 区域 | 分离方式 | 替换方式 |
|------|---------|---------|
| `{{CITY}}` `{{DAYS}}` 等 | `{{占位符}}` → 字符串替换 | 简单 |
| `dayRoutes[]` | JS 数组 | AI 手工构造 |
| `daysData[]` | JS 数组 | AI 手工构造 |
| `guideModules[]` | JS 数组（含 HTML 片段） | AI 手工构造 |
| **预算标签页** | **硬编码在 `renderBudgetTab()` 函数体内** | **AI 手工重写整个函数体** |
| **清单标签页** | **硬编码在 `renderChecklistTab()` 函数体内** | **AI 手工重写整个函数体** |
| `calcFullBudget()` | 数值硬编码（`*{{DAYS}}`） | 占位符替换 |

**影响**：无法用脚本批量灌数据，AI 是唯一生产线工人。每天 100 份攻略 = 100 次手工重写预算/清单 HTML。

### 🟡 规模化瓶颈

| 瓶颈 | 当前限制 | 理想方案 |
|------|---------|---------|
| 数据采集 | AI 手动搜索（5-8 轮交互） | 预建城市数据库 |
| 数据注入 | AI 手工拼接 JS 对象 | JSON 数据文件 + 模板引擎渲染 |
| 预算/清单 | AI 手工写 HTML 表格 | 纯数据配置 → JS 自动渲染 |
| CDN 修复 | 每次手动改 | 模板修复一次，永久生效 |

### 🟢 assets/lib/ 第三方库许可证

| 文件 | 版本 | License | 版权 |
|------|------|---------|------|
| `leaflet.js` | 1.9.4 | BSD-2-Clause | © 2010-2023 Vladimir Agafonkin, CloudMade |
| `maplibre-gl.js` | 4.7.1 | BSD-3-Clause | © MapLibre contributors |
| `leaflet-maplibre-gl.js` | 0.0.22 | MIT | © MapLibre contributors |

## 入口页面设计规范（index.html）

### 为什么需要入口页面

多个 HTML 攻略文件放在同一个目录时，用户直接打开目录不会自动加载任何页面。需要在根目录放置 `index.html` 作为导航入口，让本地用户（和有服务器的用户）都能快速找到并进入目标攻略。

### 本地 file:// 协议兼容性验证清单

入口页面和所有攻略页面必须能通过 `file://` 协议直接打开（双击即用）。必须满足：

| 检查项 | 要求 | 后果 |
|--------|------|------|
| 无 `fetch()` 本地文件 | 浏览器 `file://` 协议禁止 fetch，触发 CORS 错误 | 页面空白或报错 |
| 无 `XMLHttpRequest` 读本地 JSON | 同上 | 数据加载失败 |
| 无 PHP / Node 后端 | 本地无服务器环境 | 页面无法渲染 |
| 无动态 `import()` 加载外部模块 | 某些浏览器 file:// 限制 | 模块加载失败 |

**结论**：所有数据必须内联在 HTML 文件中（inline），不能分离成外部 JSON 文件通过 JS 动态加载。

### CDN 依赖的 graceful degradation

即使使用外部 CDN 资源，也必须保证核心内容（文字、表格、清单）在无网环境下完全可用：

| 外部依赖 | 来源 | 无网降级行为 |
|----------|------|-------------|
| MapLibre GL 地图库 | jsdelivr / unpkg CDN | 地图区域空白，攻略文字正常显示 |
| Noto Sans SC 字体 | Google Fonts | 回退到系统 sans-serif 字体 |
| OpenFreeMap 地图瓦片 | tiles.openfreemap.org | 地图瓦片加载失败，其余内容正常 |

**测试方法**：在浏览器 DevTools → Network 标签勾选 "Offline"，刷新页面，确认非地图区域完全可用。

### 双主题共存模式（Dark + Light）

入口页面和攻略页面应同时支持暗色和明色两种主题，用户可自由切换。

#### 设计原则

1. **两个主题不是「选一取消另一」**，而是互斥切换 — 当前只有一个生效，但切换按钮始终可见
2. **记住用户选择**：通过 `localStorage` 持久化，下次打开自动用上次主题
3. **跟随系统**：未手动选择时，通过 `window.matchMedia('(prefers-color-scheme: light)')` 自动跟随系统设置
4. **两个按钮都保留**：不是单选/复选框，而是两个独立按钮（暗色按钮 + 明色按钮），当前选中的高亮

#### 实现模式

```javascript
// 主题切换
function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('theme', theme);
  document.querySelectorAll('.theme-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.theme === theme);
  });
}

// 初始化
const saved = localStorage.getItem('theme');
if (saved) {
  setTheme(saved);
} else if (window.matchMedia('(prefers-color-scheme: light)').matches) {
  setTheme('light');
}
```

#### CSS 变量结构

```css
[data-theme="dark"] {
  --bg: #0b0e14;
  --bg-card: rgba(22, 27, 34, 0.85);
  --text: #e6edf3;
  --accent: #ff6b4a;
  /* ... 暗色完整变量集 ... */
}

[data-theme="light"] {
  --bg: #f6f8fa;
  --bg-card: rgba(255, 255, 255, 0.85);
  --text: #1f2328;
  --accent: #e5533d;
  /* ... 明色完整变量集 ... */
}
```

### 入口页面布局结构

```
┌─────────────────────────────────────────────┐
│                          [🌙暗色] [☀️明色]  │  ← 右上角主题切换
├─────────────────────────────────────────────┤
│                                             │
│                  🗺️ Logo                    │
│              AI Local Friend                │
│          智能旅游攻略 · 城市深度游指南       │
│                                             │
│  ┌─────────────────┐  ┌─────────────────┐  │
│  │ 📋              │  │ 🏙️              │  │
│  │ 通用模板        │  │ 上海 15 天深度游│  │
│  │ 可复用的城市... │  │ 完整行程规划... │  │
│  │ [Template]      │  │ [已上线]        │  │
│  └─────────────────┘  └─────────────────┘  │
│                                             │
│       AI Local Friend · 本地优先 · 双击即开  │
└─────────────────────────────────────────────┘
```

### 创建入口页面的触发条件

满足以下任一条件时，需要创建或更新 `index.html` 入口页面：

- 项目根目录缺少 `index.html` / `start.html` / `index.htm`
- 新增了独立的攻略 HTML 文件（需要添加入口卡片）
- 用户要求「打包发给别人」或「离线可用」
- 项目交付 / 发版前

---

*创建于 2026-07-18 · 上海 15 天攻略实战验证 · V1→V2→V3 迭代 · 2026-07-20 审计新增已知问题章节 · 2026-07-19 新增入口页面设计规范*
