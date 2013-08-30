var system = require('system')
var page = require('webpage').create(),
    server = 'http://www.hanginghyena.com/hangmansolver',
    word = system.args[1],
    missed = system.args[2]

//set a time limit
setTimeout(function(){
    console.log('time to end');
    phantom.exit();
}, 5000);

page.settings.loadImages = false;

page.open(server, function (status) {
    if (status !== 'success') {
        //failed
        console.log(JSON.stringfy({choice:'?'}));
    } else {
//        console.log(page.content);
        page.onConsoleMessage = function (msg) {
            console.log(msg);
            phantom.exit();
        };

        page.evaluate(function(ppp, eee){
          jQuery.post('http://www.hanginghyena.com/gateway/lookup', {pattern:ppp, exclusions:eee}, function(data){console.log(JSON.stringify(data))})
        }, word, missed);
    }
});
