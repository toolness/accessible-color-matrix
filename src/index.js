'use strict';

var Elm = require('./Main');
var qs = require('./qs');
var jscolorify = require('./jscolorify');
var setFavicon = require('./favicon');
var main = document.getElementById('main');

function setFaviconFromState(state) {
  setFavicon(state.map(function(pair) {
    return pair[1];
  }));
}

jscolorify.init(main);

var initialState = qs.parse();
var app = Elm.Main.embed(main, initialState);

setFaviconFromState(initialState);

if (window.history.pushState) {
  app.ports.updateQs.subscribe(function(state) {
    window.history.pushState({}, "", '?' + qs.stringify(state));
    setFaviconFromState(state);
  });

  window.addEventListener('popstate', function(e) {
    var state = qs.parse();

    app.ports.qsUpdated.send(state);
    setFaviconFromState(state);
  }, false);
}

if ('scrollRestoration' in window.history) {
  // Having the browser remember the user's scroll state when
  // they press the back button is actually probably *not* what
  // the user wants in this case, so we'll disable it if possible.
  window.history.scrollRestoration = 'manual';
}
