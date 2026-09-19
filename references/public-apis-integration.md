# Public-APIs 集成参考（AI 地陪）

> 来源：GitHub `public-apis/public-apis` 仓库（730+ 免费 API）
> 用途：筛选出对旅行规划有实际价值的 API，提升攻略数据质量

---

## 已验证可用的 API

### 天气类

| API | 用途 | Auth | 国内可用 | 备注 |
|-----|------|------|---------|------|
| **QWeather** | 精准天气预报（3-30天） | apiKey | ✅ | 已集成到 Agentkey，每次 0.1 credit |
| **Open-Meteo** | 全球天气预报 | 无需 | ✅ | 非商用免费，适合备选 |
| **wttr.in** | 终端一行查天气 | 无需 | ✅ | `curl wttr.in/Nanjing?format=j1` |
| **ColorfulClouds (彩云天气)** | 国内最精准天气 | apiKey | ✅ | 分钟级降雨预报，适合出行决策 |
| **Sunrise-Sunset** | 日出日落时间 | 无需 | ✅ | 规划拍照黄金时段（日出后/日落前1h） |

### 地图/路线类

| API | 用途 | Auth | 国内可用 | 备注 |
|-----|------|------|---------|------|
| **openrouteservice** | 路线规划 + POI + 等时线 | apiKey | ✅ | 有限额，适合多点路线优化 |
| **GraphHopper** | A→B 路线 + 转弯导航 | apiKey | ✅ | 适合自驾路线计算 |
| **Google Maps** | 地图 + 地理编码 | apiKey | ⚠️ 需翻墙 | 国内用高德/百度替代 |
| **HERE Maps** | 地图数据 | apiKey | ✅ | 国际旅行适用 |

### 摄影/图片类

| API | 用途 | Auth | 国内可用 | 备注 |
|-----|------|------|---------|------|
| **Unsplash** | 参考拍照构图 | OAuth | ✅ | 搜索目的地图片参考构图 |
| **Pexels** | 免费素材 | apiKey | ✅ | 同上 |
| **Remove.bg** | 一键抠图 | apiKey | ✅ | 拍完照后期处理，有限额 |

### 旅行服务类

| API | 用途 | Auth | 国内可用 | 备注 |
|-----|------|------|---------|------|
| **Tripadvisor** | 餐厅/景点评分 | apiKey | ✅ | 国际旅行评分参考 |
| **Amadeus** | 机票/酒店搜索 | OAuth | ✅ | 有限额，国际旅行适用 |

---

## 实用组合

### 拍照规划组合
```
Sunrise-Sunset（算黄金时段） + QWeather（看天气是否适合外拍）
```

### 路线优化组合
```
openrouteservice（多点路线规划） + GraphHopper（实时导航）
```

### 美食决策组合
```
Tripadvisor（国际评分） + 大众点评浏览器（本地评价） + Serper/search（中文搜索）
```

### 照片后期组合
```
Remove.bg（抠图） + Unsplash（参考构图风格）
```

---

## 获取 Public-APIs 仓库内容的方法

当需要从 GitHub public-apis 仓库筛选特定类别 API 时：

```powershell
# 1. 下载 README
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$r = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/public-apis/public-apis/master/README.md" -UseBasicParsing -TimeoutSec 15
$r.Content | Out-File "temp-apis.txt" -Encoding UTF8

# 2. 搜索特定类别
Select-String -Path "temp-apis.txt" -Pattern "### Weather|### Transportation|### Photography|### Geocoding"

# 3. 读取匹配行的上下文
```

注意：PowerShell 中 `curl` 是 `Invoke-WebRequest` 的别名，不支持 `-s` 参数。必须用 `Invoke-WebRequest -UseBasicParsing`。

---

## 国内替代 API

Public-APIs 仓库主要收录国际 API，中国区场景建议用：

| 需求 | 推荐 API | 说明 |
|------|---------|------|
| 天气 | QWeather / 彩云天气 | 国内最准 |
| 地图 | 高德地图 API | 国内首选 |
| 停车场 | 高德 POI 搜索 | 搜索"停车场" |
| 公交/地铁 | 高德公交路线 | 含实时到站 |
| 景点 | 高德 POI + 大众点评 | 评分+评价 |
| 美食 | 大众点评 + 小红书浏览器 | 本地化最强 |

---

*最后更新：2026-07-23*
