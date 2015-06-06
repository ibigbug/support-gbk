chardet = require 'chardet'
iconv = require 'iconv-lite'
fs = require 'fs'


module.exports =
  activate: ->
    @convert()

  convert: ->
    editorViews = atom.workspace.getTextEditors
    handleBuffer for editorView in editorViews


handleBuffer = (editorView) ->
  editor = editorView.getEditor()
  path = editor.getPath()
  return if not path

  encoding = chardet.detectFileSync(path)
  buffer = editor.getBuffer()

  refreshEditor(editor)

  buffer.onDidReload ()->
    refreshEditor(editor)

  buffer.onDidSave ()->
    saveEditor(editor, encoding)


  buffer.onDidDestroy ()->
    buffer.off 'reloaded'
    buffer.off 'saved'
    buffer.off 'destroyed'
    saveEditor(editor, encoding)


saveEditor = (editor, encoding)->
  path = editor.getPath()
  return if not path
  buff = iconv.encode(editor.getText(), encoding)
  console.log('Saving file with encoding: ' + encoding)
  fs.writeFileSync(path, buff)


refreshEditor = (editor) ->
  buffer = editor.getBuffer()
  path = editor.getPath()
  return if not path

  encoding = chardet.detectFileSync(path)
  console.log('Loading file with encoding: ' + encoding)
  converted = iconv.decode(fs.readFileSync(path), encoding)

  buffer.onDidConflict ()->
    return true
  buffer.setText(converted)
