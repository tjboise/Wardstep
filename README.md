# Wardstep

一款 Roguelite 空间策略防御游戏，目标平台 Steam。

玩家**自由摆放**最多 9 个格子，拼出任意形状的巡逻路线（L形、十字、环形……）。骑士自动沿路径踩格，触发格子上的武器攻击敌人；每个格子可独立附魔强化效果。选择不同角色职业，与武器类型产生天然协同。8大关，地形各异，步步为营，守卫城堡。

---

## 可玩 Demo

**[Demo HTML · 当前分支 / Current branch](demo/index.html)** — 第一大关完整体验（2小关 + 精英关 + Boss关）

## 设计文档

- [游戏设计文档 GDD](docs/GDD.md) — 完整设计规格（世界背景·核心机制·全系统）
- [开发路线图](docs/roadmap.md) — 16 个月计划，Godot 4 引擎，TJ + Wei Sun 分工

## 在线预览 / Online Preview

图鉴名称链接通过 HTML Preview 直接显示 WS_dev 分支的界面，无需下载或启动本地服务器。页面列保留相对源码链接，跟随 GitHub 当前浏览的分支。

Catalogue title links render the WS_dev interface through HTML Preview, with no download or local server required. The file links remain relative and follow the branch currently viewed on GitHub.

在线预览链接明确固定为 WS_dev；第三方服务可能有短暂缓存。此方案不修改 main 或现有 GitHub Pages 发布配置。

Online preview links explicitly target WS_dev. The third-party preview service may briefly cache updates. This setup does not change main or the existing GitHub Pages configuration.

[线上 Demo / Published Demo](https://tjboise.github.io/Wardstep/demo/) 仍由 main 发布。 / Still published from main.

## 设计资源

| 类别 | 页面 | 说明 |
|------|------|------|
| **[武器图鉴 · 在线预览](https://htmlpreview.github.io/?https://github.com/tjboise/Wardstep/blob/WS_dev/design/weapons/index.html)** | [design/weapons/](design/weapons/) | 12种武器（含6种新增双语设计）·三级升级数据 |
| **[附魔图鉴 · 在线预览](https://htmlpreview.github.io/?https://github.com/tjboise/Wardstep/blob/WS_dev/design/enchants/index.html)** | [design/enchants/](design/enchants/) | 5种附魔·三级效果·武器协同 |
| **[人物图鉴 · 在线预览](https://htmlpreview.github.io/?https://github.com/tjboise/Wardstep/blob/WS_dev/design/characters/index.html)** | [design/characters/](design/characters/) | 可选职业、专属被动、武器倾向 |
| **[遗物图鉴 · 在线预览](https://htmlpreview.github.io/?https://github.com/tjboise/Wardstep/blob/WS_dev/design/relics/index.html)** | [design/relics/](design/relics/) | 16件遗物·分五类·稀有度 |
| **[怪物图鉴 · 在线预览](https://htmlpreview.github.io/?https://github.com/tjboise/Wardstep/blob/WS_dev/design/monsters/index.html)** | [design/monsters/](design/monsters/) | 5种普通怪·16位Boss（8关各2位） |
| **[关卡图鉴 · 在线预览](https://htmlpreview.github.io/?https://github.com/tjboise/Wardstep/blob/WS_dev/design/stages/index.html)** | [design/stages/](design/stages/) | 8大关地形设计·敌人配置·攻略提示 |
| **[局外成长 · 在线预览](https://htmlpreview.github.io/?https://github.com/tjboise/Wardstep/blob/WS_dev/design/meta/index.html)** | [design/meta/](design/meta/) | 解锁进程·挑战诅咒·组合记忆 |
| **[音乐图鉴 · 在线预览](https://htmlpreview.github.io/?https://github.com/tjboise/Wardstep/blob/WS_dev/design/music/index.html)** | [design/music/](design/music/) | 4首程序性音轨设计（调性/BPM/音色层） |
| 源代码 | [src/](src/) | 引擎待定 |

## 开发日志

| 日期 | 里程碑 |
|------|--------|
| 2026-08-31 | 项目启动，核心玩法确定 |
| 2026-08-31 | 格子系统、铲子机制、8大关结构确定 |
| 2026-08-31 | 可玩 Demo：第一大关完整通关体验（遗物系统、精英关、Boss） |
| 2026-09-01 | 升级系统、连携机制、商店刷新递增费用 |
| 2026-09-02 | 玩法转型：玩家自由摆格·武器系统·附魔·职业差异化 |
| 2026-09-03 | 世界观确立：界碑传送叙事框架·16位Boss完整技能设计·局外成长三子系统 |
| 2026-09-04 | 开发路线图：Godot 4·16个月计划·TJ+Wei Sun分工·Steam上架清单 |

