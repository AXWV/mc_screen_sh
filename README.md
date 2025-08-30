Minecraft 服务器管理脚本 (mc3.sh)

一个功能强大的 Bash 脚本，用于简化 Minecraft 服务器的命令执行和管理。通过简码和预设配置，让服务器管理变得更加高效便捷。

✨ 功能特点

· 🚀 多命令支持 - 支持 tp、give、fill、effect、summon 等常用命令
· ⚡ 命令简码系统 - 使用单字母简码减少输入量 (t=tp, g=give, e=effect, s=summon, f=fill)
· 📍 预设坐标点 - 内置常用坐标点，支持自定义添加
· 🎯 物品和生物简码 - 使用简码代替完整物品/生物名称
· ⏱️ 智能默认值 - effect 命令自动设置合理默认值
· 💻 Screen 会话集成 - 通过 screen 会话与服务器交互
· 🔧 高度可定制 - 所有简码和预设均可自定义
· 🎮 完整命令支持 - 可直接执行任意 Minecraft 命令

📦 安装与配置

基本安装

1. 将脚本下载到您的服务器：

```bash
wget https://github.com/AXWV/mc_screen_sh/main/mc3.sh
chmod +x mc3.sh
```

1. 确保您的 Minecraft 服务器运行在 screen 会话中：

```bash
screen -S mine -d -m java -Xmx4G -jar server.jar nogui
```

自定义配置

编辑脚本文件以自定义以下设置：

```bash
# 默认配置
SESSION_NAME="mine"          # Screen 会话名称
DEFAULT_PLAYER="AXWV3825"    # 默认玩家ID

# 添加自定义坐标点
LOCATIONS["village"]="1200 64 -500"
LOCATIONS["mine"]="85 11 -200"

# 添加自定义物品简码
ITEM_ALIASES["wsword"]="wooden_sword"
ITEM_ALIASES["cobble"]="cobblestone"

# 添加自定义生物简码
ENTITY_ALIASES["cave"]="cave_spider"
ENTITY_ALIASES["ender"]="endermite"

# 添加自定义命令简码
CUSTOM_COMMANDS["tohome"]="tp {PLAYER} home"
CUSTOM_COMMANDS["givediamonds"]="give {PLAYER} diamond 64"
```

🚀 使用方法

直接执行完整命令

```bash
./mc3.sh '完整命令'
```

示例：

```bash
./mc3.sh 'say Hello World'
./mc3.sh 'tp AXWV3825 100 64 100'
./mc3.sh 'give AXWV3825 diamond 5'
```

使用简码命令

传送命令 (tp/t)

```bash
./mc3.sh t [玩家ID] [位置/坐标]
```

示例：

```bash
./mc3.sh t AXWV3825 home          # 传送到home位置
./mc3.sh tp AXWV3825 100 64 100   # 传送到指定坐标
./mc3.sh t home                   # 使用默认玩家传送到home
```

给予物品命令 (give/g)

```bash
./mc3.sh g [玩家ID] [物品/物品简码] [数量]
```

示例：

```bash
./mc3.sh g AXWV3825 diamond 5     # 给予5个钻石
./mc3.sh give AXWV3825 sw 1       # 给予1个钻石剑(sw简码)
./mc3.sh g diamond 64             # 给默认玩家64个钻石
```

填充命令 (fill/f)

```bash
./mc3.sh f [坐标1] [坐标2] [方块/方块简码]
```

示例：

```bash
./mc3.sh f 0 64 0 10 70 10 stone  # 用石头填充区域
./mc3.sh fill "0 64 0" "10 70 10" block  # 使用方块简码"block"(钻石块)
```

效果命令 (effect/e)

```bash
./mc3.sh e [玩家ID] [效果/效果ID] [持续时间(秒)] [强度]
```

示例：

```bash
./mc3.sh e AXWV3825 speed         # 默认10000ticks和强度255
./mc3.sh effect AXWV3825 speed 60 # 60秒，默认强度255
./mc3.sh e AXWV3825 16 60 1       # 使用效果ID(16=夜视)
./mc3.sh e speed 30               # 给默认玩家速度效果30秒
```

召唤命令 (summon/s)

```bash
./mc3.sh s [生物/生物简码] [位置/坐标]
```

示例：

```bash
./mc3.sh s cow home               # 在home位置召唤牛
./mc3.sh summon zombie 100 64 100 # 在指定坐标召唤僵尸
./mc3.sh s cow                    # 在默认位置召唤牛
```

