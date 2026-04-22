# 🔧 您的飞书配置指南

## ✅ 已获取的信息

- **App ID:** `cli_a96285948f795cba`
- **App Secret:** `GEYC6TjicKCOHVwPzHb9QciwM5BIE4JT`

---

## 📋 需要在飞书开放平台完成的配置

### 第1步：添加应用权限（必须）

1. **访问应用管理页面**
   ```
   https://open.feishu.cn/app/cli_a96285948f795cba
   ```

2. **点击【权限管理】**

3. **搜索并添加以下权限：**
   
   **云文档权限（必须）：**
   - ✅ `docx:document` - 查看、评论、编辑和管理文档
   - ✅ `drive:drive` - 查看、评论、编辑和管理云空间中的文件

   **其他权限（可选）：**
   - `im:message` - 发送消息（用于发送培训通知）
   - `contact:user.base` - 获取用户基本信息

4. **点击【发布版本】**
   - 这一步非常重要！
   - 权限必须发布后才能生效

---

### 第2步：配置OAuth重定向URL（必须）

1. **点击【安全设置】**
   
   或直接访问：
   ```
   https://open.feishu.cn/app/cli_a96285948f795cba/safe
   ```

2. **找到【重定向URL】部分**

3. **添加以下URL：**
   ```
   http://localhost:3000/callback
   ```

4. **点击【保存】**

---

### 第3步：确认应用已启用

1. **在应用详情页**

2. **确认应用状态为【已启用】**

3. **如果是【停用】状态，点击【启用】**

---

## 🚀 完成上述配置后，运行以下命令

### 方式1：使用配置脚本（推荐）

在终端运行：

```bash
cd ~/cc_test/training-site

# 运行配置脚本
./setup-feishu-mcp.sh
```

当提示输入时：
- App ID: `cli_a96285948f795cba`
- App Secret: `GEYC6TjicKCOHVwPzHb9QciwM5BIE4JT`

脚本会自动打开浏览器进行授权。

---

### 方式2：手动配置（如果脚本失败）

#### 2.1 登录飞书

```bash
npx -y @larksuiteoapi/lark-mcp login \
  -a cli_a96285948f795cba \
  -s GEYC6TjicKCOHVwPzHb9QciwM5BIE4JT \
  --scope "offline_access docx:document drive:drive im:message"
```

浏览器会自动打开，点击【同意授权】。

#### 2.2 配置Kiro MCP

编辑 `~/.kiro/settings/mcp.json`：

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
        "cli_a96285948f795cba",
        "-s",
        "GEYC6TjicKCOHVwPzHb9QciwM5BIE4JT",
        "--oauth",
        "--token-mode",
        "user_access_token",
        "-t",
        "docx.v1.document.create,docx.v1.document.raw_content.create,drive.v1.file.list,drive.v1.folder.create,preset.docx.default"
      ],
      "disabled": false,
      "autoApprove": []
    }
  },
  "powers": {
    "mcpServers": {}
  }
}
```

#### 2.3 重启Kiro

重启Kiro使配置生效。

---

## 🎯 配置完成后的测试

### 测试1：检查MCP工具是否可用

在Kiro中对我说：
```
列出所有可用的飞书MCP工具
```

应该能看到类似这些工具：
- `docx.v1.document.create` - 创建文档
- `drive.v1.folder.create` - 创建文件夹
- `drive.v1.file.list` - 列出文件

### 测试2：创建测试文件夹

在Kiro中对我说：
```
使用飞书MCP，在我的云空间创建一个测试文件夹"测试"
```

如果成功，说明配置正确！

---

## 📝 配置完成后，开始同步培训内容

在Kiro中对我说：

```
使用飞书MCP，执行以下操作：

1. 在我的飞书云空间创建文件夹"液冷连接系统专家顾问特训营"

2. 在该文件夹下创建5个子文件夹：
   - Day 1 - 液冷基础与行业生态
   - Day 2 - 产品深度解析
   - Day 3 - 客户场景与解决方案
   - Day 4 - 顾问式销售技巧
   - Day 5 - 实战演练与考核

3. 读取 ~/cc_test/training-site/feishu-export/ 目录下的所有Markdown文件

4. 将每个Markdown文件的内容创建为飞书文档，放入对应的Day文件夹中
```

---

## 🔧 常见问题

### Q1: 登录时浏览器没有自动打开？

**A:** 手动复制终端显示的URL到浏览器打开。

### Q2: 授权后显示"登录失败"？

**A:** 检查：
1. 应用权限是否已添加并发布
2. 重定向URL是否配置为 `http://localhost:3000/callback`
3. 应用是否已启用

### Q3: Kiro中看不到飞书MCP工具？

**A:** 
1. 确认已重启Kiro
2. 检查 `~/.kiro/settings/mcp.json` 配置
3. 在终端测试：
   ```bash
   npx -y @larksuiteoapi/lark-mcp mcp -a cli_a96285948f795cba -s GEYC6TjicKCOHVwPzHb9QciwM5BIE4JT --oauth --token-mode user_access_token
   ```

### Q4: 无法创建文档，提示"权限不足"？

**A:**
1. 确认权限包含 `docx:document` 和 `drive:drive`
2. 确认权限已点击【发布版本】
3. 重新登录：
   ```bash
   npx -y @larksuiteoapi/lark-mcp login -a cli_a96285948f795cba -s GEYC6TjicKCOHVwPzHb9QciwM5BIE4JT --scope "offline_access docx:document drive:drive"
   ```

---

## ✅ 配置检查清单

完成以下所有步骤：

- [ ] 在飞书开放平台添加权限（`docx:document` + `drive:drive`）
- [ ] 点击【发布版本】使权限生效
- [ ] 配置重定向URL（`http://localhost:3000/callback`）
- [ ] 确认应用已启用
- [ ] 运行登录命令并在浏览器授权
- [ ] 配置 `~/.kiro/settings/mcp.json`
- [ ] 重启Kiro
- [ ] 在Kiro中测试MCP工具是否可用

全部完成后，就可以开始同步培训内容了！🎉

---

**App ID:** cli_a96285948f795cba  
**配置页面:** https://open.feishu.cn/app/cli_a96285948f795cba  
**创建时间:** 2026年4月22日
