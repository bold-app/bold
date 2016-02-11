###
Bold - more than just blogging.
Copyright (C) 2015-2016 Jens Krämer <jk@jkraemer.net>

This file is part of Bold.

Bold is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

Bold is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with Bold.  If not, see <http://www.gnu.org/licenses/>.
###
$ = jQuery

$.fn.extend
  uploader: (options)->
    settings =
      container: '#uploaded-files'
      debug: true
      initPicker: false
      limitConcurrentUploads: 2
      uploadsPlaceholder: '#uploads-placeholder'
      onlyImages: false
      i18n:
        maxFileSize: 'File is too big'
        minFileSize: 'File is too small'
        acceptFileTypes: 'Filetype not allowed'
        maxNumberOfFiles: 'Max number of files exceeded'
        uploadedBytes: 'Uploaded bytes exceed file size'
        emptyResult: 'Empty file upload result'
        otherFailure: 'Unknown error'


    settings = $.extend settings, options
    settings.haveFileReader = $.type(FileReader) isnt 'undefined'

    log = (msg) ->
      console?.log msg if settings.debug

    adjustProgressBar = (element, percentage) ->
      percent = percentage + '%'
      $(element).css 'width', percent
      $(element).attr 'aria-valuenow', percentage

    uploadsPlaceholder = ->
      $(settings.uploadsPlaceholder)

    isImage = (file)->
      if $.type(file.type) isnt "undefined"
        file.type.match(/^image\/(tiff|png|jpeg)$/)
      else
        file.name.match(/\.(tiff?|png|jpe?g|ico)$/i)

    addForUpdate = (e, data)->
      log 'addForUpdate'
      file = data.files[0]
      data.context = $(settings.update)
      data.context.find('.filemeta').text(file.name)

      if settings.haveFileReader and isImage(file)
        reader = new FileReader()
        reader.onload = (e)->
          data.context.find('img').attr('src', e.target.result)
        reader.readAsDataURL(file)

      data.context.find('div.progress-wrapper').show()
      xhr = data.submit()
      data.context.find('.progress a.cancel').click (e)->
        xhr.abort()
        $('#modal').html('').modal('hide')
        e.preventDefault()
        false


    add = (e, data)->
      if settings.update
        addForUpdate e, data
      else
        uploadsPlaceholder().hide()
        file = data.files[0]

        if settings.haveFileReader and isImage(file)
          data.context = $(settings.container + ' .preview.img.template').first().clone().removeClass('template').appendTo($(settings.container))
          reader = new FileReader()
          reader.onload = (e)->
            data.context.find('img').attr('src', e.target.result)
          reader.readAsDataURL(file)

        else if !settings.onlyImages
          data.context = $(settings.container + ' .preview.txt.template').first().clone().removeClass('template').appendTo($(settings.container))

        if data.context
          xhr = data.submit()
          data.context.find('a.cancel').click (e)->
            xhr.abort()
            data.context.remove()
            if $(settings.container + ' .thumb').size() <= 2
              uploadsPlaceholder().show()

            e.preventDefault()
            false

    doneForUpdate = (e, data)->
      log 'doneForUpdate'
      file = data.result.files[0]
      data.context.find('.progress-wrapper').hide()

    done = (e, data)->
      log 'done'
      if settings.update
        doneForUpdate e, data
      else
        file = data.result.files[0]
        data.context.find('div.progress').remove()
        if settings.initPicker
          data.context.find('a.cancel').remove()
          data.context.data('md', file.markdown)
          data.context.data('asset-id', file.id)
          data.context.on 'click', window.boldEditor.pickImage
        else
          $('#add-more').show()
          data.context.find('a.cancel').click (e)->
            $.ajax type: file.delete_type, url: file.delete_url
            data.context.remove()
            if $(settings.container + ' .thumb').size() <= 2
              uploadsPlaceholder().show()
              $('#add-more').hide()
            e.preventDefault()
            false

    progress = (e, data)->
      progress = parseInt data.loaded / data.total * 100, 10
      adjustProgressBar data.context.find('.progress-bar'), progress

    @each (i, element)->
      form = $(element)
      form.fileupload(
        dataType: 'json'
        limitConcurrentUploads: settings.limitConcurrentUploads
        add: add
        done: done
        progress: progress
      )

