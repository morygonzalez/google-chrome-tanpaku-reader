HOST = 'http://tanpaku.grouptube.jp/'

entryList = []

getAntenna = (callback) ->
  $.ajax
    url: HOST
    dataType: 'html'
    success: (res) ->
      $('#indicator').hide()
      items = []
      $(res).find('ul.information li').each ->
        entry_titles = $(this).contents().filter(-> this.textContent.match(/\S/))
        user_name = $(this).find('a + a').attr('href').replace(/^(event|diary|file)\/user\/(.+?)\/.*/, "$2")
        if entry_titles.length > 0
          entry_title = entry_titles[0].textContent
        else
          entry_title = '■'
        items.push
          blog_title: $(this).find('a + a').text()
          entry_title: entry_title
          entry_url: HOST + $(this).find('a + a').attr('href')
          user_name: user_name
          user_image: "#{HOST}images/users/#{user_name}/icon/s.jpg"
      callback items.reverse()

getUnreadCount = ->
  entryList.length

openEntry = (entry) ->
  chrome.tabs.getSelected null, (tab) ->
    return if tab.url == entry.entry_url
    chrome.tabs.update tab.id, {url: entry.entry_url}

showEntry = (entry, unread_count) ->
  openEntry(entry)
  $('#title').text entry.entry_title
  $('#user_icon').empty().append $('<img>').attr(src: entry.user_image, title: entry.user_name)
  $('#user_name').empty().append $('<a>').attr(href: "#{HOST}user/#{entry.user_name}").text(entry.user_name)
  $('#unread_count').text(unread_count)

hideButton = ->
  $('#next-button').hide()

showEmptyMessage = ->
  $('.small-info').hide()
  $('#title').text('未読記事はありません')

showNextEntry = ->
  chrome.extension.sendRequest {method: "getNextEntry"}, (res) ->
    if res.entry
      showEntry(res.entry, res.unread_count)

    if res.unread_count == 0
      hideButton()

    if ! res.entry
      showEmptyMessage()

$ ->
  showNextEntry()

  $('#next-button').click ->
    showNextEntry()
    false

  $('#user_name a').live 'click', ->
    chrome.tabs.create
      url: $(this).attr('href')
    window.close()

  $('#next-button').focus()
