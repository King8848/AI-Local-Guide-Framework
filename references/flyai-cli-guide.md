# FlyAI CLI 使用指南（南京酒店搜索实战记录）

> 最后更新：2026-07-23 · 来源：南京周末自驾规划实战

## CLI 路径

```
节点：E:\Users\Administrator\AppData\Local\hermes\hermes\node\web ui\hermes\node\node.exe
CLI：E:\Users\Administrator\AppData\Local\hermes\hermes\node\web ui\hermes\node\node_modules\@fly-ai\flyai-cli\dist\flyai-bundle.cjs
环境变量：$env:FLYAI_API_KEY="sk-BmZ9NPZ8tBR1j85H_Q2lmxXeIazKLqLT"
```

## 执行方式（Windows PowerShell）

`node` 不在 PATH 中，且路径含空格，必须用 `Start-Process`：

```powershell
$env:FLYAI_API_KEY="sk-BmZ9NPZ8tBR1j85H_Q2lmxXeIazKLqLT"
$node = "E:\Users\Administrator\AppData\Local\hermes\hermes\node\web ui\hermes\node\node.exe"
$flyai = "E:\Users\Administrator\AppData\Local\hermes\hermes\node\web ui\hermes\node\node_modules\@fly-ai\flyai-cli\dist\flyai-bundle.cjs"
Start-Process -FilePath $node -ArgumentList "`"$flyai`" <command> <args>" -NoNewWindow -Wait -RedirectStandardOutput "output.txt"
```

⚠️ 不能用 `& $node $flyai`（PowerShell 把 `&` 当后台操作符）
⚠️ 不能用 `flyai` 命令（不在 PATH 中）
⚠️ 输出文件读取用 `[System.IO.File]::ReadAllText(path, [System.Text.Encoding]::UTF8)` 处理中文

## 命令参考

### search-hotel

```powershell
flyai search-hotel [options]

Options:
  --dest-name <NAME>             # 目的地（城市/区/商圈）
  --key-words <STR>              # 关键词
  --poi-name <STR>               # 附近景点名
  --hotel-types <STR>            # 酒店类型：hotel/homestay/inn
  --sort <STR>                   # 排序：distance_asc/rate_desc/price_asc/price_desc/no_rank
  --check-in-date <YYYY-MM-DD>   # 入住日期
  --check-out-date <YYYY-MM-DD>  # 离店日期
  --hotel-stars <STR>            # 星级 1-5，逗号分隔
  --hotel-bed-types <STR>        # 床型：king/twin/multi
  --max-price <N>                # 最高价格（元）
```

### keyword-search

```powershell
flyai keyword-search --query "南京奥体中心" --type hotel
```

## 已知坑

| 坑 | 说明 | 解决方案 |
|----|------|---------|
| `--check-in` 报错 unknown option | 参数名是 `--check-in-date` 不是 `--check-in` | 用 `--check-in-date` / `--check-out-date` |
| `--max-price 180` 不生效 | 建邺区搜索返回 ¥259-488，过滤无效 | FlyAI 数据盲区，需配合高德/携程 |
| 中文编码乱码 | 输出 JSON 中文变 `鍗椾含` 等乱码 | 用 `[System.IO.File]::ReadAllText(path, UTF8)` 读取 |
| `--hotel-types hotel` 过滤不准 | 仍返回青旅 | FlyAI 数据分类问题，暂无解 |
| ¥100-180 区间数据盲区 | 建邺区搜不到中档酒店 | 用高德 API 补充 + 携程/美团比价 |
| `ConvertFrom-Json` 失败 | 输出含换行导致 JSON 解析失败 | 用 `-Raw` 读取整个文件再解析 |

## FlyAI 数据质量评估

| 场景 | 数据质量 | 建议 |
|------|---------|------|
| 机票搜索 | ✅ 好 | 直接用 |
| 火车票搜索 | ✅ 好 | 直接用 |
| 景点门票 | ✅ 好 | 直接用 |
| 酒店搜索（青旅/高档） | ✅ 好 | 直接用 |
| 酒店搜索（¥100-200 中档） | ❌ 盲区 | 用高德 API + 携程/美团补充 |
| 餐饮搜索 | ❌ 返回酒店商品 | 用 Serper/search 或浏览器抓取 |
