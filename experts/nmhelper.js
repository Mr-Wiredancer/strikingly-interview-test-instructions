var system = require('system')
var page = require('webpage').create(),
    server = 'http://nmichaels.org/hangsolve.py',
    word = system.args[1],
    missed = system.args[2],
    c1 = word.substr(0, 1),
    c2 = word.substr(1, 1),
    c3 = word.substr(2, 1),
    c4 = word.substr(3, 1),
    c5 = word.substr(4, 1),
    data = 'pattern0='+(c1==='?'?'':c1)+'&pattern1='+(c2==='?'?'':c2)+'&pattern2='+(c3==='?'?'':c3)+'&pattern3='+(c4==='?'?'':c4)+'&pattern4='+(c5==='?'?'':c5)+'&guessed='+missed+'&game=hangman&action=display';

//set a time limit
setTimeout(function(){
    console.log(JSON.stringify({choice:'?'}));
    phantom.exit();
}, 10000);

page.settings.loadImages = false;

page.open(server, 'post', data, function (status) {
    if (status !== 'success') {
        //failed
        console.log(JSON.stringfy({choice:'?'}));
    } else {
      var result = page.evaluate(function(){
          if (!document.querySelector('.guess')){
            return '?';
          }else{
            return document.querySelector('.guess').innerHTML.trim().substr(0, 1);
          }
      });
      console.log(JSON.stringify({choice:result}));
    }
    phantom.exit();
});
