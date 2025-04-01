#!/bin/bash
set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 处理图片文件
log "开始处理图片文件..."
cd assets/images || { log "无法进入assets/images目录"; exit 1; }

declare -A name_map
for file in *; do
    if [ -f "$file" ]; then
        log "正在计算 $file 的MD5..."
        md5_full=$(md5sum "$file" | awk '{print $1}')
        md5_16="${md5_full:0:16}"
        extension="${file##*.}"
        newname="${md5_16}.${extension}"
        
        if [[ -e "$newname" ]]; then
            log "警告：$newname 已存在，跳过 $file 的重命名"
            continue
        fi
        
        mv -v -- "$file" "$newname"
        name_map["$file"]="$newname"
        log "重命名: $file -> $newname"
    fi
done
cd - > /dev/null

# 生成替换规则
replacements_file=$(mktemp)
log "生成替换规则..."
for key in "${!name_map[@]}"; do
    oldname="$key"
    newname="${name_map[$key]}"
    old_escaped=$(sed 's/[][\/&*.^$]/\\&/g' <<< "$oldname")
    echo "s|assets/images/${old_escaped}|assets/images/${newname}|g" >> "$replacements_file"
done

# 处理Markdown文件
log "开始更新Markdown文件..."
cd markdown || { log "无法进入markdown目录"; exit 1; }

updated_files=0
old_pattern=$(printf "%s\n" "${!name_map[@]}" | sed 's/[][\.^$*+?{}|]/\\&/g' | paste -sd '|')

# 关键修复：使用进程替换避免子shell问题
while IFS= read -r -d '' md_file; do
    log "正在检查文件: $md_file"
    if grep -q -E "assets/images/(${old_pattern})" "$md_file"; then
        log "正在更新引用: $md_file"
        sed -i -f "$replacements_file" "$md_file"
        ((updated_files++))
        log "已完成更新: $md_file"
    else
        log "无需要更新的引用: $md_file"
    fi
done < <(find . -type f $ -iname "*.md" -o -iname "*.markdown" $ -print0)

cd - > /dev/null
rm "$replacements_file"

log "处理完成！共更新了 $updated_files 个Markdown文件"


# 保持窗口不关闭
echo "按任意键继续..."
read -n 1 -s -r