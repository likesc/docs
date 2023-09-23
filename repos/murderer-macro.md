---
layout : default
title : murderer-macro(真凶宏) 使用文档
lang : zh-CN
permalink : /murderer-macro/
donate : "#支持"
date : 2023-09-23 17:29
---

此插件用于改善旧版本宏的使用, 仅适用于 WoW 1.12(vanilla) 客户端,
受 [CleverMacro](https://github.com/DanielAdolfsson/CleverMacro) 启发而作

名字之所以叫真凶, 是因为我最近关注了一些悬疑凶杀案(unsolved murders)

插件目前目前完成度为 99.99%, 仅供内部成员使用

## 安装

- 下载并且解压到游戏文件夹的 `Interface\AddOns\` 目录下

- 然后将目录名修改为 `murderer-macro`, 最后的文件结构大致如下:

  ```bash
  ├── Data ..
  ├── Documentation ..
  ├── Errors ..
  ├── Interface
  │     └── AddOns
  │           └── murderer-macro
  │                  ├── murderer-macro.lua
  │                  └── murderer-macro.toc
  ├── WDB ..
  ├── WTF ..
  ├── ...
  ├── WoW.exe
  ├── ...
  .
  ```

- 不要与同类型插件同时启用, 混合使用的结果是未知的, 你应该选择最适合自己的

  此插件与同类型插件是相互排斥的, 同类型插件有: `CleverMacro`, `Roid-Macro`, `MacroExtender`, `ClassicMacros`, `SuperMacro` 等等

### 兼容

此插件目前仅适用于暴雪**原有动作条**, 对于 `[@mouseover]` 的支持同样仅适用于原有的头像/血条框体,
而对于其它插件目前测试过兼容仅有:

- [x] `NotGrid` : 只大致看了下源码, 感觉不需要做任何兼容处理

- [x] `pfUI` : 只简单测试了下, 但补丁还未合并

### Bugs

- 初始化失败 : 当刚进入游戏如果看到 `murderer-macro failed to load, try '/console reloadui' or '/rl' to resolve it`

  按照提示重载一下应该就能解决

  > 这个问题是在刚进入游戏时此插件想要缓存动作条上的技能失败引起的,
  > 特别是当你删除了 WDB 目录下的文件时(游戏有更新时一般会要求你手动删除它们),
  > 因为一些技能例如 : "攻击" 的图标依赖于缓存里的武器数据
  >
  > 虽然我已经在第 50 个 commit 上采用了延迟的方法尝试解决, 但总是会有意外

- 条件选项 : `[cd]` 所对应的图标没有及时更新(目前而言我并不想添加太多的检测)

## 基础语法

除了 `#showtooltip`, `#show` 其它所有 `#` 开头的语句都会被当成注释而忽略
包括 `#CastSpellByName(...)` 也一样会被此插件忽略, 只是这个语句能被客户端识别到

[命令](#命令)

[条件选项](#条件选项)

如果你使用的是英文客户端, 那么要注意“技能/道具名字”的 **大小写** 必须完全和“技能书”或“背包”中显示的一样

还有要注意的是 [“宏图标”](#宏图标) 和 [“宏技能”](#宏技能) 是各自独立的,
也就是说你所看到的图标并不一定就是宏运行时的技能(所见并不一定即所得)

### 宏技能

当按下快捷键或者点击动作条, 宏所执行的技能

- “宏技能”是实时的因为它只在你按下按键或点击鼠标时才计算

- “宏技能”是稳定的因为其相关的代码非常简单

#### 宏技能限制

每一次按键或点击只能执行一个技能/道具, 这意味着一键爆发之类的宏将不可用,
也不能按一次就同时喝水吃面包。

当然有一些技能可以和别的技能组合同时执行, 例如: “攻击”, "自动射击"

此插件 **不支持** `/castsequence`, 需要通过 `[cd]` 检测技能 CD 或者
`[has]` 检测自身 buff 的方式将多个技能放置于同一个宏之中, 非常的繁琐

> 由于 WoW 1.12 客户端缺少 `UNIT_SPELLCAST_SENT` 事件因此放弃尝试实现 `/castsequence`

### 宏图标

当宏包含有 `#showtooltip` 或 `#show` 时, 在动作条上所显示的图标

- “宏图标”不是实时的, 有多个地方进行了延迟处理

- “宏图标”是不稳定的, 其代码过于复杂, 复杂就意味着潜在性的各种 BUG

- “宏图标”并不总是准确的, 因为缺乏相应的事件通知, 一些情况下图标并没有及时更新因此图标可能会是过时的

  例如: 条件选项: `[cd]`, 即使物品的 CD 已经好了但是“宏图标”并没有及时更新

如果 `#showtooltip` 后边为空, 那么将显示下一行命令的当前图标,
支持图标的命令只有: `/cast` , `/use`, `/equip`, `/eq`, `/施放`

#### 宏图标的局限性

1. 宏图标 **不能** 显示技能目标是否超出距离

2. 宏图标 **不能** 显示技能的当前状态, 例如: 当你按下“英勇打击”时图标应该高亮,
按“攻击”，“射击” 技能时图标应该闪烁以表示其处于激活状态

3. 宏图标 **只能** 根据“魔法/能量/怒气”值来判断宏的当前技能是否可用,
因此不能正确地显示那些触发技能如 “压制”，“斩杀” 的**可用状态**

以上是默认的状态下宏图标的限制, 但是如果某个宏技能很重要, 可以使用 [技能关联欺骗] 突破限制

[宏图标的局限性]: #宏图标的局限性

## 命令

写在宏内部的所有命令都支持 [条件选项](#条件选项), 命令只有在条件语句通过后才会执行

以下所有命令只能在宏的内部使用, 在聊天窗口尝试输入下边命令是无效的

- `/cast 法术名字/装备栏位/道具名字`, 中文客户端可以使用 `/施放`

  示例: 优先对鼠标指向的目标施放变形术

  ```
  #show
  /cast [@mouseover][]变形术
  ```

  示例: 强制丢魔杖

  ```
  #show
  #CastSpellByName("射击")
  /cast !射击
  ```

  **注意:** 目前不支持任何宠物技能

- `/use` 完全等用于 `/cast`

- `/eq 装备名字` 或 `/equip`

  示例: 武器换盾宏

  ```
  #show [worn:盾牌]17;16
  /eq 双手武器名字
  /eq 单手武器名字
  /eq 盾牌名字
  ```

- `/equipslot 装备栏位 装备名字`

  示例: 你想要把某个单手武器装备到副手上

  ```
  /equipslot 17 单手武器名字
  ```

  也可以用来交换主副手武器:

  ```
  /equipslot 16 17
  ```

- `/click 全局按钮名字 [2]` : 模拟鼠标左键点击指定名字的按钮, 如果参数 `2` 存在则表示模拟鼠标右键点击

  需要能全局访问到的名字比如 `PlayerFrame`

  当"全局按钮名字"为数字时, 表示为“动作条按钮”栏位, 当你按住 `alt` 键用鼠标移上去时可以看见 “动作条按钮” 的栏位是多少

  对于默认的动作条你只能点击你能看得到“动作条按钮”，例如如果你现在处于战斗姿态那么你无法点击防御姿态下的“动作条按钮”

- `/startattack` 开始攻击, 注意这个语句需要有 [技能关联欺骗] 支持

- `/stopattack` 依赖于 `PlayerFrame.incombat`

- `/swapactionbar A B` : 比较常用的就是 `/swapactionbar 1 2` 切换 1, 2号动作条

- `/cleartarget` : 清除当前目标

- `/stopcasting` : 停止当前施法, 对引导类型的法术如: “奥术飞弹” 无效

- `/stopmacro` : 停止执行后续的宏, 一般配合 `[条件选项]` 使用

- `/cancelform` : 取消当前姿态, 对德鲁伊取消变形, 对盗贼则取消潜行

- `/cancelaura NAME` : 取消自身的某一个 buff

  也可以用来取消坐骑, 例如 : `/cancelaura 上马后的Buff名字`

- `/targetenemy`       : 同 `TargetNearestEnemy()`, 选中最近的敌人

  通常配合条件一起使用, 例如: `/targetenemy [noexists]` 当你没有目标时才选中最近的敌人

- `/targetlasttarget`  : 同 `targetlasttarget()`, 选中最后一次的目标
- `/targetlastenemy`   : 同 `TargetLastEnemy()`, 选中最后一次的敌人

- `/petattack`    : 宠物攻击 （注: 我没有猎人或术士账号测试它们, 但我想应该是没问题的）
- `/petfollow`    : 宠物跟随
- `/petstay`      : 宠物停留
- `/petpassive`   : 宠物进入被动模式, 可以用来使宠物停止攻击
- `/petdefensive` : 宠物进入防御模式


### 强制前缀

强制前缀 `!` 可以加在技能前, 例如: `/cast !射击`, 但并不是对所有技能有效
其内部使用的是 `IsCurrentAction` 和 `IsAutoRepeatAction` 来检测技能是否处于活动状态,
支持强制模式的技能有: “攻击”, “射击”, “自动射击” 等等通常那些能使动作条图标高亮的技能

很怪异的是盗贼的潜行可以使用 `!` 强制潜行, 但对德鲁伊的潜行却是无效的,
还有对猎人的守护也是无效的

**重要:** “强制前缀”需要 [技能关联欺骗] 的支持才有效, 因此强制丢魔杖的宏可能类似于:

```
#show
#CastSpellByName("射击")
/cast !射击
```

> 引入“强制前缀”给宏解析器带了了一个 BUG, 就是会把所有命令后边碰到的第一个 `!` 符号当成“技能强制前缀”,
因此当你在宏的内部写下: `/说 !你好` 后点击宏看不到那个感叹号的

还有就是强制模式的图标显示有点特别

```
#show
#CastSpellByName("自动射击")
/cast !自动射击
```

这里 `/cast !自动射击` 后边没有别的语句了, 那么将会显示 “自动射击” 所对应的图标

```
#show
/cast !自动射击
/cast 奥术射击
```

这里 `/cast !自动射击` 后边有别的语句, 那么这里将会显示“奥术射击”所对应的图标

## 条件选项

基础概念

- `[A][B]技能` : 表示 A 或者 B 任意一个满足都会执行
- `[A, B]技能` : 表示 A 和 B 必须同时满足才会执行
- `[]技能`     : 空条件等同于满足条件, 因此后边的技能一定会执行

  例如 : `/cast [@mouseover][]变形术` 优先对鼠标指向的目标施放变形术

- 除了用于检测自身的条件外, 默认情况下条件都以当前目标作为测试对象, 使用 `@` 可以修改当前目标, 比较常见的是 `[@mouseover]`

- 可以使用 `no` 反转, 例如 `[exists]` 表示必须要有目标, 而 `[noexists]` 则表示当目标不存在时

### 条件选项列表

- `[help]` : “目标”是否为友善(可以给其加 buff 的单位)

- `[dead]` : “目标”是否已经死亡

- `[harm]` : “目标”是否为敌对单位

- `[exists]` : “目标”是否存在

- `[guy]` : “目标”是玩家时

- `[combat]` : 自身是否处于战斗中

- `[mod]`, `[mod:alt/ctrl/shift]` : 当个 `[mod]` 表示按下任意 alt/ctrl/shift 时,

- `[form]`, `[form:1/2/...]`, `[stance]` : 姿态检测, 可以用 `/` 同时检测多个姿态表示"或者"

  对盗贼来说 `[form]` 或 `[form:1]` 都可以表示潜行状态, `[noform]` 表示非潜行状态

  对德鲁伊来说 `[form]` 表示任意变形状态, `[noform]` 则表示人形态, `[form:1]` 表示熊形态,
  `[form:1/3]` 表示熊形态或者猫形态

  姿态号码等同于姿态条按钮的位置, 从左到右从 1 开始

- `[alt]` : 等同于 `[mod:alt]`

- `[ctrl]` : 等同于 `[mod:ctrl]`

- `[shift]` : 等同于 `[mod:shift]`

- `[you]` : 当“目标”的目标是你时, 例如 : `/cast [noyou]嘲讽` 当你“目标”的目标不是你时才嘲讽

- `[has]`, `[has:NAME]`, `[has:NAME >< 秒]` : 检测“自身”是否有某个 "buff/debuff", 如果使用了 `> 或 <` 则仅限于 "buff"

   注意 `[has : NAME > 10]` 表示 NAME “大于等于” 10 秒, 反过来则是 “小于等于”

- `[thas]`, `[thas:NAME]` : 检测“目标”是否存在某个 "buff/debuff" (仅限于能看见的)

- `[cd]`, `[cd:NAME]` : 当前技能或 NAME 的 CD 还没冷却好时, 一般使用 `[nocd]` 来检测技能或物品没有 CD

- `[ava]`, `[ava:NAME]` : 当前技能或 NAME 可用时, 例如: `/cast [ava]压制`, 注意这个需要 [技能关联欺骗] 支持

- `[worn:装备名/装备类型]` `[equipped:装备名/装备类型]` : 是否已经装备了 装备名/装备类型, 装备类型参考 [支持的装备类型](#支持的装备类型)

- `[pet], [pet:NAME/TYPE]` : 当宠物存在或者指定类型的宠物存在时(即使已死亡), 如果你使用英文客户端注意大小写要一致

  由于目前不支持宠物技能, 因此这个选项没什么用, 还有就是我没有猎人或术士因此没有测试过

  对于宠物的类型可以在聊天窗口输入 : `/run DEFAULT_CHAT_FRAME:AddMessage(UnitCreatureFamily("pet"))`

- `[bar:N]`, `[actionbar:N]` : 检测当前动作条, 默认情况下当前动作条为 1 号, 可以使用 `/swapactionbar 1 2` 切换到 2 号

- `[stealth]` : 当前是否已经潜行, 这个是给德鲁伊用的, 盗贼使用更简单的 `[form]` 即可以表示潜行

- `[channeling]`, `[channeling:NAME]` : 当前是否在引导某法术, 例如奥数飞弹

  注意这个选项依赖于暴雪原施法条, 如果你使用 `pfUI` 那么这个是无效的

### 支持的装备类型

注意如果你使用英文客户端, 注意大小写必须和下边列出的一致

|      en-US       |  中文客户端  |   别名(注意大小写必须一致) |
| ---------------- | ------------ | --------- |
 One-Hand          | 单手         | 1H        (用于检测"单手武器")
 Two-Hand          | 双手         | 2H        (用于检测"双手武器")
 Held In Off-hand  | 副手物品     | OH        (仅用于非武器类别的物品)
 Two-Handed Axes   | 双手斧       | 2H Axes
 Two-Handed Maces  | 双手锤       | 2H Maces
 Two-Handed Swords | 双手剑       | 2H Swords
 One-Handed Swords | 单手斧       | Axes
 One-Handed Maces  | 单手锤       | Maces
 One-Handed Swords | 单手剑       | Swords
 Fishing Pole      | 鱼竿         |
 Polearms          | 长柄武器     |
 Staves            | 法杖         |
 Daggers           | 匕首         |
 Shields           | 盾牌         |
 Crossbows         | 弩           |
 Bows              | 弓           |
 Guns              | 枪械         |
 Wands             | 魔杖         |
 Thrown            | 投掷武器     |
 Librams           | 圣契         |
 Idols             | 神像         |
 Totems            | 图腾         |

示例 :

```
[worn:1H]        检测主手是否装备了单手武器
[worn:17 1H]     检测副手是否装备了单手武器 ( 17 为副手的栏位)
[worn:2H]        检测是否装备了双手武器
[worn:盾牌]      检测是否装备了盾牌

[worn : 匕首]    检测主手是否装备了匕首
[worn : 17 匕首] 检测副手是否装备了匕首
```

## 技能关联欺骗

使动作条上一个栏位与宏技能进行关联, 两种方式任意选择其中一种即可:

- 将法术书里相关技能(任意等级)拖到任意的动作条上, 不可见的动作条也行, 或者动作条上已有 `#CastSpellByName("相关技能")` 的宏

  当你搜索 “自动攻击” 宏时应该会发现一些宏也有类似的要求,
  基于同样的原理这里也一样, 当然你不用担心性能问题,
  因为此插件只在进入游戏时 **仅搜寻一次** 整个动作条栏的所有技能并缓存

- 直接使用: `#CastSpellByName("技能名称")`, 如果你想保持动作条简洁不想拖技能

  这个技巧同样来自于包含有 `/run -- CastSpellByName("技能名称")` 的宏,
  一些自动攻击宏采用了这种方式, 其目的是为了欺骗客户端此宏所对应的技能

  **注意:** 这个语句必须放在所有 **命令语句** 前才有效果, 因此它通常在 `#showtooltip` 前或后边,
  技能名字必须使用 **双引号** 括起来, 只有这样WOW客户端才能识别。

必须要使用“技能关联欺骗”的行为如下:

- 想要突破 [宏图标的局限性]

- `/startattack` 和其相关的技能是“攻击”，因此动作条上必须至少有一个和“攻击”的技能存在, 或者你的宏应该像这样:

  ```
  #CastSpellByName("攻击")
  /startattack
  ```

  > 注: 之所以选择这种麻烦的方式是因为它目前是最可靠的

- 带有[强制前缀](#强制前缀) **`!`** 的技能

- 条件选项 `[ava]`

  ```
  #show
  /cast [ava]压制;英勇打击
  ```

  上边宏想要起作用, 那么动作条上至要有一个“压制”的技能或者宏, 或者将宏修改为:

  ```
  #show
  #CastSpellByName("压制")
  /cast [ava]压制;英勇打击
  ```

[技能关联欺骗]: #技能关联欺骗

## 示例

事例有太多的 `#CastSpellByName(...)` 看上去非常烦人,
但其实很多情况下, 这个辅助语句都不是必要的, 建议参考 [技能关联欺骗] 和 [宏图标的局限性] 了解一些细节

换盾, 有盾牌时显示盾牌图标, 否则显示主手武器

```
#show [worn:盾牌]17;16
/eq 双手武器名字
/eq 单手武器名字
/eq 盾牌名字
```

示例: 优先对鼠标指向的目标施放变形术

```
#show
/cast [@mouseover,nohelp][]变形术
```

丢魔杖

```
#show
#CastSpellByName("射击")
/cast !射击
```

自动攻击

```
#show
#CastSpellByName("攻击")
/startattack
```

当没有目标时, 自动选择最近的敌人

```
#show
#CastSpellByName("自动射击")
/targetenemy [noexists]
/cast !自动射击
/cast 奥术射击
```

还击 (未测试)

```
#show
#CastSpellByName("还击")
/cast [ava, nocd]还击;邪恶攻击
```

弓弩枪 (未测试)

```
#show
#CastSpellByName("弓射击")
/cast [worn:弓]弓射击;[worn:弩]弩射击;[worn:枪械]枪械射击;投掷
```

其它脚本宏

```lua
-- 双倍经验剩余显示
/run local e, m = (GetXPExhaustion() or 0), UnitXPMax("player"); local r = math.floor(1000 * e / m) / 1000; DEFAULT_CHAT_FRAME:AddMessage("双倍经验剩余: " .. e .. ", 倍率: " .. r)

-- 删除 XXXX 进入/退出频道提示
/run ChatFrame_RemoveMessageGroup(ChatFrame1, "CHANNEL")

-- 主要用于在哈卡岛快速上交绿色宝石, 或者一些类似的例如上交物品换声望, 可将数字 1 改成任务对话框相应的选项 (未测试)
/run SelectGossipAvailableQuest(1)
/run CompleteQuest()
/run GetQuestReward()
```

## !支持

<details>
	<summary>捐助付款码</summary>
	<img alt="wechat donation qrcode" src="data:image/png;base64,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"/>
</details>
