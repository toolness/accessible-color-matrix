exports.init = function init(main) {
  // Elm's apparent lack of virtual DOM lifecycle management
  // functions (a la React), as well as its lack of support
  // for Custom Elements, makes it difficult to reuse
  // third-party JS UI code.
  //
  // For now, we'll have to resort to MutationObservers
  // to "upgrade" any elements that have been marked-up by
  // our Elm code as being in need of upgrading.

  if (!(window.MutationObserver && window.jscolor)) {
    return;
  }

  var observer = new MutationObserver(function(mutations) {
    var els = main.querySelectorAll('[data-jscolorify]');
    var el;

    for (var i = 0; i < els.length; i++) {
      el = els[i];
      if (!el._hasBeenJscolorified) {
        el._hasBeenJscolorified = true;
        new jscolor(el);
      }
    }
  });

  observer.observe(main, {
    subtree: true,
    childList: true
  });
};
