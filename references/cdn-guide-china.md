# 国内环境 CDN 选择指南

> 适用于所有需要加载外部 JS/CSS/资源的前端页面。

---

## 问题

以下 CDN 在国内加载慢或被墙：
- `unpkg.com` → **被墙**
- `cartocdn.com` → 地图瓦片加载慢
- `cdnjs.cloudflare.com` → 不稳定
- `raw.githubusercontent.com` → 被墙

---

## 推荐替换

| 用途 | ❌ 避免 | ✅ 推荐 |
|------|--------|--------|
| JS 库 | `unpkg.com` | `cdn.jsdelivr.net` |
| CSS 库 | `unpkg.com` | `cdn.jsdelivr.net` |
| 地图 JS | `unpkg.com/maplibre-gl` | `cdn.jsdelivr.net/npm/maplibre-gl@4.7.1` |
| 地图桥接 | `unpkg.com/@maplibre/maplibre-gl-leaflet` | `cdn.jsdelivr.net/npm/@maplibre/maplibre-gl-leaflet@0.0.22` |
| 地图瓦片（矢量·首选） | — | `tiles.openfreemap.org/styles/liberty` ✅ 国内可用（2026-07-18 验证） |
| 地图瓦片（栅格·降级） | `cartocdn.com` | `tile.openstreetmap.org` |
| 原始文件 | `raw.githubusercontent.com` | `ghproxy.com` 或 `raw.fastgit.org` |

---

## 本地回退方案

CDN 不可用时（离线/内网），使用已下载到 `assets/lib/` 的本地副本（2026-07-18 已就绪，5 文件 ≈ 1 MB）：

```html
<link rel="stylesheet" href="assets/lib/leaflet.css">
<script src="assets/lib/leaflet.js"></script>
<link href="assets/lib/maplibre-gl.css" rel="stylesheet">
<script src="assets/lib/maplibre-gl.js"></script>
<script src="assets/lib/leaflet-maplibre-gl.js"></script>
```

---

## MapLibre GL + OpenFreeMap 完整示例

```html
<!-- ✅ JS 库：jsdelivr CDN -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js"></script>
<link href="https://cdn.jsdelivr.net/npm/maplibre-gl@4.7.1/dist/maplibre-gl.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/maplibre-gl@4.7.1/dist/maplibre-gl.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@maplibre/maplibre-gl-leaflet@0.0.22/leaflet-maplibre-gl.js"></script>
```

```javascript
// ✅ Liberty 矢量瓦片（免费无需 key，2026-07-18 国内实测通过）
const map = L.map('map', { center: [28.194, 112.970], zoom: 13 });
L.maplibreGL({
  style: 'https://tiles.openfreemap.org/styles/liberty',
}).addTo(map);
```

---

## Leaflet + OSM 降级示例

```html
<!-- ❌ 旧版（unpkg 被墙） -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<!-- ✅ 新版（jsdelivr 国内可用） -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js"></script>
```

```javascript
// OSM 栅格瓦片（降级方案，比 CartoDB 稳定）
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '&copy; OSM', maxZoom: 18
}).addTo(map);
```

---

*最后更新：2026-07-18 · MapLibre GL + OpenFreeMap 国内验证通过*
