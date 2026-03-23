# Novella Site

Novella 官网静态站，基于 Jaspr `static` 模式构建，通过 GitHub Actions 部署到 Cloudflare Pages。

## 本地开发

1. 安装 Jaspr CLI

```bash
dart pub global activate jaspr_cli
```

2. 安装依赖

```bash
npm install
dart pub get
```

3. 拉取 GitHub 数据（必须，无 mock 数据回退）

```bash
export GITHUB_TOKEN=your_token
dart run tool/fetch_site_data.dart
```

4. 构建 CSS

```bash
npx @tailwindcss/cli -i src/input.css -o web/styles.css --minify
```

5. 启动开发服务器

```bash
jaspr serve
```

## 构建

```bash
jaspr build --sitemap-domain https://novella.celia.sh
```

常用环境变量：

- `GITHUB_REPOSITORY`，默认 `Kanscape/Novella`
- `GITHUB_TOKEN`，必需，构建期读取 GitHub API
- `SITE_URL`，默认 `https://novella.celia.sh`
- `SITE_BASE_PATH`，默认 `/`
- `SITE_DATA_PATH`，默认 `.generated/site_data.json`
