util = require('util')
requestify = require('requestify')
childProcess = require('child_process');
phantomjs = require('phantomjs');
binPath = phantomjs.path;
path = require('path');
DEBUG = false
#only handles 4~8-letter words.
class HwfcExpert
  constructor:(@game, @expertIndex)->
    @helper = 'hwfchelper.js'

  getNextGuess: ()->
    DEBUG and @game.log('hwfc\'s getnextguess is called')
    expert = this
    word = @game.currentWord
    missed = @game.missed

    if word.length<4 or word.length>8
      expert.game.vote.apply(expert.game, ['?', expert.expertIndex])
      return

    childArgs = [
      path.join(__dirname, @helper)
      word.replace(/\*/g, '?')
      missed
    ]

    childProcess.execFile(binPath, childArgs, (err, stdout, stderr)->
      result = JSON.parse(stdout)
      expert.game.vote.apply(expert.game, [result.choice, expert.expertIndex])
    )

exports.HwfcExpert = HwfcExpert
