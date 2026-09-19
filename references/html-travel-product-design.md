# HTML 旅行产品交互设计规范

> 2026-07-21 更新：控制中心 + 行动卡已同步到 `template.html`（统一模板）。
> 2026-07-20 实战验证：上海 15 天攻略 HTML 产品级优化

## 版本迭代记录

| 日期 | 变更 |
|------|------|
| 2026-07-21 | 新增精简轻量版模板（`新模板/初级模板.html`）；天气模块（城市名+实时时间）确认为通用模块 |
| 2026-07-21 | 控制中心 + 行动卡 + 行程状态系统同步到 `template.html`（统一模板）。 |
| 2026-07-20 | 上海 15 天实战验证：控制中心、行动卡、减玻璃、强层级 |

## 产品定位

**AI 根据用户需求生成的一份可交互私人旅行手册**

不是普通旅游网页、不是旅游攻略文章、不是信息展示页面。

用户购买旅行规划服务后获得这个 HTML 文件，在手机浏览器中打开，在旅行过程中持续使用。

## 模板体系

| 模板 | 路径 | 定位 | 地图引擎 | 适用场景 |
|------|------|------|----------|----------|
| 完整功能版 | `template.html` | 私家商业能力 | MapLibre GL + OpenFreeMap | 多日深度游、预算规划、POI 联动 |
| 精简轻量版 | `新模板/初级模板.html` | 轻量部署/快速交付 | MapLibre GL + OpenFreeMap Liberty | 熟客纯吃攻略、快速交付、微信分享 |
| 适配版 | `新模板/电脑端&手机端适配版.html` | 桌面+移动双端 | MapLibre GL + OpenFreeMap | 长文档、双端体验、侧边栏导航 |

### 精简轻量版模板结构

```
TRIP = {
  meta: { title, subtitle, city, province, coord, coordLabel, startDate, watermark, tags },
  overview: { regions, rules, warning },
  categories: { bf, lu, sn, di, dr, sight, hotel, shop },
  lodging: [...],
  checklist: [...],
  days: [{
    label, date, title, budget, color, summary,
    locs: [{ n, lat, lng, t, tm, d, p, addr?, hours?, tel?, alt? }]
  }]
}
```

天气卡、住宿清单、预算打卡追踪、高亮今日进度条等能力均为模板内置，**无需额外开发**。

## 核心设计原则

### 1. 执行导向 > 装饰效果

用户不是在阅读攻略，而是在「执行」旅行。

| 用户真正需要 | 对应设计 |
|-------------|---------|
| 今天去哪？ | 控制中心"今日卡片"突出显示 |
| 下一站是什么？ | Day 卡片折叠态摘要 |
| 怎么过去？ | 行动卡"🧭 导航"按钮 |
| 需要多久？ | 时间线上下文明确 |
| 花多少钱？ | 价格标签每卡显式 |
| 哪些地方完成？ | 已结束卡片变灰淡化 |

### 2. 首页 = 旅行控制中心

用户打开文件 **5 秒内**知道"今天我要怎么玩"。

#### 控制中心组件结构

```html
<div class="control-center">
  <!-- 城市信息 -->
  <div class="cc-city">上海</div>
  <div class="cc-subtitle">15天深度旅行 · 即将出发</div>
  
  <!-- 统计面板 -->
  <div class="cc-stats">
    <div><span class="cc-stat-val">15</span><span>旅行天数</span></div>
    <div><span class="cc-stat-val">61</span><span>打卡地点</span></div>
    <div><span class="cc-stat-val">9</span><span>夜生活</span></div>
  </div>
  
  <!-- 今日指引 -->
  <div class="cc-today">
    <div>📍 今天 · Day 3</div>
    <div class="cc-today-title">武康路→安福路</div>
    <div class="cc-today-sub">5 个地点 · 梧桐区</div>
    <div>点击查看详情 →</div>
  </div>
  
  <!-- 快捷入口 -->
  <div class="cc-quick-row">
    <button>🗺️ 地图总览</button>
    <button>✅ 出行清单</button>
    <button>💰 预算</button>
  </div>
</div>
```

### 3. Day 卡片 = 行动卡

每个 Day 卡片包含：
- Day N + 路线描述 + 片区标签 + 展开箭头
- 摘要行：📍 N个地点 · 🏘️ 片区 · 🌙 夜生活（如有）
- 时间线：圆点 + 时间 + 地点名(可点地图跳转) + 描述 + 价格 + 标签
- 行动行：🧭 导航 + 📍 地图（按钮触发行动）

**今日卡片特殊处理**：
- 渐变背景（accent → accent-2）
- 白色文字
- 双栏网格布局的圆点
- 标签半透明

**已结束卡片**：
- 50%透明度 + 灰色滤镜

### 4. 地图联动

- 点击地点标题 → `flyToPOI()` 地图飞到 POI
- 点击"📍 地图"按钮 → 同上
- 点击"🧭 导航"按钮 → 弹出导航菜单
- 点击"🗺️ 地图总览" → 展开全行程地图

### 5. 视觉简化：减玻璃、强层级

**避免**：
- 重度玻璃拟态（backdrop-filter 开销大）
- 大量渐变
- 复杂动画
- 炫技效果

**推荐**：
- 纯色卡片（`var(--bg-card-solid)`）
- 统一圆角阴影
- 清晰字体层级：标题/正文/辅助信息
- 信息层级 > 装饰效果

### 6. 模板变量集中管理

```javascript
const mapCenter = [121.47, 31.23];
const CITY_NAME = '上海';
const TRIP_DAYS = 15;
const tripStartDate = '2026-10-01';
```

替换城市只需改这 4 个变量 + 数据数组。

## 代码实现要点

### CSS 关键变量

```css
:root {
  --bg: #f4f7ff;
  --bg-card-solid: #ffffff;
  --accent: #2563eb;
  --accent-2: #06b6d4;
  --text: #0b1b3a;
  --text-dim: #4a5e80;
  --border: rgba(37, 99, 235, 0.14);
  --shadow-sm: 0 1px 3px rgba(37,99,235,0.08);
}
```

### 行动按钮统一模式

```css
.t-nav-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 5px 12px;
  background: var(--accent-soft);
  color: var(--accent);
  border: 1px solid rgba(37,99,235,0.2);
  border-radius: 8px;
  font-size: 0.74em;
  font-weight: 600;
  cursor: pointer;
}
```

### 移动端适配

```css
@media (max-width: 768px) {
  .control-center {
    padding: 22px 18px 16px;
    margin-bottom: 18px;
  }
  .t-nav-btn {
    padding: 6px 14px;
    min-height: 36px;  /* 触摸友好 */
  }
}
```

## 质量控制

修改时必须遵守：
1. 先读完整代码再改
2. 不删除现有有效功能
3. 不为了视觉效果牺牲功能
4. 不大幅度改变已有数据结构
5. 优先 CSS/HTML/JS 优化完成，不是重写
6. 修改过程中检查手机端布局、JS 报错、点击响应
7. 保持代码可维护性
