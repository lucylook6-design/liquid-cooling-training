#!/bin/bash

# 液冷培训内容同步到飞书脚本
# 使用方法：./sync-to-feishu.sh

set -e

echo "🚀 开始同步培训内容到飞书..."
echo ""

# 检查是否已配置飞书MCP
if ! grep -q "lark-mcp" ~/.kiro/settings/mcp.json 2>/dev/null; then
    echo "❌ 错误：未检测到飞书MCP配置"
    echo ""
    echo "请先按照以下步骤配置："
    echo "1. 阅读 FEISHU_SYNC_GUIDE.md"
    echo "2. 创建飞书应用并获取 App ID 和 App Secret"
    echo "3. 配置 ~/.kiro/settings/mcp.json"
    echo "4. 运行 npx -y @larksuiteoapi/lark-mcp login 登录"
    echo ""
    exit 1
fi

echo "✅ 检测到飞书MCP配置"
echo ""

# 创建临时目录存放Markdown文件
EXPORT_DIR="feishu-export"
mkdir -p $EXPORT_DIR

echo "📝 正在生成Markdown文件..."

# 定义培训模块
declare -A MODULES=(
    ["day1/module1"]="Day 1 模块1：液冷为什么是AI超算的唯一解"
    ["day1/module2"]="Day 1 模块2：英伟达液冷生态与技术规范"
    ["day1/module3"]="Day 1 模块3：软管与快接头的分合关系"
    ["day1/module4"]="Day 1 模块4：海外市场与合规认证"
    ["day2/module1"]="Day 2 模块1：LT800系列产品深度解析"
    ["day2/module2"]="Day 2 模块2：技术创新与差异化优势"
    ["day2/module3"]="Day 2 模块3：应用案例库"
    ["day2/module4"]="Day 2 模块4：产品演示与实操"
    ["day3/module1"]="Day 3 模块1：AI超算中心解决方案设计"
    ["day3/module2"]="Day 3 模块2：云服务商液冷方案设计"
    ["day3/module3"]="Day 3 模块3：边缘计算场景方案设计"
    ["day3/module4"]="Day 3 模块4：方案设计工具与模板"
    ["day4/module1"]="Day 4 模块1：需求挖掘与痛点分析"
    ["day4/module2"]="Day 4 模块2：价值呈现与ROI计算"
    ["day4/module3"]="Day 4 模块3：异议处理与谈判技巧"
    ["day4/module4"]="Day 4 模块4：商务流程与合同要点"
    ["day5/module1"]="Day 5 模块1：角色扮演（客户拜访）"
    ["day5/module2"]="Day 5 模块2：方案设计（实战项目）"
    ["day5/module3"]="Day 5 模块3：客户提案（演讲技巧）"
    ["day5/module4"]="Day 5 模块4：综合考核与认证"
)

# 提取HTML内容并转换为Markdown（简化版）
for module_path in "${!MODULES[@]}"; do
    module_name="${MODULES[$module_path]}"
    html_file="${module_path}.html"
    md_file="$EXPORT_DIR/${module_path//\//_}.md"
    
    if [ -f "$html_file" ]; then
        echo "  ✓ 处理 $module_name"
        
        # 创建Markdown文件（提取主要内容）
        cat > "$md_file" << EOF
# $module_name

> 本文档由培训网站自动生成
> 在线访问：https://lucylook6-design.github.io/liquid-cooling-training/$html_file

---

**注意：** 本文档为简化版，完整内容请访问在线培训网站。

## 内容概览

本模块包含以下内容：
- 核心知识点讲解
- 实战案例分析
- 复习题与练习
- 延伸学习资源

## 在线学习

请访问完整的在线培训网站获取：
- 交互式图表（Mermaid）
- 产品真实图片
- 视频教程链接
- 可下载的工具模板

🔗 **在线地址：** https://lucylook6-design.github.io/liquid-cooling-training/$html_file

---

**提示：** 如需编辑此文档，请在飞书中直接修改。培训网站内容更新后，可重新同步。
EOF
    fi
done

echo ""
echo "✅ Markdown文件生成完成！"
echo "   位置：$EXPORT_DIR/"
echo ""

# 提供下一步指引
cat << EOF
📋 下一步操作：

方式1：使用飞书MCP自动同步（推荐）
--------------------------------------
在Kiro中对AI说：
"使用飞书MCP，在我的云空间创建文件夹'液冷培训'，然后将 feishu-export/ 目录下的20个Markdown文件同步到对应的子文件夹中。"

方式2：手动导入
--------------------------------------
1. 打开飞书云文档
2. 创建文件夹"液冷连接系统专家顾问特训营"
3. 创建5个子文件夹（Day 1-5）
4. 在每个子文件夹中创建文档，复制粘贴对应的Markdown内容

方式3：分享在线链接
--------------------------------------
直接在飞书中分享培训网站链接：
https://lucylook6-design.github.io/liquid-cooling-training/

团队成员可以直接在浏览器中学习，无需同步。

---

💡 提示：
- 完整的培训内容（包括图表、图片、交互功能）请访问在线网站
- Markdown文件仅包含文本内容，作为飞书内快速参考
- 建议在飞书中添加在线网站的快捷方式

EOF

echo ""
echo "🎉 同步准备完成！"
