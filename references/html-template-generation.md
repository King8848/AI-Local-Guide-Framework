# HTML 模板生成工作流（travel-control-template.html）

> JSON 驱动模板，2162 行 / 134KB。不能用 patch 工具（锚点漂移+转义问题）。
>
> **复用原则（用户明确纠正过）**：完整复用模板，功能全保留（4 tab + 地图 + 清单勾选 + 费用 donut + 天气动画 + POI 详情 + 导航菜单），只换数据 + 修国内兼容（CDN/地图/导航/卡片图）。**不要精简砍功能**——用户说过「不需要什么太精简，本来就是有类似的模板」「你这个精简的太难用了」。

## 生成新旅行 HTML 的步骤

### Step 1：Python 脚本替换 JSON 数据

```python
import re
template = r"E:\AI Projects\travel-skill-repo\新模板\travel-control-template.html"
with open(template, "r", encoding="utf-8") as f:
    html = f.read()

# 替换 <script id="trip-data"> 块内的 JSON
pattern = r'(<script id="trip-data" type="application/json">)\s*\n(.*?)\s*\n(\s*</script>)'
html = re.sub(pattern, r'\g<1>\n' + new_json + r'\n\3', html, flags=re.DOTALL)

# 更新 title
html = html.replace('<title>旅行控制中心 · 模板</title>', '<title>你的标题</title>')
```

### Step 2：封面图 base64 内嵌

封面图 `../assets/hero-cover.jpg` 通常不存在。用 SVG 生成渐变图 → base64 替换：

```python
import base64
svg = '<svg xmlns="http://www.w3.org/2000/svg" width="800" height="400">...</svg>'
b64 = "data:image/svg+xml;base64," + base64.b64encode(svg.encode("utf-8")).decode("utf-8")
html = html.replace('src="../assets/hero-cover.jpg"', f'src="{b64}"')
```

### Step 3：指南（guides）更新

guides 数组支持 4 种 type：
- `tip` → 青色贴士（lightbulb 图标）
- `warning` → 红色避坑（alert-triangle 图标）
- `food` → 橙色美食（utensils 图标）
- `note` → 紫色注意（info 图标）

指南内容应覆盖：酒店、停车、拍摄、行程方案、拍照点位、美食、预算、穿衣、APP、行李、演唱会、雨天备案、高速服务区、紧急联系、注意事项。

## 数据结构

```json
{
  "trips": [{ "id", "title", "subtitle", "destination", "start_date", "end_date", "budget_total", "weather_temp", "weather_desc", "weather_icon" }],
  "itinerary": [{ "id", "trip_id", "day_index", "day_label", "day_date", "time_label", "title", "category", "location_name", "address", "lat", "lng", "duration", "note", "done", "sort_order" }],
  "checklist": [{ "id", "trip_id", "label", "checked", "sort_order" }],
  "expenses": [{ "id", "trip_id", "category", "amount", "day_index", "created_at" }],
  "guides": [{ "id", "type", "title", "content" }]
}
```

**注意**：坐标必须是 WGS-84（GPS 原始坐标），导航链接会自动转换为高德/百度/腾讯坐标。

## 常见坑

