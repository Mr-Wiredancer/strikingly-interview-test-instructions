util = require('util')
requestify = require('requestify')
DEBUG = false
class HhExpert
  constructor:(@game, @expertIndex)->

  getNextGuess: ()->
    DEBUG and @game.log('sb\'s getnextguess is called')
    expert = this
    word = @game.currentWord
    missed = @game.missed

    requestify.post('http://www.scrabulizer.com/hangman/solve', {
      pattern: word.replace(/\*/g, '?')
      exclusions: missed
    }).then((response)->
      body = JSON.parse(response.body)

      choices = Object.keys(body.recs)
      if choices.length is 0
        result = '?'
      else
        result = choices[0]
      expert.game.vote.apply(expert.game, [result, @expertIndex])
    )

exports.HhExpert = HhExpert
