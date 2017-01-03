'use strict';

var Elm = require('./Main');
var qs = require('./qs');
var jscolorify = require('./jscolorify');
var main = document.getElementById('main');

jscolorify.init(main);

var app = Elm.Main.embed(main, qs.parse());

if (window.history.pushState) {
  app.ports.updateQs.subscribe(function(state) {
    window.history.pushState({}, "", '?' + qs.stringify(state));
  });

  window.addEventListener('popstate', function(e) {
    app.ports.qsUpdated.send(qs.parse());
  }, false);
}
