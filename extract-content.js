#!/usr/bin/env node

/**
 * 提取培训网站HTML内容并转换为飞书文档格式
 * 使用方法：node extract-content.js
 */

const fs = require('fs');
const path = require('path');

// 培训模块定义
const modules = [
  { day: 1, module: 1, title: '液冷为什么是AI超算的唯一解', file: 'day1/module1.html' },
  { day: 1, module: 2, title: '英伟达液冷生态与技术规范', file: 'day1/module2.html' },
  { day: 1, module: 3, title: '软管与快接头的分合关系', file: 'day1/module3.html' },
  { day: 1, module: 4, title: '海外市场与合规认证', file: 'day1/module4.html' },
  { day: 2, module: 1, title: 'LT800系列产品深度解析', file: 'day2/module1.html' },
  { day: 2, module: 2, title: '技术创新与差异化优势', file: 'day2/module2.html' },
  { day: 2, module: 3, title: '应用案例库', file: 'day2/module3.html' },
  { day: 2, module: 4, title: '产品演示与实操', file: 'day2/module4.html' },
  { day: 3, module: 1, title: 'AI超算中心解决方案设计', file: 'day3/module1.html' },
  { day: 3, module: 2, title: '云服务商液冷方案设计', file: 'day3/module2.html' },
  { day: 3, module: 3, title: '边缘计算场景方案设计', file: 'day3/module3.html' },
  { day: 3, module: 4, title: '方案设计工具与模板', file: 'day3/module4.html' },
  { day: 4, module: 1, title: '需求挖掘与痛点分析', file: 'day4/module1.html' },
  { day: 4, module: 2, title: '价值呈现与ROI计算', file: 'day4/module2.html' },
  { day: 4, module: 3, title: '异议处理与谈判技巧', file: 'day4/module3.html' },
  { day: 4, module: 4, title: '商务流程与合同要点', file: 'day4/module4.html' },
  { day: 5, module: 1, title: '角色扮演（客户拜访）', file: 'day5/module1.html' },
  { day: 5, module: 2, title: '方案设计（实战项目）', file: 'day5/module2.html' },
  { day: 5, module: 3, title: '客户提案（演讲技巧）', file: 'day5/module3.html' },
  { day: 5, module: 4, title: '综合考核与认证', file: 'day5/module4.html' },
];

// Day标题映射
const dayTitles = {
  1: '液冷基础与行业生态',
  2: '产品深度解析',
  3: '客户场景与解决方案',
  4: '顾问式销售技巧',
  5: '实战演练与考核'
};

// 简单的HTML标签清理
function cleanHtml(html) {
  return html
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, '')
    .replace(/<header\b[^<]*(?:(?!<\/header>)<[^<]*)*<\/header>/gi, '')
    .replace(/<nav\b[^<]*(?:(?!<\/nav>)<[^<]*)*<\/nav>/gi, '')
    .replace(/<footer\b[^<]*(?:(?!<\/footer>)<[^<]*)*<\/footer>/gi, '');
}

// 提取文本内容
function extractText(html) {
  let text = cleanHtml(html);
  
  // 提取标题
  text = text.replace(/<h1[^>]*>(.*?)<\/h1>/gi, '\n# $1\n');
  text = text.replace(/<h2[^>]*>(.*?)<\/h2>/gi, '\n## $1\n');
  text = text.replace(/<h3[^>]*>(.*?)<\/h3>/gi, '\n### $1\n');
  
  // 提取列表
  text = text.replace(/<li[^>]*>(.*?)<\/li>/gi, '• $1\n');
  
  // 提取段落
  text = text.replace(/<p[^>]*>(.*?)<\/p>/gi, '$1\n\n');
  
  // 提取强调
  text = text.replace(/<strong[^>]*>(.*?)<\/strong>/gi, '**$1**');
  text = text.replace(/<em[^>]*>(.*?)<\/em>/gi, '*$1*');
  
  // 提取链接
  text = text.replace(/<a[^>]*href="([^"]*)"[^>]*>(.*?)<\/a>/gi, '[$2]($1)');
  
  // 清理剩余HTML标签
  text = text.replace(/<[^>]+>/g, '');
  
  // 清理多余空行
  text = text.replace(/\n{3,}/g, '\n\n');
  
  // 解码HTML实体
  text = text
    .replace(/&nbsp;/g, ' ')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'");
  
  return text.trim();
}

// 创建输出目录
const outputDir = 'feishu-export';
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// 创建模块清单
const manifest = {
  title: '液冷连接系统专家顾问特训营',
  website: 'https://lucylook6-design.github.io/liquid-cooling-training/',
  totalModules: modules.length,
  days: {},
  modules: []
};

console.log('🚀 开始提取培训内容...\n');

