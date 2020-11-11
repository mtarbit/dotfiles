$(function(){

    var $div = $('.progress');
    var secondsRemaining = +$div.data('duration');

    function update() {
        var secs = (secondsRemaining % 60);
        var mins = Math.floor(secondsRemaining / 60);

        var messageParts = [];
        if (mins) messageParts.push('<span class="mins">' + mins + '</span> minutes');
        if (secs) messageParts.push('<span class="secs">' + secs + '</span> seconds');

        $div.html(messageParts.join(' and ') + ' remaining');

        secondsRemaining--;
    }

    setInterval(update, 1000);

    update();
});
