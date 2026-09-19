# 旅行控制中心模板

## 概述

基于 `travel-control-template.html` 的单文件旅行控制中心模板。AI Local Friend 生成 HTML 时只需替换 JSON 数据块。

## 使用方法

1. 复制 `E:\AI Projects\travel-skill-repo\新模板\travel-control-template.html`
2. 替换 `<script id="trip-data" type="application/json">` 中的 JSON
3. 改封面图 `<img id="hero-cover">` 的 src
4. 浏览器打开即可

## JSON 数据结构

```json
{
  "_template_version": "1.0",
  "trips": [
    {
      "id": 1,
      "title": "新马双国 7天6晚 海岛自然游",
      "subtitle": "新加坡花园城市 + 马来西亚海岛秘境",
      "destination": "新加坡 / 马六甲",
      "start_date": "2026-07-22",
      "end_date": "2026-07-28",
      "budget_total": 9500,
      "weather_temp": 31,
      "weather_desc": "多云转晴",
      "weather_icon": "cloud-sun"
    }
  ],
  "itinerary": [
    {
      "id": 1, "trip_id": 1, "day_index": 1,
      "day_label": "Day 1", "day_date": "2026-07-22",
      "time_label": "10:00", "title": "抵达樟宜机场",
      "category": "traffic", "location_name": "新加坡樟宜机场",
      "address": "Singapore Changi Airport",
      "lat": 1.3599, "lng": 103.9894,
      "duration": "—", "note": "轻逛星耀樟宜室内瀑布",
      "done": false, "sort_order": 1
    }
  ],
  "checklist": [{ "id": 1, "trip_id": 1, "label": "护照", "checked": false, "sort_order": 1 }],
  "expenses": [{ "id": 1, "trip_id": 1, "category": "交通", "amount": 2500, "day_index": null, "created_at": "2026-07-01" }],
  "guides": [{ "id": 1, "type": "tip", "title": "签证提示", "content": "持护照说走就走" }]
}
```

## 关键字段说明

### itinerary[]
- `category`: `spot`(景点) / `food`(美食) / `traffic`(交通) / `shop`(购物)
- `lat`/`lng`: **必须是 WGS-84 坐标**（GPS 原始坐标），导航链接会自动转换
- `sort_order`: 当天内的排序

### guides[]
- `type`: `tip`(小贴士) / `warning`(警告) / `food`(美食) / `note`(备注)

## 注意事项

- 需联网加载 Tailwind CSS、Lucide、MapLibre（CDN）
- 封面图支持本地路径或 base64
- 支持多旅程切换（trips 数组可多个）
- 坐标转换函数 `wgs84ToGcj02` / `wgs84ToBd09` 已内置，生成时保留
