#!/bin/bash

# 默认配置
SESSION_NAME="mine"
DEFAULT_PLAYER="AXWV3825"

# 命令简码映射
declare -A COMMAND_MAP=(
    ["t"]="tp"
    ["g"]="give"
    ["f"]="fill"
    ["e"]="effect"
    ["s"]="summon"
)

# 预设坐标点
declare -A LOCATIONS=(
    ["home"]="80 70 -175"
    ["birthplace"]="5000 67 -174"
    ["spawn"]="0 64 0"
    ["nether"]="13 70 7"
    ["end"]="100 49 0"
)

# 效果ID映射（常用效果）
declare -A EFFECTS=(
    ["speed"]=1
    ["slowness"]=2
    ["haste"]=3
    ["mining_fatigue"]=4
    ["strength"]=5
    ["instant_health"]=6
    ["instant_damage"]=7
    ["jump_boost"]=8
    ["nausea"]=9
    ["regeneration"]=10
    ["resistance"]=11
    ["fire_resistance"]=12
    ["water_breathing"]=13
    ["invisibility"]=14
    ["blindness"]=15
    ["night_vision"]=16
    ["hunger"]=17
    ["weakness"]=18
    ["poison"]=19
    ["wither"]=20
    ["health_boost"]=21
    ["absorption"]=22
    ["saturation"]=23
    ["glowing"]=24
    ["levitation"]=25
    ["luck"]=26
    ["unluck"]=27
    ["slow_falling"]=28
    ["conduit_power"]=29
    ["dolphins_grace"]=30
    ["bad_omen"]=31
    ["hero_of_the_village"]=32
)

# 物品简码映射（用户可自定义）
declare -A ITEM_ALIASES=(
    ["sw"]="diamond_sword"
    ["pick"]="diamond_pickaxe"
    ["axe"]="diamond_axe"
    ["shovel"]="diamond_shovel"
    ["dsword"]="diamond_sword"
    ["dpick"]="diamond_pickaxe"
    ["daxe"]="diamond_axe"
    ["dshovel"]="diamond_shovel"
    ["apple"]="apple"
    ["gapple"]="golden_apple"
    ["egg"]="egg"
    ["arrow"]="arrow"
    ["bow"]="bow"
    ["shield"]="shield"
    ["torch"]="torch"
    ["block"]="diamond_block"
    ["ingot"]="iron_ingot"
    ["gold"]="gold_ingot"
    ["diamond"]="diamond"
    ["emerald"]="emerald"
    ["coal"]="coal"
    ["stick"]="stick"
    ["string"]="string"
    ["feather"]="feather"
    ["gunpowder"]="gunpowder"
    ["snowball"]="snowball"
    ["boat"]="oak_boat"
    ["bucket"]="bucket"
    ["water"]="water_bucket"
    ["lava"]="lava_bucket"
    ["milk"]="milk_bucket"
    ["book"]="book"
    ["enchant"]="enchanted_book"
    ["xp"]="experience_bottle"
    ["firework"]="firework_rocket"
    ["elytra"]="elytra"
    ["totem"]="totem_of_undying"
    ["disc"]="music_disc_13"
    # 添加更多物品简码...
)

# 生物简码映射（用户可自定义）
declare -A ENTITY_ALIASES=(
    ["cow"]="cow"
    ["pig"]="pig"
    ["sheep"]="sheep"
    ["chicken"]="chicken"
    ["zombie"]="zombie"
    ["skeleton"]="skeleton"
    ["creeper"]="creeper"
    ["spider"]="spider"
    ["enderman"]="enderman"
    ["witch"]="witch"
    ["slime"]="slime"
    ["guardian"]="guardian"
    ["elder"]="elder_guardian"
    ["wither"]="wither"
    ["ender"]="ender_dragon"
    ["ghast"]="ghast"
    ["blaze"]="blaze"
    ["magma"]="magma_cube"
    ["shulker"]="shulker"
    ["villager"]="villager"
    ["iron"]="iron_golem"
    ["snow"]="snow_golem"
    ["wolf"]="wolf"
    ["ocelot"]="ocelot"
    ["horse"]="horse"
    ["donkey"]="donkey"
    ["mule"]="mule"
    ["llama"]="llama"
    ["parrot"]="parrot"
    ["bat"]="bat"
    ["squid"]="squid"
    ["dolphin"]="dolphin"
    ["turtle"]="turtle"
    ["phantom"]="phantom"
    ["vex"]="vex"
    ["evoker"]="evoker"
    ["vindicator"]="vindicator"
    ["pillager"]="pillager"
    ["ravager"]="ravager"
    ["bee"]="bee"
    ["fox"]="fox"
    ["panda"]="panda"
    ["cat"]="cat"
    ["wandering"]="wandering_trader"
    # 添加更多生物简码...
)

