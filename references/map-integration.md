# MapLibre GL + OpenFreeMap 矢量瓦片集成指南

> 来源：2026-07-18 上海 15 天攻略迭代验证
> 前提：Leaflet + CartoDB/OSM/ArcGIS 栅格瓦片在国内全部不稳定

## 为什么不用 Leaflet

Leaflet 设计用于栅格瓦片（PNG 图片），国内访问 CartoDB/OSM/ArcGIS 全部超时。即使加三级 fallback 链也不稳定。

## 正确方案

```html
<script src="https://unpkg.com/maplibre-gl@4.7.1/dist/maplibre-gl.js"></script>
<link rel="stylesheet" href="https://unpkg.com/maplibre-gl@4.7.1/dist/maplibre-gl.css">
```

```js
const map = new maplibregl.Map({
  container: 'map',
  style: 'https://tiles.openfreemap.org/styles/liberty', // 矢量 .pbf，免费免 key
  center: [121.47, 31.23], // [lng, lat]
  zoom: 10,
  attributionControl: false
});
```

## 备选方案

| 方案 | URL | 说明 |
|------|-----|------|
| OpenFreeMap Liberty | `tiles.openfreemap.org/styles/liberty` | 首选，免费免 key |
| 高德瓦片 | `webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}` | 零配置最快，需换 Leaflet |

## POI 标记（可点击）

```js
// 添加 POI 源和图层
map.addSource('poi-1', {
  type: 'geojson',
  data: { type: 'Feature', geometry: { type: 'Point', coordinates: [lng, lat] }, properties: { name: '标签名' } }
});
map.addLayer({
  id: 'poi-1-circle', type: 'circle', source: 'poi-1',
  paint: { 'circle-radius': 7, 'circle-color': '#ff6b4a', 'circle-opacity': 0.8, 'circle-stroke-color': '#fff', 'circle-stroke-width': 2 }
});
map.addLayer({
  id: 'poi-1-label', type: 'symbol', source: 'poi-1',
  layout: { 'text-field': ['get', 'name'], 'text-size': 11, 'text-offset': [0, 1.8], 'text-anchor': 'top' }
});

// 点击飞行
map.on('click', 'poi-1-circle', e => {
  map.flyTo({ center: [e.lngLat.lng, e.lngLat.lat], zoom: 15, duration: 600 });
});
```

## 路线连线（GeoJSON LineString）

```js
map.addSource('route-1', {
  type: 'geojson',
  data: { type: 'Feature', geometry: { type: 'LineString', coordinates: [[lng1,lat1],[lng2,lat2],...] } }
});
map.addLayer({
  id: 'route-line-1', type: 'line', source: 'route-1',
  paint: { 'line-color': '#ff6b4a', 'line-width': 3, 'line-opacity': 0.4 },
  layout: { visibility: 'none' } // 默认隐藏，点击天时显示
});
```

## 定位

```js
map.addControl(new maplibregl.GeolocateControl({
  positionOptions: { enableHighAccuracy: true },
  trackUserLocation: true,
  showUserHeading: true
}), 'bottom-left');
```

## fitBounds（飞到一天的所有坐标）

```js
const bounds = new maplibregl.LngLatBounds();
coords.forEach(c => bounds.extend(c));
map.fitBounds(bounds, { padding: 60, duration: 800 });
```

## 极简 POI 风格（与旅行进度联动）

> 2026-07-21 用户确认：只保留小点点，去掉 emoji/标签，已完成=绿色，未探索=白色

```js
// 构建 POI GeoJSON，携带 done 属性
function poiGeoJSON(locs, dayId) {
  return {
    type: 'FeatureCollection',
    features: locs.map((l, idx) => ({
      type: 'Feature',
      geometry: { type: 'Point', coordinates: [l.lng, l.lat] },
      properties: { name: l.n, dayId, idx, time: l.tm, desc: l.d, price: l.p || '', done: !!progress[dayId + '-' + idx] }
    }))
  };
}

// 绘制 — data-driven styling 根据 done 自动变绿/白
map.addSource(srcId, { type: 'geojson', data: poiGeoJSON(pts, dayId) });
map.addLayer({
  id: srcId + '-circle', type: 'circle', source: srcId,
  paint: {
    'circle-radius': 8,
    'circle-color': ['match', ['get', 'done'], true, '#16a34a', '#ffffff'], // 绿色 / 白色
    'circle-opacity': 0.95,
    'circle-stroke-color': ['match', ['get', 'done'], true, '#16a34a', '#b0b0b0'], // 绿色描边 / 灰色描边
    'circle-stroke-width': 1.5
  }
});
```

**关键点：**
- ✅ 不需要 emoji、不需要 label 图层、不需要 L.marker/DivIcon
- ✅ `circle-radius: 8` + `opacity: 0.95` = 半透明小点，不遮挡地图细节
- ✅ `circle-stroke-color` 联动：已完成用绿色描边，未探索用灰色描边
- ✅ 数据中用 `done` 属性驱动颜色，样式全在 `paint` 层，无需手动 `setIcon`

## 勾选后实时刷新（setData 模式）

```js
function updateMarkerStates() {
  if (!map) return;
  mapState.pois.forEach(srcId => {
    const src = map.getSource(srcId);
    if (!src || !src._data) return;
    const data = src._data;
    if (!data.features) return;
    data.features.forEach(f => {
      const p = f.properties;
      f.properties.done = !!progress[p.dayId + '-' + p.idx];
    });
    src.setData(data); // 🔑 触发重绘，地图上的点瞬间变色
  });
}
```

**对比舊方案**： MapLibre GL marker 用 DOM ＋ CSS 图标，每次更新要移除重建；数据绑定方案只需 `setData`，性能 O(1)，不改图层。

## POI 点击 Popup

```js
map.on('click', srcId + '-circle', function(e) {
  const f = e.features[0];
  const p = f.properties;
  const done = !!progress[p.dayId + '-' + p.idx];
  const html = `<b style="font-size:15px">${p.name}</b>${done ? ' ✓ 已探索' : ''}
    <br><span style="color:#888">${p.time}</span><br>${p.desc}
    ${p.price ? '<br><span style="color:#ff6b35;font-weight:600">' + p.price + '</span>' : ''}`;
  new maplibregl.Popup({ offset: [0, -14], closeButton: false, maxWidth: 240 })
    .setLngLat(f.geometry.coordinates).setHTML(html).addTo(map);
});
```

---

*创建于 2026-07-21 · 长沙攻略迭代 · POI 与旅行进度联动*