自定义命令

```bash
./mc3.sh [自定义命令] [参数]
```

示例：

```bash
./mc3.sh tohome                   # 传送默认玩家回家
./mc3.sh givediamonds             # 给默认玩家64个钻石
./mc3.sh tohome AXWV3825          # 传送指定玩家回家
```

⚙️ 配置说明

预设坐标点

脚本内置了一些常用坐标点，您可以在 LOCATIONS 数组中添加或修改：

```bash
declare -A LOCATIONS=(
    ["home"]="80 70 -175"
    ["birthplace"]="5000 67 -174"
    ["spawn"]="0 64 0"
    ["nether"]="13 70 7"
    ["end"]="100 49 0"
    # 添加更多坐标点...
)
```

物品简码

您可以在 ITEM_ALIASES 数组中自定义物品简码：

```bash
declare -A ITEM_ALIASES=(
    ["sw"]="diamond_sword"
    ["pick"]="diamond_pickaxe"
    ["block"]="diamond_block"
    ["ingot"]="iron_ingot"
    # 添加更多物品简码...
)
```

生物简码

您可以在 ENTITY_ALIASES 数组中自定义生物简码：

```bash
declare -A ENTITY_ALIASES=(
    ["cow"]="cow"
    ["zombie"]="zombie"
    ["skeleton"]="skeleton"
    # 添加更多生物简码...
)
```

效果映射

脚本包含了常用的效果映射：

```bash
declare -A EFFECTS=(
    ["speed"]=1
    ["night_vision"]=16
    ["strength"]=5
    ["invisibility"]=14
    # 更多效果...
)
```

自定义命令

您可以添加自定义命令简码：

```bash
declare -A CUSTOM_COMMANDS=(
    ["tohome"]="tp {PLAYER} home"
    ["tospawn"]="tp {PLAYER} spawn"
    ["givediamonds"]="give {PLAYER} diamond 64"
    ["giveop"]="give {PLAYER} diamond_pickaxe 1"
    # 添加更多自定义命令...
)
```

🛠️ 高级用法

批量命令执行

您可以创建脚本文件批量执行命令：

```bash
#!/bin/bash
./mc3.sh 'say 服务器即将重启'
./mc3.sh 'say 请做好准备'
./mc3.sh 'say 10秒后重启'
sleep 10
./mc3.sh 'restart'
```

与其他脚本集成

```bash
#!/bin/bash
# 备份服务器并通知玩家
./mc3.sh 'say 开始服务器备份'
./backup-server.sh
./mc3.sh 'say 备份完成'
```

定时任务

使用 crontab 设置定时任务：

```bash
# 每天凌晨3点重启服务器
0 3 * * * /path/to/mc3.sh 'say 每日重启中...' && /path/to/mc3.sh 'restart'
```

🚨 注意事项

1. 确保 Minecraft 服务器运行在指定的 screen 会话中
2. 脚本需要执行权限：chmod +x mc3.sh
3. 确保您有权限执行 Minecraft 命令
4. 坐标格式为 "x y z"，注意使用引号包含空格

🔧 故障排除

Screen 会话不存在

如果出现 "screen会话不存在" 错误，请先创建 screen 会话：

```bash
screen -S mine -d -m
# 然后在会话中启动服务器
screen -S mine -X stuff "java -Xmx4G -jar server.jar nogui\n"
```

权限问题

确保脚本有执行权限：

```bash
chmod +x mc3.sh
```

命令不执行

检查 Minecraft 服务器是否正常运行，并且有 OP 权限执行命令。

🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

1. Fork 本项目
2. 创建特性分支：git checkout -b feature/AmazingFeature
3. 提交更改：git commit -m 'Add some AmazingFeature'
4. 推送到分支：git push origin feature/AmazingFeature
5. 提交 Pull Request

📄 许可证

有不起

📝 更新日志

v1.2.0

· 新增自定义命令功能
· 支持 {PLAYER} 占位符
· 改进帮助信息

v1.1.0

· 添加物品和生物简码支持
· 添加 effect 命令默认值
· 支持直接执行完整命令

v1.0.0

· 初始版本发布
· 支持 tp、give、fill、effect、summon 命令
· 添加命令简码系统
· 支持预设坐标点

---

希望这个脚本能让您的 Minecraft 服务器管理更加轻松愉快！如有任何问题或建议，请随时提交 Issue。