# **Godot 脚本结构**<br>**Godot Script Structure**

Godot 编辑器插件，用于查看当前 **GDScript** 的脚本结构。  
A Godot editor plugin for exploring the structure of the active **GDScript**.

> **支持版本 : Godot 官方版 4.6.1**  
> **Supported Version : Godot Official 4.6.1**

> **分支说明 :** **main** 分支以 **Godot 官方版 4.6.1** 为主要开发与测试基准。  
> **Branch Description :** **main** branch is primarily developed and tested based on **Godot 官方版 4.6.1**

## **功能**<br>**Features**

- 以树状结构显示**类、常量、变量、信号、函数和枚举**。  
	Displays **classes, constants, variables, signals, functions, and enums** in a tree.

- 支持**嵌套类**，并区分静态成员和普通成员。  
	Supports **nested classes** and distinguishes static members from regular members.

- 使用**搜索框**按名称筛选符号，并通过**类型按钮**显示或隐藏不同类别。  
	Filter symbols by name with the **search field** and show or hide categories with the **type buttons**.

- 选择树中的**符号**可跳转到脚本对应的代码行。  
	Select a **symbol** in the tree to jump to its line in the script.

- 脚本内容或当前编辑脚本变化时，结构会**自动刷新**。  
	The structure **refreshes automatically** when the source or active script changes.

## **安装**<br>**Installation**

**步骤一 :** 将插件文件夹复制到 Godot 项目的 `res://addons/` 目录。  
**Step 1 :** Copy the plugin folder into the Godot project's `res://addons/` directory.

**步骤二 :** 在 Godot 中打开 `项目` > `项目设置` > `插件` 。  
**Step 2 :** In Godot, open `Project` > `Project Settings` > `Plugins`.

**步骤三 :** 启用 `Script Structure` 插件。  
**Step 3 :** Enable the `Script Structure` plugin.

## **使用**<br>**Usage**

打开 **GDScript** 后，在脚本编辑器的结构面板中浏览符号。  
Open a **GDScript** and browse its symbols in the structure panel of the script editor.

输入名称可筛选符号；点击类型图标可切换该类别的**显示状态**。  
Enter a name to filter symbols; click a type icon to toggle that category's **visibility**.

点击任意符号即可在脚本中**定位到对应行**。  
Click any symbol to **navigate to its corresponding line** in the script.

> **⚠ ⚠ ⚠**  
> **本项目在开发过程中大量使用了 AI 代码生成技术。虽然已由作者进行测试，但仍建议在生产环境中先进行充分验证。**  
> **This project was developed with extensive use of AI code generation. Although tested by the author, thorough validation in a production environment is recommended.**  
> **⚠ ⚠ ⚠**
