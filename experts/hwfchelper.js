var system = require('system')
var page = require('webpage').create(),
    server = 'http://www.hangingwithfriendscheat.org/',
    word = system.args[1],
    missed = system.args[2],
    letters = ['','','','','','','',''];
var noClue = true;

for (var i=0; i<word.length; i++){
    var l = word.substr(i, 1);
    if (l!='?'){
        letters[i] = l;
        noClue = false;
    }
}

//hwfc doesn't accept patterns that have no clue(all unknown)
if (noClue){
    console.log(JSON.stringify({choice:'?'}));
    phantom.exit();
}

var data = 'noLetters='+word.length+'&letter_0='+letters[0]+'&letter_1='+letters[1]+'&letter_2='+letters[2]+'&letter_3='+letters[3]+'&letter_4='+letters[4]+'&letter_5='+letters[5]+'&letter_6='+letters[6]+'&letter_7='+letters[7]+'&bad_letters='+missed+'';

//set a time limit
setTimeout(function(){
    console.log(JSON.stringify({choice:'?'}));
    phantom.exit();
}, 5000);

page.settings.loadImages = false;

page.open(server, 'post', data, function (status) {
    if (status !== 'success') {
        //failed
        console.log(JSON.stringfy({choice:'?'}));
    } else {
//        console.log(page.content);
      var result = page.evaluate(function(){
        if (document.querySelector('.formcontainer b')){
          return '?'
        }
        var text = document.querySelector('.formcontainer strong').innerHTML;
        return text.substr(text.length-1, 1);
      });
      console.log(JSON.stringify({choice:result}));
    }
    phantom.exit();
});
