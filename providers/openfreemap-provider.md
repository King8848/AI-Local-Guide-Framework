# OpenFreeMap Provider — 免费地图瓦片

> 基于 OpenStreetMap 数据的免费地图瓦片服务。

---

## 类型
map

## 能力
- 矢量瓦片（MVT）
- 多种地图样式（Liberty, Bright, Positron）
- 无需 API Key
- 全球覆盖

## 接口

### 瓦片 URL
```
https://tiles.openfreemap.org/styles/{style}/tiles/{z}/{x}/{y}.pbf
```

### 样式
| 样式 | URL | 说明 |
|------|-----|------|
| Liberty | `https://tiles.openfreemap.org/styles/liberty/style.json` | 默认，彩色 |
| Bright | `https://tiles.openfreemap.org/styles/bright/style.json` | 亮色 |
| Positron | `https://tiles.openfreemap.org/styles/positron/style.json` | 浅色 |

### 使用示例（MapLibre GL JS）
```javascript
const map = new maplibregl.Map({
  container: 'map',
  style: 'https://tiles.openfreemap.org/styles/liberty/style.json',
  center: [116.4, 39.9],
  zoom: 10
});
```

## 调用方式
HTTP 直接调用，无需注册或 API Key。

## 许可证
- 瓦片服务：MIT
- 地图数据：ODbL (OpenStreetMap contributors)
- 地图样式：BSD-3-Clause + CC BY 4.0

## 注意事项
- 免费使用，无需 API Key
- 中国大陆访问速度取决于网络环境
- 建议使用 MapLibre GL JS 渲染矢量瓦片
- 数据来源：OpenStreetMap (ODbL) — 需要署名

---

*Last updated: 2026-07-19*
