#!/bin/bash

# 飞书MCP配置向导
# 使用方法：./setup-feishu-mcp.sh

set -e

echo "🚀 飞书MCP配置向导"
echo "================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 步骤1：检查Node.js
echo -e "${BLUE}步骤1：检查Node.js环境${NC}"
echo "--------------------------------"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js已安装：$NODE_VERSION${NC}"
else
    echo -e "${RED}✗ Node.js未安装${NC}"
    echo "请访问 https://nodejs.org/ 下载安装"
    exit 1
fi
echo ""

# 步骤2：引导创建飞书应用
echo -e "${BLUE}步骤2：创建飞书应用${NC}"
echo "--------------------------------"
echo "请按照以下步骤创建飞书应用："
echo ""
echo "1. 访问飞书开放平台："
echo -e "   ${YELLOW}https://open.feishu.cn/${NC}"
echo ""
echo "2. 点击【控制台】→【创建企业自建应用】"
echo ""
echo "3. 填写应用信息："
echo "   • 应用名称：液冷培训同步工具"
echo "   • 应用描述：用于同步培训内容到飞书云文档"
echo ""
echo "4. 创建后，获取以下信息："
echo "   • App ID（形如：cli_xxxxxx）"
echo "   • App Secret（形如：xxxxxx）"
echo ""
echo -e "${YELLOW}按回车键继续...${NC}"
read

# 步骤3：输入App ID和App Secret
echo ""
echo -e "${BLUE}步骤3：输入应用凭证${NC}"
echo "--------------------------------"
echo -n "请输入 App ID: "
read APP_ID

if [ -z "$APP_ID" ]; then
    echo -e "${RED}✗ App ID不能为空${NC}"
    exit 1
fi

echo -n "请输入 App Secret: "
read -s APP_SECRET
echo ""

if [ -z "$APP_SECRET" ]; then
    echo -e "${RED}✗ App Secret不能为空${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 凭证已输入${NC}"
echo ""

# 步骤4：配置应用权限
echo -e "${BLUE}步骤4：配置应用权限${NC}"
echo "--------------------------------"
echo "请在飞书开放平台为应用添加以下权限："
echo ""
echo "【云文档权限】"
echo "  • docx:document - 创建、编辑、读取文档"
echo "  • drive:drive - 访问云空间"
echo ""
echo "【其他权限（可选）】"
echo "  • im:message - 发送消息通知"
echo "  • contact:user.base - 获取用户信息"
echo ""
echo "添加权限后，点击【发布版本】使权限生效"
echo ""
echo -e "${YELLOW}权限配置完成后，按回车键继续...${NC}"
read

# 步骤5：配置OAuth重定向URL
echo ""
echo -e "${BLUE}步骤5：配置OAuth重定向URL${NC}"
echo "--------------------------------"
echo "在飞书开放平台的应用设置中："
echo ""
echo "1. 找到【安全设置】→【重定向URL】"
echo "2. 添加以下URL："
echo -e "   ${YELLOW}http://localhost:3000/callback${NC}"
echo "3. 保存设置"
echo ""
echo -e "${YELLOW}配置完成后，按回车键继续...${NC}"
read

# 步骤6：登录飞书（获取用户访问令牌）
echo ""
echo -e "${BLUE}步骤6：登录飞书账号${NC}"
echo "--------------------------------"
echo "即将打开浏览器进行授权登录..."
echo ""
echo -e "${YELLOW}按回车键开始登录...${NC}"
read

echo ""
echo "正在启动登录流程..."
npx -y @larksuiteoapi/lark-mcp login -a "$APP_ID" -s "$APP_SECRET" --scope "offline_access docx:document drive:drive"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ 登录成功！${NC}"
else
    echo ""
    echo -e "${RED}✗ 登录失败，请检查App ID和App Secret是否正确${NC}"
    exit 1
fi

# 步骤7：配置Kiro MCP
echo ""
echo -e "${BLUE}步骤7：配置Kiro MCP${NC}"
echo "--------------------------------"

MCP_CONFIG_FILE="$HOME/.kiro/settings/mcp.json"

# 备份现有配置
if [ -f "$MCP_CONFIG_FILE" ]; then
    cp "$MCP_CONFIG_FILE" "$MCP_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✓ 已备份现有配置${NC}"
fi

# 读取现有配置
if [ -f "$MCP_CONFIG_FILE" ]; then
    EXISTING_CONFIG=$(cat "$MCP_CONFIG_FILE")
else
    EXISTING_CONFIG='{"mcpServers":{},"powers":{"mcpServers":{}}}'
fi

# 创建新的MCP配置
cat > /tmp/lark-mcp-config.json << EOF
{
  "lark-mcp": {
    "command": "npx",
    "args": [
      "-y",
      "@larksuiteoapi/lark-mcp",
      "mcp",
      "-a",
      "$APP_ID",
      "-s",
      "$APP_SECRET",
      "--oauth",
      "--token-mode",
      "user_access_token",
      "-t",
      "docx.v1.document.create,docx.v1.document.raw_content.create,drive.v1.file.list,drive.v1.folder.create,preset.docx.default"
    ],
    "disabled": false,
    "autoApprove": []
  }
}
EOF

# 合并配置（使用jq如果可用，否则手动合并）
if command -v jq &> /dev/null; then
    echo "$EXISTING_CONFIG" | jq ".mcpServers += $(cat /tmp/lark-mcp-config.json)" > "$MCP_CONFIG_FILE"
else
    # 简单合并（假设现有配置为空或简单结构）
    cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": $(cat /tmp/lark-mcp-config.json),
  "powers": {
    "mcpServers": {}
  }
}
EOF
fi

rm /tmp/lark-mcp-config.json

echo -e "${GREEN}✓ MCP配置已更新${NC}"
echo "   配置文件：$MCP_CONFIG_FILE"
echo ""

# 步骤8：完成
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}🎉 配置完成！${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "下一步操作："
echo ""
echo "1. 重启Kiro使MCP配置生效"
echo ""
echo "2. 在Kiro中对AI说："
echo -e "   ${YELLOW}\"使用飞书MCP，将培训网站内容同步到飞书云文档\"${NC}"
echo ""
echo "3. AI将自动："
echo "   • 在飞书云空间创建文件夹'液冷培训'"
echo "   • 创建5个子文件夹（Day 1-5）"
echo "   • 将20个模块内容同步到对应文档"
echo ""
echo "配置信息已保存："
echo "  • App ID: $APP_ID"
echo "  • MCP配置: $MCP_CONFIG_FILE"
echo "  • 备份文件: $MCP_CONFIG_FILE.backup.*"
echo ""
echo -e "${BLUE}提示：如需重新配置，请运行 ./setup-feishu-mcp.sh${NC}"
echo ""
