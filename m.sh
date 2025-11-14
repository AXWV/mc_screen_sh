#!/bin/bash
#version:1.3.2
# 默认配置
# [""]=""
SESSION_NAME="mcbedrock"
DEFAULT_PLAYER="AXWV3825"

# 操作模式
MODE="direct"

# 映射文件路径
EFFECT_MAP_FILE="xg.id"    # 效果简码
ITEM_MAP_FILE="wp.id"      # 物品简码
ENTITY_MAP_FILE="sw.id"    # 生物简码
CMD_MAP_FILE="dc.id"       # 预设命令
LOCATION_MAP_FILE="pc.id"  # 预设坐标

# 内置预设坐标（优先使用）
declare -A LOCATIONS=(
    ["birthplace"]="-118 70 -162"
)

# 内置预设命令（优先使用）
declare -A CUSTOM_COMMANDS=(
    ["tb"]="tp {PLAYER} birthplace"
)

# 加载外部映射文件
load_external_mappings() {
    # 加载效果映射
    if [[ -f "$EFFECT_MAP_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ $key =~ ^# ]] || [[ -z $key ]] && continue
            EFFECTS["$key"]="$value"
        done < "$EFFECT_MAP_FILE"
    fi
    
    # 加载物品映射
    if [[ -f "$ITEM_MAP_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ $key =~ ^# ]] || [[ -z $key ]] && continue
            ITEM_ALIASES["$key"]="$value"
        done < "$ITEM_MAP_FILE"
    fi
    
    # 加载生物映射
    if [[ -f "$ENTITY_MAP_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ $key =~ ^# ]] || [[ -z $key ]] && continue
            ENTITY_ALIASES["$key"]="$value"
        done < "$ENTITY_MAP_FILE"
    fi
    
    # 加载命令映射（不覆盖内置）
    if [[ -f "$CMD_MAP_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ $key =~ ^# ]] || [[ -z $key ]] && continue
            # 只有当键不存在时才添加，保证内置优先
            if [[ -z "${CUSTOM_COMMANDS[$key]}" ]]; then
                CUSTOM_COMMANDS["$key"]="$value"
            fi
        done < "$CMD_MAP_FILE"
    fi
    
    # 加载坐标映射（不覆盖内置）
    if [[ -f "$LOCATION_MAP_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ $key =~ ^# ]] || [[ -z $key ]] && continue
            # 只有当键不存在时才添加，保证内置优先
            if [[ -z "${LOCATIONS[$key]}" ]]; then
                LOCATIONS["$key"]="$value"
            fi
        done < "$LOCATION_MAP_FILE"
    fi
}

# 初始化映射数组
declare -A EFFECTS
declare -A ITEM_ALIASES
declare -A ENTITY_ALIASES

# 加载外部映射
load_external_mappings

# 显示帮助信息
usage() {
    echo "version:1.3.2"
    echo "用法:"
    echo "  直接命令: $0 [-s session_name] '命令'"
    echo "  传送命令:"
    echo "    $0 tp 玩家名 x y z"
    echo "    $0 -t x y z                    # 传送默认玩家到坐标"
    echo "    $0 -tt 预设坐标                # 传送默认玩家到预设坐标"
    echo "    $0 -ttp 玩家名 预设坐标        # 传送某玩家到预设坐标"
    echo "  给予命令:"
    echo "    $0 -give 玩家名 物品名(可为预设) 数量"
    echo "    $0 -g 物品名(可为预设) 数量      # 给默认玩家物品"
    echo "  说话命令:"
    echo "    $0 -say 文本"
    echo "  效果命令:"
    echo "    $0 -effect 玩家名 效果名/ID [持续时间] [强度]"
    echo "    $0 -e 效果名/ID [持续时间] [强度] # 给默认玩家效果"
    echo "  召唤命令:"
    echo "    $0 -summon 生物名/简码 [坐标]"
    echo "    $0 -s 生物名/简码 [坐标]         # 在默认位置召唤"
    echo "  填充命令:"
    echo "    $0 -fill x1 y1 z1 x2 y2 z2 方块名"
    echo "    $0 -f x1 y1 z1 x2 y2 z2 方块名"
    echo ""
    echo "选项:"
    echo "  -s session_name  指定tmux会话名称（默认为mcbedrock）"
    echo "  -p player_id     指定玩家ID（默认为AXWV3825）"
    echo "  -n quantity      指定物品数量（默认为64，仅与-give一起使用）"
    echo ""
    echo "预设位置:"
    for loc in "${!LOCATIONS[@]}"; do
        echo "  $loc: ${LOCATIONS[$loc]}"
    done | head -10
    if [ ${#LOCATIONS[@]} -gt 10 ]; then
        echo "  ... (共${#LOCATIONS[@]}个位置，查看 $LOCATION_MAP_FILE 获取完整列表)"
    fi
    echo ""
    echo "自定义命令:"
    for cmd in "${!CUSTOM_COMMANDS[@]}"; do
        echo "  $cmd: ${CUSTOM_COMMANDS[$cmd]}"
    done | head -5
    if [ ${#CUSTOM_COMMANDS[@]} -gt 5 ]; then
        echo "  ... (共${#CUSTOM_COMMANDS[@]}个命令，查看 $CMD_MAP_FILE 获取完整列表)"
    fi
    echo ""
    echo "简码文件:"
    echo "  $EFFECT_MAP_FILE - 效果简码"
    echo "  $ITEM_MAP_FILE - 物品简码" 
    echo "  $ENTITY_MAP_FILE - 生物简码"
    echo "  $CMD_MAP_FILE - 预设命令"
    echo "  $LOCATION_MAP_FILE - 预设坐标"
    exit 1
}

# 函数：替换所有简码为完整值
expand_shortcuts() {
    local cmd="$1"
    local player="$2"
    
    # 替换玩家占位符
    cmd="${cmd//\{PLAYER\}/$player}"
    
    # 替换坐标简码
    for loc in "${!LOCATIONS[@]}"; do
        cmd="${cmd//$loc/${LOCATIONS[$loc]}}"
    done
    
    # 替换物品简码
    for item in "${!ITEM_ALIASES[@]}"; do
        cmd="${cmd//$item/${ITEM_ALIASES[$item]}}"
    done
    
    # 替换生物简码
    for entity in "${!ENTITY_ALIASES[@]}"; do
        cmd="${cmd//$entity/${ENTITY_ALIASES[$entity]}}"
    done
    
    # 替换效果简码
    for effect in "${!EFFECTS[@]}"; do
        cmd="${cmd//$effect/${EFFECTS[$effect]}}"
    done
    
    echo "$cmd"
}

# 检查参数数量
if [ $# -eq 0 ]; then
    echo "错误: 参数不足"
    usage
fi

# 处理全局选项
SESSION_NAME="mcbedrock"
PLAYER="$DEFAULT_PLAYER"
QUANTITY=64

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s)
            SESSION_NAME="$2"
            shift 2
            ;;
        -p)
            PLAYER="$2"
            shift 2
            ;;
        -n)
            QUANTITY="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            break
            ;;
    esac
done

# 如果没有参数了，显示帮助
if [ $# -eq 0 ]; then
    usage
fi

# 获取第一个参数
FIRST_ARG="$1"
shift

# 根据第一个参数判断模式
case "$FIRST_ARG" in
    "tp")
        # tp 玩家名 x y z
        if [ $# -lt 3 ]; then
            echo "错误: tp命令需要玩家名和坐标参数"
            usage
        fi
        TP_PLAYER="$1"
        shift
        COORDS="$*"
        FINAL_CMD="tp $TP_PLAYER $COORDS"
        ;;
    "-t")
        # -t x y z (传送默认玩家到坐标)
        if [ $# -lt 3 ]; then
            echo "错误: -t命令需要坐标参数"
            usage
        fi
        COORDS="$*"
        FINAL_CMD="tp $PLAYER $COORDS"
        ;;
    "-tt")
        # -tt 预设坐标 (传送默认玩家到预设坐标)
        if [ $# -lt 1 ]; then
            echo "错误: -tt命令需要预设坐标参数"
            usage
        fi
        LOCATION="$1"
        if [[ -n "${LOCATIONS[$LOCATION]}" ]]; then
            COORDS="${LOCATIONS[$LOCATION]}"
            FINAL_CMD="tp $PLAYER $COORDS"
        else
            echo "错误: 未知的预设坐标 '$LOCATION'"
            echo "可用预设坐标: ${!LOCATIONS[@]}"
            exit 1
        fi
        ;;
    "-ttp")
        # -ttp 玩家名 预设坐标 (传送某玩家到预设坐标)
        if [ $# -lt 2 ]; then
            echo "错误: -ttp命令需要玩家名和预设坐标参数"
            usage
        fi
        TP_PLAYER="$1"
        LOCATION="$2"
        if [[ -n "${LOCATIONS[$LOCATION]}" ]]; then
            COORDS="${LOCATIONS[$LOCATION]}"
            FINAL_CMD="tp $TP_PLAYER $COORDS"
        else
            echo "错误: 未知的预设坐标 '$LOCATION'"
            echo "可用预设坐标: ${!LOCATIONS[@]}"
            exit 1
        fi
        ;;
    "-give")
        # -give 玩家名 物品名 数量
        if [ $# -lt 2 ]; then
            echo "错误: -give命令需要玩家名和物品名参数"
            usage
        fi
        GIVE_PLAYER="$1"
        ITEM="$2"
        GIVE_QUANTITY="${3:-$QUANTITY}"
        
        # 检查是否是物品简码
        if [[ -n "${ITEM_ALIASES[$ITEM]}" ]]; then
            ITEM="${ITEM_ALIASES[$ITEM]}"
        fi
        
        FINAL_CMD="give $GIVE_PLAYER $ITEM $GIVE_QUANTITY"
        ;;
    "-g")
        # -g 物品名 数量 (给默认玩家物品)
        if [ $# -lt 1 ]; then
            echo "错误: -g命令需要物品名参数"
            usage
        fi
        ITEM="$1"
        GIVE_QUANTITY="${2:-$QUANTITY}"
        
        # 检查是否是物品简码
        if [[ -n "${ITEM_ALIASES[$ITEM]}" ]]; then
            ITEM="${ITEM_ALIASES[$ITEM]}"
        fi
        
        FINAL_CMD="give $PLAYER $ITEM $GIVE_QUANTITY"
        ;;
    "-say")
        # -say 文本
        if [ $# -lt 1 ]; then
            echo "错误: -say命令需要文本参数"
            usage
        fi
        TEXT="$*"
        FINAL_CMD="say $TEXT"
        ;;
    "-effect"|"-e")
        # -effect 玩家名 效果名/ID [持续时间] [强度]
        # -e 效果名/ID [持续时间] [强度]
        if [ $# -lt 1 ]; then
            echo "错误: effect命令需要效果参数"
            usage
        fi
        
        if [[ "$FIRST_ARG" == "-effect" ]]; then
            EFFECT_PLAYER="$1"
            EFFECT_ARG="$2"
            DURATION="$3"
            AMPLIFIER="$4"
            shift 4
        else
            EFFECT_PLAYER="$PLAYER"
            EFFECT_ARG="$1"
            DURATION="$2"
            AMPLIFIER="$3"
            shift 3
        fi
        
        # 检查效果是否是名称，如果是则转换为ID
        if [[ -n "${EFFECTS[$EFFECT_ARG]}" ]]; then
            EFFECT_ID="${EFFECTS[$EFFECT_ARG]}"
        else
            EFFECT_ID="$EFFECT_ARG"
        fi
        
        # 设置默认值
        DURATION="${DURATION:-10000}"  # 默认10000 ticks (约500秒)
        AMPLIFIER="${AMPLIFIER:-255}"   # 默认强度255
        
        # 如果提供的是秒数而不是tick数，转换为tick数 (1秒 = 20ticks)
        if [[ "$DURATION" =~ ^[0-9]+$ ]] && [ "$DURATION" -lt 1000 ]; then
            DURATION=$((DURATION * 20))
            echo "注意: 已将秒数转换为tick数: $DURATION ticks"
        fi
        
        FINAL_CMD="effect give $EFFECT_PLAYER $EFFECT_ID $DURATION $AMPLIFIER"
        ;;
    "-summon"|"-s")
        # -summon 生物名/简码 [坐标]
        # -s 生物名/简码 [坐标]
        if [ $# -lt 1 ]; then
            echo "错误: summon命令需要生物参数"
            usage
        fi
        
        ENTITY="$1"
        SUMMON_COORDS="$2"
        
        # 检查是否是生物简码
        if [[ -n "${ENTITY_ALIASES[$ENTITY]}" ]]; then
            ENTITY="${ENTITY_ALIASES[$ENTITY]}"
        fi
        
        # 处理坐标
        if [[ -n "$SUMMON_COORDS" ]]; then
            if [[ -n "${LOCATIONS[$SUMMON_COORDS]}" ]]; then
                COORDS="${LOCATIONS[$SUMMON_COORDS]}"
            else
                COORDS="$SUMMON_COORDS"
            fi
        else
            COORDS="~ ~ ~"  # 默认在当前位置召唤
        fi
        
        FINAL_CMD="summon $ENTITY $COORDS"
        ;;
    "-fill"|"-f")
        # -fill x1 y1 z1 x2 y2 z2 方块名
        # -f x1 y1 z1 x2 y2 z2 方块名
        if [ $# -lt 7 ]; then
            echo "错误: fill命令需要两个坐标和一个方块参数"
            usage
        fi
        
        COORDS1="$1 $2 $3"
        COORDS2="$4 $5 $6"
        BLOCK="$7"
        
        # 检查是否是物品简码
        if [[ -n "${ITEM_ALIASES[$BLOCK]}" ]]; then
            BLOCK="${ITEM_ALIASES[$BLOCK]}"
        fi
        
        FINAL_CMD="fill $COORDS1 $COORDS2 $BLOCK"
        ;;
    *)
        # 检查是否是自定义命令
        if [[ -n "${CUSTOM_COMMANDS[$FIRST_ARG]}" ]]; then
            # 处理自定义命令
            CMD_TEMPLATE="${CUSTOM_COMMANDS[$FIRST_ARG]}"
            FINAL_CMD=$(expand_shortcuts "$CMD_TEMPLATE" "$PLAYER")
        else
            # 直接命令模式
            FINAL_CMD="$FIRST_ARG $*"
        fi
        ;;
esac

# 检查tmux会话是否存在
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "错误: tmux会话 '$SESSION_NAME' 不存在"
    echo "请先创建tmux会话: tmux new-session -d -s $SESSION_NAME"
    exit 1
fi

# 向tmux会话发送命令
tmux send-keys -t "$SESSION_NAME" "$FINAL_CMD" Enter
echo "命令已发送到tmux会话 '$SESSION_NAME': $FINAL_CMD"
# 等待命令执行并读取3行内容显示执行结果
echo "正在读取执行结果..."
sleep 1  # 等待命令执行
echo "=== 最近3行输出 ==="
tmux capture-pane -p -t "$SESSION_NAME" | tail -n 3
echo "=================="