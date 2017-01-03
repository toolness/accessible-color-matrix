'use strict';

var Elm = require('./Main');
var qs = require('./qs');

Elm.Main.embed(document.getElementById('main'), qs.parse());
