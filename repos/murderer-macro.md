---
layout : default
title : murderer-macro(真凶宏) 使用文档
lang : zh-CN
permalink : /murderer-macro/
donate : "#支持"
date : 2023-09-28 15:32
---

此插件用于改善旧版本宏的使用, 仅适用于 WoW 1.12(vanilla) 客户端,
受 [CleverMacro](https://github.com/DanielAdolfsson/CleverMacro) 启发而作

名字之所以叫真凶, 是因为我最近关注了一些悬疑凶杀案(unsolved murders)

插件非整合包, 从零开始实现(from scratch), 目前完成度为 99.99%, 仅供内部人员使用

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
  │                 ├── murderer-macro.lua
  │                 └── murderer-macro.toc
  ├── WDB ..
  ├── WTF ..
  ├── ...
  ├── WoW.exe
  ├── ...
  .
  ```

- 不要与同类型插件同时启用, 混合使用导致的结果未知, 同类型插件有: `CleverMacro`, `Roid-Macro`, `MacroExtender`, `ClassicMacros`, `SuperMacro` 等等

### 兼容

此插件目前仅适用于暴雪**原有动作条**, 对于 `[@mouseover]` 同样仅适用于原有的头像/血条框体,
而对于其它插件目前兼容的有:

- [x] `NotGrid` : 未测试, 没做任何处理, 但应该没问题

- [x] `pfUI` : 简单测试过

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

示例有太多的 `#CastSpellByName(...)` 看上去非常烦人,
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

-- 一键脱装备
/run for _, v in ipairs({1,3,5,6,7,8,9,10,16,17,18}) do PickupInventoryItem(v) PutItemInBackpack() ClearCursor() end

-- 对话框自动交任务, 可将数字 1 改成其它. 例如哈卡岛的绿宝石上交任务, 或者别的上交物品任务
/run SelectGossipAvailableQuest(1)
/run CompleteQuest()
/run GetQuestReward()
```

## !支持

to be continued...
