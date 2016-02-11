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
$ ->

  window.boldEditor = {

    toggleZenMode: ->
      $('body').toggleClass 'zenmode'

    initAce: (el)->

      $ta = $(el)
      $form = $ta.closest('form')
      $ta.hide()
      window.boldEditor.editor = editor = ace.edit $ta.data 'container'
      editor.$blockScrolling = Infinity
      editor.session.setValue $ta.val()

      editor.on 'focus', ->
        $('#title-caps').attr('rel', 'editor')

      $('#title-field').on 'focus', ->
        $('#title-caps').attr('rel', 'title-field')

      $('#title-caps').on 'click', ->
        if $(this).attr('rel') == 'editor'
          # work on body text
          range = editor.getSelectionRange()
          if range.isEmpty()
            text = editor.session.getLine range.start.row
            range.start.column = 0
            range.end.column = Number.MAX_VALUE
            if match = text.match /^(#+\s+)(.+)$/
              range.start.column = match[1].length
              text = match[2]
          else
            text = editor.session.getTextRange range

          editor.session.replace range, titleCaps(text)
        else
          # work on title
          $field = $('#'+$(this).attr('rel'))
          $field.val titleCaps($field.val())

        editor.focus()
        false

      $('#zen-mode').on 'click', ->
        window.boldEditor.toggleZenMode()
        false

      # :w in vi mode
      editor.commands.addCommand
        name: 'Save',
        bindKey: {win: 'Ctrl-S',  mac: 'Command-S'},
        readOnly: false,
        exec: (editor)->
          $form.submit()

      # :wp in vi mode
      editor.commands.addCommand
        name: 'SaveAndPublish',
        bindKey: {win: 'Ctrl-Shift-S',  mac: 'Command-Shift-S'},
        readOnly: false,
        exec: (editor)->
          $('#do_publish').val('1')
          $form.submit()

      # :wpq in vi mode
      editor.commands.addCommand
        name: 'SaveAndPublishAndQuit',
        readOnly: false,
        exec: (editor)->
          $('#do_publish').val '1'
          $('#go_back').val '1'
          $form.submit()

      # :wq
      editor.commands.addCommand
        name: 'SaveAndQuit',
        readOnly: false,
        exec: (editor)->
          $('#go_back').val '1'
          $form.submit()

      # remove trailing white space from pasted text
      editor.on 'paste', (object)->
        object.text = object.text.replace /[ \t]+$/gm, ''

      # copy text to our form field whenever it changes
      editor.session.on 'change', ->
        $ta.val editor.session.getValue()

      # nobody should override Ctrl-t in a browser
      editor.commands.bindKeys 'ctrl-t':null
      editor.commands.bindKeys 'cmd-t':null

      if $ta.data('vimmode') == true
        # in vim mode we can go to line by :line<enter>, so free up Ctrl-l
        editor.commands.bindKeys 'ctrl-l':null
        editor.commands.bindKeys 'cmd-l':null
        editor.setKeyboardHandler 'ace/keyboard/vim'

      editor.setBehavioursEnabled false
      editor.setShowPrintMargin false

      editor.session.setMode 'ace/mode/markdown'
      editor.session.setUseWrapMode true
      editor.session.setTabSize 2
      editor.session.setUseSoftTabs true
      if $('input.title').val().length == 0
        $('input.title').focus()
      else
        editor.focus()

    # dirty tracking
    initDirty: (form)->
      form
        .dirty
          preventLeaving: true
        .on 'dirty', ()->
          $('#change-template').attr('disabled', true)
          $('button[name=save]').attr('disabled', false)
          $('button[name=publish]').attr('disabled', false)
        .on 'clean', ()->
          $('#change-template').attr('disabled', false)
          $('button[name=save]').attr('disabled', true)
          $('button.has-no-draft[name=publish]').attr('disabled', true)


    pickImage: (e)->
      if $('#imagepicker').data('rel') == 'editor'
        # insert markdown into editor
        markdown = $(this).data('md')
        size = $('#image-version :selected').val()
        markdown = markdown.replace 'IMAGE_VERSION', size

        markdown = if link_to = $('#image-link input[type=hidden]').val()
          markdown.replace 'LINK_TO', link_to
        else
          markdown.replace /!?!LINK_TO/, ''

        window.boldEditor.saveImageOptions size, link_to
        window.boldEditor.editor.insert markdown
        window.boldEditor.editor.focus()
      else
        # template image field
        id = $('#imagepicker').data('rel')
        $field = $('#'+id)
        $field.val $(this).data('asset-id')
        $('#'+id+'_preview').empty().append($(this).find('img'))
        $field.parent().find('a.clear').show()
        $field.trigger('change') # nudge dirty plugin

      $('#modal').html('').modal('hide')
      e.preventDefault()
      false

    initImagepicker: ->
      $('#imagepicker .thumb').on 'click', window.boldEditor.pickImage


    saveImageOptions: (size, link_to)->
      window.boldEditor.imageLinkOptions = {
        image_version: size
        image_link: link_to
      }


    restoreImageOptions: ->
      if opts = window.boldEditor.imageLinkOptions
        $('#image-version select').val opts.image_version
        $('#image-link select').val opts.image_link

  }

  $('textarea.ace').each ->
    window.boldEditor.initAce this

  # remove selected image for template field
  $(document).on 'click', 'a.clear', (e)->
    id = $(this).attr('rel')
    $('#'+id).val('').trigger('change') # nudge dirty plugin
    $('#'+id+'_preview').empty()
    $(this).hide()
    e.preventDefault()
    false

  # init dirty checking
  $('#bold-editor-form').each (idx, form)->
    window.boldEditor.initDirty $(form)

  # check dirty state before template change
  $(document).on 'click', '#change-template', (e)->
    if $form.data('dirty-is-dirty') == true
      alert $(this).data('ondirty')
      false
    else
      true


