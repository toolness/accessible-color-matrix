var FAVICON_WIDTH = 16;
var FAVICON_SQUARES_PER_SIDE = 4;

var gDefaultHref = null;

function drawPalette(canvas, squaresPerSide, colors) {
  var ctx = canvas.getContext('2d');
  var squareWidth = canvas.width / squaresPerSide;
  var row;
  var col;
  var colorIndex = 0;

  for (row = 0; row < squaresPerSide; row += 1) {
    for (col = 0; col < squaresPerSide; col += 1) {
      ctx.fillStyle = '#' + colors[colorIndex];
      ctx.fillRect(
        col * squareWidth,
        row * squareWidth,
        squareWidth,
        squareWidth
      );
      colorIndex = (colorIndex + 1) % colors.length;
    }
  }
}

function createFaviconURL(colors) {
  var canvas = document.createElement('canvas');

  canvas.width = FAVICON_WIDTH;
  canvas.height = FAVICON_WIDTH;

  drawPalette(canvas, FAVICON_SQUARES_PER_SIDE, colors);

  return canvas.toDataURL();
}

function setFavicon(colors) {
  var link = document.querySelector('link[rel="icon"]');
  var href;

  if (link) {
    if (gDefaultHref === null) {
      gDefaultHref = link.getAttribute('href');
    }

    href = gDefaultHref;

    if (colors.length) {
      href = createFaviconURL(colors);
    }

    link.setAttribute('href', href);
  }
}

module.exports = setFavicon;
