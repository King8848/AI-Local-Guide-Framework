# FlyAI Provider — 实时搜索适配器

> 用于酒店/机票/景点/火车票实时搜索。

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

## 调用方式

CLI 命令（需安装 `flyai-cli`）：

```bash
pip install flyai-cli

flyai search-hotel --dest-name "上海" --check-in "2026-08-01" --adults 2
flyai search-flight --from "NCK" --to "SHA" --date "2026-08-01"
flyai search-poi --dest-name "杭州" --query "西湖"
flyai search-train --from "南昌" --to "上海" --date "2026-08-01"
flyai keyword-search --query "成都火锅"
flyai ai-search --query "适合带老人去的杭州景点"
```

## 许可证
MIT

## 注意事项
- 需要安装 `flyai-cli`（`pip install flyai-cli`）
- 部分功能可能需要 API Key
- 响应时间：5-15秒
- 建议搭配缓存使用

---

*Last updated: 2026-07-19*
