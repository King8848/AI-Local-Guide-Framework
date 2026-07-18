# Trip Engine Usage

> 如何使用模板引擎生成 HTML 攻略页面

---

## 使用流程

1. Planner Engine 产生 TripData JSON
2. TripData JSON 注入到 templates 中的 HTML 模板
3. 生成最终 HTML 文件

---

## 占位符语法

| 语法 | 说明 |
|------|------|
| `{{CITY}}` | 城市名 |
| `{{DAYS}}` | 天数 |
| `{{DATE}}` | 生成日期 |
| `{{STYLE}}` | 旅行风格 |
| `{{DAYS_LOOP_START}} ... {{DAYS_LOOP_END}}` | 循环每天行程 |
| `{{DAY_NUM}}` | 当天序号（1, 2, 3...） |
| `{{DAY_THEME}}` | 当天主题 |
| `{{DAY_AREA}}` | 当天主区域 |
| `{{ACTIVITIES_LOOP_START}} ... {{ACTIVITIES_LOOP_END}}` | 循环活动 |
| `{{TIME}}` | 活动时间 |
| `{{NAME}}` | 活动名称 |
| `{{COST}}` | 费用 |
| `{{NOTE}}` | 补充说明 |

---

## 自定义主题

开发者可创建自己的 HTML 模板：

1. 复制 `templates/demo.html`
2. 修改 CSS 变量或整体设计
3. 保留所有必需占位符
4. 命名为 `my-theme.html` 放入 templates 目录

### CSS 变量

```css
:root {
  --bg: #f8f9fa;          /* 背景色 */
  --text: #212529;        /* 文字色 */
  --accent: #0d6efd;      /* 强调色 */
  --card: #ffffff;        /* 卡片背景 */
  --border: #dee2e6;      /* 边框色 */
}
```

---

## TripData → HTML 示例

### 输入（TripData）
```json
{
  "city": "杭州",
  "days": 3,
  "route": [
    {
      "day": 1,
      "theme": "西湖经典",
      "area": "西湖周边",
      "items": [
        {"time": "09:00-11:30", "name": "断桥残雪", "cost": "免费"},
        {"time": "14:00-17:00", "name": "苏堤春晓", "cost": "免费"}
      ]
    }
  ]
}
```

### 处理逻辑（伪代码）
```
for each day in route:
    fill DAY_NUM, DAY_THEME, DAY_AREA
    for each item in day.items:
        fill TIME, NAME, COST, NOTE
```

### 输出
浏览器打开即可看到：
- 每天一个卡片
- 每段行程一行
- 费用标注
- 预算汇总
- 避坑提醒

---

## 协作开发模板

欢迎贡献不同风格的模板！

**方向**：
- 🗺️ 地图嵌入模板（含路线可视化）
- 📊 预算仪表盘模板
- 📱 移动端优先模板
- 🌙 暗夜模式模板
- 🧳 行李清单专用模板

---

*Last updated: 2026-07-19*