| 坑 | 预防 |
|----|------|
| patch 工具替换 JSON 失败 | 用 Python 脚本 str.replace/re.sub |
| 封面图显示破碎图标 | base64 SVG 内嵌 |
| 坐标用 GCJ-02 导致偏移 | 用 WGS-84 原始坐标 |
| **CDN unpkg 被墙** | 复用前全局 replace `unpkg.com/` → `cdn.jsdelivr.net/npm/`（Tailwind browser / Lucide / MapLibre 三处都挂 unpkg）|
| **地图 CartoCDN 国内超时** | 模板默认 `buildStyle` 用 `basemaps.cartocdn.com` 栅格，国内必超时。改成 `return 'https://tiles.openfreemap.org/styles/liberty'`（MapLibre 矢量 style URL，可直接当 style 用）|
| **导航菜单 4 图按需砍** | `openNavSheet` 里的数组默认高德/百度/腾讯/Apple 四图，按需删（如跟团只留高德+Apple）。删百度记得 bd 变量、删腾讯记得 gcj 仍被高德用 |
| **tab 结构改造** | 模板 4 tab 是行程/清单/预算/指南（data-tab + div id + switchTab 数组 + render 函数四处联动）。改成行程/美食/Vlog/费用时：改 button 标签+图标、改 div 内容、重写 renderChecklist(→美食)/renderGuides(→Vlog) 函数体、删 calculator 按钮+overlay+监听（预算改费用清单时）。⚠️ **标签映射别搞反**：`data-tab=budget` 对应 `renderBudget`（费用 donut）→ 标「费用」；`data-tab=guides` 对应 `renderGuides`（重写为 Vlog）→ 标「Vlog」。上次把两者标签对调，用户反馈「Vlog 和费用搞反了」 |
| **Python 脚本替换更稳** | 复用模板用 Python `read → 统一 \r\n 为 \n → 多个 str.replace / re.sub → write`，别用 patch 工具（HTML 转义陷阱）。重写 JS 函数用「花括号平衡匹配」定位函数体 |
| guides 内容太少指南 tab 空 | 至少 20+ 条覆盖所有板块 |

## 验证与联网图片（2026-08-27 补充）

### 验证 HTML 渲染（机器无 playwright/puppeteer）

机器上 playwright/puppeteer 均未装，但系统必有 Edge/Chrome，用无头模式验证：

```powershell
# 手机尺寸截图
Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList '--headless=new','--disable-gpu','--hide-scrollbars','--screenshot=E:\_preview.png','--window-size=390,844','--virtual-time-budget=12000','file:///E:/_preview.html' -NoNewWindow -Wait
# 验证 JS 渲染后的 DOM（防白屏）
Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList '--headless=new','--disable-gpu','--dump-dom','--virtual-time-budget=12000','file:///E:/_preview.html' -RedirectStandardOutput "E:\_dom.txt" -NoNewWindow -Wait
```

- 用 `Start-Process -NoNewWindow -Wait`（`&` 会被误判为 background）
- `--virtual-time-budget` 给 JS 渲染留时间（地图/粒子/动画）
- `--dump-dom` 输出的 DOM 若含 day-card + 各景点名 = 渲染成功（Edge 报的 QQBrowser/USB ERROR 是无关噪声）
- 中文路径用 `file://` 前先 `Copy-Item` 到英文名（如 `E:\_preview.html`）

### 联网找卡片背景图

- 境外图床（Wikimedia API / Wikipedia REST）在这台机器上超时，不可用
- 用 agentkey `Serper/searchImages`（0.2/次，走 agentkey 服务器不依赖本机网络）搜图取 `imageUrl`
- **Wikimedia 图片 CDN 国内也超时**（2026-08-27 实测 `upload.wikimedia.org` 全挂，不只 API）→ **首选搜狐图床 `*.itc.cn`**（实测 200，国内快、无防盗链）；次选国内新闻站 `static.bjd.com.cn`（北京日报）/ `imgm.gmw.cn`（光明网）、搜狐 `cdn.sohucs.com`、政府站 `gov.cn`（均实测 200）。定图前用 `Invoke-WebRequest -Method Head` 逐个测可达性再写进 HTML
- 卡片封面图是**用户硬需求**：行程卡片不能是纯文字，要有封面图。做法 = itinerary 数据加 `"image"` 字段（有图的景点填 URL），`renderItinerary` 模板里 `${item.image ? '<div ...style="background-image:...url(图)"...></div>' : ''}` 渲染在卡片顶部；无图点位（火车站/加餐）留空自然跳过
- 每张卡 CSS 用 `linear-gradient(...), url('图')` 叠加，图片加载失败降级到渐变底色，不白屏
