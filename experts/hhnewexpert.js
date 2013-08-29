// Generated by CoffeeScript 1.6.2
(function() {
  var DEBUG, HhnewExpert, cheerio, requestify, util;

  util = require('util');

  requestify = require('requestify');

  cheerio = require('cheerio');

  DEBUG = false;

  HhnewExpert = (function() {
    function HhnewExpert(game, expertIndex) {
      this.game = game;
      this.expertIndex = expertIndex;
    }

    HhnewExpert.prototype.getNextGuess = function() {
      var expert, missed, word;

      DEBUG && this.game.log('sb\'s getnextguess is called');
      expert = this;
      word = this.game.currentWord;
      missed = this.game.missed;
      return requestify.post('http://www.scrabulizer.com/hangman/solve', {
        pattern: word.replace(/\*/g, '?'),
        exclusions: missed
      }).then(function(response) {
        var body, choices, result;

        body = JSON.parse(response.body);
        choices = Object.keys(body.recs);
        if (choices.length === 0) {
          result = '?';
        } else {
          result = choices[0];
        }
        return expert.game.vote.apply(expert.game, [result, this.expertIndex]);
      });
    };

    return HhnewExpert;

  })();

  exports.HhnewExpert = HhnewExpert;

}).call(this);
