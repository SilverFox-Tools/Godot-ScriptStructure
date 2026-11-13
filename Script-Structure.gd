@tool
extends EditorPlugin

var _Methods_List: ItemList
var _Methods_List_Parent: Node
var _Methods_List_Index := -1
var _Filter_Bar: HBoxContainer
var _Filter_Edit: LineEdit
var _Options_Button: Button
var _Type_Filter_Row: HBoxContainer
var _Tree: Tree
var _Symbol_Icons: Dictionary = {}
var _Filter_Buttons: Dictionary = {}
var _Symbol_Types := ["类", "常量", "变量", "信号", "函数", "枚举"]
var _Visible_Types: Dictionary = {}
var _Original_Placeholder := ""
var _Original_Filter_Text := ""
var _Original_Options_Visible := false
var _Replacement_Installed := false
var _Lookup_Warning_Reported := false
var _Current_Script: GDScript
var _Last_Source := ""
var _Class_Name_Pattern := RegEx.new()
var _Class_Pattern := RegEx.new()
var _Function_Pattern := RegEx.new()
var _Member_Pattern := RegEx.new()
var _Annotation_Pattern := RegEx.new()
var _Symbol_Colors := {
	"类": Color("#3b82f6"),
	"常量": Color("#f97316"),
	"变量": Color("#facc15"),
	"信号": Color("#22c55e"),
	"函数": Color("#ef4444"),
	"枚举": Color("#a855f7"),
}


func _enter_tree() -> void:
	_Class_Name_Pattern.compile("^class_name\\s+([A-Za-z_][A-Za-z0-9_]*)")
	_Class_Pattern.compile("^class\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*:")
	_Function_Pattern.compile("^(static\\s+)?func\\s+([A-Za-z_][A-Za-z0-9_]*)")
	_Member_Pattern.compile("^(static\\s+)?(var|const|signal|enum)\\s+([A-Za-z_][A-Za-z0-9_]*)")
	_Annotation_Pattern.compile("^@[A-Za-z_][A-Za-z0-9_]*(?:\\([^\\n]*\\))?\\s*")
	for Kind in _Symbol_Types:
		_Visible_Types[Kind] = true
	for Kind in _Symbol_Colors:
		_Symbol_Icons[Kind] = _Create_Symbol_Icon(_Symbol_Colors[Kind], false)
		_Symbol_Icons["静态" + Kind] = _Create_Symbol_Icon(_Symbol_Colors[Kind], true)
	_Symbol_Icons["根类"] = _Create_Symbol_Icon(Color("#38bdf8"), false)

	set_process(true)
	call_deferred("_Install_Methods_List_Replacement")


func _exit_tree() -> void:
	set_process(false)
	if is_instance_valid(_Filter_Edit):
		_Filter_Edit.placeholder_text = _Original_Placeholder
		_Filter_Edit.text = _Original_Filter_Text
		if _Filter_Edit.text_changed.is_connected(_On_Search_Changed):
			_Filter_Edit.text_changed.disconnect(_On_Search_Changed)
	if is_instance_valid(_Options_Button):
		_Options_Button.visible = _Original_Options_Visible
	if is_instance_valid(_Type_Filter_Row):
		var Filter_Parent := _Type_Filter_Row.get_parent()
		if Filter_Parent != null:
			Filter_Parent.remove_child(_Type_Filter_Row)
		_Type_Filter_Row.queue_free()
	if is_instance_valid(_Tree):
		var Tree_Parent := _Tree.get_parent()
		if Tree_Parent != null:
			Tree_Parent.remove_child(_Tree)
		_Tree.queue_free()
	if is_instance_valid(_Methods_List) and is_instance_valid(_Methods_List_Parent):
		_Methods_List_Parent.add_child(_Methods_List)
		_Methods_List_Parent.move_child(
			_Methods_List, mini(_Methods_List_Index, _Methods_List_Parent.get_child_count() - 1)
		)


