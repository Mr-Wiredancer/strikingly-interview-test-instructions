util = require('util')
requestify = require('requestify')
cheerio = require('cheerio')
DEBUG = false
#only handles 5-letter words.
#server doesn't accept http request from different origin?
class NmExpert
  constructor:(@game, @expertIndex)->
    @requestUrl = 'http://nmichaels.org/hangsolve.py'

  getNextGuess: ()->
    DEBUG and @game.log('nm\'s getnextguess is called')
    expert = this
    word = @game.currentWord
    missed = @game.missed

    if word.length isnt 5
      @game.vote.apply(@game, ['?', @expertIndex])
    else
      requestify.post(@requestUrl, {
        pattern0: word.substr(0, 1).replace('*','').toUpperCase()
        pattern1: word.substr(1, 1).replace('*','').toUpperCase()
        pattern2: word.substr(2, 1).replace('*','').toUpperCase()
        pattern3: word.substr(3, 1).replace('*','').toUpperCase()
        pattern4: word.substr(4, 1).replace('*','').toUpperCase()
        game: 'hangman'
        guessed: missed
        action: 'display'
      }).then((response)->
        $ = cheerio.load(response.body)
        console.log(response)
        if $('.guess').length is 0
          result = '?'
        else
          result = $('.guess').first().html().trim().substr(0, 1)
        expert.game.vote.apply(expert.game, [result, @expertIndex])
      )

exports.NmExpert = NmExpert
