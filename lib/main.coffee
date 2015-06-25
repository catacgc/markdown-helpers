# AutoMdLinksView = require './markdown-helpers-view'
request = require('request')

module.exports =
  activate: (state) ->
    atom.commands.add "atom-text-editor",
      "markdown-helpers:convert-link": => @convert(new GoogleWebConvertor())
    atom.commands.add "atom-text-editor",
      "markdown-helpers:convert-image": => @convert(new GoogleImageConvertor())

  convert: (convertor) ->
    editor = atom.workspace.getActivePaneItem()
    selection = editor.getLastSelection()
    text = selection.getText()

    return unless text

    callback = (text) => @updateSelection(text)

    convertor.convert(text, callback)

  updateSelection: (text) ->
    editor = atom.workspace.getActivePaneItem()
    selection = editor.getLastSelection()
    selection.insertText(text)


class GoogleWebConvertor
    url: 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q='

    format: (text, link) -> "[#{text}](#{link})"

    convert: (text, callback) ->
        handler = (error, response, body) =>
            @handleResponse(text, body, callback)

        request.get({url: @url + text, json:true}, handler)

    handleResponse: (text, json, callback) ->
      result_title = json.responseData.results[0].titleNoFormatting
      link = json.responseData.results[0].unescapedUrl

      callback(@format(text, link))

  class GoogleImageConvertor extends GoogleWebConvertor
      url: 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q='

      format: (text, link) ->  "![#{text}](#{link})"
