angular.module('starter.services', [])
.factory 'Chats', ->
  # Might use a resource here that returns a JSON array
  # Some fake testing data
  chats = [
    {
      id: 0
      name: 'Ben Sparrow'
      lastText: 'You on your way?'
      face: 'img/ben.png'
    }
    {
      id: 1
      name: 'Max Lynx'
      lastText: 'Hey, it\'s me'
      face: 'img/max.png'
    }
    {
      id: 2
      name: 'Adam Bradleyson'
      lastText: 'I should buy a boat'
      face: 'img/adam.jpg'
    }
    {
      id: 3
      name: 'Perry Governor'
      lastText: 'Look at my mukluks!'
      face: 'img/perry.png'
    }
    {
      id: 4
      name: 'Mike Harrington'
      lastText: 'This is wicked good ice cream.'
      face: 'img/mike.png'
    }
  ]
  {
    all: ->
      chats
    remove: (chat) ->
      chats.splice chats.indexOf(chat), 1
      return
    get: (chatId) ->
      i = 0
      while i < chats.length
        if chats[i].id == parseInt(chatId)
          return chats[i]
        i++
      null

  }
.factory 'getStaticJson', ($http, $log) ->
  root_dir = "data/"
  (path)  ->
    file_path = root_dir + path
    $http.get(file_path)
      .success(res) ->
        res
      , (err) ->
        $log.debug err
        reject err
        
