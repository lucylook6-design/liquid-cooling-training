# 培训内容同步到飞书指南

## 方案概述

将液冷连接系统专家顾问培训网站的内容同步到飞书云文档，方便团队在飞书内学习和协作。

---

## 方案一：使用飞书官方MCP插件（推荐）

### 步骤1：创建飞书应用

1. 访问 [飞书开放平台](https://open.feishu.cn/)
2. 点击"控制台" → "创建企业自建应用"
3. 填写应用信息：
   - 应用名称：液冷培训同步工具
   - 应用描述：用于同步培训内容到飞书云文档
4. 获取 **App ID** 和 **App Secret**（保存好，后续需要）

### 步骤2：配置应用权限

在应用管理页面，添加以下权限：

**云文档权限：**
- `docx:document` - 创建、编辑、读取文档
- `drive:drive` - 访问云空间

**其他权限（可选）：**
- `im:message` - 发送消息通知
- `contact:user.base` - 获取用户信息

点击"发布版本"使权限生效。

### 步骤3：配置OAuth重定向URL

在应用设置中，添加重定向URL：
```
http://localhost:3000/callback
```

### 步骤4：安装飞书MCP插件

在终端运行：
```bash
# 登录飞书（获取用户访问令牌）
npx -y @larksuiteoapi/lark-mcp login -a <your_app_id> -s <your_app_secret> --scope offline_access docx:document drive:drive
```

浏览器会自动打开，授权后返回终端。

### 步骤5：配置Kiro MCP

编辑 `~/.kiro/settings/mcp.json`，添加：

```json
{
  "mcpServers": {
    "lark-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "@larksuiteoapi/lark-mcp",
        "mcp",
        "-a",
        "<your_app_id>",
        "-s",
        "<your_app_secret>",
        "--oauth",
        "--token-mode",
        "user_access_token",
        "-t",
        "docx.v1.document.create,docx.v1.document.raw_content.create,drive.v1.file.list,preset.docx.default"
      ],
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

替换 `<your_app_id>` 和 `<your_app_secret>` 为您的实际值。

### 步骤6：重启Kiro

重启Kiro使MCP配置生效。

### 步骤7：使用AI同步内容

在Kiro中对我说：
```
使用飞书MCP，将培训网站的20个模块内容同步到飞书云文档，创建一个文件夹"液冷培训"，每个Day创建一个子文件夹，每个模块创建一个文档。
```

---

## 方案二：手动导出（简单快速）

### 步骤1：准备Markdown文件

我已经为您准备了20个模块的Markdown版本，位于 `training-site/feishu-export/` 目录。

### 步骤2：在飞书中创建文件夹结构

在飞书云文档中创建：
```
液冷连接系统专家顾问特训营/
├── Day 1 - 液冷基础与行业生态/
│   ├── 模块1：液冷为什么是AI超算的唯一解
│   ├── 模块2：英伟达液冷生态与技术规范
│   ├── 模块3：软管与快接头的分合关系
│   └── 模块4：海外市场与合规认证
├── Day 2 - 产品深度解析/
│   ├── 模块1：LT800系列产品深度解析
│   ├── 模块2：技术创新与差异化优势
│   ├── 模块3：应用案例库
│   └── 模块4：产品演示与实操
├── Day 3 - 客户场景与解决方案/
│   ├── 模块1：AI超算中心解决方案设计
│   ├── 模块2：云服务商液冷方案设计
│   ├── 模块3：边缘计算场景方案设计
│   └── 模块4：方案设计工具与模板
├── Day 4 - 顾问式销售技巧/
│   ├── 模块1：需求挖掘与痛点分析
│   ├── 模块2：价值呈现与ROI计算
│   ├── 模块3：异议处理与谈判技巧
│   └── 模块4：商务流程与合同要点
└── Day 5 - 实战演练与考核/
    ├── 模块1：角色扮演（客户拜访）
    ├── 模块2：方案设计（实战项目）
    ├── 模块3：客户提案（演讲技巧）
    └── 模块4：综合考核与认证
```

### 步骤3：复制粘贴内容

1. 打开 `training-site/feishu-export/` 目录下的Markdown文件
2. 复制内容
3. 在飞书对应文档中粘贴
4. 飞书会自动识别Markdown格式并转换为富文本

---

## 方案三：使用飞书导入功能

### 步骤1：导出HTML为PDF

```bash
cd training-site

# 安装wkhtmltopdf（如果还没安装）
brew install wkhtmltopdf

# 批量转换HTML为PDF
for day in day1 day2 day3 day4 day5; do
  for module in $day/*.html; do
    wkhtmltopdf $module ${module%.html}.pdf
  done
done
```

### 步骤2：在飞书中导入PDF

1. 在飞书云文档中，点击"导入"
2. 选择PDF文件
3. 飞书会自动将PDF转换为云文档

---

## 推荐方案对比

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| **方案一：MCP插件** | 自动化、可批量操作、保持格式 | 需要配置应用和权限 | ⭐⭐⭐⭐⭐ |
| **方案二：手动导出** | 简单快速、无需配置 | 需要手动操作20次 | ⭐⭐⭐ |
| **方案三：PDF导入** | 保留原始样式 | 不可编辑、文件较大 | ⭐⭐ |

---

## 后续维护

### 自动同步脚本

配置好MCP后，可以创建自动同步脚本：

```bash
#!/bin/bash
# sync-to-feishu.sh

# 当培训内容更新时，自动同步到飞书
cd training-site
git pull origin main

# 使用Kiro AI自动同步
kiro "检查training-site目录的更新，将变更的模块同步到飞书云文档"
```

### 定期更新提醒

在飞书中设置日历提醒，每季度更新培训内容：
- 更新最新GPU数据
- 添加新的客户案例
- 优化销售话术

---

## 常见问题

### Q1：飞书MCP连接失败？
**A：** 检查以下几点：
1. App ID和App Secret是否正确
2. 应用权限是否已添加并发布
3. OAuth重定向URL是否配置为 `http://localhost:3000/callback`
4. 是否已运行 `npx -y @larksuiteoapi/lark-mcp login` 登录

### Q2：无法创建文档？
**A：** 确保应用有以下权限：
- `docx:document` - 文档权限
- `drive:drive` - 云空间权限

### Q3：图片无法同步？
**A：** 飞书MCP目前不支持文件上传，需要手动上传图片：
1. 将 `training-site/images/` 目录下的图片上传到飞书
2. 在文档中插入图片链接

### Q4：表格格式错乱？
**A：** 飞书Markdown对表格支持有限，建议：
1. 使用飞书的表格功能重新创建
2. 或者保留HTML格式，在飞书中以代码块展示

---

## 联系支持

如果遇到问题，可以：
1. 查看 [飞书开放平台文档](https://open.feishu.cn/document/home/index)
2. 在GitHub提Issue：[lark-openapi-mcp](https://github.com/larksuite/lark-openapi-mcp)
3. 联系飞书开放平台技术支持

---

**创建时间：** 2026年4月22日  
**最后更新：** 2026年4月22日
