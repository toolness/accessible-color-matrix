'use strict';

var Elm = require('./Main');
var qs = require('./qs');
var app = Elm.Main.embed(document.getElementById('main'), qs.parse());

if (window.history.pushState) {
  app.ports.updateQs.subscribe(function(state) {
    window.history.pushState({}, "", '?' + qs.stringify(state));
  });

  window.addEventListener('popstate', function(e) {
    app.ports.qsUpdated.send(qs.parse());
  }, false);
}
