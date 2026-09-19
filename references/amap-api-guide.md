# 高德地图 API 集成指南

> 高德地图 Web API 是 ai-local-friend 的核心 POI 数据源之一，免费额度充足，国内数据最全。

## API Key

用户需自行申请：https://lbs.amap.com/ → 控制台 → 创建应用 → 获取 Web 服务 key
配置方式：调用时拼入 URL 参数 `key=$env:AMAP_API_KEY`（环境变量）或用户手动提供

## 核心接口

### 1. 关键词搜索 `/v3/place/text`

搜索城市内的 POI（景点/餐厅/酒店/停车场等）。

```
GET https://restapi.amap.com/v3/place/text
  ?key=xxx
  &keywords=景点
  &city=南京
  &types=风景名胜
  &offset=20
  &page=1
  &extensions=all
```

**常用 types 编码**：
| 类型 | types 值 |
|------|----------|
| 风景名胜 | 110000 |
| 餐饮服务 | 050000 |
| 住宿服务 | 100000 |
| 交通设施-停车场 | 150900 |
| 江浙小吃 | 050100 |
| 中餐厅 | 050100 |
| 粉丝汤 | 050100 |
| 快餐 | 050300 |

### 2. 周边搜索 `/v3/place/around`

以某个坐标为中心搜索附近 POI，适合"奥体中心附近找酒店/停车场"。

```
GET https://restapi.amap.com/v3/place/around
  ?key=xxx
  &location=118.737,32.003    ← 经度,纬度
  &keywords=酒店
  &radius=3000                 ← 搜索半径（米）
  &offset=20
  &extensions=all
```

**注意**：`location` 格式是 `经度,纬度`（不是纬度,经度）。

### 3. POI 详情（需 ID）

从搜索结果中获取 `id` 字段后，可查询详情。

## 返回字段说明

`extensions=all` 时返回完整信息：

| 字段 | 说明 | 示例 |
|------|------|------|
| `name` | POI 名称 | "古鸡鸣寺" |
| `address` | 地址 | "鸡鸣寺路1号" |
| `location` | 坐标 | "118.795246,32.061061" |
| `biz_ext.rating` | 评分 | "4.8" |
| `biz_ext.cost` | 人均消费 | "24.00" |
| `biz_ext.open_time` | 营业时间 | "07:30-17:00" |
| `biz_ext.opentime2` | 详细营业时间 | "周一至周日 07:30-17:00..." |
| `tel` | 电话 | "025-57715595" |
| `photos[].url` | 照片 URL | 高德 CDN 链接 |
| `type` | 类型 | "风景名胜;寺庙道观" |
| `keytag` | 标签 | "寺庙" |
| `adname` | 区名 | "玄武区" |
| `level` | 景区等级 | "AAAA" / "AAAAA" |

## PowerShell 调用模板

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$r = Invoke-WebRequest -Uri "https://restapi.amap.com/v3/place/text?key=$env:AMAP_API_KEY&keywords=景点&city=南京&types=风景名胜&offset=20&extensions=all" -UseBasicParsing
$json = $r.Content | ConvertFrom-Json
$json.pois | ForEach-Object {
    Write-Output "[$($_.name)] 评分:$($_.biz_ext.rating) 地址:$($_.address) 门票:$($_.biz_ext.cost) 电话:$($_.tel)"
}
```

## 周边搜索模板（找酒店/停车场）

```powershell
# 以奥体中心为中心，3km 内搜酒店
$r = Invoke-WebRequest -Uri "https://restapi.amap.com/v3/place/around?key=$env:AMAP_API_KEY&location=118.730,32.005&keywords=酒店&radius=3000&offset=20&extensions=all" -UseBasicParsing
```

## 照片 URL 用法

高德返回的照片 URL 可直接在浏览器/img 标签中使用：
```
https://store.is.autonavi.com/showpic/xxx
http://aos-cdn-image.amap.com/sns/ugccomment/xxx.jpg
```

用于 HTML 攻略模板中的 `<img>` 标签。

## 已知限制

- `biz_ext.cost` 酒店类 POI 通常为空（高德不提供房价）
- 酒店价格需结合携程/美团搜索获取
- 搜索结果最多 600 条（分页 offset+page）
- 照片 URL 可能有时效性

## 与其他数据源的配合

| 需求 | 首选 | 备选 |
|------|------|------|
| 景点/餐厅 POI | 高德 API | FlyAI search-poi |
| 酒店列表 | 高德 API（around） | FlyAI search-hotel |
| 酒店价格 | 携程/美团 web search | FlyAI（有价格但有时隐藏） |
| 停车场 | 高德 API（types=150900） | 大众点评浏览器 |
| 天气 | QWeather API | Open-Meteo（免费无 key） |
| 美食评价 | 高德评分 + 大众点评浏览器 | 小红书浏览器 |