func _process(_Delta: float) -> void:
	if not _Replacement_Installed:
		_Install_Methods_List_Replacement()
		return

	var Script_Editor := EditorInterface.get_script_editor()
	var Active_Script := Script_Editor.get_current_script() as GDScript
	var Source := Active_Script.source_code if Active_Script != null else ""
	if Active_Script != _Current_Script or Source != _Last_Source:
		_Refresh_Symbols()


func _Install_Methods_List_Replacement() -> void:
	if _Replacement_Installed:
		return

	var Script_Editor := EditorInterface.get_script_editor()
	if Script_Editor == null:
		return

	for Node in Script_Editor.find_children("*", "LineEdit", true, false):
		var Line_Edit := Node as LineEdit
		if Line_Edit.placeholder_text == "Filter Methods":
			_Filter_Edit = Line_Edit
			break

	if _Filter_Edit == null:
		for Node in Script_Editor.find_children("*", "LineEdit", true, false):
			var Line_Edit := Node as LineEdit
			if not Line_Edit.get_parent() is HBoxContainer:
				continue
			var Container := Line_Edit.get_parent().get_parent()
			if not Container is VBoxContainer:
				continue
			for Child in Container.get_children():
				if Child is ItemList:
					_Filter_Edit = Line_Edit
					break
			if _Filter_Edit != null:
				break

	if _Filter_Edit != null:
		_Filter_Bar = _Filter_Edit.get_parent() as HBoxContainer
		var Filter_Container := _Filter_Bar.get_parent()
		for Child in _Filter_Bar.get_children():
			if Child is Button:
				_Options_Button = Child
				break
		for Child in Filter_Container.get_children():
			if Child is ItemList:
				_Methods_List = Child
				break

	if _Methods_List == null:
		if not _Lookup_Warning_Reported:
			push_warning("Could not find the built-in Script Editor methods list.")
			_Lookup_Warning_Reported = true
		return

	var Parent := _Methods_List.get_parent()
	var Methods_List_Index := _Methods_List.get_index()
	_Methods_List_Parent = Parent
	_Methods_List_Index = Methods_List_Index
	_Tree = Tree.new()
	_Tree.Name = "Script-Structure"
	_Tree.columns = 1
	_Tree.hide_root = false
	_Tree.size_flags_horizontal = _Methods_List.size_flags_horizontal
	_Tree.size_flags_vertical = _Methods_List.size_flags_vertical
	_Tree.custom_minimum_size = _Methods_List.custom_minimum_size
	_Tree.item_selected.connect(_On_Tree_Item_Selected)
	Parent.add_child(_Tree)
	Parent.move_child(_Tree, Methods_List_Index)
	Parent.remove_child(_Methods_List)

	if is_instance_valid(_Filter_Edit):
		_Original_Placeholder = _Filter_Edit.placeholder_text
		_Original_Filter_Text = _Filter_Edit.text
		_Filter_Edit.text_changed.connect(_On_Search_Changed)
		_Type_Filter_Row = HBoxContainer.new()
		_Type_Filter_Row.Name = "Script-Symbol-Type-Filters"
		_Type_Filter_Row.add_theme_constant_override("separation", 2)
		_Filter_Bar.get_parent().add_child(_Type_Filter_Row)
		for Kind in _Symbol_Types:
			var Filter_Button := TextureButton.new()
			Filter_Button.Name = "%s-Filter" % Kind
			Filter_Button.tooltip_text = "%s：显示" % Kind
			Filter_Button.custom_minimum_size = Vector2(18, 18)
			Filter_Button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			Filter_Button.texture_normal = _Create_Symbol_Icon(_Symbol_Colors[Kind], false)
			Filter_Button.texture_pressed = _Create_Hollow_Circle_Icon(_Symbol_Colors[Kind])
			Filter_Button.toggle_mode = true
			Filter_Button.button_pressed = false
			Filter_Button.toggled.connect(_On_Type_Filter_Toggled.bind(Kind, Filter_Button))
			_Type_Filter_Row.add_child(Filter_Button)
			_Filter_Buttons[Kind] = Filter_Button
	if is_instance_valid(_Options_Button):
		_Original_Options_Visible = _Options_Button.visible
		_Options_Button.hide()

	_Replacement_Installed = true
	_Refresh_Symbols()


