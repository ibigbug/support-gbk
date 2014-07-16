chardet = require 'chardet'
iconv = require 'iconv-lite'
fs = require 'fs'


module.exports =
  activate: ->
    @convert()

  convert: ->
    atom.workspaceView.eachEditorView (editorView) ->
      handleBuffer(editorView)


handleBuffer = (editorView) ->
  editor = editorView.getEditor()
  path = editor.getPath()
  return if not path

  encoding = chardet.detectFileSync(path)
  buffer = editor.getBuffer()

  refreshEditor(editor)

  buffer.on 'reloaded', ()->
    refreshEditor(editor)

  buffer.on 'saved', ()->
    saveEditor(editor, encoding)

  buffer.on 'destroyed', ()->
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

  buffer.on 'contents-conflicted', ()->
    return true
  buffer.setText(converted)
  buffer.off 'contents-conflicted'
