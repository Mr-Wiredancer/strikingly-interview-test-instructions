requestify = require('requestify')
util = require('util')
BbExpert = require('./experts/bbexpert').BbExpert
NmExpert = require('./experts/nmexpert').NmExpert
HhnewExpert = require('./experts/hhnewexpert').HhnewExpert
HhExpert = require('./experts/hhexpert').HhExpert
HwfcExpert = require('./experts/hwfcexpert').HwfcExpert
fs = require('fs')
letters = 'etaoinshrdlcumwfgypbvkjxqz'
DEBUG = false
class Hangman
  constructor: ()->
    @userId = 'lijiahao90@gmail.com'
    @requestUrl =  'http://strikingly-interview-test.herokuapp.com/guess/process'
    @currentWord = ''
    @currentWordFinished = false
    @wordsFinished = 0
    @missed = ''
    
    @letterIndex = 0

    @experts = [new HhnewExpert(this, 0)]
    @voteCount = 0
    @votes = []
    for expert in @experts
      @votes.push(null)

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
    #TODO: may do something else
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
      #@sendGuessRequest(@getNextGuess())
      @callVote()

  callVote: ()->
    DEBUG and @log('callVote called')
    for expert in @experts
      expert.getNextGuess()

  vote: (choice, expertIndex)->
    DEBUG and @log('vote called')
    DEBUG and @log(util.format('choice is %s, index is %s', choice, expertIndex))
    @votes[expertIndex] = choice
    if @votes.indexOf(null)<0
      @sendGuessRequest(@getMajorityVote())

  getMajorityVote: ()->
    DEBUG and @log('getMajorVote called')
    total = {}
    for vote in @votes
      if total[vote]
        total[vote]+=1
      else
        total[vote] = 1
    sortedVotes = []
    for vote, count of total
      sortedVotes.push({'vote':vote, 'count':count})
     
    sortedVotes.sort((a, b)->
      return b.count-a.count
    )

    if sortedVotes[0].vote is '?'
      if sortedVotes.length>1
        result = sortedVotes[1].vote
      else
        result = @getNextGuess()
    else
      result = sortedVotes[0].vote
    @votes = (null for vote in @votes)
    return result

  getNextGuess: ()->
    @letterIndex+=1
    l = letters[@letterIndex-1]
    if @currentWord.indexOf(l)>-1 or @missed.indexOf(l)>-1
      @letterIndex+=1
      l = letters[@letterIndex-1]
    return l

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

  sendGuessRequest: (letter)->
    DEBUG and @log('sendGuessRequest called')
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
          #missed the guess
          DEBUG and game.log('missed word: '+letter)
          game.missed+=letter.toUpperCase()

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
    
    
