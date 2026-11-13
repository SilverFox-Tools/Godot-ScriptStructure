# <strong><span style="color: #007FFF;">Godot 脚本结构</span></strong><br><strong><span style="color: #007FFF;">Godot Script Structure</span></strong>

Godot 编辑器插件，用于查看当前 <strong><span style="color: #3FFF3F;">GDScript</span></strong> 的脚本结构。<br>A Godot editor plugin for exploring the structure of the active <strong><span style="color: #3FFF3F;">GDScript</span></strong>.

## <strong><span style="color: #007FFF;">功能</span></strong><br><strong><span style="color: #007FFF;">Features</span></strong>

- 以树状结构显示<strong><span style="color: #3FFF3F;">类、常量、变量、信号、函数和枚举</span></strong>。<br>Displays <strong><span style="color: #3FFF3F;">classes, constants, variables, signals, functions, and enums</span></strong> in a tree.

- 支持<strong><span style="color: #3FFF3F;">嵌套类</span></strong>，并区分静态成员和普通成员。<br>Supports <strong><span style="color: #3FFF3F;">nested classes</span></strong> and distinguishes static members from regular members.

- 使用<strong><span style="color: #3FFF3F;">搜索框</span></strong>按名称筛选符号，并通过<strong><span style="color: #3FFF3F;">类型按钮</span></strong>显示或隐藏不同类别。<br>Filter symbols by name with the <strong><span style="color: #3FFF3F;">search field</span></strong> and show or hide categories with the <strong><span style="color: #3FFF3F;">type buttons</span></strong>.

- 选择树中的<strong><span style="color: #3FFF3F;">符号</span></strong>可跳转到脚本对应的代码行。<br>Select a <strong><span style="color: #3FFF3F;">symbol</span></strong> in the tree to jump to its line in the script.

- 脚本内容或当前编辑脚本变化时，结构会<strong><span style="color: #3FFF3F;">自动刷新</span></strong>。<br>The structure <strong><span style="color: #3FFF3F;">refreshes automatically</span></strong> when the source or active script changes.

## <strong><span style="color: #007FFF;">安装</span></strong><br><strong><span style="color: #007FFF;">Installation</span></strong>

<strong><span style="color: #FFBF00;">步骤一：</span></strong> 将插件文件夹复制到 Godot 项目的 <strong><span style="color: #3FFF3F;">res://addons/</span></strong> 目录。<br><strong><span style="color: #FFBF00;">Step 1:</span></strong> Copy the plugin folder into the Godot project's <strong><span style="color: #3FFF3F;">res://addons/</span></strong> directory.

<strong><span style="color: #FFBF00;">步骤二：</span></strong> 在 Godot 中打开“项目 > 项目设置 > 插件”。<br><strong><span style="color: #FFBF00;">Step 2:</span></strong> In Godot, open <strong><span style="color: #3FFF3F;">Project &gt; Project Settings &gt; Plugins</span></strong>.

<strong><span style="color: #FFBF00;">步骤三：</span></strong> 启用 <strong><span style="color: #3FFF3F;">Script Structure</span></strong> 插件。<br><strong><span style="color: #FFBF00;">Step 3:</span></strong> Enable the <strong><span style="color: #3FFF3F;">Script Structure</span></strong> plugin.

## <strong><span style="color: #007FFF;">使用</span></strong><br><strong><span style="color: #007FFF;">Usage</span></strong>

打开 <strong><span style="color: #3FFF3F;">GDScript</span></strong> 后，在脚本编辑器的结构面板中浏览符号。<br>Open a <strong><span style="color: #3FFF3F;">GDScript</span></strong> and browse its symbols in the structure panel of the script editor.

输入名称可筛选符号；点击类型图标可切换该类别的<strong><span style="color: #3FFF3F;">显示状态</span></strong>。<br>Enter a name to filter symbols; click a type icon to toggle that category's <strong><span style="color: #3FFF3F;">visibility</span></strong>.

点击任意符号即可在脚本中<strong><span style="color: #3FFF3F;">定位到对应行</span></strong>。<br>Click any symbol to <strong><span style="color: #3FFF3F;">navigate to its corresponding line</span></strong> in the script.

> <strong><span style="color: #FFFF00;">⚠ ⚠ ⚠ ⚠ ⚠</span></strong><br>
> <strong><span style="color: #BF0000;">本项目在开发过程中大量使用了 AI 代码生成技术。虽然已由作者进行测试，但仍建议在生产环境中先进行充分验证。<br>This project was developed with extensive use of AI code generation. Although tested by the author, thorough validation in a production environment is recommended.</span></strong><br>
> <strong><span style="color: #FFFF00;">⚠ ⚠ ⚠ ⚠ ⚠</span></strong>
