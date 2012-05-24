// Generated by CoffeeScript 1.3.3
(function() {
  var HOST, INTERVAL, checkNewBlogs, entryList, getLastVisitedEpoch, setLastVisitedEpoch, updateBadge, updateEntryList;

  INTERVAL = 1000 * 600;

  HOST = 'http://tanpaku.grouptube.jp/';

  entryList = [];

  getLastVisitedEpoch = function() {
    return +localStorage['lastVisited'] || 0;
  };

  setLastVisitedEpoch = function(epoch) {
    return localStorage['lastVisited'] = epoch;
  };

  updateEntryList = function(callback) {
    return $.ajax({
      url: HOST,
      dataType: 'html',
      success: function(res) {
        var keyTime;
        if (entryList.length > 0) {
          keyTime = entryList[entryList.length - 1].time;
        } else {
          keyTime = getLastVisitedEpoch();
        }
        $($(res).find('ul.information li.info_notice').get().reverse()).each(function() {
          var entry, entry_title, entry_titles, flgDup, group_name, user_name;
          entry_titles = $(this).contents().filter(function() {
            return this.textContent.match(/\S/);
          });
          user_name = $(this).find('a + a').attr('href').replace(/^(?:event|diary|file)\/user\/(.+?)\/.*/, "$1");
          group_name = $(this).find('a + a').attr('href').replace(/.*group\/(\d+)\/.+$/, "$1");
          if (entry_titles.length > 0) {
            entry_title = entry_titles[0].textContent;
          } else {
            entry_title = '■';
          }
          entry = {
            blog_title: $(this).find('a + a').text(),
            entry_title: entry_title,
            entry_url: HOST + $(this).find('a + a').attr('href'),
            user_name: user_name,
            user_image: "" + HOST + "images/users/" + user_name + "/icon/s.jpg",
            group_name: group_name,
            group_image: "" + HOST + "images/groups/" + group_name + "/s.jpg"
          };
          flgDup = false;
          $(entryList).each(function() {
            if (this.entry_url === entry.entry_url) {
              return flgDup = true;
            }
          });
          if (!flgDup) {
            return entryList.push(entry);
          }
        });
        if (callback) {
          return callback();
        }
      }
    });
  };

  chrome.browserAction.setBadgeBackgroundColor({
    color: [56, 136, 218, 255]
  });

  updateBadge = function() {
    var label;
    label = entryList.length > 0 ? String(entryList.length) : "";
    return chrome.browserAction.setBadgeText({
      text: label
    });
  };

  checkNewBlogs = function() {
    return updateEntryList(function() {
      return updateBadge();
    });
  };

  setInterval(function() {
    return checkNewBlogs();
  }, INTERVAL);

  checkNewBlogs();

  chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
    var entry, len;
    if (request.method !== "getNextEntry") {
      return;
    }
    if (entryList.length > 0) {
      entry = entryList.shift();
      len = entryList.length;
      setLastVisitedEpoch(entry.time);
      updateBadge();
      return sendResponse({
        entry: entry,
        unread_count: len
      });
    } else {
      return sendResponse({
        entry: null,
        unread_count: 0
      });
    }
  });

}).call(this);
