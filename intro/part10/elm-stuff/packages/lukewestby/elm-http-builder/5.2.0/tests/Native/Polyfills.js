var _user$project$Native_Polyfills = (function () {
  global.FormData = function () { this._data = []; };
  Object.defineProperty(global.FormData.prototype, 'append', {
    value: function () {
      this._data.push(Array.prototype.slice.call(arguments));
    },
    enumerable: false,
  });

  return {
    enabled: true,
  };
}());