func _Refresh_Symbols() -> void:
	var Script_Editor := EditorInterface.get_script_editor()
	_Current_Script = Script_Editor.get_current_script() as GDScript
	_Tree.clear()

	if _Current_Script == null:
		_Last_Source = ""
		return

	_Last_Source = _Current_Script.source_code
	var Lines := _Last_Source.split("\n")
	var Root_Name := _Current_Script.resource_path.get_file().get_basename()
	for Line in Lines:
		var Class_Match := _Class_Name_Pattern.search(Line.strip_edges())
		if Class_Match != null:
			Root_Name = Class_Match.get_string(1)
			break

	var Root := _Tree.create_item()
	Root.set_text(0, Root_Name)
	Root.set_metadata(0, {"line": 1, "kind": "根类"})
	Root.set_icon(0, _Symbol_Icons["根类"])
	var Class_Stack: Array[Dictionary] = []
	var Function_Indent := -1

	for Line_Index in range(Lines.size()):
		var Source_Line: String = Lines[Line_Index]
		var Trimmed := Source_Line.strip_edges()
		if Trimmed.is_empty() or Trimmed.begins_with("#"):
			continue

		var Indentation := _Get_Indentation(Source_Line)
		if Function_Indent >= 0:
			if Indentation > Function_Indent:
				continue
			Function_Indent = -1

		while not Class_Stack.is_empty() and Indentation <= Class_Stack.back()["indent"]:
			Class_Stack.pop_back()

		var Clean_Line := _Strip_Annotations(Trimmed)
		var Nested_Class_Match := _Class_Pattern.search(Clean_Line)
		if Nested_Class_Match != null:
			var Class_Parent: TreeItem = Root
			if not Class_Stack.is_empty():
				Class_Parent = Class_Stack.back()["item"]
			var Class_Item := Class_Parent
			if _Is_Type_Visible("类"):
				Class_Item = _Add_Symbol_To_Parent(
					Class_Parent, "类", Nested_Class_Match.get_string(1), Line_Index + 1
				)
			Class_Stack.append({"indent": Indentation, "item": Class_Item})
			continue

		var Parent: TreeItem = Root
		if not Class_Stack.is_empty():
			Parent = Class_Stack.back()["item"]

		var Function_Match := _Function_Pattern.search(Clean_Line)
		if Function_Match != null:
			var Is_Static_Function := not Function_Match.get_string(1).is_empty()
			var Function_Name := Function_Match.get_string(2) + "()"
			if _Is_Type_Visible("函数"):
				_Add_Symbol_To_Parent(
					Parent, "函数", Function_Name, Line_Index + 1, Is_Static_Function
				)
			Function_Indent = Indentation
			continue

		var Member_Match := _Member_Pattern.search(Clean_Line)
		if Member_Match == null:
			continue

		var Is_Static_Member := not Member_Match.get_string(1).is_empty()
		var Kind := Member_Match.get_string(2)
		var Label := "变量"
		match Kind:
			"const":
				Label = "常量"
			"signal":
				Label = "信号"
			"enum":
				Label = "枚举"
		if not _Is_Type_Visible(Label):
			continue
		_Add_Symbol_To_Parent(
			Parent, Label, Member_Match.get_string(3), Line_Index + 1, Is_Static_Member
		)

	Root.set_collapsed(false)
	_Apply_Filters(Root)


func _Add_Symbol_To_Parent(
	Parent: TreeItem, Kind: String, Name: String, Line: int, Is_Static: bool = false
) -> TreeItem:
	var Item := _Tree.create_item(Parent)
	var Display_Kind := "静态" + Kind if Is_Static else Kind
	Item.set_text(0, Name)
	Item.set_metadata(0, {"line": Line, "kind": Kind})
	Item.set_tooltip_text(0, "%s第 %d 行" % ["静态，" if Is_Static else "", Line])
	Item.set_icon(0, _Symbol_Icons[Display_Kind])
	return Item


