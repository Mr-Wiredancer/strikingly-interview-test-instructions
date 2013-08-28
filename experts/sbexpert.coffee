util = require('util')
requestify = require('requestify')
cheerio = require('cheerio')
DEBUG = false
class SbExpert
  constructor:(@game, @expertIndex)->

  getNextGuess: ()->
    DEBUG and @game.log('sb\'s getnextguess is called')
    expert = this
    word = @game.currentWord
    missed = @game.missed

    requestify.post('http://www.scrabulizer.com/hangman/solve', {
      pattern: word.replace(/\*/g, '?')
      failedLetters: missed
    }).then((response)->
      $ = cheerio.load(response.body)

      if $('table').length is 0
        #TODO: no solution(represented by ?) from the expert
        expert.game.vote.apply(expert.game, ['?', expert.expertIndex])
      else
        choice = $('table').first().find('td').first().html()
        DEBUG and expert.game.log.apply(expert.game, [util.format('sbexpert guesses that the charac is %s based on the word is %s and missed are %s', choice, word, missed)])
        expert.game.vote.apply(expert.game, [choice, expert.expertIndex])
    )

exports.SbExpert = SbExpert
