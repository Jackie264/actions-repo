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
```

### 2. parse-ipk-file （单文件版）

解析单个 .ipk 文件，直接输出 pkg、ver、arch。

```yaml
- name: Parse one ipk
  id: parse
  uses: yourname/actions-repo/.github/actions/parse-ipk-file@v1
  with:
    file: sdk/upload/x86_64/packages/shadowsocks-rust-ssserver_1.23.5-1_x86_64.ipk

- name: Show result
  run: |
    echo "pkg=${{ steps.parse.outputs.pkg }}"
    echo "ver=${{ steps.parse.outputs.ver }}"
    echo "arch=${{ steps.parse.outputs.arch }}"
```

### 3. gen-luci-mk-patch

扫描 packages/**/Makefile，将 ../../luci.mk 替换为 $(TOPDIR)/feeds/luci/luci.mk，并生成补丁文件。

```yaml
- name: Generate luci.mk patch
  id: lucipatch
  uses: yourname/actions-repo/.github/actions/gen-luci-mk-patch@v1
  with:
    packages_dir: sdk/packages
    output_dir: sdk/patches

- name: Show patch path
  run: echo "Patch file: ${{ steps.lucipatch.outputs.patch_file }}"
```

### 4. ipkg-make-index

生成 OpenWrt Packages 索引文件。

```yaml
- name: Generate Packages index
  id: index
  uses: yourname/actions-repo/.github/actions/ipkg-make-index@v1
  with:
    pkg_dir: sdk/upload/${{ matrix.platform }}/packages
    output_file: sdk/upload/${{ matrix.platform }}/Packages

- name: Show index path
  run: echo "Packages index at ${{ steps.index.outputs.index_file }}"
```

## 🔖 版本管理

•  推荐使用 tag（例如 @v1.0.0）来引用，保证稳定性。
•  如果要持续跟进最新改动，可以用 @main，但可能会有不兼容更新。

## 📌 总结

这个仓库目前提供了四个 Action，覆盖了 包解析 → 信息汇总 → luci.mk 补丁 → Packages 索引 的完整链路。  
你可以单独使用，也可以在一个 CI/CD workflow 里组合调用。
