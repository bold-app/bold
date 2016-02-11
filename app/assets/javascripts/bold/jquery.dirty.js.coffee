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

# form dirty checker, loosely based on
# Dirrty (https://github.com/rubentd/dirrty) by Rubén Torres
$.fn.extend
  dirty: (options)->

    settings =
      preventLeaving: true
      leavingMessage: 'You have unsaved changes'
      debug: false

    settings = $.extend settings, options


    log = (msg) ->
      console?.log msg if settings.debug


    init = ($form) ->
      $form.data('dirty-history', ['clean', 'clean'])
      $form.data('dirty-is-dirty', false)
      saveInitialValues $form
      setEvents $form


    saveInitialValues = ($form) ->
      $form.find('input, select, textarea').each ->
        $input = $(this)
        unless ignoreField($input)
          $input.data 'dirty-initial-value', $input.val()
          $input.data 'dirty-is-dirty', false
      $form.find('input[type=checkbox], input[type=radio]').each ->
        $(this).data($(this).is(':checked') ? 'checked' : 'unchecked')


    # true for fields we want to ignore
    ignoreField = ($input) ->
      $input.attr('name') == 'authenticity_token'


    # true if the form is dirty
    isDirty = ($form) ->
      $form.data('dirty-is-dirty') == true


    setEvents = ($form) ->
      if settings.preventLeaving
        $form.on 'submit', ->
          $form.data 'dirty-submitting', true
        $(window).on 'beforeunload', ->
          if isDirty($form) && !$form.data('dirty-submitting')
            return settings.leavingMessage
      $form.find('input, select').change ->
        checkValues $form
      $form.find("input, textarea").on 'keyup keydown blur', ->
        checkValues $form


    checkValues = ($form) ->
      $form.find("input, select, textarea").each ->
        $input = $(this)
        unless ignoreField($input)
          $input.data 'dirty-is-dirty', ($input.val() != $input.data('dirty-initial-value'))
      $form.find('input[type=checkbox], input[type=radio]').each ->
        $input = $(this)
        initialValue = $input.attr 'dirty-initial-value'
        $input.data 'dirty-is-dirty', (($input.is(':checked') && initialValue != 'checked') || (!$input.is(':checked') && initialValue == 'checked'))

      dirty = false
      $form.find("input, select, textarea").each ->
        if $(this).data('dirty-is-dirty')
          dirty = true

      if dirty
        setDirty $form
      else
        setClean $form

      fireEvents $form


    history = ($form) ->
      $form.data 'dirty-history'


    pushHistory = ($form, status) ->
      h = history $form
      h[0] = h[1]
      h[1] = status


    setDirty = ($form) ->
      $form.data 'dirty-is-dirty', true
      pushHistory $form, 'dirty'


    setClean = ($form) ->
      $form.data 'dirty-is-dirty', false
      pushHistory $form, 'clean'


    fireEvents = ($form) ->
      if isDirty($form) && wasJustClean($form)
        $form.trigger 'dirty'
      if !isDirty($form) && wasJustDirty($form)
        $form.trigger 'clean'


    wasJustClean = ($form) ->
      history($form)[0] == 'clean'


    wasJustDirty = ($form) ->
      history($form)[0] == 'dirty'


    @each (i, form)->
      init $(form)


