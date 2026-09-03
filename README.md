# Wardstep

一款 Roguelite 卡牌构筑策略防御游戏，目标平台 Steam。

在一张不断扩展的格子地图上放置符文，守卫中心核心。小人自动巡逻踩格触发符文效果，怪物从四面涌来。买铲子扩格子，买符文堆构筑，赢 Boss 拿稀有牌，撑过 8 大关。

---

## 可玩 Demo

**[▶ 立即游玩](https://tjboise.github.io/Wardstep/demo/)** — 第一大关完整体验（2小关 + 精英关 + Boss关）

## 设计文档

- **[互动设计文档](https://tjboise.github.io/Wardstep/docs/design.html)** — 含格子演示、卡牌、关卡结构（网页版）
- [游戏设计文档 GDD](docs/GDD.md) — 完整设计规格
- [符文系统 & 连携设计](docs/rune-system.md) — 符文等级、7种二连携、3种三连携、策略构筑举例

## 设计资源

| 类别 | 页面 | 说明 |
|------|------|------|
| **[符文图鉴](https://tjboise.github.io/Wardstep/design/runes/)** | [design/runes/](design/runes/) | 所有符文的完整设计，可搜索筛选 |
| **[音乐图鉴](https://tjboise.github.io/Wardstep/design/music/)** | [design/music/](design/music/) | 4首程序性音轨设计（调性/BPM/音色层/和弦） |
| 遗物图鉴 | [design/relics/](design/relics/) | 即将上线 |
| 怪物图鉴 | [design/monsters/](design/monsters/) | 即将上线 |
| 关卡设计 | [design/stages/](design/stages/) | 即将上线 |
| 源代码 | [src/](src/) | 引擎待定 |

## 开发日志

| 日期 | 里程碑 |
|------|--------|
| 2026-08-31 | 项目启动，核心玩法确定 |
| 2026-08-31 | 格子系统、铲子机制、8大关结构确定 |
| 2026-08-31 | 可玩 Demo：第一大关完整通关体验（遗物系统、精英关、Boss） |
| 2026-09-01 | 符文升级系统（Lv1/2/3 自动合成）、7种二连携 + 3种三连携、商店刷新递增费用 |

## 灵感来源

- **Balatro** — 遗物系统、局内累积感、随机构筑
- **Slay the Spire** — 卡牌升级路线、元进度
- **Hades** — 每局都有成长感
- 原版手机游戏 — 跑道 + 触发机制
