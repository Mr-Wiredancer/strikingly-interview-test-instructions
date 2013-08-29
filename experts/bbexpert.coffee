util = require('util')
requestify = require('requestify')
Browser = require('zombie')
DEBUG = true
class BbExpert
  constructor:(@game, @expertIndex)->
    @requestUrl = 'http://blogmybrain.com/hanging-with-friends-cheat/'
    @browser = new Browser()
    @browser.visit(@requestUrl)

  getNextGuess: ()->
    DEBUG and @game.log('bb\'s getnextguess is called')
    expert = this
    word = @game.currentWord
    missed = @game.missed

    @browser.visit(@requestUrl,{ silent: true}, (e,b)->
      setTimeout(()->
        DEBUG and console.log('page opened')
        expert.browser.fill.apply(expert.browser, ['#pz', word.replace(/\*/g, '?')])
        expert.browser.fill.apply(expert.browser, ['#incorrects', missed])
        DEBUG and console.log('about to submit')
        expert.browser.pressButton.apply(expert.browser, ['Guess Word', ()->
          DEBUG and console.log('form submitted')
          if expert.browser.window.document.querySelector('#pick0') and (expert.browser.window.document.querySelector('#pick0').parentNode.childNodes.length is 31)
            choice = '?'
          else
            choice = expert.browser.query('#pick0').parentNode.childNodes[7].value

          expert.game.vote.apply(expert.game, [choice, expert.expertIndex])
        ])

      ,0)
    )

exports.BbExpert = BbExpert

