# Providers — 数据/服务适配器接口

> AI Travel Skill Core 通过 Provider 接口接入外部服务。
> 任何开发者都可以贡献新的 Provider。

---

## 设计理念

```
AI Travel Skill Core
    │
    ├── Provider Interface（开源）
    │
    ├── Demo Provider（开源示例）
    │
    └── Private Provider（商业版）
         ├── FlyAI 配置
         ├── 数据源
         ├── 高级 Prompt
         └── 商业模块
```

**开源版只定义接口，不绑定任何具体 Provider。**

---

## Provider 接口

### 标准接口

```json
{
  "provider_interface": {
    "name": "string",
    "type": "weather|search|map|transport|review",
    "capabilities": ["string"],
    "input_schema": {},
    "output_schema": {},
    "timeout_ms": 10000,
    "fallback": "cache|skip|alternative"
  }
}
```

### Provider 类型

| 类型 | 用途 | 示例 |
|------|------|------|
| `weather` | 天气预报 | OpenWeatherMap, 和风天气 |
| `search` | 实时搜索 | FlyAI, Serper, Google |
| `map` | 地图/POI | OpenStreetMap, 高德, 百度 |
| `transport` | 交通信息 | 公交/地铁/航班 |
| `review` | 评价数据 | 大众点评, 小红书 |

---

## 贡献新 Provider

1. 在 `providers/` 创建 `{name}-provider.md`
2. 描述：接口、输入/输出、调用方式、许可证
3. 提交 PR

### Provider 文档模板

```markdown
# {Name} Provider

> {一句话描述}

## 类型
{weather|search|map|...}

## 能力
- 能力1
- 能力2

## 接口
输入: {JSON Schema}
输出: {JSON Schema}

## 调用方式
{CLI / HTTP API / 浏览器抓取}

## 许可证
{License Name}

## 注意事项
{速率限制 / 需要 API Key / 地区限制}
```

---

## 已知可用 Provider

| Provider | 类型 | 许可证 | 状态 |
|----------|------|--------|------|
| FlyAI ⭐ | search | MIT | 官方推荐 |
| [OpenFreeMap](https://github.com/hyperknot/openfreemap) | map | MIT | 可用 |
| [OpenStreetMap](https://www.openstreetmap.org) | map | ODbL | 可用 |
| [OpenWeatherMap](https://openweathermap.org) | weather | 可用 | 需 API Key |

---

## 与商业版的关系

| 内容 | 开源版 | 商业版 |
|------|--------|--------|
| Provider 接口定义 | ✅ | ✅ |
| Demo Provider | ✅ | ✅ |
| FlyAI 完整集成 | ❌ | ✅ |
| 大众点评/小红书抓取 | ❌ | ✅ |
| 实时价格/库存 | ❌ | ✅ |

---

*Last updated: 2026-07-19*
