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
  console.log('Read file with encoding: ' + encoding)
  converted = iconv.decode(fs.readFileSync(path), encoding)

  buffer = editor.getBuffer()
  buffer.setText(converted)
  buffer.save()

  buffer.on 'saved', () ->
    saveBufferWithEncoding(path, buffer, encoding)
    buffer.off 'saved'
    handleBuffer(editorView)

  buffer.on 'destroyed', ->
    buffer.off 'saved'
    buffer.off 'destroyed'
    saveBufferWithEncoding(path, buffer, encoding)


saveBufferWithEncoding = (path, buffer, encoding) ->
  buff = iconv.encode(buffer.getText(), encoding)
  fs.writeFileSync(path, buff)
