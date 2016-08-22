(() => {
  var root = this;

  var protos = {};

  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = protos;
    }
    exports.proto = protos;
  } else {
    root.proto = protos;
  }

  // $MESSAGE

})();