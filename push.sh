#!/bin/bash
set -e
# rm -rf .idea

check_unreferenced_markdown() {
  local svg_file="assets/index.svg"
  local markdown_dir="markdown"
  local tmp_referenced
  local has_unreferenced=0

  tmp_referenced="$(mktemp)"

  grep -oE '(xlink:href|href)="[^"]+"' "$svg_file" \
    | sed -E 's/^[^"]+"([^"]+)".*/\1/' \
    | sed -nE 's#^.*/markdown/([^"?]+)(\.md)?$#\1#p' \
    | sort -u > "$tmp_referenced"

  while IFS= read -r -d '' markdown_file; do
    local markdown_name
    markdown_name="$(basename "$markdown_file" .md)"

    if ! grep -Fxq "$markdown_name" "$tmp_referenced"; then
      if [ "$has_unreferenced" -eq 0 ]; then
        echo "Unreferenced markdown files:"
      fi

      has_unreferenced=1
      echo "  - ${markdown_file#./}"
    fi
  done < <(find "./${markdown_dir}" -type f -name "*.md" -print0 | sort -z)

  if [ "$has_unreferenced" -eq 0 ]; then
    echo "All markdown files are referenced in ${svg_file}."
  fi

  rm -f "$tmp_referenced"
}

check_unreferenced_assets() {
  local markdown_dir="markdown"
  local assets_dir="assets"
  local tmp_referenced
  local has_unreferenced=0

  tmp_referenced="$(mktemp)"

  grep -rhoE '(\.\./|/)?assets/(drawio|images)/[^") >]+' "$markdown_dir" \
    | sed -E 's#^(\.\./|/)?assets/#assets/#' \
    | sort -u > "$tmp_referenced"

  while IFS= read -r -d '' asset_file; do
    local asset_path
    asset_path="${asset_file#./}"

    if ! grep -Fxq "$asset_path" "$tmp_referenced"; then
      if [ "$has_unreferenced" -eq 0 ]; then
        echo "Unreferenced assets files:"
      fi

      has_unreferenced=1
      echo "  - $asset_path"
    fi
  done < <(find "./${assets_dir}/drawio" "./${assets_dir}/images" -type f -print0 | sort -z)

  if [ "$has_unreferenced" -eq 0 ]; then
    echo "All files in ${assets_dir}/drawio and ${assets_dir}/images are referenced in markdown."
  fi

  rm -f "$tmp_referenced"
}

check_unreferenced_markdown
check_unreferenced_assets

find ./assets/drawio -type f -name "*.bkp" -delete
sed -i 's#http://localhost:3000##g' assets/index.svg
sed -i 's|http://localhost:3000|https://zhanjixun.github.io|g' README.md
git pull
git add -A
git commit -m 'script push'
git push
read -n 1 -s -r -p "按任意键退出..."
