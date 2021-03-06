// Generated by CoffeeScript 1.6.2
(function() {
  var NaiveExpert;

  NaiveExpert = (function() {
    function NaiveExpert(game, expertIndex) {
      this.game = game;
      this.expertIndex = expertIndex;
      this.letters = 'etaoinshrdlcumwfgypbvkjxqz'.toUpperCase();
    }

    NaiveExpert.prototype.getNextGuess = function() {
      var l, _i, _len, _ref;

      _ref = this.letters;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        l = _ref[_i];
        if (this.game.currentWord.indexOf(l) < 0 && this.game.missed.indexOf(l) < 0) {
          this.game.vote.apply(this.game, [l.toUpperCase(), this.expertIndex]);
          return;
        }
      }
      return this.game.vote.apply(this.game, ['?', this.expertIndex]);
    };

    return NaiveExpert;

  })();

  exports.NaiveExpert = NaiveExpert;

}).call(this);