# 显示帮助信息
usage() {
    echo "用法: $0 [头值] [用户值] [附加值] [附加值1] [附加值2]"
    echo "或:    $0 '完整命令'"
    echo ""
    echo "头值: tp/t, give/g, fill/f, effect/e, summon/s 或完整命令"
    echo "用户值: 玩家ID(默认AXWV3825) 或坐标(用于fill)"
    echo "附加值: "
    echo "  - tp: 坐标/坐标简码/玩家"
    echo "  - give: 物品名/物品简码"
    echo "  - fill: 坐标"
    echo "  - effect: 效果名/ID"
    echo "  - summon: 生物名/生物简码"
    echo "附加值1: "
    echo "  - give: 数量"
    echo "  - fill: 物品名/物品简码"
    echo "  - effect: 持续时间(秒)"
    echo "  - summon: 坐标/坐标简码"
    echo "附加值2: "
    echo "  - effect: 效果强度"
    echo ""
    echo "示例:"
    echo "  $0 t AXWV3825 home        # 传送玩家到home"
    echo "  $0 g AXWV3825 sw 1        # 给玩家1个钻石剑(sw简码)"
    echo "  $0 f 0 64 0 10 70 10 stone # 用石头填充区域"
    echo "  $0 e AXWV3825 speed       # 给玩家速度效果(默认时间10000刻，强度255)"
    echo "  $0 e AXWV3825 speed 60    # 给玩家速度效果60秒，默认强度255"
    echo "  $0 e AXWV3825 speed 60 1  # 给玩家速度效果60秒，强度1"
    echo "  $0 s cow home             # 在home位置召唤牛"
    echo "  $0 'say Hello World'      # 直接执行完整命令"
    echo ""
    echo "预设位置:"
    for loc in "${!LOCATIONS[@]}"; do
        echo "  $loc: ${LOCATIONS[$loc]}"
    done
    echo ""
    echo "可用效果:"
    for eff in "${!EFFECTS[@]}"; do
        echo "  $eff (ID: ${EFFECTS[$eff]})"
    done | head -10
    echo "  ... (更多效果可用，使用效果名或ID)"
    echo ""
    echo "物品简码示例:"
    for alias in "${!ITEM_ALIASES[@]}"; do
        echo "  $alias → ${ITEM_ALIASES[$alias]}"
    done | head -5
    echo "  ... (更多简码可用)"
    echo ""
    echo "生物简码示例:"
    for alias in "${!ENTITY_ALIASES[@]}"; do
        echo "  $alias → ${ENTITY_ALIASES[$alias]}"
    done | head -5
    echo "  ... (更多简码可用)"
    exit 1
}