// 处理每个模块
modules.forEach((module) => {
  const filePath = path.join(__dirname, module.file);
  
  if (!fs.existsSync(filePath)) {
    console.log(`⚠️  文件不存在: ${module.file}`);
    return;
  }
  
  console.log(`📝 处理 Day ${module.day} 模块${module.module}: ${module.title}`);
  
  // 读取HTML文件
  const html = fs.readFileSync(filePath, 'utf-8');
  
  // 提取文本内容
  const content = extractText(html);
  
  // 创建Markdown文件
  const dayFolder = `Day${module.day}`;
  const dayFolderPath = path.join(outputDir, dayFolder);
  if (!fs.existsSync(dayFolderPath)) {
    fs.mkdirSync(dayFolderPath, { recursive: true });
  }
  
  const outputFileName = `模块${module.module}_${module.title}.md`;
  const outputFilePath = path.join(dayFolderPath, outputFileName);
  
  // 生成Markdown内容
  const markdown = `# Day ${module.day} 模块${module.module}：${module.title}

> **在线学习：** [点击访问](https://lucylook6-design.github.io/liquid-cooling-training/${module.file})

---

${content}

---

## 📚 延伸学习

完整的培训内容（包括交互式图表、产品图片、视频链接）请访问在线培训网站：

🔗 **在线地址：** https://lucylook6-design.github.io/liquid-cooling-training/${module.file}

---

**提示：** 本文档由培训网站自动生成，如需编辑请在飞书中直接修改。
`;
  
  fs.writeFileSync(outputFilePath, markdown, 'utf-8');
  
  // 添加到清单
  if (!manifest.days[module.day]) {
    manifest.days[module.day] = {
      title: `Day ${module.day}：${dayTitles[module.day]}`,
      modules: []
    };
  }
  
  manifest.days[module.day].modules.push({
    module: module.module,
    title: module.title,
    file: `${dayFolder}/${outputFileName}`,
    url: `https://lucylook6-design.github.io/liquid-cooling-training/${module.file}`
  });
  
  manifest.modules.push({
    day: module.day,
    module: module.module,
    title: module.title,
    file: `${dayFolder}/${outputFileName}`,
    url: `https://lucylook6-design.github.io/liquid-cooling-training/${module.file}`
  });
});

// 保存清单
fs.writeFileSync(
  path.join(outputDir, 'manifest.json'),
  JSON.stringify(manifest, null, 2),
  'utf-8'
);

// 创建README
const readme = `# 液冷连接系统专家顾问特训营 - 飞书导出版

本目录包含培训网站的20个模块内容，已转换为Markdown格式，可直接导入飞书云文档。

## 📁 文件结构

\`\`\`
feishu-export/
├── Day1/                    # Day 1：液冷基础与行业生态
│   ├── 模块1_液冷为什么是AI超算的唯一解.md
│   ├── 模块2_英伟达液冷生态与技术规范.md
│   ├── 模块3_软管与快接头的分合关系.md
│   └── 模块4_海外市场与合规认证.md
├── Day2/                    # Day 2：产品深度解析
│   ├── 模块1_LT800系列产品深度解析.md
│   ├── 模块2_技术创新与差异化优势.md
│   ├── 模块3_应用案例库.md
│   └── 模块4_产品演示与实操.md
├── Day3/                    # Day 3：客户场景与解决方案
│   ├── 模块1_AI超算中心解决方案设计.md
│   ├── 模块2_云服务商液冷方案设计.md
│   ├── 模块3_边缘计算场景方案设计.md
│   └── 模块4_方案设计工具与模板.md
├── Day4/                    # Day 4：顾问式销售技巧
│   ├── 模块1_需求挖掘与痛点分析.md
│   ├── 模块2_价值呈现与ROI计算.md
│   ├── 模块3_异议处理与谈判技巧.md
│   └── 模块4_商务流程与合同要点.md
├── Day5/                    # Day 5：实战演练与考核
│   ├── 模块1_角色扮演（客户拜访）.md
│   ├── 模块2_方案设计（实战项目）.md
│   ├── 模块3_客户提案（演讲技巧）.md
│   └── 模块4_综合考核与认证.md
├── manifest.json            # 模块清单（JSON格式）
└── README.md                # 本文件
\`\`\`

## 📊 培训概览

- **总模块数：** 20个
- **总时长：** 40小时（5天）
- **培训目标：** 达到行业Top 20%的专家级顾问型销售能力

## 🔗 在线学习

完整的培训内容（包括交互式图表、产品图片、视频链接）请访问：

**培训网站：** https://lucylook6-design.github.io/liquid-cooling-training/

## 📝 使用方法

### 方法1：使用飞书MCP自动同步（推荐）

在Kiro中对AI说：
\`\`\`
使用飞书MCP，将feishu-export目录下的内容同步到飞书云文档
\`\`\`

### 方法2：手动导入

1. 在飞书云文档中创建文件夹"液冷培训"
2. 创建5个子文件夹（Day1-Day5）
3. 在每个子文件夹中创建文档
4. 复制对应的Markdown内容并粘贴

## 💡 注意事项

- Markdown文件仅包含文本内容，作为快速参考
- 完整的交互功能（图表、图片、链接）请访问在线网站
- 建议在飞书中添加在线网站的快捷方式

---

**生成时间：** ${new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' })}  
**培训网站：** https://lucylook6-design.github.io/liquid-cooling-training/
`;

fs.writeFileSync(path.join(outputDir, 'README.md'), readme, 'utf-8');

console.log('\n✅ 内容提取完成！');
console.log(`\n📁 输出目录: ${outputDir}/`);
console.log(`📄 共生成 ${modules.length} 个Markdown文件`);
console.log(`📋 清单文件: ${outputDir}/manifest.json`);
console.log('\n下一步：运行 ./sync-to-feishu.sh 同步到飞书');
