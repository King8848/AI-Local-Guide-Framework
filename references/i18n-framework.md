# i18n 国际化框架（HTML 攻略模板）

> 来源：2026-07-18 上海攻略迭代——用户提出"中英版"需求
> 适用：`template.html` 模板

## 设计原则

- **框架搭好，内容按需填充**：国内路线只填中文，国际路线才写英文
- **数据层双语**：用 `t()` helper 函数，字符串原样返回，对象按 `lang` 取值
- **UI 控件全量翻译**：30+ 条标签覆盖所有界面元素

## 架构

```
lang='zh' (默认)
    │
    ├── uiLabels.zh / uiLabels.en  ← UI 控件双语
    ├── t(obj)                     ← 数据层翻译函数
    └── toggleLang()               ← 切语言时刷新所有 UI
```

## toggleLang() 更新范围

切换语言时更新以下元素：
1. 4 个标签页按钮文本
2. 地图控件（定位/放大/收起/关闭）
3. 地图跳转链接（高德/百度/腾讯）
4. 水印文字
5. `renderContent()` 重新执行（内容区刷新）

## 数据层用法

### 国内路线（只填中文，t()原样返回）

```javascript
const daysData = [{ d:1, sub:"静安寺→巨鹿路", segs:[{ti:"老盛兴汤包馆", de:"本地人扎堆..."}] }];
```

### 国际路线（填双语，t()按lang取值）

```javascript
const daysData = [{ d:1, sub:{zh:"新宿→涩谷",en:"Shinjuku → Shibuya"}, segs:[{ti:{zh:"一兰拉面",en:"Ichiran Ramen"}, de:{zh:"24小时营业",en:"Open 24h"}}] }];
```

### t() 函数

```javascript
function t(obj){ return typeof obj==='object'&&obj!==null?(obj[lang]||obj.zh||''):obj }
```

## 语言按钮

- 位置：侧边栏 header 右上角（主题按钮左侧）
- 文本：中文模式显示 `EN`，英文模式显示 `中`

## 注意事项

- 国内路线零改动：字符串数据 t() 原样返回
- 餐厅名/地址不翻译：品牌名就是品牌名
- 地图 POI 标签不翻译
- 水印必须双语：aiNote + aiBy 始终跟随语言切换