# 检查参数数量
if [ $# -eq 0 ]; then
    echo "错误: 参数不足"
    usage
fi

# 检查是否是直接执行完整命令
if [ $# -eq 1 ] && [[ "$1" == *" "* ]]; then
    # 只有一个参数且包含空格，认为是完整命令
    FINAL_CMD="$1"
else
    # 获取参数
    HEAD="$1"
    USER_VAL="$2"
    EXTRA_VAL="$3"
    EXTRA_VAL1="$4"
    EXTRA_VAL2="$5"

    # 解析头值命令
    if [[ -n "${COMMAND_MAP[$HEAD]}" ]]; then
        CMD="${COMMAND_MAP[$HEAD]}"
    else
        CMD="$HEAD"
    fi

    # 根据命令类型处理
    case "$CMD" in
        "tp")
            # 处理传送命令
            if [[ -n "${LOCATIONS[$EXTRA_VAL]}" ]]; then
                COORDS="${LOCATIONS[$EXTRA_VAL]}"
            else
                COORDS="$EXTRA_VAL"
            fi
            FINAL_CMD="tp $USER_VAL $COORDS"
            ;;
        "give")
            # 处理给予命令
            # 检查是否是物品简码
            ITEM="$EXTRA_VAL"
            if [[ -n "${ITEM_ALIASES[$EXTRA_VAL]}" ]]; then
                ITEM="${ITEM_ALIASES[$EXTRA_VAL]}"
            fi
            FINAL_CMD="give $USER_VAL $ITEM ${EXTRA_VAL1:-64}"
            ;;
        "fill")
            # 处理填充命令
            # 检查用户值是否是坐标(包含空格)
            if [[ "$USER_VAL" == *" "* ]]; then
                # 用户值是坐标，直接使用
                COORDS1="$USER_VAL"
                COORDS2="$EXTRA_VAL"
                BLOCK="$EXTRA_VAL1"
                
                # 检查是否是物品简码
                if [[ -n "${ITEM_ALIASES[$BLOCK]}" ]]; then
                    BLOCK="${ITEM_ALIASES[$BLOCK]}"
                fi
            else
                # 用户值是玩家ID，需要额外的坐标参数
                if [ $# -lt 4 ]; then
                    echo "错误: fill命令需要两个坐标和一个方块参数"
                    usage
                fi
                COORDS1="$EXTRA_VAL"
                COORDS2="$EXTRA_VAL1"
                BLOCK="$5"  # 需要第五个参数作为方块
                
                # 检查是否是物品简码
                if [[ -n "${ITEM_ALIASES[$BLOCK]}" ]]; then
                    BLOCK="${ITEM_ALIASES[$BLOCK]}"
                fi
                shift
            fi
            FINAL_CMD="fill $COORDS1 $COORDS2 $BLOCK"
            ;;
        "effect")
            # 处理效果命令
            # 检查效果是否是名称，如果是则转换为ID
            EFFECT_ID="$EXTRA_VAL"
            if [[ -n "${EFFECTS[$EXTRA_VAL]}" ]]; then
                EFFECT_ID="${EFFECTS[$EXTRA_VAL]}"
            fi
            
            # 设置默认值
            DURATION="${EXTRA_VAL1:-10000}"  # 默认10000 ticks (约500秒)
            AMPLIFIER="${EXTRA_VAL2:-255}"   # 默认强度255
            
            # 如果提供的是秒数而不是tick数，转换为tick数 (1秒 = 20ticks)
            if [[ "$DURATION" =~ ^[0-9]+$ ]] && [ "$DURATION" -lt 1000 ]; then
                DURATION=$((DURATION * 20))
                echo "注意: 已将秒数转换为tick数: $EXTRA_VAL1秒 = $DURATION ticks"
            fi
            
            FINAL_CMD="effect give $USER_VAL $EFFECT_ID $DURATION $AMPLIFIER"
            ;;
        "summon")
            # 处理召唤命令
            # 检查是否是生物简码
            ENTITY="$USER_VAL"
            if [[ -n "${ENTITY_ALIASES[$USER_VAL]}" ]]; then
                ENTITY="${ENTITY_ALIASES[$USER_VAL]}"
            fi
            
            # 处理坐标
            if [[ -n "${LOCATIONS[$EXTRA_VAL]}" ]]; then
                COORDS="${LOCATIONS[$EXTRA_VAL]}"
            else
                COORDS="$EXTRA_VAL"
            fi
            
            FINAL_CMD="summon $ENTITY $COORDS"
            ;;
        *)
            # 未知命令，直接传递所有参数
            FINAL_CMD="$HEAD $USER_VAL $EXTRA_VAL $EXTRA_VAL1 $EXTRA_VAL2"
            ;;
    esac
fi

# 检查screen会话是否存在
if ! screen -list | grep -q "\.$SESSION_NAME\s"; then
    echo "错误: screen会话 '$SESSION_NAME' 不存在"
    echo "请先创建screen会话: screen -S $SESSION_NAME -d -m"
    exit 1
fi

# 向screen会话发送命令
screen -S $SESSION_NAME -X stuff "$FINAL_CMD\n"
echo "命令已发送到screen会话 '$SESSION_NAME': $FINAL_CMD"