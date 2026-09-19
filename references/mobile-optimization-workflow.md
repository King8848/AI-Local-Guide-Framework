# 移动端优化工作流（2026-07-20 实战）

## 标准工作流（最重要）

```
1. 用户提需求 → AI 先讨论方案，确认范围后再动手
2. 只改 15dayShangHaiTrip.html（实例文件），绝不碰 template.html
3. 浏览器预览验证 → 用户认可
4. git commit + 同步到 template.html
```

**反例**：未确认就改 template.html → 破坏桌面端 → 用户说"是不是做项目不记不读取大脑的"

## 原则

**桌面端已完善的界面不动。移动端优化 = 纯增量改动。**

## JS 改动规范

```javascript
// 1. 工具函数
function isMobile(){ return window.innerWidth <= 768 }

// 2. 受影响的函数：在函数体内分叉
function toggleMap(show){
  if(isMobile()){
    // 移动端：新逻辑（浮球系统）
    const fm = document.getElementById('floatMap');
    const mb = document.getElementById('mapBubble');
    // ... mobile-only logic
  } else {
    // 桌面端：原逻辑（floatMapBtn）
    const fm = document.getElementById('floatMap'), fb = document.getElementById('floatMapBtn');
    // ... original desktop logic, DO NOT MODIFY
  }
}

// 3. 新增函数：只在移动端有意义
function cycleMapTier(){ /* 仅移动端调用 */ }
function minimizeMapToBubble(){ /* 仅移动端调用 */ }
```

## CSS 改动规范

```css
/* 桌面端：显式隐藏移动专有元素 */
.map-tier-btn { display: none; }
#mapBubble { display: none; }
#navMenu { display: none; }

/* 移动端 @media：覆盖隐藏规则 */
@media (max-width: 768px) {
  .map-tier-btn { display: inline-block !important; }
  #mapBubble.show { display: flex; }
  #navMenu.show { display: block; }
  
  /* 移动端独有样式放这里，不要碰桌面端原有规则 */
}
```

## HTML 改动规范

- 只加新元素（`#mobile-topbar`、`#mapBubble`、`#navMenu`），不删旧元素
- 共享元素（`#floatMap` header 按钮）通过 CSS 控制桌面/移动显示
- 桌面端 `display:none` 默认隐藏新元素，移动端 `@media` 覆盖显示

## 文件同步规范

- template.html 改动后，一次性用 Python 脚本同步到 15dayShangHaiTrip.html
- 不要用多次 patch 逐行改——累积误差会导致 JS 语法错误
- 对于有真实数据的文件（如 Shanghai），用「模板 + 数据提取 + 占位符替换」重建，不逐段替换

## 🔴 关键 CSS 作用域陷阱

JS 添加 `classList.add('show')` 后元素不显示，最常见的原因是 **`.show` 规则只写在了移动端 `@media` 里**。

```css
/* ❌ 错误：.show 只在 @media 内 */
@media (max-width: 768px) {
  #navMenu.show { display: block; }
}
/* 桌面端点 🧭 后 show class 加了但 display:none 没被覆盖 */

/* ✅ 正确：.show 必须在 @media 外也定义一份 */
#navMenu { display: none; }
#navMenu.show { display: block; }  /* 桌面端也生效 */
@media (max-width: 768px) {
  #navMenu.show { display: block; }  /* 移动端也生效 */
}
```

**通用法则**：任何有 `.show` / `.open` / `.active` 类切换的元素，display 规则必须同时存在于：
1. 桌面端 CSS（`@media` 外）— 定义默认隐藏 + `.show` 显示
2. 移动端 CSS（`@media` 内）— 覆盖尺寸/位置等移动特有样式

## 验证清单

- [ ] 桌面端 `floatMapBtn` 可见且可点击打开地图
- [ ] 桌面端地图按钮文字、交互逻辑与改动前一致
- [ ] 模板 `{{DAYS}}` 等占位符在重建后全部替换为真实值
- [ ] `</script></body></html>` 关闭标签完整
- [ ] JS 零语法错误（`browser_console`）
- [ ] `daysData`、`dayRoutes`、`guideModules` 在 `window` 上可访问

## MapLibre GL 移动端配置

```javascript
map=new maplibregl.Map({
  container:'floatMapBody',
  style:'https://tiles.openfreemap.org/styles/liberty',
  scrollWheelZoom:!isMobile(),  // 桌面滚轮缩放，移动端禁用（防页面滚动冲突）
  dragRotate:!isMobile()        // 移动端禁双指旋转
});
```

## 触控友好 CSS

```css
/* viewport */
<meta name="viewport" content="..., user-scalable=no">

/* 移动端 @media */
@media (max-width: 768px) {
  .maplibregl-ctrl-group button { width:44px!important; height:44px!important; }
  .maplibregl-popup-content { font-size:15px!important; padding:12px 16px!important; }
}
```

## 开源版水印广告（2026-07-20 决策）

用户明确要求：开源版加水印，引导用户升级定制版。**方案 A（第三条水印）已通过。**

### 实现

```html
<!-- template.html 第 ~1280 行 -->
<div id="watermark">
  <span>AI生成仅供参考，以实际情况为准</span>
  <span>AI Local Friend 出品</span>
  <span id="wm-upgrade" onclick="window.open('https://github.com/King8848/AI-Local-Guide-Frameworl#联系方式','_blank')">
    升级定制 · 更多功能 · 1v1专业定制
  </span>
</div>
```

### i18n

```javascript
const uiLabels = {
  zh: { /* ... */ upgrade:'升级定制 · 更多功能 · 1v1专业定制' },
  en: { /* ... */ upgrade:'Upgrade · More Features · 1v1 Custom' }
};
```

### CSS

```css
#wm-upgrade {
  pointer-events: auto !important;  /* 覆盖父级 pointer-events:none */
  cursor: pointer;
  opacity: 0.4;
  transition: opacity 0.2s;
}
#wm-upgrade:hover { opacity: 1 !important; text-decoration: underline; }
```

### toggleLang 更新第三 span

```javascript
if(wm){
  wm.querySelector('span:first-child').textContent=uiLabels[lang].aiNote;
  wm.querySelector('span:nth-child(2)').textContent=uiLabels[lang].aiBy;  // 注意是 nth-child(2) 不是 last-child
  wm.querySelector('span:last-child').textContent=uiLabels[lang].upgrade;
}
```

### 实现状态

- **决策**：✅ 通过（用户确认「是的」）
- **执行**：⏳ 等待 write_file/patch 工具恢复后执行

## Git 工作流

- 仓库：`E:\AI Projects\travel-skill-repo\`
- 每次改动后 commit，未 commit 的可用 `git checkout` 恢复
- 用户认可后才 commit；commit message 写清楚改动范围（移动端/桌面端不动）
