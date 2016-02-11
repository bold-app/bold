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
window.bold = {

  delay: (ms, func)-> setTimeout func, ms

  # do the undo post request and execute the returned JS
  undo: (link)->
    url = $(link).attr('rel')
    $.ajax url, type: 'POST', dataType: 'script'

  initDirtyForNavigation: ($form) ->
    $form
      .dirty preventLeaving: false
      .on 'dirty', -> $(this).find('button').show()
      .on 'clean', -> $(this).find('button').hide()

  initDirtyForNavigations: ->
    $('.navigations-list form').each ->
      window.bold.initDirtyForNavigation $(this)

  initNavigationSorting: ->
    url = $('.navigations-list').data 'url'
    $('.navigations-list').sortable 'destroy'
    $('.navigations-list').sortable().bind 'sortupdate', (e, ui) ->
      console?.log 'sort update: '+ui.item.data('id')+', '+ui.index
      $.ajax
        url: url
        type: 'PUT'
        data: { id: ui.item.data('id'), new_position: ui.index }

}


$ ->

  toastr.options.positionClass = 'toast-bottom-center'
  toastr.options.preventDuplicates = true

  $('#content_meta_description').charCount allowed: 160, counterId: '#meta_description_wrapper .help-block', counterText: $('#meta_description_wrapper .help-block').text()

  $('.combobox').combobox()
  $('input.content-slug').slugify('input.title')


  $(document).on 'click', '.disabled.content-slug', (e)->
    $(this).find('input').attr('disabled', false).focus()

  # add selected assets to content
  $(document).on 'click', '#insert-btn', ()->
    asset_ids = []
    $('.thumb.selected').each (i, thumb)->
      asset_ids.push $(thumb).data('id')
    old_asset_ids = $('#asset-ids').val()
    $('#asset-ids').val(old_asset_ids + ',' + asset_ids.join())
    true

  # media thumbnail list - select elements
  $(document).on 'click', '.thumb[data-id]', (e) ->
    $(this).toggleClass 'selected'
    selected = $('.thumb.selected').size()
    if selected > 0
      $('#delete-btn').removeClass('btn-default').addClass('btn-danger')
      $('#insert-btn').removeClass('btn-default').addClass('btn-primary')
      $('#select-count').show().find('span').text(selected)
    else
      $('#delete-btn').removeClass('btn-danger').addClass('btn-default')
      $('#insert-btn').removeClass('btn-primary').addClass('btn-default')
      $('#select-count').hide()

    if selected == 1
      $.ajax $('.thumb.selected a').attr('href'), method: 'GET', dataType: 'script'
    else
      # TODO bulk edit? tags...
      $('#edit-asset').html('')

    e.preventDefault()
    false


  # bulk-delete selected assets
  $(document).on 'click', 'a#delete-btn', (e) ->
    ids = ''
    for item in $('.thumb.selected')
      ids += $(item).data('id') + ','
    $.ajax $(this).attr('href'),
      data: { ids: ids.toString() }
      dataType: 'script'
      type: 'DELETE'
    e.preventDefault()
    false


  # select thing from list-group for preview / show
  $(document).on 'click', 'a.list-group-item', (e) ->
    unless $(this).parent('.list-group').hasClass('multiple')
      $(this).siblings('.list-group-item').removeClass 'active'
    $(this).addClass 'active'

  # back to list view (mobile only)
  $(document).on 'click', 'a.back-to-list-group', (e) ->
    $('.right-col').addClass 'hidden-xs'
    $('.left-col').removeClass 'hidden-xs'
    false

  # submit activity form
  $('select.auto-submit').on 'change', (e)->
    $(this).parent('form').submit()

  window.bold.initNavigationSorting()

