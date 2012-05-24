INTERVAL = 1000 * 600
HOST = 'http://tanpaku.grouptube.jp/'

entryList = []

getLastVisitedEpoch = ->
  + localStorage['lastVisited'] || 0

setLastVisitedEpoch = (epoch) ->
  localStorage['lastVisited'] = epoch

updateEntryList = (callback) ->
  $.ajax
    url: HOST
    dataType: 'html'
    success: (res) ->

      if entryList.length > 0
        keyTime = entryList[entryList.length - 1].time
      else
        keyTime = getLastVisitedEpoch()

      # $.each と Array.reverse を組み合わせたので ごちゃっとしてる 旧→新 の順で見るため
      $($(res).find('ul.information li.info_notice').get().reverse()).each ->
        entry_titles = $(this).contents().filter(-> this.textContent.match(/\S/))
        user_name = $(this).find('a + a').attr('href')
          .replace(/^(?:event|diary|file)\/user\/(.+?)\/.*/, "$1")
        group_name = $(this).find('a + a').attr('href')
          .replace(/.*group\/(\d+)\/.+$/, "$1")
        if entry_titles.length > 0
          entry_title = entry_titles[0].textContent
        else
          entry_title = '■'
        entry =
          blog_title: $(this).find('a + a').text()
          entry_title: entry_title
          entry_url: HOST + $(this).find('a + a').attr('href')
          user_name: user_name
          user_image: "#{HOST}images/users/#{user_name}/icon/s.jpg"
          group_name: group_name
          group_image: "#{HOST}images/groups/#{group_name}/s.jpg"

        flgDup = false

        $(entryList).each ->
          if @.entry_url == entry.entry_url
            flgDup = true

        unless flgDup
          entryList.push entry

      callback() if callback

chrome.browserAction.setBadgeBackgroundColor({color: [56,136, 218, 255]})

updateBadge = ->
  label = if entryList.length > 0 then String(entryList.length) else ""
  chrome.browserAction.setBadgeText
    text: label

checkNewBlogs = ->
  updateEntryList ->
    updateBadge()

setInterval ->
  checkNewBlogs()
, INTERVAL

checkNewBlogs()


chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  return if request.method != "getNextEntry"

  if entryList.length > 0
    entry = entryList.shift()
    len = entryList.length
    setLastVisitedEpoch(entry.time)
    # setLastVisitedEpoch(entry.time)
    updateBadge()
    sendResponse
      entry: entry
      unread_count: len

  else
    sendResponse
      entry: null
      unread_count: 0
