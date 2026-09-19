# 坐标系转换：WGS-84 ↔ GCJ-02 / BD-09

## 背景

中国地图服务使用加密坐标系，直接用 GPS(WGS-84) 坐标会有 ~500m 偏移：
- **高德/腾讯**：GCJ-02（国测局坐标）
- **百度**：BD-09（在 GCJ-02 基础上再加密）
- **Apple/OSM/MapLibre+CartoDB**：WGS-84（无需转换）

## 规则

1. **地图数据（lat/lng）统一用 WGS-84** — MapLibre + CartoDB tiles 直接显示正确
2. **导航链接需转换** — 跳转到高德/百度/腾讯时必须转对应坐标系
3. AI Local Friend 生成的 JSON 数据中所有坐标必须是 WGS-84

## 转换函数

```javascript
// WGS-84 → GCJ-02
function transformLat(x, y) {
  var ret = -100.0 + 2.0*x + 3.0*y + 0.2*y*y + 0.1*x*y + 0.2*Math.sqrt(Math.abs(x));
  ret += (20.0*Math.sin(6.0*x*Math.PI) + 20.0*Math.sin(2.0*x*Math.PI)) * 2.0/3.0;
  ret += (20.0*Math.sin(y*Math.PI) + 40.0*Math.sin(y/3.0*Math.PI)) * 2.0/3.0;
  ret += (160.0*Math.sin(y/12.0*Math.PI) + 320*Math.sin(y*Math.PI/30.0)) * 2.0/3.0;
  return ret;
}
function transformLng(x, y) {
  var ret = 300.0 + x + 2.0*y + 0.1*x*x + 0.1*x*y + 0.1*Math.sqrt(Math.abs(x));
  ret += (20.0*Math.sin(6.0*x*Math.PI) + 20.0*Math.sin(2.0*x*Math.PI)) * 2.0/3.0;
  ret += (20.0*Math.sin(x*Math.PI) + 40.0*Math.sin(x/3.0*Math.PI)) * 2.0/3.0;
  ret += (150.0*Math.sin(x/12.0*Math.PI) + 300.0*Math.sin(x/30.0*Math.PI)) * 2.0/3.0;
  return ret;
}
function wgs84ToGcj02(lng, lat) {
  var a=6378245.0, ee=0.00669342162296594323;
  var dLat=transformLat(lng-105.0, lat-35.0), dLng=transformLng(lng-105.0, lat-35.0);
  var radLat=lat/180.0*Math.PI, magic=Math.sin(radLat);
  magic=1-ee*magic*magic; var sqrtMagic=Math.sqrt(magic);
  dLat=(dLat*180.0)/((a*(1-ee))/(magic*sqrtMagic)*Math.PI);
  dLng=(dLng*180.0)/(a/sqrtMagic*Math.cos(radLat)*Math.PI);
  return {lng: lng+dLng, lat: lat+dLat};
}
function wgs84ToBd09(lng, lat) {
  var gcj=wgs84ToGcj02(lng, lat), x=gcj.lng, y=gcj.lat;
  var z=Math.sqrt(x*x+y*y)+0.00002*Math.sin(y*Math.PI);
  var theta=Math.atan2(y,x)+0.000003*Math.cos(x*Math.PI);
  return {lng: z*Math.cos(theta)+0.0065, lat: z*Math.sin(theta)+0.006};
}
```

## 导航链接模板

```javascript
const {lat, lng} = item;          // WGS-84 原始
const gcj = wgs84ToGcj02(lng, lat);
const bd  = wgs84ToBd09(lng, lat);

// 高德：coordinate=gaode 表示传入的是 GCJ-02
`https://uri.amap.com/marker?position=${gcj.lng},${gcj.lat}&name=${name}&coordinate=gaode`

// 百度：coord_type=bd09ll
`https://api.map.baidu.com/marker?location=${bd.lat},${bd.lng}&title=${name}&content=${name}&output=html&coord_type=bd09ll`

// 腾讯：GCJ-02
`https://apis.map.qq.com/uri/v1/marker?marker=coord:${gcj.lat},${gcj.lng};title:${name}&referer=trip`

// Apple：WGS-84 原始
`https://maps.apple.com/?q=${name}&ll=${lat},${lng}`
```

## 常见坑

- 高德 `coordinate=gaode` = 告诉高德"我传的已经是 GCJ-02"，如果传 WGS-84 会双重偏移
- 百度 `coord_type=gcj02` 是错的（模板旧版用了这个），应该是 `bd09ll`
- 腾讯地图的 coord 参数顺序是 `lat,lng`（不是 lng,lat）
