util = require('util')
requestify = require('requestify')
cheerio = require('cheerio')
DEBUG = false
class NmExpert
  constructor:(@game, @expertIndex)->
    @requestUrl = 'http://nmichaels.org/hangsolve.py'

  getNextGuess: ()->
    DEBUG and @game.log('nm\'s getnextguess is called')
    expert = this
    word = @game.currentWord
    missed = @game.missed

    requestify.post(@requestUrl, {
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

exports.NmExpert = NmExpert
