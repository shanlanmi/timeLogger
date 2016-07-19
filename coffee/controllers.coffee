angular.module('starter.controllers', []
).controller('HomeCtrl', ($scope, $stateParams, $log , $http, $state
$localStorage, getStaticJson) ->

  $scope.input = {
    yesterday: null
    newData: null
  }

  if $stateParams.debug
    $log.debug "Current Model: Debug"
    $http.get('data/new_mock.txt').then (res)  ->
      $scope.input.newData = res.data
      $scope.conversion()

  # return "2016-12-12"
  getSimpleDate = (fullDate = new Date)->
    if typeof fullDate == 'string'
      fullDate = new Date fullDate
    year = fullDate.getFullYear()
    month = fullDate.getMonth() + 1
    day = fullDate.getDate()
    "#{year}-#{month}-#{day}"

  $scope.input.yesterday = getSimpleDate()

  strToDate = (str) ->
    output = new Date str
    year = (new Date).getFullYear()
    output.setFullYear(year)
    output

  # when input
  $scope.$watch('input.newData', ->
    if $scope.input.newData
      console.log "start conversion"
      $scope.conversion()
  )

  $scope.conversion = ->
    tempData = $scope.input.newData.split('\n')
    $scope.formatData = {
      "date": null
      "log": []
    }
    itemObj = (str) ->
      arr = str.split('","')
      obj = {
        type: arr[0].replace '"',''
        from: strToDate arr[1]
        to: strToDate arr[2]
        comment: arr[3].replace '"',''}
      $scope.formatData.log.push obj
      $scope.formatData.date = $scope.input.yesterday
    itemObj i for i in tempData when i.match(/^"\w+/)
    $scope.formatData.log.sort (a, b) ->
      a.from - b.from
    # ==========> set 24:00 <==========
    firstCore = false
    for item in $scope.formatData.log
      if item.type is "CoreSleep" and !firstCore
        firstCore = true
        item.from.setHours 24
        item.from.setMinutes 0
      else if item.type is "CoreSleep" and firstCore
        item.to.setHours 0
        item.to.setMinutes 0
      item.during = (item.to - item.from) / 1000 / 60
    $localStorage.formatData = $scope.formatData
    console.log $localStorage.formatData
    $scope.displayData = JSON.stringify $scope.formatData

  return

).controller('StatusCtrl',($scope, $localStorage) ->
  $scope.formatData = $localStorage.formatData


  $scope.breakTime =
    averageGoal: 5
    countGoal: 15
    analyse: ->
      count = 0
      sum = 0
      for data in $scope.formatData.log when data.type == "BreakTime" &&
      data.during > 1
        count++
        sum += data.during
      @count = count
      @average = sum / count
      return

  $scope.sumLimit =
    breakfastGoal: 20
    lunchGoal: 30
    dinnerGoal: 20
    cookingGoal: 30
    goodmorningGoal: 40
    coresleepGoal: 210
    napGoal: 50
    analyse: ->
      getSum = (type) ->
        sum = 0
        for data in $scope.formatData.log when data.type.toLowerCase()==type &&
        data.during > 1
          sum += data.during
        $scope.sumLimit[type] = sum
      # ==========> get object key and getSum <==========
      keys = Object.keys @
      for key in keys when key isnt "analyse"
        #keyName = ((key.substring 0,1).toUpperCase() + (key.substring 1)).
        #  replace 'Goal',''
        keyName = key.replace 'Goal',''
        getSum(keyName)
      return

  $scope.multipleSum =
    pomodoro: [
      'Upgrde',
      'Maintain'
      'Daily',
      'Weekly',
      'RSS',
      'DayOne',
      'Font-end',
      'PathSource'
      'Sport',
      'healthCare',
      'P2P',
      'IndexFund',
      'Finance']
    pomodoroTimesGoal: 20
    pomodoroAveGoal: 30
    breakPomodoroGoal: 0.5
    unPassionalWorks: ['PathSourc', 'WorkTalk']
    passionalWorks: ['Font-end']
    passionalWorksGoal: 6
    workSumGoal: 8
    sleep: ['CoreSleep', 'Nap']
    sleepGoal: 4.5
    myTimeGoal: 12
    myTimePercentGoal: 0.6
    myTime: [
      'Upgrde',
      'maintain',
      'Daily',
      'Weekly',
      '冥想',
      'DayOne',
      'Font-end',
      'Sport',
      'healthCare',
      'P2P',
      'IndexFund',
      'Finance',
      'Social',
      'Family',
      'Cat']
    analyse: ->
      getSum = (type) ->
        count = 0
        sum = 0
        for data in $scope.formatData.log when data.type == type &&
        data.during > 1
          count++
          sum += data.during
        [count, sum]
      getArrSum = (arr) ->
        arrSum = 0
        arrCount = 0
        for type in arr
          res = getSum(type)
          arrCount += res[0]
          arrSum += res[1]
        [arrCount, arrSum]
      # ==========> pomodoro <==========
      result = getArrSum(@pomodoro)
      @pomodoroTimes = result[0]
      @pomodoroSum = result[1]
      @pomodoroAve = @pomodoroSum / @pomodoroTimes
      @breakPomodoro = $scope.breakTime.count / @pomodoroTimes
      # ==========> work <==========
      @passionalSum = getArrSum(@passionalWorks)[1] / 60
      @workSum = getArrSum(@unPassionalWorks)[1] / 60 + @passionalSum
      # ==========> my time <==========
      @myTimeSum = getArrSum(@myTime)[1] / 60
      @sleepSum = getArrSum(@sleep)[1] / 60
      @myTimePercent = @myTimeSum / ( 24 - @sleepSum)

  
  $scope.toPercent = (num) ->
    output = (num * 100).toFixed(1)
    output = output + "%"
    output

  $scope.tableItems = []
  $scope.addItem = ->
    add = (project, index, status, more) ->
      if more
        isHighlight = if status > index then true else false
      else
        isHighlight = if status < index then true else false
      $scope.tableItems.push {
        project: project
        index: index
        status: status
        highlight: isHighlight
      }
    add 'My Time', $scope.multipleSum.myTimeGoal,
      $scope.multipleSum.myTimeSum.toFixed(1), false
    add 'My Percent', $scope.toPercent($scope.multipleSum.myTimePercentGoal),
      $scope.toPercent($scope.multipleSum.myTimePercent), false
    add 'Core Sleep', $scope.sumLimit.coresleepGoal/60,
      ($scope.sumLimit.coresleep/60).toFixed(1), true
    add 'Nap', $scope.sumLimit.napGoal, $scope.sumLimit.nap, true
    add 'Pomodoro Times', $scope.multipleSum.pomodoroTimesGoal,
      $scope.multipleSum.pomodoroTimes, false
    add 'Pomodoro Average', $scope.multipleSum.pomodoroAveGoal,
      $scope.multipleSum.pomodoroAve.toFixed(1), true
    add 'Break times', $scope.breakTime.countGoal, $scope.breakTime.count, false
    add 'Average break', $scope.breakTime.averageGoal, $scope.breakTime.average,
      true
    add 'BreakTime / Pomodoro',
      $scope.toPercent $scope.multipleSum.breakPomodoroGoal,
      $scope.toPercent($scope.multipleSum.breakPomodoro), false
    add 'Passional Work', $scope.multipleSum.passionalWorksGoal,
      $scope.multipleSum.passionalSum.toFixed(1), false
    add 'Work Sum', $scope.multipleSum.workSumGoal,
      $scope.multipleSum.workSum.toFixed(1), true
    add 'Lunch', $scope.sumLimit.lunchGoal, $scope.sumLimit.lunch, true
    add 'Dinner', $scope.sumLimit.dinnerGoal, $scope.sumLimit.dinner, true
    add 'Cooking', $scope.sumLimit.cookingGoal, $scope.sumLimit.cooking, true
    add 'GoodMorning', $scope.sumLimit.goodmorningGoal,
      $scope.sumLimit.goodmorning, true

# $scope.statusOutput = "
#   My Time
#   #{$scope.multipleSum.myTimeGoal}
#   #{$scope.multipleSum.myTimeSum.toFixed(1)}
#   My Percent
#   #{$scope.toPercent($scope.multipleSum.myTimePercentGoal)}
#   #{$scope.toPercent($scope.multipleSum.myTimePercent)}
#   Core Sleep
#   #{$scope.sumLimit.coresleepGoal/60}
#   #{($scope.sumLimit.coresleep/60).toFixed(1)}
#   Nap
#   #{$scope.sumLimit.napGoal}
#   #{$scope.sumLimit.nap}
#   Pomodoro Times
#   #{$scope.multipleSum.pomodoroTimesGoal}
#   #{$scope.multipleSum.pomodoroTimes}
#   Pomodoro Average
#   #{$scope.multipleSum.pomodoroAveGoal}
#   #{$scope.multipleSum.pomodoroAve.toFixed(1)}
#   Break times
#   #{$scope.breakTime.countGoal}
#   #{$scope.breakTime.count}
#   Average break
#   #{$scope.breakTime.averageGoal}
#   #{$scope.breakTime.average}
#   BreakTime / Pomodoro
#   #{$scope.toPercent($scope.multipleSum.breakPomodoroGoal)}
#   #{$scope.toPercent($scope.multipleSum.breakPomodoro)}
#   Passional Work
#   #{$scope.multipleSum.passionalWorksGoal}
#   #{$scope.multipleSum.passionalSum.toFixed(1)}
#   Work Sum
#   #{$scope.multipleSum.workSumGoal}
#   #{$scope.multipleSum.workSum.toFixed(1)}
#   Lunch
#   #{$scope.sumLimit.lunchGoal}
#   #{$scope.sumLimit.lunch}
#   Dinner
#   #{$scope.sumLimit.dinnerGoal}
#   #{$scope.sumLimit.dinner}
#   Cooking
#   #{$scope.sumLimit.cookingGoal}
#   #{$scope.sumLimit.cooking}
#   GoodMorning
#   #{$scope.sumLimit.goodmorningGoal}
#   #{$scope.sumLimit.goodmorning}
# "

  $scope.analyse = ->
    console.log $localStorage.formatData
    console.log "start analyse"
    $scope.breakTime.analyse()
    $scope.sumLimit.analyse()
    $scope.multipleSum.analyse()
    $scope.addItem()

  $scope.analyse()

  return

).controller 'SettingCtrl', ($scope) ->
  $scope.settings = enableFriends: true
  return

