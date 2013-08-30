util = require('util')
childProcess = require('child_process');
phantomjs = require('phantomjs');
binPath = phantomjs.path;
path = require('path');
DEBUG = true
class HhnewExpert
  constructor:(@game, @expertIndex)->
    @helper = 'hhnewhelper.js'

  getNextGuess: ()->
    DEBUG and @game.log('hhnewexpert\'s getnextguess is called')
    expert = this
    word = @game.currentWord
    missed = @game.missed

    childArgs = [
      path.join(__dirname, @helper)
      word.replace(/\*/g, '?')
      missed
    ]

    childProcess.execFile(binPath, childArgs, (err, stdout, stderr)->
      try
        data = JSON.parse(stdout).recs
        arr = Object.keys(data)
        arr.sort((a, b)->
          return data[b]-data[a]
        )
        DEBUG and console.log(data)
        result = arr[0]
      catch e
        result = '?'

      expert.game.vote.apply(expert.game, [result, expert.expertIndex])
    )


exports.HhnewExpert = HhnewExpert
