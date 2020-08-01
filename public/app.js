function setLocalTime() {
  var elements = document.querySelectorAll('time');
  for(var i = 0; i < elements.length; i++) {
    var d = new Date(0);
    d.setUTCSeconds(elements[i].getAttribute('data-seconds'));
    elements[i].innerText = d.toLocaleDateString("en", { month: "short", day: "2-digit"});
  }
}

function timeAgo(seconds) {
  seconds = Math.floor(new Date().getTime() / 1000) - seconds;

  if (Math.floor(seconds / 31536000) > 1) { return null; }
  if (Math.floor(seconds / 2592000) > 1) { return null; }
  if (Math.floor(seconds / 86400) > 1) { return null; }

  var interval = Math.floor(seconds / 3600);
  if (interval > 1) {
    return interval + " hours ago";
  }

  if(interval === 1) {
    return "about an hour ago"
  }

  interval = Math.floor(seconds / 60);
  if (interval > 1) {
    return interval + " minutes ago";
  }

  if(interval === 1) {
    return "about a minute ago"
  }

  return Math.floor(seconds) + " seconds ago";
}

function setTimeAgo() {
  var elements = document.querySelectorAll('time');
  for(var i = 0; i < elements.length; i++) {
    var seconds = elements[i].getAttribute('data-seconds');
    var ago = timeAgo(seconds)

    if(!!ago) {
      elements[i].innerText = ago;
    }
  }
}

window.addEventListener('DOMContentLoaded', function() {
  setLocalTime();
  setTimeAgo();

  htmx.on('htmx:afterSettle', function(evt) {
    setLocalTime();
    setTimeAgo();
  })
});

document.body.addEventListener('htmx:configRequest', function(evt) {
  var csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  if(evt.detail.verb !== 'get') {
    evt.detail.parameters['__csrf-token'] = csrfToken;
  }
});
