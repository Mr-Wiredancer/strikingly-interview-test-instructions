util = require('util')
requestify = require('requestify')
childProcess = require('child_process');
phantomjs = require('phantomjs');
binPath = phantomjs.path;
path = require('path');
DEBUG = true
class BbExpert
  constructor:(@game, @expertIndex)->
    @bbhelper = 'bbhelper.js'

  getNextGuess: ()->
    DEBUG and @game.log('bb\'s getnextguess is called')
    expert = this
    word = @game.currentWord
    missed = @game.missed

    childArgs = [
      path.join(__dirname, @bbhelper)
      word.replace(/\*/g, '?')
      missed
    ]

    childProcess.execFile(binPath, childArgs, (err, stdout, stderr)->
      try
        result = JSON.parse(stdout)
        expert.game.vote.apply(expert.game, [result.choice, expert.expertIndex])
      catch e
        expert.game.vote.apply(expert.game, ['?', expert.expertIndex])
    )

exports.BbExpert = BbExpert

