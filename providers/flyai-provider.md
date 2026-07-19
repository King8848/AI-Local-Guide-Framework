# FlyAI Provider — 实时搜索适配器

> 🏨 **酒店 / ✈️ 机票 / 🚂 火车票** — 实时比价，精准推荐
> 
> 👉 [立即使用 FlyAI](https://flyai.com) — 预订酒店、度假商品享优惠

---

## 类型

search

## 能力

- 酒店搜索
- 机票搜索
- 景点搜索
- 火车票搜索
- 关键词搜索
- AI 语义搜索

## 架构

本 Provider 采用**代理模式**，API Key 由代理服务统一管理，不暴露至客户端：

```
开源项目 (GitHub)
├── providers/
│   └── flyai-provider.md    ← 调用逻辑（无 key）
├── .env.example              ← 配置模板
└── proxy-server/             ← 代理服务端（可选）
    └── flyai-proxy.py        ← 持有 key，对外提供接口
```

### 两种使用方式

| 用户类型 | 方式 | 安全 |
|----------|------|------|
| **自己/高级用户** | 本地跑 CLI，`.env` 填 key | ✅ key 不暴露 |
| **普通用户** | 连你的代理服务 | ✅ key 在服务端 |

---

## 接口

### 输入

```json
{
  "command": "search-hotel|search-flight|search-poi|search-train|keyword-search|ai-search",
  "params": {
    "dest_name": "string",
    "check_in": "YYYY-MM-DD",
    "check_out": "YYYY-MM-DD",
    "adults": 1
  }
}
```

### 输出

```json
{
  "status": "success",
  "data": {
    "items": [
      {
        "name": "string",
        "price": "string",
        "rating": "number",
        "location": "string"
      }
    ]
  }
}
```

---

## 配置

### 方式一：本地 CLI（推荐高级用户）

1. 复制 `.env.example` 为 `.env`
2. 填入你的 FlyAI API Key：
   ```bash
   FLYAI_API_KEY=***
   ```
3. CLI 会自动读取环境变量

### 方式二：代理服务（推荐开源项目）

1. 部署代理服务，配置 `FLYAI_API_KEY`
2. 开源项目配置代理端点：
   ```bash
   FLYAI_PROXY_URL=https://your-proxy.com/api
   ```
3. 用户调用代理服务，key 不暴露

---

## CLI 命令

```bash
pip install flyai-cli

flyai search-hotel --dest-name "上海" --check-in "2026-08-01" --adults 2
flyai search-flight --from "NCK" --to "SHA" --date "2026-08-01"
flyai search-poi --dest-name "杭州" --query "西湖"
flyai search-train --from "南昌" --to "上海" --date "2026-08-01"
flyai keyword-search --query "成都火锅"
flyai ai-search --query "适合带老人去的杭州景点"
```

---

## 推广者入驻

**成为推广者，获取佣金收益：**

1. **申请入驻** — 在飞猪控制台申请成为推广者
2. **获取 API Key** — 控制台获取正式 Key，配置至 Skill 中
3. **用户购买** — 用户通过你的 Agent 预订飞猪商品
4. **佣金归因** — 系统自动完成佣金归因
5. **查看收益** — 前往控制台查看收益，进行佣金提现

### 收益说明

- **收益来源**：用户通过你的 Agent 预订飞猪商品所产生的佣金
- **支持分佣商品**：酒店、度假类商品
- **暂不参与分佣**：交通类商品

---

## 许可证

MIT

## 注意事项

- 需要安装 `flyai-cli`（`pip install flyai-cli`）
- 部分功能可能需要 API Key
- 响应时间：5-15秒
- 建议搭配缓存使用
- ⚠️ **安全提示**：API Key 仅限服务器/CLI 使用，请勿暴露在前端代码中

---

*Last updated: 2026-07-19*
