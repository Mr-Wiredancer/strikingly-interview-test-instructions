#guess acoording to relative frequencies of alphabets
class NaiveExpert
  constructor:(@game, @expertIndex)->
    @letters = 'etaoinshrdlcumwfgypbvkjxqz'.toUpperCase()

  getNextGuess: ()->
    for l in @letters
      if @game.currentWord.indexOf(l)<0 and @game.missed.indexOf(l)<0
        @game.vote.apply(@game, [l.toUpperCase(), @expertIndex])
        return
    @game.vote.apply(@game, ['?', @expertIndex])

exports.NaiveExpert = NaiveExpert
