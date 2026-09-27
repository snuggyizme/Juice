class_name Main extends Control

var docs: Array[Document]
var docIndex: int

@onready var fileDialog: FileDialog = $FileDialog

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save()
	elif event.is_action_pressed("open"):
		open()

func _onFilesSelected(pathsPacked: PackedStringArray) -> void:
	var paths: Array[String] = pathsPacked
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
	
func save() -> void:
	var doc: Document = docs[docIndex]
	var file := FileAccess.open(doc.path, FileAccess.WRITE)
	if file:
		file.store_string(doc.text)

func open() -> void:
	fileDialog.popup_centered()

func addDocumentTab(doc: Document) -> void:
	pass
