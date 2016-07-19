angular.module('starter', ['ionic', 'starter.controllers', 'starter.services', 'ngStorage']).run(function($ionicPlatform) {
  $ionicPlatform.ready(function() {
    if (window.cordova && window.cordova.plugins && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      cordova.plugins.Keyboard.disableScroll(true);
    }
    if (window.StatusBar) {
      StatusBar.styleDefault();
    }
  });
}).config(function($stateProvider, $urlRouterProvider) {
  $stateProvider.state('tab', {
    url: '/tab',
    abstract: true,
    templateUrl: 'templates/tabs.html'
  }).state('tab.home', {
    url: '/home?debug',
    views: {
      'tab-home': {
        templateUrl: 'templates/tab-home.html',
        controller: 'HomeCtrl'
      }
    }
  }).state('tab.status', {
    url: '/status?debug',
    views: {
      'tab-home': {
        templateUrl: 'templates/tab-status.html',
        controller: 'StatusCtrl'
      }
    }
  }).state('tab.setting', {
    url: '/setting',
    views: {
      'tab-setting': {
        templateUrl: 'templates/tab-setting.html',
        controller: 'SettingCtrl'
      }
    }
  });
  $urlRouterProvider.otherwise('/tab/home');
});
