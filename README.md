# mc_screen_sh
通过在服务器端执行命令到指定运行我的世界基岩版screen会话
Minecraft 服务器管理脚本 (mc3.sh)

一个功能强大的 Bash 脚本，用于简化 Minecraft 服务器的命令执行和管理。通过简码和预设配置，让服务器管理变得更加高效便捷。

功能特点

· 🚀 支持多种 Minecraft 命令（tp、give、fill、effect、summon）
· ⚡ 命令简码系统，减少输入量
· 📍 预设坐标点，快速传送
· 🎯 物品和生物简码映射
· ⏱️ 效果命令默认参数，简化操作
· 💻 通过 screen 会话与服务器交互
· 🔧 高度可自定义的配置

安装与配置

1. 将脚本下载到您的服务器：

```bash
wget https://raw.githubusercontent.com/yourusername/yourrepository/main/mc3.sh
chmod +x mc3.sh
```

1. 确保您的 Minecraft 服务器运行在 screen 会话中：

```bash
screen -S mine -d -m java -Xmx4G -jar server.jar nogui
```

1. 根据需要自定义脚本中的配置（可选）：

· 修改默认玩家 ID
· 添加或修改预设坐标点
· 自定义物品和生物简码

使用方法

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
./mc3.sh t AXWV3825 home
./mc3.sh tp AXWV3825 100 64 100
```

给予物品命令 (give/g)

```bash
./mc3.sh g [玩家ID] [物品/物品简码] [数量]
```

示例：

```bash
./mc3.sh g AXWV3825 diamond 5
./mc3.sh give AXWV3825 sw 1  # 使用物品简码"sw"(钻石剑)
```

填充命令 (fill/f)

```bash
./mc3.sh f [坐标1] [坐标2] [方块/方块简码]
```

示例：

```bash
./mc3.sh f 0 64 0 10 70 10 stone
./mc3.sh fill "0 64 0" "10 70 10" block  # 使用方块简码"block"(钻石块)
```

效果命令 (effect/e)

```bash
./mc3.sh e [玩家ID] [效果/效果ID] [持续时间(秒)] [强度]
```

示例：

```bash
./mc3.sh e AXWV3825 speed        # 默认10000ticks和强度255
./mc3.sh effect AXWV3825 speed 60    # 60秒，默认强度255
./mc3.sh e AXWV3825 16 60 1      # 使用效果ID(16=夜视)
```

召唤命令 (summon/s)

```bash
./mc3.sh s [生物/生物简码] [位置/坐标]
```

示例：

```bash
./mc3.sh s cow home             # 在home位置召唤牛
./mc3.sh summon zombie 100 64 100 # 在指定坐标召唤僵尸
```

配置说明

预设坐标点

脚本内置了一些常用坐标点，您可以在 LOCATIONS 数组中添加或修改：

```bash
declare -A LOCATIONS=(
    ["home"]="80 70 -175"
    ["birthplace"]="5000 67 -174"
    ["spawn"]="0 64 0"
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
    # 更多效果...
)
```

高级用法

自定义默认值

您可以修改脚本开头的默认配置：

```bash
SESSION_NAME="mine"          # screen 会话名称
DEFAULT_PLAYER="AXWV3825"    # 默认玩家ID
```

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

注意事项

1. 确保 Minecraft 服务器运行在指定的 screen 会话中
2. 脚本需要执行权限：chmod +x mc3.sh
3. 确保您有权限执行 Minecraft 命令
4. 坐标格式为 "x y z"，注意使用引号包含空格

故障排除

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

贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

许可证

有不起

更新日志

v1.0.0

· 初始版本发布
· 支持 tp、give、fill、effect、summon 命令
· 添加命令简码系统
· 支持预设坐标点
· 添加物品和生物简码映射

---

希望这个脚本能让您的 Minecraft 服务器管理更加轻松愉快！如有任何问题或建议，请随时提交 Issue。
