# 安装

## 环境要求

- **Godot Engine** 4.x
- 无需额外依赖或插件

## 第一步：下载插件

### 方式 A：Git 克隆（推荐）

将仓库直接克隆到项目的 `addons/` 目录：

```bash
cd your_godot_project/addons/
git clone https://github.com/jinyangcruise/GDSQL.git gdsql
```

### 方式 B：下载 ZIP

1. 从 [GitHub Releases](https://github.com/jinyangcruise/GDSQL/releases) 下载最新版本 ZIP
2. 将 `addons/gdsql` 文件夹解压到项目的 `addons/` 目录

项目结构应如下：

```
your_godot_project/
├── addons/
│   └── gdsql/
│       ├── plugin.cfg
│       ├── basic/
│       ├── database/
│       ├── gbatis/
│       └── ...
├── project.godot
└── ...
```

## 第二步：启用插件

1. 在 Godot 编辑器中打开项目
2. 进入 **项目 → 项目设置 → 插件**
3. 在列表中找到 **GDSQL**
4. 将状态改为 **启用**

## 第三步：访问工作台

启用后，Godot 编辑器顶部会出现 **GDSQL** 按钮。点击它切换到 GDSQL 主屏——可视化数据库工作台。

## 验证安装

在任意 GDScript 文件中测试：

```gdscript
func _ready():
    var dao = GDSQL.BaseDao.new()
    print("GDSQL 加载成功！")
```

如果项目正常运行无报错，说明 GDSQL 已就绪。

## 下一步

- [快速开始](./getting-started) — 创建第一个数据库并执行查询
- [可视化工作台](./workbench) — 探索编辑器界面
- [链式 DAO API](./dao-api) — 开始在代码中编写数据库查询
