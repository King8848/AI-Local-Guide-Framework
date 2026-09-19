# 训练过程与踩坑记录（Lessons Learned）

> 本文档记录 AI Local Friend 在实战迭代中踩过的坑。**每次使用本 skill 前必读**，避免重复犯错。
> 所有教训均来自真实 session，按"事故 → 根因 → 修复"结构记录。

---

## 一、数据源 / 图片（2026-08-27 血泪）

| 坑 | 根因 | 修复 |
|----|------|------|
| 联网图片全部加载失败 | **Wikimedia / Wikipedia 国内直接超时**（API 和图片 CDN 都不通） | 图片源改用国内可达图床（见下） |
| 以为"境外图床更稳定" | 大陆网络环境，境外 CDN 大面积超时 | 优先国内源 |

**国内可达图源（实测 200）：**
- ✅ 搜狐图床 `*.itc.cn` / `*.cdn.sohucs.com`（最稳、量大）
- ✅ 政府/官媒站：`*.gov.cn`、`bjd.com.cn`（北京日报）、`gmw.cn`（光明网）
- ✅ 各大门户新闻图床（人民网/新华网，注意 http/https）
- ❌ Wikimedia `upload.wikimedia.org`（国内超时）
- ❌ 境外 Unsplash / Tripadvisor（不稳定）

**验证图源可达性的命令：**
    Invoke-WebRequest -Uri "图片URL" -Method Head -TimeoutSec 12 -UseBasicParsing

**搜图工具**：agentkey 的 `Serper/searchImages`（走 agentkey 服务器，不依赖本机网络；本机 curl 搜图会超时）。

---

## 二、HTML 模板复用（血泪最多）

模板 `travel-control-template.html`（~2300 行，JSON 驱动）复用前**必须**改这几处，否则手机打开必挂：

| 坑 | 现象 | 修复 |
|----|------|------|
| **CDN 挂 unpkg** | 国内打不开，全白屏 | 全局替换 `unpkg.com/` → `cdn.jsdelivr.net/npm/`（Tailwind / Lucide / MapLibre 三处）|
| **地图 CartoCDN** | 地图一直转圈/超时 | `buildStyle()` 改成 `return 'https://tiles.openfreemap.org/styles/liberty'` |
| **图片挂了白屏** | 卡片图空白 | CSS 用 `linear-gradient(...), url('图')` 叠加，图挂了降级到渐变 |
| 导航菜单 4 图 | 百度/腾讯用不上 | `openNavSheet` 数组按需砍（跟团只留高德 + Apple）|
| 卡片要背景图 | 模板行程卡是纯文字 | 数据加 `image` 字段，`renderItinerary` 里插 `${item.image ? ... : ''}` |
| 坐标偏移 | POI 标点飘 | 数据必须 **WGS-84**（GPS 原始坐标），导航链接自动转 GCJ-02/BD-09 |

**tab 结构映射**：模板 4 tab = 行程 / 清单 / 预算 / 指南。改成自定义 tab 时，四处联动都要改：button 标签+图标、div 内容、`switchTab` 数组、render 函数。砍计算器要同时删按钮 + overlay + 监听，否则 init 报 null。

---

## 三、验证（无 playwright 时）

本机 **playwright / puppeteer 都没装**，但系统必有 Edge：

    # 手机尺寸截图
    Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList '--headless=new','--disable-gpu','--screenshot=E:\_p.png','--window-size=390,844','--virtual-time-budget=12000','file:///E:/_p.html' -NoNewWindow -Wait

    # 验证 JS 渲染后的 DOM（防白屏）
    Start-Process ... -ArgumentList '--headless=new','--dump-dom',... -RedirectStandardOutput "E:\_dom.txt" -NoNewWindow -Wait

- 用 `Start-Process -NoNewWindow -Wait`（不要用 `and` 号后台语法，会被误判）
- `--virtual-time-budget` 给 JS/地图留渲染时间
- `--dump-dom` 输出含 day-card + 景点名 = 渲染成功
- Edge 报的 QQBrowser/USB ERROR 是无关噪声

---

## 四、内容 / 偏好

| 坑 | 教训 |
|----|------|
| 跟团游 ≠ 自驾 ≠ 自由行 | 跟团是"一车一导、行程固定"，只能**置景**官方行程，不能重排；自驾才能给停车/绕路方案 |
| 偏好是光谱不是开关 | "不想天天吃甜" ≠ "只吃辣"，中间地带永远存在 |
| 拍照是核心需求 | 和美食、游玩同等重要，必须在规划阶段嵌入（几点去/穿什么/怎么摆）|
| 晚上 ≠ 早睡也不 = 夜店 | 轻度散步即可，平衡处理 |
| 范围失控 | **只改要求改的**，不多删不多加，清理残留前先问 |

---

## 五、工作流

| 坑 | 教训 |
|----|------|
| 大段替换 HTML 用错工具 | 含引号/转义的 HTML 大段替换，用 **Python `str.replace`**，不用 patch 工具（转义陷阱）|
| PowerShell 后台误判 | 命令里出现 `and` 符号（&）会被当成后台操作符，改用 `Start-Process`，或拆分命令 |
| 中文路径读取 | 用 `read_file` 工具或 Python `open(..., encoding=utf-8)`；PowerShell `Get-Content -Encoding UTF8` 也可 |

---

## 六、开源合规

- 开源前**必须审计密钥**：`Select-String -Pattern "sk-[A-Za-z0-9]{10,}"`
- 本项目的 FlyAI key 与微信联系方式按作者要求**保留**（微信以暗水印形式存在模板中）
- LICENSE 用 `LICENSE`（无扩展名），Apache 2.0 必须配 `NOTICE`
- GitHub 建仓库选 **None**（不用语言模板），.gitignore 自定义

---

*最后更新：2026-08-27 · 每次 session 结束追加新踩的坑*

---

## 七、开源上传踩坑（2026-08-27）

| 坑 | 教训 |
|----|------|
| `.gitignore` 误拦源码示例 | 产物规则（如 `examples/*.html`）会连**源码示例**一起拦掉。上传后必做「工作区文件数 vs 远程文件数」比对；用 `git check-ignore -v <文件>` 定位规则。本次就漏传了 1 个示例，靠 100 vs 99 才发现 |
| 覆盖式上传保留历史 | 清空仓库目录时**保留 `.git`**，旧内容仍在历史里可回滚；用普通 commit（非 force push）覆盖更安全 |
