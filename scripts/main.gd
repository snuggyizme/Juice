class_name Main extends Control

const FALLBACK_SPRITE: Texture2D = preload("res://sprites/icons/fallback.png")

@export var icons: Dictionary[String, Texture2D]
@export_category("Internal Refs")
@export var tabBar: TabBar
@export var codeEdit: CodeEdit

var docs: Array[Document]
var docIndex: int:
	set(x):
		docIndex = x
		swapTab(docs[x])

@onready var fileDialog: FileDialog = $FileDialog

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save()
	elif event.is_action_pressed("open"):
		open()
	elif event.is_action_pressed("zoomIn"):
		zoom(1)
	elif event.is_action_pressed("zoomOut"):
		zoom(-1)

func _onFilesSelected(paths: PackedStringArray) -> void:
	var newDocs: Array[Document] = []
	for i: String in paths:
		var document := Document.new()
		document.name = i.get_file()
		document.text = FileAccess.get_file_as_string(i)
		document.path = i
		newDocs.append(document)
	
	for i: Document in newDocs:
		if i in docs:
			continue
		
		docs.append(i)
		addDocumentTab(i)

func _onTabBarTabChanged(tab: int) -> void:
	docIndex = tab
	swapTab(docs[docIndex])

func _onTabBarTabClosed(tab: int) -> void:
	tabBar.remove_tab(tab) # I think this moves the current index or smth
	docIndex = tabBar.current_tab # So now we are moved over

	if docs[docIndex].isDirty:
		return # TODO # Actual implementation
	
	docs.remove_at(tab)
	
	if docs.size() < 1:
		codeEdit.editable = false

func _onCodeEditTextChanged() -> void:
	docs[docIndex].text = codeEdit.text

func save() -> void:
	var doc: Document = docs[docIndex]
	var file := FileAccess.open(doc.path, FileAccess.WRITE)
	if file:
		file.store_string(doc.text)

func open() -> void:
	fileDialog.popup_centered()

func addDocumentTab(doc: Document) -> void:
	codeEdit.visible = true
	
	tabBar.add_tab(doc.name, icons.get(doc.name.get_extension(), FALLBACK_SPRITE))
	var i: int = tabBar.get_tab_count() - 1
	tabBar.set_tab_icon_max_width(i, 16)
	tabBar.current_tab = i
	docs[i] = doc
	docIndex = i

func swapTab(doc: Document) -> void:
	codeEdit.text = doc.text

func zoom(x: int) -> void:
	var currentFontSize: int = codeEdit.get_theme_font_size("font_size")
	codeEdit.add_theme_font_size_override("font_size", currentFontSize + x)
	
