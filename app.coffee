requestify = require('requestify')
util = require('util')
BbExpert = require('./experts/bbexpert').BbExpert
SbExpert = require('./experts/sbexpert').SbExpert
NmExpert = require('./experts/nmexpert').NmExpert
HhnewExpert = require('./experts/hhnewexpert').HhnewExpert
HhExpert = require('./experts/hhexpert').HhExpert
HwfcExpert = require('./experts/hwfcexpert').HwfcExpert
NaiveExpert = require('./experts/naiveexpert').NaiveExpert
fs = require('fs')
DEBUG = false

#a solver using randomized weighted majority algorithm
class Hangman
  constructor: ()->
    @userId = 'lijiahao90@gmail.com'
    @requestUrl =  'http://strikingly-interview-test.herokuapp.com/guess/process'
    @currentWord = ''
    @currentWordFinished = false
    @wordsFinished = 0
    @missed = ''

    @experts = [
      new SbExpert(this, 0)
      new NaiveExpert(this, 1)
      new NmExpert(this, 2)
      new HhExpert(this, 3)
      new HhnewExpert(this, 4)
      new HwfcExpert(this, 5)
    ]
    @voteCount = 0
    @votes = []
    @weights = []
    for expert in @experts
      @votes.push(null)
      @weights.push(1)

    @sendInitGameRequest()


  initiateGame: (@secret, @numWordsGuess, @numGuessesPerWord)->
    game = this
    @numGuessesAllowedCurrentWord = @numGuessesPerWord
    @log(util.format("Hangman game %s initiated. Number of words to guess: %s; Number of guesses per word: %s", @secret, @numWordsGuess, @numGuessesPerWord))
    fs.open('games.txt', 'a', 0o666, (err, fd)->
      fs.write(fd, game.secret+"\n", null, undefined, ()->

      )
    )
    @startGame()

  startGame: ()->
#    DEBUG and @log('startGame called')
    @nextMove()

  resetGame: ()->
    @currentWord = ''
    @currentWordFinished = false
    @wordsFinished = 0
    @missed = ''

    @letterIndex = 0

    @experts = [new SbExpert(this, 0)]
    @voteCount = 0
    @votes = []
    for expert in @experts
      @votes.push(null)

    @sendInitGameRequest()


  nextMove: ()->
#    DEBUG and @log('nextMove called')
    if @currentWord is ''
      @sendNextWordRequest()
    else if @wordsFinished is @numWordsGuess
#      @log('gameFinished')
#      @sendGetResultRequest()
      @resetGame()
    else if @currentWordFinished or (@numGuessesAllowedCurrentWord is 0)
#      @log('time to get new word')
      @wordsFinished+=1
      @currentWordFinished = false
      @missed = ''
      @numGuessesAllowedCurrentWord = @numGuessesPerWord
      @letterIndex = 0
      @sendNextWordRequest()
    else
      DEBUG and @log('making new guess')
      #current word not finished, make another guess  
      @callVote()

  callVote: ()->
    DEBUG and @log('')
#    DEBUG and @log('callVote called')
    for expert, index in @experts
#      DEBUG and console.log('expert '+index)
      expert.getNextGuess()

  vote: (choice, expertIndex)->
    choice = choice.toUpperCase()
#    DEBUG and @log('vote called')
#    DEBUG and @log(util.format('choice is %s, index is %s', choice, expertIndex))
    @votes[expertIndex] = choice
    if @votes.indexOf(null)<0
#      DEBUG and @log(@votes)
      @sendGuessRequest(@getBestGuess())

  getBestGuess:()->
    total = {}
    totalWeight = 0
    for vote, index in @votes
      #ignore '?' votes
      if vote isnt '?'
        w = @weights[index]
        if total[vote]
          total[vote] += w
        else
          total[vote] = w
        totalWeight += w

    sortedVotes = []
    for vote, count of total
      sortedVotes.push({'vote':vote, 'count':count})

    sortedVotes.sort((a, b)->
      dif = b.count-a.count
      if dif is 0
        return Math.random()-0.5
      return dif
    )

    theNum = Math.random()*totalWeight
