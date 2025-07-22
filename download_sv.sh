#!/usr/bin/env bash
set -euo pipefail

# 下载脚本：根据 CSV 中的拍摄日期选择不同的 PHP 下载脚本
# 用法：./download_sv.sh [csv_file] [output_dir]
#   csv_file   默认："pano_metadata.csv"
#   output_dir 默认："streetview"

csv_file="${1:-pano_metadata.csv}"
out_dir="${2:-streetview}"

# 如果目标目录不存在，创建它
if [[ ! -d "$out_dir" ]]; then
  echo "Directory '$out_dir' does not exist — creating it."
  mkdir -p "$out_dir"
fi

echo "Using CSV: $csv_file"
echo "Output directory: $out_dir"

# 计算总行数（去掉表头）
total=$(( $(wc -l < "$csv_file") - 1 ))
echo "Total panoramas: $total"

i=1

# 跳过表头，从第二行开始读取
tail -n +2 "$csv_file" | while IFS=, read -r id lat lon date; do
  printf "[%d/%d] ID: %s, Date: %s\n" "$i" "$total" "$id" "$date"
  
  # 提取年份（取 yyyy 部分）
  year="${date%%-*}"

  # 根据年份选择脚本
  if [[ "$year" =~ ^[0-9]{4}$ ]] && (( year < 2020 )); then
    php ./streetview-dl-oldpics.php "$id"
  else
    php ./streeview-dl.php "$id"
  fi
  
  # 移动下载的文件到目标目录
  mv stl-"$id"*.jpg stm-"$id"*.jpg sts-"$id"*.jpg "$out_dir"/ 2>/dev/null || true
  
  i=$((i + 1))
done
