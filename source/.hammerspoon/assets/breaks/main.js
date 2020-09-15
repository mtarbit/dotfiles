$(function(){

    var $div = $('.progress');
    var secs = +$div.data('duration');

    function update() {
        $div.html((secs--) + ' seconds remaining');
    }

    setInterval(update, 1000);

    update();
});
