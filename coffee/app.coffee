# Ionic Starter App
# angular.module is a global place for creating,
# registering and retrieving Angular modules
# 'starter' is the name of this angular module example
# (also set in a <body> attribute in index.html)
# the 2nd parameter is an array of 'requires'
# 'starter.services' is found in services.js
# 'starter.controllers' is found in controllers.js
angular.module('starter', [
  'ionic'
  'starter.controllers'
  'starter.services'
  'ngStorage'
]).run(($ionicPlatform) ->
  $ionicPlatform.ready ->
    # Hide the accessory bar by default
    # (remove this to show the accessory bar above the keyboard
    # for form inputs)
    if window.cordova and window.cordova.plugins and
    window.cordova.plugins.Keyboard
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar true
      cordova.plugins.Keyboard.disableScroll true
    if window.StatusBar
      # org.apache.cordova.statusbar required
      StatusBar.styleDefault()
    return
  return
).config ($stateProvider, $urlRouterProvider) ->
  # Ionic uses AngularUI Router which uses the concept of states
  # Learn more here: https://github.com/angular-ui/ui-router
  # Set up the various states which the app can be in.
  # Each state's controller can be found in controllers.js
  $stateProvider
    .state 'tab',
      url: '/tab'
      abstract: true
      templateUrl: 'templates/tabs.html'
    .state 'tab.home',
      url: '/home?debug'
      views: 'tab-home':
        templateUrl: 'templates/tab-home.html'
        controller: 'HomeCtrl'
    .state 'tab.status',
      url: '/status?debug'
      views: 'tab-home':
        templateUrl: 'templates/tab-status.html'
        controller: 'StatusCtrl'
    .state 'tab.setting',
      url: '/setting'
      views: 'tab-setting':
        templateUrl: 'templates/tab-setting.html'
        controller: 'SettingCtrl'
  # if none of the above states are matched, use this as the fallback
  $urlRouterProvider.otherwise '/tab/home'
  return
