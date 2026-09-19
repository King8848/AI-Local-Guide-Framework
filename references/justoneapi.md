# JustOneAPI — 小红书/社交媒体数据源

> 来源：`https://justoneapi.com` | Apifox 文档：`https://zh.apifox.justoneapi.com/`

---

## ⚠️ 状态：注册关门，token 拿不到（2026-07-18 确认）

**本适配器停用。** 注册页面无法完成注册，无法获取 token。小红书数据源已回退到浏览器方案。

---

## 为什么需要它

ai-local-friend 需要小红书美食信号（热门打卡店、本地推荐），但：

- ❌ 浏览器直连 → IP 被拦（错误 300012）
- ❌ opencli xiaohongshu → 已废弃
- ❌ **JustOneAPI REST API** → 注册关门，token 拿不到
- ✅ **回退到 Hermes 浏览器方案** → `browser_navigate` + `browser_snapshot`，有降级链兜底

---

## 当前数据源决策（替代 JustOneAI 方案）

```
主数据源: 大众点评（浏览器）→ 硬信号（评分/排队/价格）
备数据源: 小红书（浏览器）→ 软信号（氛围/拍照/体验）
第三源:   FlyAI ai-search → 跨平台语义搜索
兜底:     本地知识库 → 不需要任何外部调用
```

### 已排除的方案

| 方案 | 排除原因 |
|------|---------|
| **JustOneAPI** | 注册关门，token 拿不到（2026-07-18 确认） |
| **Spider_XHS**（cv-cat/Spider_XHS） | 需要 Python 3.10+ + Node.js 20+、Cookie 2小时过期、签名算法维护、与 skill 零依赖设计矛盾 |
| **其他 GitHub 小红书爬虫** | 同上，全部需要 Cookie + 抗反爬维护 |

**核心原则**：skill 里的"数据源"= 告诉 Agent 去哪找。需要安装/维护/登录的方案都不适合。

---

## 原始文档（已废弃，留档）

以下内容保留供参考，实际已不可用。

### API 端点（对 ai-local-friend 最相关）

| 接口 | 路径 | 用途 |
|------|------|------|
| 小红书热榜 | `GET /api/xiaohongshu/hot-list/v1` | 当前热门话题 |
| 小红书笔记搜索 V2 | `GET /api/xiaohongshu/note-search/v2` | 关键词搜美食/景点笔记 |
| 小红书笔记详情 V2 | `GET /api/xiaohongshu/note-detail/v2` | 获取笔记正文+评论 |
| 小红书关键词建议 | `GET /api/xiaohongshu/keyword-suggest/v1` | 自动扩展搜索词 |
| 社交媒体跨平台搜索 | `GET /api/social-media/cross-platform-search/v1` | 多维搜(小红书+抖音+B站+微博) |

**服务器**：`https://api.justoneapi.com`（global）/ `http://47.117.133.51:30015`（cn）

### 认证

所有接口需要 `?token=xxx` 参数。**获取 token**：`https://console.justoneapi.com/` 注册 → 控制台获取。（已确认无法注册）
