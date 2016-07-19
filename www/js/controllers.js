angular.module('starter.controllers', []).controller('HomeCtrl', function($scope, $stateParams, $log, $http, $state, $localStorage, getStaticJson) {
  var getSimpleDate, strToDate;
  $scope.input = {
    yesterday: null,
    newData: null
  };
  if ($stateParams.debug) {
    $log.debug("Current Model: Debug");
    $http.get('data/new_mock.txt').then(function(res) {
      $scope.input.newData = res.data;
      return $scope.conversion();
    });
  }
  getSimpleDate = function(fullDate) {
    var day, month, year;
    if (fullDate == null) {
      fullDate = new Date;
    }
    if (typeof fullDate === 'string') {
      fullDate = new Date(fullDate);
    }
    year = fullDate.getFullYear();
    month = fullDate.getMonth() + 1;
    day = fullDate.getDate();
    return year + "-" + month + "-" + day;
  };
  $scope.input.yesterday = getSimpleDate();
  strToDate = function(str) {
    var output, year;
    output = new Date(str);
    year = (new Date).getFullYear();
    output.setFullYear(year);
    return output;
  };
  $scope.$watch('input.newData', function() {
    if ($scope.input.newData) {
      console.log("start conversion");
      return $scope.conversion();
    }
  });
  $scope.conversion = function() {
    var firstCore, i, item, itemObj, j, k, len, len1, ref, tempData;
    tempData = $scope.input.newData.split('\n');
    $scope.formatData = {
      "date": null,
      "log": []
    };
    itemObj = function(str) {
      var arr, obj;
      arr = str.split('","');
      obj = {
        type: arr[0].replace('"', ''),
        from: strToDate(arr[1]),
        to: strToDate(arr[2]),
        comment: arr[3].replace('"', '')
      };
      $scope.formatData.log.push(obj);
      return $scope.formatData.date = $scope.input.yesterday;
    };
    for (j = 0, len = tempData.length; j < len; j++) {
      i = tempData[j];
      if (i.match(/^"\w+/)) {
        itemObj(i);
      }
    }
    $scope.formatData.log.sort(function(a, b) {
      return a.from - b.from;
    });
    firstCore = false;
    ref = $scope.formatData.log;
    for (k = 0, len1 = ref.length; k < len1; k++) {
      item = ref[k];
      if (item.type === "CoreSleep" && !firstCore) {
        firstCore = true;
        item.from.setHours(24);
        item.from.setMinutes(0);
      } else if (item.type === "CoreSleep" && firstCore) {
        item.to.setHours(0);
        item.to.setMinutes(0);
      }
      item.during = (item.to - item.from) / 1000 / 60;
    }
    $localStorage.formatData = $scope.formatData;
    console.log($localStorage.formatData);
    return $scope.displayData = JSON.stringify($scope.formatData);
  };
}).controller('StatusCtrl', function($scope, $localStorage) {
  $scope.formatData = $localStorage.formatData;
  $scope.breakTime = {
    averageGoal: 5,
    countGoal: 15,
    analyse: function() {
      var count, data, j, len, ref, sum;
      count = 0;
      sum = 0;
      ref = $scope.formatData.log;
      for (j = 0, len = ref.length; j < len; j++) {
        data = ref[j];
        if (!(data.type === "BreakTime" && data.during > 1)) {
          continue;
        }
        count++;
        sum += data.during;
      }
      this.count = count;
      this.average = sum / count;
    }
  };
  $scope.sumLimit = {
    breakfastGoal: 20,
    lunchGoal: 30,
    dinnerGoal: 20,
    cookingGoal: 30,
    goodmorningGoal: 40,
    coresleepGoal: 210,
    napGoal: 50,
    analyse: function() {
      var getSum, j, key, keyName, keys, len;
      getSum = function(type) {
        var data, j, len, ref, sum;
        sum = 0;
        ref = $scope.formatData.log;
        for (j = 0, len = ref.length; j < len; j++) {
          data = ref[j];
          if (data.type.toLowerCase() === type && data.during > 1) {
            sum += data.during;
          }
        }
        return $scope.sumLimit[type] = sum;
      };
      keys = Object.keys(this);
      for (j = 0, len = keys.length; j < len; j++) {
        key = keys[j];
        if (!(key !== "analyse")) {
          continue;
        }
        keyName = key.replace('Goal', '');
        getSum(keyName);
      }
    }
  };
  $scope.multipleSum = {
    pomodoro: ['Upgrde', 'Maintain', 'Daily', 'Weekly', 'RSS', 'DayOne', 'Font-end', 'PathSource', 'Sport', 'healthCare', 'P2P', 'IndexFund', 'Finance'],
    pomodoroTimesGoal: 20,
    pomodoroAveGoal: 30,
    breakPomodoroGoal: 0.5,
    unPassionalWorks: ['PathSourc', 'WorkTalk'],
    passionalWorks: ['Font-end'],
    passionalWorksGoal: 6,
    workSumGoal: 8,
    sleep: ['CoreSleep', 'Nap'],
    sleepGoal: 4.5,
    myTimeGoal: 12,
    myTimePercentGoal: 0.6,
    myTime: ['Upgrde', 'maintain', 'Daily', 'Weekly', '冥想', 'DayOne', 'Font-end', 'Sport', 'healthCare', 'P2P', 'IndexFund', 'Finance', 'Social', 'Family', 'Cat'],
    analyse: function() {
      var getArrSum, getSum, result;
      getSum = function(type) {
        var count, data, j, len, ref, sum;
        count = 0;
        sum = 0;
        ref = $scope.formatData.log;
        for (j = 0, len = ref.length; j < len; j++) {
          data = ref[j];
          if (!(data.type === type && data.during > 1)) {
            continue;
          }
          count++;
          sum += data.during;
        }
        return [count, sum];
      };
      getArrSum = function(arr) {
        var arrCount, arrSum, j, len, res, type;
        arrSum = 0;
        arrCount = 0;
        for (j = 0, len = arr.length; j < len; j++) {
          type = arr[j];
          res = getSum(type);
          arrCount += res[0];
          arrSum += res[1];
        }
        return [arrCount, arrSum];
      };
      result = getArrSum(this.pomodoro);
      this.pomodoroTimes = result[0];
      this.pomodoroSum = result[1];
      this.pomodoroAve = this.pomodoroSum / this.pomodoroTimes;
      this.breakPomodoro = $scope.breakTime.count / this.pomodoroTimes;
      this.passionalSum = getArrSum(this.passionalWorks)[1] / 60;
      this.workSum = getArrSum(this.unPassionalWorks)[1] / 60 + this.passionalSum;
      this.myTimeSum = getArrSum(this.myTime)[1] / 60;
      this.sleepSum = getArrSum(this.sleep)[1] / 60;
      return this.myTimePercent = this.myTimeSum / (24 - this.sleepSum);
    }
  };
  $scope.toPercent = function(num) {
    var output;
    output = (num * 100).toFixed(1);
    output = output + "%";
    return output;
  };
  $scope.tableItems = [];
  $scope.addItem = function() {
    var add;
    add = function(project, index, status, more) {
      var isHighlight;
      if (more) {
        isHighlight = status > index ? true : false;
      } else {
        isHighlight = status < index ? true : false;
      }
      return $scope.tableItems.push({
        project: project,
        index: index,
        status: status,
        highlight: isHighlight
      });
    };
    add('My Time', $scope.multipleSum.myTimeGoal, $scope.multipleSum.myTimeSum.toFixed(1), false);
    add('My Percent', $scope.toPercent($scope.multipleSum.myTimePercentGoal), $scope.toPercent($scope.multipleSum.myTimePercent), false);
    add('Core Sleep', $scope.sumLimit.coresleepGoal / 60, ($scope.sumLimit.coresleep / 60).toFixed(1), true);
    add('Nap', $scope.sumLimit.napGoal, $scope.sumLimit.nap, true);
    add('Pomodoro Times', $scope.multipleSum.pomodoroTimesGoal, $scope.multipleSum.pomodoroTimes, false);
    add('Pomodoro Average', $scope.multipleSum.pomodoroAveGoal, $scope.multipleSum.pomodoroAve.toFixed(1), true);
    add('Break times', $scope.breakTime.countGoal, $scope.breakTime.count, false);
    add('Average break', $scope.breakTime.averageGoal, $scope.breakTime.average, true);
    add('BreakTime / Pomodoro', $scope.toPercent($scope.multipleSum.breakPomodoroGoal), $scope.toPercent($scope.multipleSum.breakPomodoro), false);
    add('Passional Work', $scope.multipleSum.passionalWorksGoal, $scope.multipleSum.passionalSum.toFixed(1), false);
    add('Work Sum', $scope.multipleSum.workSumGoal, $scope.multipleSum.workSum.toFixed(1), true);
    add('Lunch', $scope.sumLimit.lunchGoal, $scope.sumLimit.lunch, true);
    add('Dinner', $scope.sumLimit.dinnerGoal, $scope.sumLimit.dinner, true);
    add('Cooking', $scope.sumLimit.cookingGoal, $scope.sumLimit.cooking, true);
    return add('GoodMorning', $scope.sumLimit.goodmorningGoal, $scope.sumLimit.goodmorning, true);
  };
  $scope.analyse = function() {
    console.log($localStorage.formatData);
    console.log("start analyse");
    $scope.breakTime.analyse();
    $scope.sumLimit.analyse();
    $scope.multipleSum.analyse();
    return $scope.addItem();
  };
  $scope.analyse();
}).controller('SettingCtrl', function($scope) {
  $scope.settings = {
    enableFriends: true
  };
});
