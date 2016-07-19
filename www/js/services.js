angular.module('starter.services', []).factory('Chats', function() {
  var chats;
  chats = [
    {
      id: 0,
      name: 'Ben Sparrow',
      lastText: 'You on your way?',
      face: 'img/ben.png'
    }, {
      id: 1,
      name: 'Max Lynx',
      lastText: 'Hey, it\'s me',
      face: 'img/max.png'
    }, {
      id: 2,
      name: 'Adam Bradleyson',
      lastText: 'I should buy a boat',
      face: 'img/adam.jpg'
    }, {
      id: 3,
      name: 'Perry Governor',
      lastText: 'Look at my mukluks!',
      face: 'img/perry.png'
    }, {
      id: 4,
      name: 'Mike Harrington',
      lastText: 'This is wicked good ice cream.',
      face: 'img/mike.png'
    }
  ];
  return {
    all: function() {
      return chats;
    },
    remove: function(chat) {
      chats.splice(chats.indexOf(chat), 1);
    },
    get: function(chatId) {
      var i;
      i = 0;
      while (i < chats.length) {
        if (chats[i].id === parseInt(chatId)) {
          return chats[i];
        }
        i++;
      }
      return null;
    }
  };
}).factory('getStaticJson', function($http, $log) {
  var root_dir;
  root_dir = "data/";
  return function(path) {
    var file_path;
    file_path = root_dir + path;
    return $http.get(file_path).success(res)(function() {
      return res;
    }, function(err) {
      $log.debug(err);
      return reject(err);
    });
  };
});
