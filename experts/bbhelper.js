var system = require('system')
var page = require('webpage').create(),
    server = 'http://blogmybrain.com/hanging-with-friends-cheat/',
    word = system.args[1],
    missed = system.args[2],
    data = 'haction=Guess+Word&bonus1=&bonus2=&bonus3=&bonus4=&bonus5=&bonus6=&bonus7=&bonus8=&wordlvl=2&assets=&puzzle='+word+'&incorrects='+missed+'&username=&cmts=';

page.open(server, 'post', data, function (status) {
    if (status !== 'success') {
        console.log('Unable to post!');
    } else {
//        console.log(page.content);
      var result = page.evaluate(function(){
        if (document.querySelector('#pick0').parentNode.childNodes.length === 31){
          return '?'
        }
        return document.getElementById('pick0').parentNode.childNodes[7].value;
      });
      console.log(JSON.stringify({choice:result}));
    }
    phantom.exit();
});
