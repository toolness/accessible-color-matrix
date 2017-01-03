var querystring = require('querystring');

var COLOR_NAME_KEY = 'n';
var COLOR_VALUE_KEY = 'v';

function ensureArray(val) {
  if (typeof(val) === 'undefined') {
    return [];
  }
  if (typeof(val) === 'string') {
    return [val];
  }
  return val;
}

exports.parse = function parseQs(str) {
  if (typeof(str) === 'undefined') {
    str = window.location.search.slice(1);
  }
  var q = querystring.parse(str);
  var names = ensureArray(q[COLOR_NAME_KEY]);
  var values = ensureArray(q[COLOR_VALUE_KEY]);
  var min = Math.min(names.length, values.length);
  var result = [];

  for (var i = 0; i < min; i++) {
    result.push([names[i], values[i]]);
  }

  return result;
};

exports.stringify = function stringifyQs(pairs) {
  var obj = {};

  obj[COLOR_NAME_KEY] = [];
  obj[COLOR_VALUE_KEY] = [];

  for (var i = 0; i < pairs.length; i++) {
    obj[COLOR_NAME_KEY].push(pairs[i][0]);
    obj[COLOR_VALUE_KEY].push(pairs[i][1]);
  }

  return querystring.stringify(obj);
};