#    DEBUG and @log(util.format('the random number is %s, total sum is %s', theNum, totalWeight))
    DEBUG and @log(@votes)
    DEBUG and @log(@weights)
#    DEBUG and @log(sortedVotes)

    for item in sortedVotes
      vote = item.vote
      vw = total[vote]
      theNum -= vw
      if theNum<0
        return vote

  sendNextWordRequest: ()->
#    DEBUG and @log('sendNextWOrdRequest called')
    @log(util.format('%s words finished. Last word is %s', @wordsFinished, @currentWord))
    game = this
    requestify.post(@requestUrl, {
      action: 'nextWord'
      userId: @userId
      secret: @secret
    }).then((response)->
      body = JSON.parse(response.body)
      if body.status is 200
        DEBUG and game.log.apply(game,[body])
        game.currentWord = body.word
        game.nextMove.apply(game, [])
      else
        game.log.apply(game, ['failed getting next word'])
        game.log.apply(game, [body])
        return
    )

  tuneWeights: (rightLetter, wrongLetter)->
    if rightLetter
      for vote, index in @votes
        if (vote isnt '?') and (vote isnt rightLetter)
          @weights[index] = @weights[index]*0.5
    else
      for vote, index in @votes
        if vote is wrongLetter
          @weights[index] = @weights[index]*0.5

    max = Math.max.apply(Math, @weights)
    if max<1
      @weights = @weights.map((e)->
        return e*2
      )

  sendGuessRequest: (letter)->
#    DEBUG and @log('sendGuessRequest called')
    DEBUG and @log(util.format('current word is %s. making guess %s', @currentWord, letter))
    game = this
    requestify.post(@requestUrl, {
      action: 'guessWord'
      guess: letter.toUpperCase()
      userId: @userId
      secret: @secret
    }).then((response)->
      body = JSON.parse(response.body)
      if body.status is 200
        if game.currentWord is body.word
          #missed the guess. `letter` is wrong
          game.missed=game.missed+letter.toUpperCase()
          DEBUG and game.log('missed: '+game.missed)
          game.tuneWeights.apply(game, [null, letter])
        else
          #`letter` is right
          game.tuneWeights.apply(game, [letter, null])

        game.votes = (null for vote in game.votes)

        game.currentWord = body.word
        if game.isGuessSuccess.apply(game, [])
          game.currentWordFinished = true
        game.numGuessesAllowedCurrentWord = body.data.numberOfGuessAllowedForThisWord

        game.nextMove.apply(game, [])
      else
        game.log.apply(game,['failed making a guess'])
        game.log.apply(game, [body])
        return
    )

  isGuessSuccess: ()->
    return @currentWord.indexOf('*') is -1

  sendGetResultRequest: ()->
    console.log('sendGetResultRequest called')
    game = this
    requestify.post(@requestUrl, {
      action: 'getTestResults'
      userId: @userId
      secret: @secret
    }).then((response)->
      body = JSON.parse(response.body)
      console.log(body)
      if body.status is 200
        game.log.apply(game, [body])
      else
        game.log.apply(game, ['failed getting test results'])
        game.log.apply(game, [body])
        return
    )



  log: (data)->
    console.log(data)

  sendInitGameRequest: ()->
    game = this
    requestify.post(@requestUrl, {
      action: 'initiateGame'
      userId: @userId
    }).then((response)->
      body = JSON.parse(response.body)
      if body.status is 200
        game.initiateGame.apply(game, [body.secret, body.data.numberOfWordsToGuess, body.data.numberOfGuessAllowedForEachWord])
      else
        game.log.apply(game, ['failed initiating the game.'])
        game.log.apply(game, [body])
        return
    )
  
global.hangman = new Hangman() 
    
    
