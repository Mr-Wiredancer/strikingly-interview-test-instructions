// Generated by CoffeeScript 1.6.2
(function() {
  var DEBUG, HhExpert, binPath, childProcess, path, phantomjs, util;

  util = require('util');

  childProcess = require('child_process');

  phantomjs = require('phantomjs');

  binPath = phantomjs.path;

  path = require('path');

  DEBUG = true;

  HhExpert = (function() {
    function HhExpert(game, expertIndex) {
      this.game = game;
      this.expertIndex = expertIndex;
      this.helper = 'hhhelper.js';
    }

    HhExpert.prototype.getNextGuess = function() {
      var childArgs, expert, missed, word;

      DEBUG && this.game.log('hh\'s getnextguess is called');
      expert = this;
      word = this.game.currentWord;
      missed = this.game.missed;
      childArgs = [path.join(__dirname, this.helper), word.replace(/\*/g, '?'), missed];
      return childProcess.execFile(binPath, childArgs, function(err, stdout, stderr) {
        var arr, data, e, result;

        try {
          data = JSON.parse(stdout).recs;
          arr = Object.keys(data);
          arr.sort(function(a, b) {
            return data[b] - data[a];
          });
          DEBUG && console.log(data);
          result = arr[0];
        } catch (_error) {
          e = _error;
          result = '?';
        }
        return expert.game.vote.apply(expert.game, [result, expert.expertIndex]);
      });
    };

    return HhExpert;

  })();

  exports.HhExpert = HhExpert;

}).call(this);
