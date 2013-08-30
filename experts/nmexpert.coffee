util = require('util')
requestify = require('requestify')
childProcess = require('child_process');
phantomjs = require('phantomjs');
binPath = phantomjs.path;
path = require('path');
DEBUG = false
#only handles 5-letter words.
#server doesn't accept http request from different origin?
class NmExpert
  constructor:(@game, @expertIndex)->
    @nmhelper = 'nmhelper.js'

  getNextGuess: ()->
    DEBUG and @game.log('nm\'s getnextguess is called')
    expert = this
    word = @game.currentWord
    missed = @game.missed

    if word.length isnt 5
      expert.game.vote.apply(expert.game, ['?', expert.expertIndex])
      return

    childArgs = [
      path.join(__dirname, @nmhelper)
      word.replace(/\*/g, '?')
      missed
    ]

    childProcess.execFile(binPath, childArgs, (err, stdout, stderr)->
      result = JSON.parse(stdout)
      expert.game.vote.apply(expert.game, [result.choice, expert.expertIndex])
    )

exports.NmExpert = NmExpert