func _On_Tree_Item_Selected() -> void:
	if _Current_Script == null:
		return
	var Selected := _Tree.get_selected()
	if Selected == null:
		return
	var Metadata: Dictionary = Selected.get_metadata(0)
	var Line: int = Metadata.get("line", 1)
	EditorInterface.edit_script(_Current_Script, Line - 1, 0)


func _On_Search_Changed(_Query: String) -> void:
	_Apply_Filters(_Tree.get_root())


func _On_Type_Filter_Toggled(Is_Hollow: bool, Kind: String, Button: TextureButton) -> void:
	_Visible_Types[Kind] = not Is_Hollow
	Button.tooltip_text = "%s：%s" % [Kind, "隐藏" if Is_Hollow else "显示"]
	_Apply_Filters(_Tree.get_root())


func _Is_Type_Visible(Kind: String) -> bool:
	return _Visible_Types.get(Kind, true)


func _Apply_Filters(Item: TreeItem) -> bool:
	if Item == null:
		return false
	var Metadata: Dictionary = Item.get_metadata(0)
	var Kind: String = Metadata.get("kind", "")
	var Is_Root := Kind == "根类"
	var Name_Matches := (
		_Filter_Edit.text.strip_edges().is_empty()
		or Item.get_text(0).to_lower().contains(_Filter_Edit.text.strip_edges().to_lower())
	)
	var Matches := Is_Root or (_Is_Type_Visible(Kind) and Name_Matches)
	var Child := Item.get_first_child()
	while Child != null:
		if _Apply_Filters(Child):
			Matches = true
		Child = Child.get_next()
	Item.visible = Matches
	if not _Filter_Edit.text.strip_edges().is_empty() and Matches:
		Item.collapsed = false
	return Matches


func _Get_Indentation(Line: String) -> int:
	var Indentation := 0
	for Character in Line:
		if Character == " " or Character == "\t":
			Indentation += 1
		else:
			break
	return Indentation


func _Strip_Annotations(Line: String) -> String:
	var Result := Line
	while not Result.is_empty():
		var Annotation_Match := _Annotation_Pattern.search(Result)
		if Annotation_Match == null:
			break
		Result = Result.substr(Annotation_Match.get_end()).strip_edges()
	return Result


func _Create_Symbol_Icon(Arg_Color: Color, Is_Static: bool) -> Texture2D:
	var Image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var Center := Vector2(7.5, 7.5)
	for Y in range(16):
		for X in range(16):
			var Alpha: float
			if Is_Static:
				var Edge_Distance := mini(mini(X - 2, 13 - X), mini(Y - 2, 13 - Y))
				Alpha = clampf(Edge_Distance + 1.0, 0.0, 1.0)
			else:
				var Distance := Vector2(X, Y).distance_to(Center)
				Alpha = clampf(6.5 - Distance, 0.0, 1.0)
			if Alpha <= 0.0:
				continue
			var Pixel_Color := Arg_Color
			Pixel_Color.a = Alpha
			Image.set_pixel(X, Y, Pixel_Color)
	return ImageTexture.create_from_image(Image)


func _Create_Hollow_Circle_Icon(Arg_Color: Color) -> Texture2D:
	var Image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var Center := Vector2(7.5, 7.5)
	for Y in range(16):
		for X in range(16):
			var Distance := Vector2(X, Y).distance_to(Center)
			var Outer_Alpha := clampf(6.5 - Distance, 0.0, 1.0)
			var Inner_Alpha := clampf(4.5 - Distance, 0.0, 1.0)
			var Alpha := maxf(Outer_Alpha - Inner_Alpha, 0.0)
			if Alpha <= 0.0:
				continue
			var Pixel_Color := Arg_Color
			Pixel_Color.a = Alpha
			Image.set_pixel(X, Y, Pixel_Color)
	return ImageTexture.create_from_image(Image)
