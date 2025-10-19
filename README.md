# actions-repo

一组与 OpenWrt 包构建和发布相关的 GitHub Actions，方便在 CI/CD 流程中直接调用。

## 📦 提供的 Actions

### 1. parse-ipk （批处理版）

扫描目录下的 `.ipk` 文件，解析出包名、版本、架构，并生成汇总文件（支持表格、CSV、JSONL）。

```yaml
- name: Generate release info
  id: geninfo
  uses: yourname/actions-repo/.github/actions/parse-ipk@v1
  with:
    base_path: sdk/upload/${{ matrix.platform }}/packages
    pattern: "**/*.ipk"
    format: table
    output_file: release-info-${{ matrix.platform }}.txt

- name: Show count
  run: echo "Processed ${{ steps.geninfo.outputs.count }} files"
