/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	"use strict";
	
	var testsContext = __webpack_require__(1);
	
	var runnable = _get__("testsContext").keys();
	
	_get__("runnable").forEach(_get__("testsContext"));
	var _RewiredData__ = {};
	let _RewireAPI__ = {};

	(function () {
	  function addPropertyToAPIObject(name, value) {
	    Object.defineProperty(_RewireAPI__, name, {
	      value: value,
	      enumerable: false,
	      configurable: true
	    });
	  }

	  addPropertyToAPIObject('__get__', _get__);
	  addPropertyToAPIObject('__GetDependency__', _get__);
	  addPropertyToAPIObject('__Rewire__', _set__);
	  addPropertyToAPIObject('__set__', _set__);
	  addPropertyToAPIObject('__reset__', _reset__);
	  addPropertyToAPIObject('__ResetDependency__', _reset__);
	  addPropertyToAPIObject('__with__', _with__);
	})();

	function _get__(variableName) {
	  return _RewiredData__ === undefined || _RewiredData__[variableName] === undefined ? _get_original__(variableName) : _RewiredData__[variableName];
	}

	function _get_original__(variableName) {
	  switch (variableName) {
	    case "testsContext":
	      return testsContext;

	    case "runnable":
	      return runnable;
	  }

	  return undefined;
	}

	function _assign__(variableName, value) {
	  if (_RewiredData__ === undefined || _RewiredData__[variableName] === undefined) {
	    return _set_original__(variableName, value);
	  } else {
	    return _RewiredData__[variableName] = value;
	  }
	}

	function _set_original__(variableName, _value) {
	  switch (variableName) {}

	  return undefined;
	}

	function _update_operation__(operation, variableName, prefix) {
	  var oldValue = _get__(variableName);

	  var newValue = operation === '++' ? oldValue + 1 : oldValue - 1;

	  _assign__(variableName, newValue);

	  return prefix ? newValue : oldValue;
	}

	function _set__(variableName, value) {
	  return _RewiredData__[variableName] = value;
	}

	function _reset__(variableName) {
	  delete _RewiredData__[variableName];
	}

	function _with__(object) {
	  var rewiredVariableNames = Object.keys(object);
	  var previousValues = {};

	  function reset() {
	    rewiredVariableNames.forEach(function (variableName) {
	      _RewiredData__[variableName] = previousValues[variableName];
	    });
	  }

	  return function (callback) {
	    rewiredVariableNames.forEach(function (variableName) {
	      previousValues[variableName] = _RewiredData__[variableName];
	      _RewiredData__[variableName] = object[variableName];
	    });
	    let result = callback();

	    if (!!result && typeof result.then == 'function') {
	      result.then(reset).catch(reset);
	    } else {
	      reset();
	    }

	    return result;
	  };
	}

	let typeOfOriginalExport = typeof module.exports;

	function addNonEnumerableProperty(name, value) {
	  Object.defineProperty(module.exports, name, {
	    value: value,
	    enumerable: false,
	    configurable: true
	  });
	}

	if ((typeOfOriginalExport === 'object' || typeOfOriginalExport === 'function') && Object.isExtensible(module.exports)) {
	  addNonEnumerableProperty('__get__', _get__);
	  addNonEnumerableProperty('__GetDependency__', _get__);
	  addNonEnumerableProperty('__Rewire__', _set__);
	  addNonEnumerableProperty('__set__', _set__);
	  addNonEnumerableProperty('__reset__', _reset__);
	  addNonEnumerableProperty('__ResetDependency__', _reset__);
	  addNonEnumerableProperty('__with__', _with__);
	  addNonEnumerableProperty('__RewireAPI__', _RewireAPI__);
	}

/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	var map = {
		"./unit_test.js": 2
	};
	function webpackContext(req) {
		return __webpack_require__(webpackContextResolve(req));
	};
	function webpackContextResolve(req) {
		return map[req] || (function() { throw new Error("Cannot find module '" + req + "'.") }());
	};
	webpackContext.keys = function webpackContextKeys() {
		return Object.keys(map);
	};
	webpackContext.resolve = webpackContextResolve;
	module.exports = webpackContext;
	webpackContext.id = 1;


/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var _expect = __webpack_require__(3);
	
	var _expect2 = _get__('_interopRequireDefault')(_get__('_expect'));
	
	function _interopRequireDefault(obj) {
	  return obj && obj.__esModule ? obj : { default: obj };
	}
	
	describe('UNIT TEST', function () {
	  it('should be true', function () {
	    (0, _get__('_expect2').default)(true).toBe(true);
	  });
	});
	var _RewiredData__ = {};
	let _RewireAPI__ = {};

	(function () {
	  function addPropertyToAPIObject(name, value) {
	    Object.defineProperty(_RewireAPI__, name, {
	      value: value,
	      enumerable: false,
	      configurable: true
	    });
	  }

	  addPropertyToAPIObject('__get__', _get__);
	  addPropertyToAPIObject('__GetDependency__', _get__);
	  addPropertyToAPIObject('__Rewire__', _set__);
	  addPropertyToAPIObject('__set__', _set__);
	  addPropertyToAPIObject('__reset__', _reset__);
	  addPropertyToAPIObject('__ResetDependency__', _reset__);
	  addPropertyToAPIObject('__with__', _with__);
	})();

	function _get__(variableName) {
	  return _RewiredData__ === undefined || _RewiredData__[variableName] === undefined ? _get_original__(variableName) : _RewiredData__[variableName];
	}

	function _get_original__(variableName) {
	  switch (variableName) {
	    case '_interopRequireDefault':
	      return _interopRequireDefault;

	    case '_expect':
	      return _expect;

	    case '_expect2':
	      return _expect2;
	  }

	  return undefined;
	}

	function _assign__(variableName, value) {
	  if (_RewiredData__ === undefined || _RewiredData__[variableName] === undefined) {
	    return _set_original__(variableName, value);
	  } else {
	    return _RewiredData__[variableName] = value;
	  }
	}

	function _set_original__(variableName, _value) {
	  switch (variableName) {}

	  return undefined;
	}

	function _update_operation__(operation, variableName, prefix) {
	  var oldValue = _get__(variableName);

	  var newValue = operation === '++' ? oldValue + 1 : oldValue - 1;

	  _assign__(variableName, newValue);

	  return prefix ? newValue : oldValue;
	}

	function _set__(variableName, value) {
	  return _RewiredData__[variableName] = value;
	}

	function _reset__(variableName) {
	  delete _RewiredData__[variableName];
	}

	function _with__(object) {
	  var rewiredVariableNames = Object.keys(object);
	  var previousValues = {};

	  function reset() {
	    rewiredVariableNames.forEach(function (variableName) {
	      _RewiredData__[variableName] = previousValues[variableName];
	    });
	  }

	  return function (callback) {
	    rewiredVariableNames.forEach(function (variableName) {
	      previousValues[variableName] = _RewiredData__[variableName];
	      _RewiredData__[variableName] = object[variableName];
	    });
	    let result = callback();

	    if (!!result && typeof result.then == 'function') {
	      result.then(reset).catch(reset);
	    } else {
	      reset();
	    }

	    return result;
	  };
	}

	let typeOfOriginalExport = typeof module.exports;

	function addNonEnumerableProperty(name, value) {
	  Object.defineProperty(module.exports, name, {
	    value: value,
	    enumerable: false,
	    configurable: true
	  });
	}

	if ((typeOfOriginalExport === 'object' || typeOfOriginalExport === 'function') && Object.isExtensible(module.exports)) {
	  addNonEnumerableProperty('__get__', _get__);
	  addNonEnumerableProperty('__GetDependency__', _get__);
	  addNonEnumerableProperty('__Rewire__', _set__);
	  addNonEnumerableProperty('__set__', _set__);
	  addNonEnumerableProperty('__reset__', _reset__);
	  addNonEnumerableProperty('__ResetDependency__', _reset__);
	  addNonEnumerableProperty('__with__', _with__);
	  addNonEnumerableProperty('__RewireAPI__', _RewireAPI__);
	}

/***/ },
/* 3 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var _Expectation = __webpack_require__(4);
	
	var _Expectation2 = _interopRequireDefault(_Expectation);
	
	var _SpyUtils = __webpack_require__(23);
	
	var _assert = __webpack_require__(21);
	
	var _assert2 = _interopRequireDefault(_assert);
	
	var _extend = __webpack_require__(25);
	
	var _extend2 = _interopRequireDefault(_extend);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function expect(actual) {
	  return new _Expectation2.default(actual);
	}
	
	expect.createSpy = _SpyUtils.createSpy;
	expect.spyOn = _SpyUtils.spyOn;
	expect.isSpy = _SpyUtils.isSpy;
	expect.restoreSpies = _SpyUtils.restoreSpies;
	expect.assert = _assert2.default;
	expect.extend = _extend2.default;
	
	module.exports = expect;

/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _isEqual = __webpack_require__(5);
	
	var _isEqual2 = _interopRequireDefault(_isEqual);
	
	var _isRegex = __webpack_require__(16);
	
	var _isRegex2 = _interopRequireDefault(_isRegex);
	
	var _assert = __webpack_require__(21);
	
	var _assert2 = _interopRequireDefault(_assert);
	
	var _SpyUtils = __webpack_require__(23);
	
	var _TestUtils = __webpack_require__(24);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	/**
	 * An Expectation is a wrapper around an assertion that allows it to be written
	 * in a more natural style, without the need to remember the order of arguments.
	 * This helps prevent you from making mistakes when writing tests.
	 */
	
	var Expectation = function () {
	  function Expectation(actual) {
	    _classCallCheck(this, Expectation);
	
	    this.actual = actual;
	
	    if ((0, _TestUtils.isFunction)(actual)) {
	      this.context = null;
	      this.args = [];
	    }
	  }
	
	  _createClass(Expectation, [{
	    key: 'toExist',
	    value: function toExist(message) {
	      (0, _assert2.default)(this.actual, message || 'Expected %s to exist', this.actual);
	
	      return this;
	    }
	  }, {
	    key: 'toNotExist',
	    value: function toNotExist(message) {
	      (0, _assert2.default)(!this.actual, message || 'Expected %s to not exist', this.actual);
	
	      return this;
	    }
	  }, {
	    key: 'toBe',
	    value: function toBe(value, message) {
	      (0, _assert2.default)(this.actual === value, message || 'Expected %s to be %s', this.actual, value);
	
	      return this;
	    }
	  }, {
	    key: 'toNotBe',
	    value: function toNotBe(value, message) {
	      (0, _assert2.default)(this.actual !== value, message || 'Expected %s to not be %s', this.actual, value);
	
	      return this;
	    }
	  }, {
	    key: 'toEqual',
	    value: function toEqual(value, message) {
	      try {
	        (0, _assert2.default)((0, _isEqual2.default)(this.actual, value), message || 'Expected %s to equal %s', this.actual, value);
	      } catch (e) {
	        // These attributes are consumed by Mocha to produce a diff output.
	        e.showDiff = true;
	        e.actual = this.actual;
	        e.expected = value;
	        throw e;
	      }
	
	      return this;
	    }
	  }, {
	    key: 'toNotEqual',
	    value: function toNotEqual(value, message) {
	      (0, _assert2.default)(!(0, _isEqual2.default)(this.actual, value), message || 'Expected %s to not equal %s', this.actual, value);
	
	      return this;
	    }
	  }, {
	    key: 'toThrow',
	    value: function toThrow(value, message) {
	      (0, _assert2.default)((0, _TestUtils.isFunction)(this.actual), 'The "actual" argument in expect(actual).toThrow() must be a function, %s was given', this.actual);
	
	      (0, _assert2.default)((0, _TestUtils.functionThrows)(this.actual, this.context, this.args, value), message || 'Expected %s to throw %s', this.actual, value || 'an error');
	
	      return this;
	    }
	  }, {
	    key: 'toNotThrow',
	    value: function toNotThrow(value, message) {
	      (0, _assert2.default)((0, _TestUtils.isFunction)(this.actual), 'The "actual" argument in expect(actual).toNotThrow() must be a function, %s was given', this.actual);
	
	      (0, _assert2.default)(!(0, _TestUtils.functionThrows)(this.actual, this.context, this.args, value), message || 'Expected %s to not throw %s', this.actual, value || 'an error');
	
	      return this;
	    }
	  }, {
	    key: 'toBeA',
	    value: function toBeA(value, message) {
	      (0, _assert2.default)((0, _TestUtils.isFunction)(value) || typeof value === 'string', 'The "value" argument in toBeA(value) must be a function or a string');
	
	      (0, _assert2.default)((0, _TestUtils.isA)(this.actual, value), message || 'Expected %s to be a %s', this.actual, value);
	
	      return this;
	    }
	  }, {
	    key: 'toNotBeA',
	    value: function toNotBeA(value, message) {
	      (0, _assert2.default)((0, _TestUtils.isFunction)(value) || typeof value === 'string', 'The "value" argument in toNotBeA(value) must be a function or a string');
	
	      (0, _assert2.default)(!(0, _TestUtils.isA)(this.actual, value), message || 'Expected %s to be a %s', this.actual, value);
	
	      return this;
	    }
	  }, {
	    key: 'toMatch',
	    value: function toMatch(pattern, message) {
	      (0, _assert2.default)(typeof this.actual === 'string', 'The "actual" argument in expect(actual).toMatch() must be a string');
	
	      (0, _assert2.default)((0, _isRegex2.default)(pattern), 'The "value" argument in toMatch(value) must be a RegExp');
	
	      (0, _assert2.default)(pattern.test(this.actual), message || 'Expected %s to match %s', this.actual, pattern);
	
	      return this;
	    }
	  }, {
	    key: 'toNotMatch',
	    value: function toNotMatch(pattern, message) {
	      (0, _assert2.default)(typeof this.actual === 'string', 'The "actual" argument in expect(actual).toNotMatch() must be a string');
	
	      (0, _assert2.default)((0, _isRegex2.default)(pattern), 'The "value" argument in toNotMatch(value) must be a RegExp');
	
	      (0, _assert2.default)(!pattern.test(this.actual), message || 'Expected %s to not match %s', this.actual, pattern);
	
	      return this;
	    }
	  }, {
	    key: 'toBeLessThan',
	    value: function toBeLessThan(value, message) {
	      (0, _assert2.default)(typeof this.actual === 'number', 'The "actual" argument in expect(actual).toBeLessThan() must be a number');
	
	      (0, _assert2.default)(typeof value === 'number', 'The "value" argument in toBeLessThan(value) must be a number');
	
	      (0, _assert2.default)(this.actual < value, message || 'Expected %s to be less than %s', this.actual, value);
	
	      return this;
	    }
	  }, {
	    key: 'toBeLessThanOrEqualTo',
	    value: function toBeLessThanOrEqualTo(value, message) {
	      (0, _assert2.default)(typeof this.actual === 'number', 'The "actual" argument in expect(actual).toBeLessThanOrEqualTo() must be a number');
	
	      (0, _assert2.default)(typeof value === 'number', 'The "value" argument in toBeLessThanOrEqualTo(value) must be a number');
	
	      (0, _assert2.default)(this.actual <= value, message || 'Expected %s to be less than or equal to %s', this.actual, value);
	
	      return this;
	    }
	  }, {
	    key: 'toBeGreaterThan',
	    value: function toBeGreaterThan(value, message) {
	      (0, _assert2.default)(typeof this.actual === 'number', 'The "actual" argument in expect(actual).toBeGreaterThan() must be a number');
	
	      (0, _assert2.default)(typeof value === 'number', 'The "value" argument in toBeGreaterThan(value) must be a number');
	
	      (0, _assert2.default)(this.actual > value, message || 'Expected %s to be greater than %s', this.actual, value);
	
	      return this;
	    }
	  }, {
	    key: 'toBeGreaterThanOrEqualTo',
	    value: function toBeGreaterThanOrEqualTo(value, message) {
	      (0, _assert2.default)(typeof this.actual === 'number', 'The "actual" argument in expect(actual).toBeGreaterThanOrEqualTo() must be a number');
	
	      (0, _assert2.default)(typeof value === 'number', 'The "value" argument in toBeGreaterThanOrEqualTo(value) must be a number');
	
	      (0, _assert2.default)(this.actual >= value, message || 'Expected %s to be greater than or equal to %s', this.actual, value);
	
	      return this;
	    }
	  }, {
	    key: 'toInclude',
	    value: function toInclude(value, compareValues, message) {
	      (0, _assert2.default)((0, _TestUtils.isArray)(this.actual) || (0, _TestUtils.isObject)(this.actual) || typeof this.actual === 'string', 'The "actual" argument in expect(actual).toInclude() must be an array, object, or a string');
	
	      if (typeof compareValues === 'string') {
	        message = compareValues;
	        compareValues = null;
	      }
	
	      message = message || 'Expected %s to include %s';
	
	      if ((0, _TestUtils.isArray)(this.actual)) {
	        (0, _assert2.default)((0, _TestUtils.arrayContains)(this.actual, value, compareValues), message, this.actual, value);
	      } else if ((0, _TestUtils.isObject)(this.actual)) {
	        (0, _assert2.default)((0, _TestUtils.objectContains)(this.actual, value, compareValues), message, this.actual, value);
	      } else {
	        (0, _assert2.default)((0, _TestUtils.stringContains)(this.actual, value), message, this.actual, value);
	      }
	
	      return this;
	    }
	  }, {
	    key: 'toExclude',
	    value: function toExclude(value, compareValues, message) {
	      (0, _assert2.default)((0, _TestUtils.isArray)(this.actual) || typeof this.actual === 'string', 'The "actual" argument in expect(actual).toExclude() must be an array or a string');
	
	      if (typeof compareValues === 'string') {
	        message = compareValues;
	        compareValues = null;
	      }
	
	      message = message || 'Expected %s to exclude %s';
	
	      if ((0, _TestUtils.isArray)(this.actual)) {
	        (0, _assert2.default)(!(0, _TestUtils.arrayContains)(this.actual, value, compareValues), message, this.actual, value);
	      } else {
	        (0, _assert2.default)(!(0, _TestUtils.stringContains)(this.actual, value), message, this.actual, value);
	      }
	
	      return this;
	    }
	  }, {
	    key: 'toHaveBeenCalled',
	    value: function toHaveBeenCalled(message) {
	      var spy = this.actual;
	
	      (0, _assert2.default)((0, _SpyUtils.isSpy)(spy), 'The "actual" argument in expect(actual).toHaveBeenCalled() must be a spy');
	
	      (0, _assert2.default)(spy.calls.length > 0, message || 'spy was not called');
	
	      return this;
	    }
	  }, {
	    key: 'toHaveBeenCalledWith',
	    value: function toHaveBeenCalledWith() {
	      for (var _len = arguments.length, expectedArgs = Array(_len), _key = 0; _key < _len; _key++) {
	        expectedArgs[_key] = arguments[_key];
	      }
	
	      var spy = this.actual;
	
	      (0, _assert2.default)((0, _SpyUtils.isSpy)(spy), 'The "actual" argument in expect(actual).toHaveBeenCalledWith() must be a spy');
	
	      (0, _assert2.default)(spy.calls.some(function (call) {
	        return (0, _isEqual2.default)(call.arguments, expectedArgs);
	      }), 'spy was never called with %s', expectedArgs);
	
	      return this;
	    }
	  }, {
	    key: 'toNotHaveBeenCalled',
	    value: function toNotHaveBeenCalled(message) {
	      var spy = this.actual;
	
	      (0, _assert2.default)((0, _SpyUtils.isSpy)(spy), 'The "actual" argument in expect(actual).toNotHaveBeenCalled() must be a spy');
	
	      (0, _assert2.default)(spy.calls.length === 0, message || 'spy was not supposed to be called');
	
	      return this;
	    }
	  }, {
	    key: 'withContext',
	    value: function withContext(context) {
	      (0, _assert2.default)((0, _TestUtils.isFunction)(this.actual), 'The "actual" argument in expect(actual).withContext() must be a function');
	
	      this.context = context;
	
	      return this;
	    }
	  }, {
	    key: 'withArgs',
	    value: function withArgs() {
	      var _args;
	
	      (0, _assert2.default)((0, _TestUtils.isFunction)(this.actual), 'The "actual" argument in expect(actual).withArgs() must be a function');
	
	      if (arguments.length) this.args = (_args = this.args).concat.apply(_args, arguments);
	
	      return this;
	    }
	  }]);
	
	  return Expectation;
	}();
	
	var aliases = {
	  toBeAn: 'toBeA',
	  toNotBeAn: 'toNotBeA',
	  toBeTruthy: 'toExist',
	  toBeFalsy: 'toNotExist',
	  toBeFewerThan: 'toBeLessThan',
	  toBeMoreThan: 'toBeGreaterThan',
	  toContain: 'toInclude',
	  toNotContain: 'toExclude'
	};
	
	for (var alias in aliases) {
	  if (aliases.hasOwnProperty(alias)) Expectation.prototype[alias] = Expectation.prototype[aliases[alias]];
	}exports.default = Expectation;

/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var whyNotEqual = __webpack_require__(6);
	
	module.exports = function isEqual(value, other) {
		return whyNotEqual(value, other) === '';
	};


/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var ObjectPrototype = Object.prototype;
	var toStr = ObjectPrototype.toString;
	var booleanValue = Boolean.prototype.valueOf;
	var has = __webpack_require__(7);
	var isArrowFunction = __webpack_require__(10);
	var isBoolean = __webpack_require__(12);
	var isDate = __webpack_require__(13);
	var isGenerator = __webpack_require__(14);
	var isNumber = __webpack_require__(15);
	var isRegex = __webpack_require__(16);
	var isString = __webpack_require__(17);
	var isSymbol = __webpack_require__(18);
	var isCallable = __webpack_require__(11);
	
	var isProto = Object.prototype.isPrototypeOf;
	
	var foo = function foo() {};
	var functionsHaveNames = foo.name === 'foo';
	
	var symbolValue = typeof Symbol === 'function' ? Symbol.prototype.valueOf : null;
	var symbolIterator = __webpack_require__(19)();
	
	var collectionsForEach = __webpack_require__(20)();
	
	var getPrototypeOf = Object.getPrototypeOf;
	if (!getPrototypeOf) {
		/* eslint-disable no-proto */
		if (typeof 'test'.__proto__ === 'object') {
			getPrototypeOf = function (obj) {
				return obj.__proto__;
			};
		} else {
			getPrototypeOf = function (obj) {
				var constructor = obj.constructor,
					oldConstructor;
				if (has(obj, 'constructor')) {
					oldConstructor = constructor;
					if (!(delete obj.constructor)) { // reset constructor
						return null; // can't delete obj.constructor, return null
					}
					constructor = obj.constructor; // get real constructor
					obj.constructor = oldConstructor; // restore constructor
				}
				return constructor ? constructor.prototype : ObjectPrototype; // needed for IE
			};
		}
		/* eslint-enable no-proto */
	}
	
	var isArray = Array.isArray || function (value) {
		return toStr.call(value) === '[object Array]';
	};
	
	var normalizeFnWhitespace = function normalizeFnWhitespace(fnStr) {
		// this is needed in IE 9, at least, which has inconsistencies here.
		return fnStr.replace(/^function ?\(/, 'function (').replace('){', ') {');
	};
	
	var tryMapSetEntries = function tryMapSetEntries(collection) {
		var foundEntries = [];
		try {
			collectionsForEach.Map.call(collection, function (key, value) {
				foundEntries.push([key, value]);
			});
		} catch (notMap) {
			try {
				collectionsForEach.Set.call(collection, function (value) {
					foundEntries.push([value]);
				});
			} catch (notSet) {
				return false;
			}
		}
		return foundEntries;
	};
	
	module.exports = function whyNotEqual(value, other) {
		if (value === other) { return ''; }
		if (value == null || other == null) {
			return value === other ? '' : String(value) + ' !== ' + String(other);
		}
	
		var valToStr = toStr.call(value);
		var otherToStr = toStr.call(value);
		if (valToStr !== otherToStr) {
			return 'toStringTag is not the same: ' + valToStr + ' !== ' + otherToStr;
		}
	
		var valIsBool = isBoolean(value);
		var otherIsBool = isBoolean(other);
		if (valIsBool || otherIsBool) {
			if (!valIsBool) { return 'first argument is not a boolean; second argument is'; }
			if (!otherIsBool) { return 'second argument is not a boolean; first argument is'; }
			var valBoolVal = booleanValue.call(value);
			var otherBoolVal = booleanValue.call(other);
			if (valBoolVal === otherBoolVal) { return ''; }
			return 'primitive value of boolean arguments do not match: ' + valBoolVal + ' !== ' + otherBoolVal;
		}
	
		var valIsNumber = isNumber(value);
		var otherIsNumber = isNumber(value);
		if (valIsNumber || otherIsNumber) {
			if (!valIsNumber) { return 'first argument is not a number; second argument is'; }
			if (!otherIsNumber) { return 'second argument is not a number; first argument is'; }
			var valNum = Number(value);
			var otherNum = Number(other);
			if (valNum === otherNum) { return ''; }
			var valIsNaN = isNaN(value);
			var otherIsNaN = isNaN(other);
			if (valIsNaN && !otherIsNaN) {
				return 'first argument is NaN; second is not';
			} else if (!valIsNaN && otherIsNaN) {
				return 'second argument is NaN; first is not';
			} else if (valIsNaN && otherIsNaN) {
				return '';
			}
			return 'numbers are different: ' + value + ' !== ' + other;
		}
	
		var valIsString = isString(value);
		var otherIsString = isString(other);
		if (valIsString || otherIsString) {
			if (!valIsString) { return 'second argument is string; first is not'; }
			if (!otherIsString) { return 'first argument is string; second is not'; }
			var stringVal = String(value);
			var otherVal = String(other);
			if (stringVal === otherVal) { return ''; }
			return 'string values are different: "' + stringVal + '" !== "' + otherVal + '"';
		}
	
		var valIsDate = isDate(value);
		var otherIsDate = isDate(other);
		if (valIsDate || otherIsDate) {
			if (!valIsDate) { return 'second argument is Date, first is not'; }
			if (!otherIsDate) { return 'first argument is Date, second is not'; }
			var valTime = +value;
			var otherTime = +other;
			if (valTime === otherTime) { return ''; }
			return 'Dates have different time values: ' + valTime + ' !== ' + otherTime;
		}
	
		var valIsRegex = isRegex(value);
		var otherIsRegex = isRegex(other);
		if (valIsRegex || otherIsRegex) {
			if (!valIsRegex) { return 'second argument is RegExp, first is not'; }
			if (!otherIsRegex) { return 'first argument is RegExp, second is not'; }
			var regexStringVal = String(value);
			var regexStringOther = String(other);
			if (regexStringVal === regexStringOther) { return ''; }
			return 'regular expressions differ: ' + regexStringVal + ' !== ' + regexStringOther;
		}
	
		var valIsArray = isArray(value);
		var otherIsArray = isArray(other);
		if (valIsArray || otherIsArray) {
			if (!valIsArray) { return 'second argument is an Array, first is not'; }
			if (!otherIsArray) { return 'first argument is an Array, second is not'; }
			if (value.length !== other.length) {
				return 'arrays have different length: ' + value.length + ' !== ' + other.length;
			}
			if (String(value) !== String(other)) { return 'stringified Arrays differ'; }
	
			var index = value.length - 1;
			var equal = '';
			var valHasIndex, otherHasIndex;
			while (equal === '' && index >= 0) {
				valHasIndex = has(value, index);
				otherHasIndex = has(other, index);
				if (!valHasIndex && otherHasIndex) { return 'second argument has index ' + index + '; first does not'; }
				if (valHasIndex && !otherHasIndex) { return 'first argument has index ' + index + '; second does not'; }
				equal = whyNotEqual(value[index], other[index]);
				index -= 1;
			}
			return equal;
		}
	
		var valueIsSym = isSymbol(value);
		var otherIsSym = isSymbol(other);
		if (valueIsSym !== otherIsSym) {
			if (valueIsSym) { return 'first argument is Symbol; second is not'; }
			return 'second argument is Symbol; first is not';
		}
		if (valueIsSym && otherIsSym) {
			return symbolValue.call(value) === symbolValue.call(other) ? '' : 'first Symbol value !== second Symbol value';
		}
	
		var valueIsGen = isGenerator(value);
		var otherIsGen = isGenerator(other);
		if (valueIsGen !== otherIsGen) {
			if (valueIsGen) { return 'first argument is a Generator; second is not'; }
			return 'second argument is a Generator; first is not';
		}
	
		var valueIsArrow = isArrowFunction(value);
		var otherIsArrow = isArrowFunction(other);
		if (valueIsArrow !== otherIsArrow) {
			if (valueIsArrow) { return 'first argument is an Arrow function; second is not'; }
			return 'second argument is an Arrow function; first is not';
		}
	
		if (isCallable(value) || isCallable(other)) {
			if (functionsHaveNames && whyNotEqual(value.name, other.name) !== '') {
				return 'Function names differ: "' + value.name + '" !== "' + other.name + '"';
			}
			if (whyNotEqual(value.length, other.length) !== '') {
				return 'Function lengths differ: ' + value.length + ' !== ' + other.length;
			}
	
			var valueStr = normalizeFnWhitespace(String(value));
			var otherStr = normalizeFnWhitespace(String(other));
			if (whyNotEqual(valueStr, otherStr) === '') { return ''; }
	
			if (!valueIsGen && !valueIsArrow) {
				return whyNotEqual(valueStr.replace(/\)\s*\{/, '){'), otherStr.replace(/\)\s*\{/, '){')) === '' ? '' : 'Function string representations differ';
			}
			return whyNotEqual(valueStr, otherStr) === '' ? '' : 'Function string representations differ';
		}
	
		if (typeof value === 'object' || typeof other === 'object') {
			if (typeof value !== typeof other) { return 'arguments have a different typeof: ' + typeof value + ' !== ' + typeof other; }
			if (isProto.call(value, other)) { return 'first argument is the [[Prototype]] of the second'; }
			if (isProto.call(other, value)) { return 'second argument is the [[Prototype]] of the first'; }
			if (getPrototypeOf(value) !== getPrototypeOf(other)) { return 'arguments have a different [[Prototype]]'; }
	
			if (symbolIterator) {
				var valueIteratorFn = value[symbolIterator];
				var valueIsIterable = isCallable(valueIteratorFn);
				var otherIteratorFn = other[symbolIterator];
				var otherIsIterable = isCallable(otherIteratorFn);
				if (valueIsIterable !== otherIsIterable) {
					if (valueIsIterable) { return 'first argument is iterable; second is not'; }
					return 'second argument is iterable; first is not';
				}
				if (valueIsIterable && otherIsIterable) {
					var valueIterator = valueIteratorFn.call(value);
					var otherIterator = otherIteratorFn.call(other);
					var valueNext, otherNext, nextWhy;
					do {
						valueNext = valueIterator.next();
						otherNext = otherIterator.next();
						if (!valueNext.done && !otherNext.done) {
							nextWhy = whyNotEqual(valueNext, otherNext);
							if (nextWhy !== '') {
								return 'iteration results are not equal: ' + nextWhy;
							}
						}
					} while (!valueNext.done && !otherNext.done);
					if (valueNext.done && !otherNext.done) { return 'first argument finished iterating before second'; }
					if (!valueNext.done && otherNext.done) { return 'second argument finished iterating before first'; }
					return '';
				}
			} else if (collectionsForEach.Map || collectionsForEach.Set) {
				var valueEntries = tryMapSetEntries(value);
				var otherEntries = tryMapSetEntries(other);
				var valueEntriesIsArray = isArray(valueEntries);
				var otherEntriesIsArray = isArray(otherEntries);
				if (valueEntriesIsArray && !otherEntriesIsArray) { return 'first argument has Collection entries, second does not'; }
				if (!valueEntriesIsArray && otherEntriesIsArray) { return 'second argument has Collection entries, first does not'; }
				if (valueEntriesIsArray && otherEntriesIsArray) {
					var entriesWhy = whyNotEqual(valueEntries, otherEntries);
					return entriesWhy === '' ? '' : 'Collection entries differ: ' + entriesWhy;
				}
			}
	
			var key, valueKeyIsRecursive, otherKeyIsRecursive, keyWhy;
			for (key in value) {
				if (has(value, key)) {
					if (!has(other, key)) { return 'first argument has key "' + key + '"; second does not'; }
					valueKeyIsRecursive = value[key] && value[key][key] === value;
					otherKeyIsRecursive = other[key] && other[key][key] === other;
					if (valueKeyIsRecursive !== otherKeyIsRecursive) {
						if (valueKeyIsRecursive) { return 'first argument has a circular reference at key "' + key + '"; second does not'; }
						return 'second argument has a circular reference at key "' + key + '"; first does not';
					}
					if (!valueKeyIsRecursive && !otherKeyIsRecursive) {
						keyWhy = whyNotEqual(value[key], other[key]);
						if (keyWhy !== '') {
							return 'value at key "' + key + '" differs: ' + keyWhy;
						}
					}
				}
			}
			for (key in other) {
				if (has(other, key) && !has(value, key)) { return 'second argument has key "' + key + '"; first does not'; }
			}
			return '';
		}
	
		return false;
	};


/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	var bind = __webpack_require__(8);
	
	module.exports = bind.call(Function.call, Object.prototype.hasOwnProperty);


/***/ },
/* 8 */
/***/ function(module, exports, __webpack_require__) {

	var implementation = __webpack_require__(9);
	
	module.exports = Function.prototype.bind || implementation;


/***/ },
/* 9 */
/***/ function(module, exports) {

	var ERROR_MESSAGE = 'Function.prototype.bind called on incompatible ';
	var slice = Array.prototype.slice;
	var toStr = Object.prototype.toString;
	var funcType = '[object Function]';
	
	module.exports = function bind(that) {
	    var target = this;
	    if (typeof target !== 'function' || toStr.call(target) !== funcType) {
	        throw new TypeError(ERROR_MESSAGE + target);
	    }
	    var args = slice.call(arguments, 1);
	
	    var bound;
	    var binder = function () {
	        if (this instanceof bound) {
	            var result = target.apply(
	                this,
	                args.concat(slice.call(arguments))
	            );
	            if (Object(result) === result) {
	                return result;
	            }
	            return this;
	        } else {
	            return target.apply(
	                that,
	                args.concat(slice.call(arguments))
	            );
	        }
	    };
	
	    var boundLength = Math.max(0, target.length - args.length);
	    var boundArgs = [];
	    for (var i = 0; i < boundLength; i++) {
	        boundArgs.push('$' + i);
	    }
	
	    bound = Function('binder', 'return function (' + boundArgs.join(',') + '){ return binder.apply(this,arguments); }')(binder);
	
	    if (target.prototype) {
	        var Empty = function Empty() {};
	        Empty.prototype = target.prototype;
	        bound.prototype = new Empty();
	        Empty.prototype = null;
	    }
	
	    return bound;
	};


/***/ },
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var isCallable = __webpack_require__(11);
	var fnToStr = Function.prototype.toString;
	var isNonArrowFnRegex = /^\s*function/;
	var isArrowFnWithParensRegex = /^\([^\)]*\) *=>/;
	var isArrowFnWithoutParensRegex = /^[^=]*=>/;
	
	module.exports = function isArrowFunction(fn) {
		if (!isCallable(fn)) { return false; }
		var fnStr = fnToStr.call(fn);
		return fnStr.length > 0 &&
			!isNonArrowFnRegex.test(fnStr) &&
			(isArrowFnWithParensRegex.test(fnStr) || isArrowFnWithoutParensRegex.test(fnStr));
	};


/***/ },
/* 11 */
/***/ function(module, exports) {

	'use strict';
	
	var fnToStr = Function.prototype.toString;
	
	var constructorRegex = /^\s*class /;
	var isES6ClassFn = function isES6ClassFn(value) {
		try {
			var fnStr = fnToStr.call(value);
			var singleStripped = fnStr.replace(/\/\/.*\n/g, '');
			var multiStripped = singleStripped.replace(/\/\*[.\s\S]*\*\//g, '');
			var spaceStripped = multiStripped.replace(/\n/mg, ' ').replace(/ {2}/g, ' ');
			return constructorRegex.test(spaceStripped);
		} catch (e) {
			return false; // not a function
		}
	};
	
	var tryFunctionObject = function tryFunctionObject(value) {
		try {
			if (isES6ClassFn(value)) { return false; }
			fnToStr.call(value);
			return true;
		} catch (e) {
			return false;
		}
	};
	var toStr = Object.prototype.toString;
	var fnClass = '[object Function]';
	var genClass = '[object GeneratorFunction]';
	var hasToStringTag = typeof Symbol === 'function' && typeof Symbol.toStringTag === 'symbol';
	
	module.exports = function isCallable(value) {
		if (!value) { return false; }
		if (typeof value !== 'function' && typeof value !== 'object') { return false; }
		if (hasToStringTag) { return tryFunctionObject(value); }
		if (isES6ClassFn(value)) { return false; }
		var strClass = toStr.call(value);
		return strClass === fnClass || strClass === genClass;
	};


/***/ },
/* 12 */
/***/ function(module, exports) {

	'use strict';
	
	var boolToStr = Boolean.prototype.toString;
	
	var tryBooleanObject = function tryBooleanObject(value) {
		try {
			boolToStr.call(value);
			return true;
		} catch (e) {
			return false;
		}
	};
	var toStr = Object.prototype.toString;
	var boolClass = '[object Boolean]';
	var hasToStringTag = typeof Symbol === 'function' && typeof Symbol.toStringTag === 'symbol';
	
	module.exports = function isBoolean(value) {
		if (typeof value === 'boolean') { return true; }
		if (typeof value !== 'object') { return false; }
		return hasToStringTag ? tryBooleanObject(value) : toStr.call(value) === boolClass;
	};


/***/ },
/* 13 */
/***/ function(module, exports) {

	'use strict';
	
	var getDay = Date.prototype.getDay;
	var tryDateObject = function tryDateObject(value) {
		try {
			getDay.call(value);
			return true;
		} catch (e) {
			return false;
		}
	};
	
	var toStr = Object.prototype.toString;
	var dateClass = '[object Date]';
	var hasToStringTag = typeof Symbol === 'function' && typeof Symbol.toStringTag === 'symbol';
	
	module.exports = function isDateObject(value) {
		if (typeof value !== 'object' || value === null) { return false; }
		return hasToStringTag ? tryDateObject(value) : toStr.call(value) === dateClass;
	};


/***/ },
/* 14 */
/***/ function(module, exports) {

	'use strict';
	
	var toStr = Object.prototype.toString;
	var fnToStr = Function.prototype.toString;
	var isFnRegex = /^\s*function\*/;
	
	module.exports = function isGeneratorFunction(fn) {
		if (typeof fn !== 'function') { return false; }
		var fnStr = toStr.call(fn);
		return (fnStr === '[object Function]' || fnStr === '[object GeneratorFunction]') && isFnRegex.test(fnToStr.call(fn));
	};
	


/***/ },
/* 15 */
/***/ function(module, exports) {

	'use strict';
	
	var numToStr = Number.prototype.toString;
	var tryNumberObject = function tryNumberObject(value) {
		try {
			numToStr.call(value);
			return true;
		} catch (e) {
			return false;
		}
	};
	var toStr = Object.prototype.toString;
	var numClass = '[object Number]';
	var hasToStringTag = typeof Symbol === 'function' && typeof Symbol.toStringTag === 'symbol';
	
	module.exports = function isNumberObject(value) {
		if (typeof value === 'number') { return true; }
		if (typeof value !== 'object') { return false; }
		return hasToStringTag ? tryNumberObject(value) : toStr.call(value) === numClass;
	};


/***/ },
/* 16 */
/***/ function(module, exports) {

	'use strict';
	
	var regexExec = RegExp.prototype.exec;
	var tryRegexExec = function tryRegexExec(value) {
		try {
			regexExec.call(value);
			return true;
		} catch (e) {
			return false;
		}
	};
	var toStr = Object.prototype.toString;
	var regexClass = '[object RegExp]';
	var hasToStringTag = typeof Symbol === 'function' && typeof Symbol.toStringTag === 'symbol';
	
	module.exports = function isRegex(value) {
		if (typeof value !== 'object') { return false; }
		return hasToStringTag ? tryRegexExec(value) : toStr.call(value) === regexClass;
	};


/***/ },
/* 17 */
/***/ function(module, exports) {

	'use strict';
	
	var strValue = String.prototype.valueOf;
	var tryStringObject = function tryStringObject(value) {
		try {
			strValue.call(value);
			return true;
		} catch (e) {
			return false;
		}
	};
	var toStr = Object.prototype.toString;
	var strClass = '[object String]';
	var hasToStringTag = typeof Symbol === 'function' && typeof Symbol.toStringTag === 'symbol';
	
	module.exports = function isString(value) {
		if (typeof value === 'string') { return true; }
		if (typeof value !== 'object') { return false; }
		return hasToStringTag ? tryStringObject(value) : toStr.call(value) === strClass;
	};


/***/ },
/* 18 */
/***/ function(module, exports) {

	'use strict';
	
	var toStr = Object.prototype.toString;
	var hasSymbols = typeof Symbol === 'function' && typeof Symbol() === 'symbol';
	
	if (hasSymbols) {
		var symToStr = Symbol.prototype.toString;
		var symStringRegex = /^Symbol\(.*\)$/;
		var isSymbolObject = function isSymbolObject(value) {
			if (typeof value.valueOf() !== 'symbol') { return false; }
			return symStringRegex.test(symToStr.call(value));
		};
		module.exports = function isSymbol(value) {
			if (typeof value === 'symbol') { return true; }
			if (toStr.call(value) !== '[object Symbol]') { return false; }
			try {
				return isSymbolObject(value);
			} catch (e) {
				return false;
			}
		};
	} else {
		module.exports = function isSymbol(value) {
			// this environment does not support Symbols.
			return false;
		};
	}


/***/ },
/* 19 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var isSymbol = __webpack_require__(18);
	
	module.exports = function getSymbolIterator() {
		var symbolIterator = typeof Symbol === 'function' && isSymbol(Symbol.iterator) ? Symbol.iterator : null;
	
		if (typeof Object.getOwnPropertyNames === 'function' && typeof Map === 'function' && typeof Map.prototype.entries === 'function') {
			Object.getOwnPropertyNames(Map.prototype).forEach(function (name) {
				if (name !== 'entries' && name !== 'size' && Map.prototype[name] === Map.prototype.entries) {
					symbolIterator = name;
				}
			});
		}
	
		return symbolIterator;
	};


/***/ },
/* 20 */
/***/ function(module, exports) {

	'use strict';
	
	module.exports = function () {
		var mapForEach = (function () {
			if (typeof Map !== 'function') { return null; }
			try {
				Map.prototype.forEach.call({}, function () {});
			} catch (e) {
				return Map.prototype.forEach;
			}
			return null;
		}());
	
		var setForEach = (function () {
			if (typeof Set !== 'function') { return null; }
			try {
				Set.prototype.forEach.call({}, function () {});
			} catch (e) {
				return Set.prototype.forEach;
			}
			return null;
		}());
	
		return { Map: mapForEach, Set: setForEach };
	};


/***/ },
/* 21 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _objectInspect = __webpack_require__(22);
	
	var _objectInspect2 = _interopRequireDefault(_objectInspect);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function assert(condition, messageFormat) {
	  for (var _len = arguments.length, extraArgs = Array(_len > 2 ? _len - 2 : 0), _key = 2; _key < _len; _key++) {
	    extraArgs[_key - 2] = arguments[_key];
	  }
	
	  if (condition) return;
	
	  var index = 0;
	
	  throw new Error(messageFormat.replace(/%s/g, function () {
	    return (0, _objectInspect2.default)(extraArgs[index++]);
	  }));
	}
	
	exports.default = assert;

/***/ },
/* 22 */
/***/ function(module, exports) {

	var hasMap = typeof Map === 'function' && Map.prototype;
	var mapSizeDescriptor = Object.getOwnPropertyDescriptor && hasMap ? Object.getOwnPropertyDescriptor(Map.prototype, 'size') : null;
	var mapSize = hasMap && mapSizeDescriptor && typeof mapSizeDescriptor.get === 'function' ? mapSizeDescriptor.get : null;
	var mapForEach = hasMap && Map.prototype.forEach;
	var hasSet = typeof Set === 'function' && Set.prototype;
	var setSizeDescriptor = Object.getOwnPropertyDescriptor && hasSet ? Object.getOwnPropertyDescriptor(Set.prototype, 'size') : null;
	var setSize = hasSet && setSizeDescriptor && typeof setSizeDescriptor.get === 'function' ? setSizeDescriptor.get : null;
	var setForEach = hasSet && Set.prototype.forEach;
	
	module.exports = function inspect_ (obj, opts, depth, seen) {
	    if (!opts) opts = {};
	    
	    var maxDepth = opts.depth === undefined ? 5 : opts.depth;
	    if (depth === undefined) depth = 0;
	    if (depth >= maxDepth && maxDepth > 0
	    && obj && typeof obj === 'object') {
	        return '[Object]';
	    }
	    
	    if (seen === undefined) seen = [];
	    else if (indexOf(seen, obj) >= 0) {
	        return '[Circular]';
	    }
	    
	    function inspect (value, from) {
	        if (from) {
	            seen = seen.slice();
	            seen.push(from);
	        }
	        return inspect_(value, opts, depth + 1, seen);
	    }
	    
	    if (typeof obj === 'string') {
	        return inspectString(obj);
	    }
	    else if (typeof obj === 'function') {
	        var name = nameOf(obj);
	        return '[Function' + (name ? ': ' + name : '') + ']';
	    }
	    else if (obj === null) {
	        return 'null';
	    }
	    else if (isSymbol(obj)) {
	        var symString = Symbol.prototype.toString.call(obj);
	        return typeof obj === 'object' ? 'Object(' + symString + ')' : symString;
	    }
	    else if (isElement(obj)) {
	        var s = '<' + String(obj.nodeName).toLowerCase();
	        var attrs = obj.attributes || [];
	        for (var i = 0; i < attrs.length; i++) {
	            s += ' ' + attrs[i].name + '="' + quote(attrs[i].value) + '"';
	        }
	        s += '>';
	        if (obj.childNodes && obj.childNodes.length) s += '...';
	        s += '</' + String(obj.nodeName).toLowerCase() + '>';
	        return s;
	    }
	    else if (isArray(obj)) {
	        if (obj.length === 0) return '[]';
	        var xs = Array(obj.length);
	        for (var i = 0; i < obj.length; i++) {
	            xs[i] = has(obj, i) ? inspect(obj[i], obj) : '';
	        }
	        return '[ ' + xs.join(', ') + ' ]';
	    }
	    else if (isError(obj)) {
	        var parts = [];
	        for (var key in obj) {
	            if (!has(obj, key)) continue;
	            
	            if (/[^\w$]/.test(key)) {
	                parts.push(inspect(key) + ': ' + inspect(obj[key]));
	            }
	            else {
	                parts.push(key + ': ' + inspect(obj[key]));
	            }
	        }
	        if (parts.length === 0) return '[' + obj + ']';
	        return '{ [' + obj + '] ' + parts.join(', ') + ' }';
	    }
	    else if (typeof obj === 'object' && typeof obj.inspect === 'function') {
	        return obj.inspect();
	    }
	    else if (isMap(obj)) {
	        var parts = [];
	        mapForEach.call(obj, function (value, key) {
	            parts.push(inspect(key, obj) + ' => ' + inspect(value, obj));
	        });
	        return 'Map (' + mapSize.call(obj) + ') {' + parts.join(', ') + '}';
	    }
	    else if (isSet(obj)) {
	        var parts = [];
	        setForEach.call(obj, function (value ) {
	            parts.push(inspect(value, obj));
	        });
	        return 'Set (' + setSize.call(obj) + ') {' + parts.join(', ') + '}';
	    }
	    else if (typeof obj === 'object' && !isDate(obj) && !isRegExp(obj)) {
	        var xs = [], keys = [];
	        for (var key in obj) {
	            if (has(obj, key)) keys.push(key);
	        }
	        keys.sort();
	        for (var i = 0; i < keys.length; i++) {
	            var key = keys[i];
	            if (/[^\w$]/.test(key)) {
	                xs.push(inspect(key) + ': ' + inspect(obj[key], obj));
	            }
	            else xs.push(key + ': ' + inspect(obj[key], obj));
	        }
	        if (xs.length === 0) return '{}';
	        return '{ ' + xs.join(', ') + ' }';
	    }
	    else return String(obj);
	};
	
	function quote (s) {
	    return String(s).replace(/"/g, '&quot;');
	}
	
	function isArray (obj) { return toStr(obj) === '[object Array]' }
	function isDate (obj) { return toStr(obj) === '[object Date]' }
	function isRegExp (obj) { return toStr(obj) === '[object RegExp]' }
	function isError (obj) { return toStr(obj) === '[object Error]' }
	function isSymbol (obj) { return toStr(obj) === '[object Symbol]' }
	
	var hasOwn = Object.prototype.hasOwnProperty || function (key) { return key in this; };
	function has (obj, key) {
	    return hasOwn.call(obj, key);
	}
	
	function toStr (obj) {
	    return Object.prototype.toString.call(obj);
	}
	
	function nameOf (f) {
	    if (f.name) return f.name;
	    var m = f.toString().match(/^function\s*([\w$]+)/);
	    if (m) return m[1];
	}
	
	function indexOf (xs, x) {
	    if (xs.indexOf) return xs.indexOf(x);
	    for (var i = 0, l = xs.length; i < l; i++) {
	        if (xs[i] === x) return i;
	    }
	    return -1;
	}
	
	function isMap (x) {
	    if (!mapSize) {
	        return false;
	    }
	    try {
	        mapSize.call(x);
	        return true;
	    } catch (e) {}
	    return false;
	}
	
	function isSet (x) {
	    if (!setSize) {
	        return false;
	    }
	    try {
	        setSize.call(x);
	        return true;
	    } catch (e) {}
	    return false;
	}
	
	function isElement (x) {
	    if (!x || typeof x !== 'object') return false;
	    if (typeof HTMLElement !== 'undefined' && x instanceof HTMLElement) {
	        return true;
	    }
	    return typeof x.nodeName === 'string'
	        && typeof x.getAttribute === 'function'
	    ;
	}
	
	function inspectString (str) {
	    var s = str.replace(/(['\\])/g, '\\$1').replace(/[\x00-\x1f]/g, lowbyte);
	    return "'" + s + "'";
	    
	    function lowbyte (c) {
	        var n = c.charCodeAt(0);
	        var x = { 8: 'b', 9: 't', 10: 'n', 12: 'f', 13: 'r' }[n];
	        if (x) return '\\' + x;
	        return '\\x' + (n < 0x10 ? '0' : '') + n.toString(16);
	    }
	}


/***/ },
/* 23 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.restoreSpies = exports.isSpy = undefined;
	exports.createSpy = createSpy;
	exports.spyOn = spyOn;
	
	var _assert = __webpack_require__(21);
	
	var _assert2 = _interopRequireDefault(_assert);
	
	var _TestUtils = __webpack_require__(24);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	/* eslint-disable prefer-rest-params */
	
	
	var noop = function noop() {};
	
	var isSpy = exports.isSpy = function isSpy(object) {
	  return object && object.__isSpy === true;
	};
	
	var spies = [];
	
	var restoreSpies = exports.restoreSpies = function restoreSpies() {
	  for (var i = spies.length - 1; i >= 0; i--) {
	    spies[i].restore();
	  }spies = [];
	};
	
	function createSpy(fn) {
	  var restore = arguments.length <= 1 || arguments[1] === undefined ? noop : arguments[1];
	
	  if (fn == null) fn = noop;
	
	  (0, _assert2.default)((0, _TestUtils.isFunction)(fn), 'createSpy needs a function');
	
	  var targetFn = void 0,
	      thrownValue = void 0,
	      returnValue = void 0;
	
	  var spy = function spy() {
	    spy.calls.push({
	      context: this,
	      arguments: Array.prototype.slice.call(arguments, 0)
	    });
	
	    if (targetFn) return targetFn.apply(this, arguments);
	
	    if (thrownValue) throw thrownValue;
	
	    return returnValue;
	  };
	
	  spy.calls = [];
	
	  spy.andCall = function (otherFn) {
	    targetFn = otherFn;
	    return spy;
	  };
	
	  spy.andCallThrough = function () {
	    return spy.andCall(fn);
	  };
	
	  spy.andThrow = function (object) {
	    thrownValue = object;
	    return spy;
	  };
	
	  spy.andReturn = function (value) {
	    returnValue = value;
	    return spy;
	  };
	
	  spy.getLastCall = function () {
	    return spy.calls[spy.calls.length - 1];
	  };
	
	  spy.reset = function () {
	    spy.calls = [];
	  };
	
	  spy.restore = spy.destroy = restore;
	
	  spy.__isSpy = true;
	
	  spies.push(spy);
	
	  return spy;
	}
	
	function spyOn(object, methodName) {
	  var original = object[methodName];
	
	  if (!isSpy(original)) {
	    (0, _assert2.default)((0, _TestUtils.isFunction)(original), 'Cannot spyOn the %s property; it is not a function', methodName);
	
	    object[methodName] = createSpy(original, function () {
	      object[methodName] = original;
	    });
	  }
	
	  return object[methodName];
	}

/***/ },
/* 24 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.stringContains = exports.objectContains = exports.arrayContains = exports.functionThrows = exports.isA = exports.isObject = exports.isArray = exports.isFunction = undefined;
	
	var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };
	
	var _isEqual = __webpack_require__(5);
	
	var _isEqual2 = _interopRequireDefault(_isEqual);
	
	var _isRegex = __webpack_require__(16);
	
	var _isRegex2 = _interopRequireDefault(_isRegex);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	/**
	 * Returns true if the given object is a function.
	 */
	var isFunction = exports.isFunction = function isFunction(object) {
	  return typeof object === 'function';
	};
	
	/**
	 * Returns true if the given object is an array.
	 */
	var isArray = exports.isArray = function isArray(object) {
	  return Array.isArray(object);
	};
	
	/**
	 * Returns true if the given object is an object.
	 */
	var isObject = exports.isObject = function isObject(object) {
	  return object && !isArray(object) && (typeof object === 'undefined' ? 'undefined' : _typeof(object)) === 'object';
	};
	
	/**
	 * Returns true if the given object is an instanceof value
	 * or its typeof is the given value.
	 */
	var isA = exports.isA = function isA(object, value) {
	  if (isFunction(value)) return object instanceof value;
	
	  if (value === 'array') return Array.isArray(object);
	
	  return (typeof object === 'undefined' ? 'undefined' : _typeof(object)) === value;
	};
	
	/**
	 * Returns true if the given function throws the given value
	 * when invoked. The value may be:
	 *
	 * - undefined, to merely assert there was a throw
	 * - a constructor function, for comparing using instanceof
	 * - a regular expression, to compare with the error message
	 * - a string, to find in the error message
	 */
	var functionThrows = exports.functionThrows = function functionThrows(fn, context, args, value) {
	  try {
	    fn.apply(context, args);
	  } catch (error) {
	    if (value == null) return true;
	
	    if (isFunction(value) && error instanceof value) return true;
	
	    var message = error.message || error;
	
	    if (typeof message === 'string') {
	      if ((0, _isRegex2.default)(value) && value.test(error.message)) return true;
	
	      if (typeof value === 'string' && message.indexOf(value) !== -1) return true;
	    }
	  }
	
	  return false;
	};
	
	/**
	 * Returns true if the given array contains the value, false
	 * otherwise. The compareValues function must return false to
	 * indicate a non-match.
	 */
	var arrayContains = exports.arrayContains = function arrayContains(array, value, compareValues) {
	  if (compareValues == null) compareValues = _isEqual2.default;
	
	  return array.some(function (item) {
	    return compareValues(item, value) !== false;
	  });
	};
	
	/**
	 * Returns true if the given object contains the value, false
	 * otherwise. The compareValues function must return false to
	 * indicate a non-match.
	 */
	var objectContains = exports.objectContains = function objectContains(object, value, compareValues) {
	  if (compareValues == null) compareValues = _isEqual2.default;
	
	  return Object.keys(value).every(function (k) {
	    if (isObject(object[k])) {
	      return objectContains(object[k], value[k], compareValues);
	    }
	
	    return compareValues(object[k], value[k]);
	  });
	};
	
	/**
	 * Returns true if the given string contains the value, false otherwise.
	 */
	var stringContains = exports.stringContains = function stringContains(string, value) {
	  return string.indexOf(value) !== -1;
	};

/***/ },
/* 25 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _Expectation = __webpack_require__(4);
	
	var _Expectation2 = _interopRequireDefault(_Expectation);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	var Extensions = [];
	
	function extend(extension) {
	  if (Extensions.indexOf(extension) === -1) {
	    Extensions.push(extension);
	
	    for (var p in extension) {
	      if (extension.hasOwnProperty(p)) _Expectation2.default.prototype[p] = extension[p];
	    }
	  }
	}
	
	exports.default = extend;

/***/ }
/******/ ]);
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAgNGQ1YjIxM2VmZDNjYTJjODU2OGQiLCJ3ZWJwYWNrOi8vLy4vN2JlM2U1MmFiMDUzYjVjYmYxMTA5ZTE0ZDYzY2I4NWUtZW50cnkuanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9zcGVjL2phdmFzY3JpcHRzL3VuaXQgb2JqZWN0IE9iamVjdCIsIndlYnBhY2s6Ly8vL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL3NwZWMvamF2YXNjcmlwdHMvdW5pdC91bml0X3Rlc3QuanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2V4cGVjdC9saWIvaW5kZXguanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2V4cGVjdC9saWIvRXhwZWN0YXRpb24uanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLWVxdWFsL2luZGV4LmpzIiwid2VicGFjazovLy8vVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9pcy1lcXVhbC93aHkuanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2hhcy9zcmMvaW5kZXguanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2Z1bmN0aW9uLWJpbmQvaW5kZXguanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2Z1bmN0aW9uLWJpbmQvaW1wbGVtZW50YXRpb24uanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLWFycm93LWZ1bmN0aW9uL2luZGV4LmpzIiwid2VicGFjazovLy8vVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9pcy1jYWxsYWJsZS9pbmRleC5qcyIsIndlYnBhY2s6Ly8vL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vaXMtYm9vbGVhbi1vYmplY3QvaW5kZXguanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLWRhdGUtb2JqZWN0L2luZGV4LmpzIiwid2VicGFjazovLy8vVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9pcy1nZW5lcmF0b3ItZnVuY3Rpb24vaW5kZXguanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLW51bWJlci1vYmplY3QvaW5kZXguanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLXJlZ2V4L2luZGV4LmpzIiwid2VicGFjazovLy8vVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9pcy1zdHJpbmcvaW5kZXguanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLXN5bWJvbC9pbmRleC5qcyIsIndlYnBhY2s6Ly8vL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vaXMtZXF1YWwvZ2V0U3ltYm9sSXRlcmF0b3IuanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLWVxdWFsL2dldENvbGxlY3Rpb25zRm9yRWFjaC5qcyIsIndlYnBhY2s6Ly8vL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vZXhwZWN0L2xpYi9hc3NlcnQuanMiLCJ3ZWJwYWNrOi8vLy9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L29iamVjdC1pbnNwZWN0L2luZGV4LmpzIiwid2VicGFjazovLy8vVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9leHBlY3QvbGliL1NweVV0aWxzLmpzIiwid2VicGFjazovLy8vVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9leHBlY3QvbGliL1Rlc3RVdGlscy5qcyIsIndlYnBhY2s6Ly8vL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vZXhwZWN0L2xpYi9leHRlbmQuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBO0FBQ0E7O0FBRUE7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBLHVCQUFlO0FBQ2Y7QUFDQTtBQUNBOztBQUVBO0FBQ0E7O0FBRUE7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7OztBQUdBO0FBQ0E7O0FBRUE7QUFDQTs7QUFFQTtBQUNBOztBQUVBO0FBQ0E7Ozs7Ozs7OztBQ3JDSSxLQUFJLGVBQWUsc0JBQStDOztBQUVsRSxLQUFJLFdBQVcsdUJBQWE7O0FBRTVCLG9CQUFpQjs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7QUNMckI7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSxrQ0FBaUMsdURBQXVEO0FBQ3hGO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOzs7Ozs7Ozs7QUNkQTs7Ozs7Ozs7QUFFQSxVQUFTO01BQ0osOEJBQ0Q7cUNBQU8sTUFBTSxLQUFLO0lBREMsRUFBckI7RUFEb0I7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7O0FDRnRCOztBQUVBOztBQUVBOztBQUVBOztBQUVBOztBQUVBOztBQUVBOztBQUVBOztBQUVBLHVDQUFzQyx1Q0FBdUMsZ0JBQWdCOztBQUU3RjtBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOztBQUVBLHlCOzs7Ozs7QUM3QkE7O0FBRUE7QUFDQTtBQUNBLEVBQUM7O0FBRUQsaUNBQWdDLDJDQUEyQyxnQkFBZ0Isa0JBQWtCLE9BQU8sMkJBQTJCLHdEQUF3RCxnQ0FBZ0MsdURBQXVELDJEQUEyRCxFQUFFLEVBQUUseURBQXlELHFFQUFxRSw2REFBNkQsb0JBQW9CLEdBQUcsRUFBRTs7QUFFampCOztBQUVBOztBQUVBOztBQUVBOztBQUVBOztBQUVBOztBQUVBOztBQUVBOztBQUVBLHVDQUFzQyx1Q0FBdUMsZ0JBQWdCOztBQUU3RixrREFBaUQsMENBQTBDLDBEQUEwRCxFQUFFOztBQUV2SjtBQUNBO0FBQ0E7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQTs7QUFFQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBO0FBQ0E7QUFDQSxRQUFPO0FBQ1A7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxJQUFHO0FBQ0g7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQTtBQUNBOztBQUVBOztBQUVBO0FBQ0E7QUFDQSxRQUFPO0FBQ1A7QUFDQSxRQUFPO0FBQ1A7QUFDQTs7QUFFQTtBQUNBO0FBQ0EsSUFBRztBQUNIO0FBQ0E7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQTs7QUFFQTs7QUFFQTtBQUNBO0FBQ0EsUUFBTztBQUNQO0FBQ0E7O0FBRUE7QUFDQTtBQUNBLElBQUc7QUFDSDtBQUNBO0FBQ0E7O0FBRUE7O0FBRUE7O0FBRUE7QUFDQTtBQUNBLElBQUc7QUFDSDtBQUNBO0FBQ0EsOEVBQTZFLGFBQWE7QUFDMUY7QUFDQTs7QUFFQTs7QUFFQTs7QUFFQTtBQUNBO0FBQ0EsUUFBTzs7QUFFUDtBQUNBO0FBQ0EsSUFBRztBQUNIO0FBQ0E7QUFDQTs7QUFFQTs7QUFFQTs7QUFFQTtBQUNBO0FBQ0EsSUFBRztBQUNIO0FBQ0E7QUFDQTs7QUFFQTs7QUFFQTtBQUNBO0FBQ0EsSUFBRztBQUNIO0FBQ0E7QUFDQTs7QUFFQTs7QUFFQTs7QUFFQTtBQUNBO0FBQ0EsSUFBRzs7QUFFSDtBQUNBLEVBQUM7O0FBRUQ7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBLEVBQUMsOEI7Ozs7OztBQzdURDs7QUFFQTs7QUFFQTtBQUNBO0FBQ0E7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QTtBQUNBO0FBQ0EsRzs7Ozs7O0FDcEhBOztBQUVBO0FBQ0E7QUFDQSxFQUFDOztBQUVEOztBQUVBOztBQUVBLHVDQUFzQyx1Q0FBdUMsZ0JBQWdCOztBQUU3Rjs7QUFFQTtBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTs7QUFFQSwwQiIsImZpbGUiOiI3YmUzZTUyYWIwNTNiNWNiZjExMDllMTRkNjNjYjg1ZS1vdXRwdXQuanMiLCJzb3VyY2VzQ29udGVudCI6WyIgXHQvLyBUaGUgbW9kdWxlIGNhY2hlXG4gXHR2YXIgaW5zdGFsbGVkTW9kdWxlcyA9IHt9O1xuXG4gXHQvLyBUaGUgcmVxdWlyZSBmdW5jdGlvblxuIFx0ZnVuY3Rpb24gX193ZWJwYWNrX3JlcXVpcmVfXyhtb2R1bGVJZCkge1xuXG4gXHRcdC8vIENoZWNrIGlmIG1vZHVsZSBpcyBpbiBjYWNoZVxuIFx0XHRpZihpbnN0YWxsZWRNb2R1bGVzW21vZHVsZUlkXSlcbiBcdFx0XHRyZXR1cm4gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0uZXhwb3J0cztcblxuIFx0XHQvLyBDcmVhdGUgYSBuZXcgbW9kdWxlIChhbmQgcHV0IGl0IGludG8gdGhlIGNhY2hlKVxuIFx0XHR2YXIgbW9kdWxlID0gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0gPSB7XG4gXHRcdFx0ZXhwb3J0czoge30sXG4gXHRcdFx0aWQ6IG1vZHVsZUlkLFxuIFx0XHRcdGxvYWRlZDogZmFsc2VcbiBcdFx0fTtcblxuIFx0XHQvLyBFeGVjdXRlIHRoZSBtb2R1bGUgZnVuY3Rpb25cbiBcdFx0bW9kdWxlc1ttb2R1bGVJZF0uY2FsbChtb2R1bGUuZXhwb3J0cywgbW9kdWxlLCBtb2R1bGUuZXhwb3J0cywgX193ZWJwYWNrX3JlcXVpcmVfXyk7XG5cbiBcdFx0Ly8gRmxhZyB0aGUgbW9kdWxlIGFzIGxvYWRlZFxuIFx0XHRtb2R1bGUubG9hZGVkID0gdHJ1ZTtcblxuIFx0XHQvLyBSZXR1cm4gdGhlIGV4cG9ydHMgb2YgdGhlIG1vZHVsZVxuIFx0XHRyZXR1cm4gbW9kdWxlLmV4cG9ydHM7XG4gXHR9XG5cblxuIFx0Ly8gZXhwb3NlIHRoZSBtb2R1bGVzIG9iamVjdCAoX193ZWJwYWNrX21vZHVsZXNfXylcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubSA9IG1vZHVsZXM7XG5cbiBcdC8vIGV4cG9zZSB0aGUgbW9kdWxlIGNhY2hlXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLmMgPSBpbnN0YWxsZWRNb2R1bGVzO1xuXG4gXHQvLyBfX3dlYnBhY2tfcHVibGljX3BhdGhfX1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5wID0gXCJcIjtcblxuIFx0Ly8gTG9hZCBlbnRyeSBtb2R1bGUgYW5kIHJldHVybiBleHBvcnRzXG4gXHRyZXR1cm4gX193ZWJwYWNrX3JlcXVpcmVfXygwKTtcblxuXG5cbi8qKiBXRUJQQUNLIEZPT1RFUiAqKlxuICoqIHdlYnBhY2svYm9vdHN0cmFwIDRkNWIyMTNlZmQzY2EyYzg1NjhkXG4gKiovIiwiXG4gICAgdmFyIHRlc3RzQ29udGV4dCA9IHJlcXVpcmUuY29udGV4dChcIi4uLy4uL3NwZWMvamF2YXNjcmlwdHMvdW5pdFwiLCBmYWxzZSk7XG5cbiAgICB2YXIgcnVubmFibGUgPSB0ZXN0c0NvbnRleHQua2V5cygpO1xuXG4gICAgcnVubmFibGUuZm9yRWFjaCh0ZXN0c0NvbnRleHQpO1xuICAgIFxuXG5cbi8qKiBXRUJQQUNLIEZPT1RFUiAqKlxuICoqIC4vN2JlM2U1MmFiMDUzYjVjYmYxMTA5ZTE0ZDYzY2I4NWUtZW50cnkuanNcbiAqKi8iLCJ2YXIgbWFwID0ge1xuXHRcIi4vdW5pdF90ZXN0LmpzXCI6IDJcbn07XG5mdW5jdGlvbiB3ZWJwYWNrQ29udGV4dChyZXEpIHtcblx0cmV0dXJuIF9fd2VicGFja19yZXF1aXJlX18od2VicGFja0NvbnRleHRSZXNvbHZlKHJlcSkpO1xufTtcbmZ1bmN0aW9uIHdlYnBhY2tDb250ZXh0UmVzb2x2ZShyZXEpIHtcblx0cmV0dXJuIG1hcFtyZXFdIHx8IChmdW5jdGlvbigpIHsgdGhyb3cgbmV3IEVycm9yKFwiQ2Fubm90IGZpbmQgbW9kdWxlICdcIiArIHJlcSArIFwiJy5cIikgfSgpKTtcbn07XG53ZWJwYWNrQ29udGV4dC5rZXlzID0gZnVuY3Rpb24gd2VicGFja0NvbnRleHRLZXlzKCkge1xuXHRyZXR1cm4gT2JqZWN0LmtleXMobWFwKTtcbn07XG53ZWJwYWNrQ29udGV4dC5yZXNvbHZlID0gd2VicGFja0NvbnRleHRSZXNvbHZlO1xubW9kdWxlLmV4cG9ydHMgPSB3ZWJwYWNrQ29udGV4dDtcbndlYnBhY2tDb250ZXh0LmlkID0gMTtcblxuXG5cbi8qKioqKioqKioqKioqKioqKlxuICoqIFdFQlBBQ0sgRk9PVEVSXG4gKiogL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL3NwZWMvamF2YXNjcmlwdHMvdW5pdCBvYmplY3QgT2JqZWN0XG4gKiogbW9kdWxlIGlkID0gMVxuICoqIG1vZHVsZSBjaHVua3MgPSAwXG4gKiovIiwiaW1wb3J0IGV4cGVjdCBmcm9tICdleHBlY3QnO1xuXG5kZXNjcmliZSgnVU5JVCBURVNUJywgKCkgPT4ge1xuICBpdCgnc2hvdWxkIGJlIHRydWUnLCAoKSA9PiB7XG4gICAgZXhwZWN0KHRydWUpLnRvQmUodHJ1ZSk7XG4gIH0pO1xufSk7XG5cblxuLyoqIFdFQlBBQ0sgRk9PVEVSICoqXG4gKiogL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL3NwZWMvamF2YXNjcmlwdHMvdW5pdC91bml0X3Rlc3QuanNcbiAqKi8iLCIndXNlIHN0cmljdCc7XG5cbnZhciBfRXhwZWN0YXRpb24gPSByZXF1aXJlKCcuL0V4cGVjdGF0aW9uJyk7XG5cbnZhciBfRXhwZWN0YXRpb24yID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfRXhwZWN0YXRpb24pO1xuXG52YXIgX1NweVV0aWxzID0gcmVxdWlyZSgnLi9TcHlVdGlscycpO1xuXG52YXIgX2Fzc2VydCA9IHJlcXVpcmUoJy4vYXNzZXJ0Jyk7XG5cbnZhciBfYXNzZXJ0MiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2Fzc2VydCk7XG5cbnZhciBfZXh0ZW5kID0gcmVxdWlyZSgnLi9leHRlbmQnKTtcblxudmFyIF9leHRlbmQyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfZXh0ZW5kKTtcblxuZnVuY3Rpb24gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChvYmopIHsgcmV0dXJuIG9iaiAmJiBvYmouX19lc01vZHVsZSA/IG9iaiA6IHsgZGVmYXVsdDogb2JqIH07IH1cblxuZnVuY3Rpb24gZXhwZWN0KGFjdHVhbCkge1xuICByZXR1cm4gbmV3IF9FeHBlY3RhdGlvbjIuZGVmYXVsdChhY3R1YWwpO1xufVxuXG5leHBlY3QuY3JlYXRlU3B5ID0gX1NweVV0aWxzLmNyZWF0ZVNweTtcbmV4cGVjdC5zcHlPbiA9IF9TcHlVdGlscy5zcHlPbjtcbmV4cGVjdC5pc1NweSA9IF9TcHlVdGlscy5pc1NweTtcbmV4cGVjdC5yZXN0b3JlU3BpZXMgPSBfU3B5VXRpbHMucmVzdG9yZVNwaWVzO1xuZXhwZWN0LmFzc2VydCA9IF9hc3NlcnQyLmRlZmF1bHQ7XG5leHBlY3QuZXh0ZW5kID0gX2V4dGVuZDIuZGVmYXVsdDtcblxubW9kdWxlLmV4cG9ydHMgPSBleHBlY3Q7XG5cblxuLyoqKioqKioqKioqKioqKioqXG4gKiogV0VCUEFDSyBGT09URVJcbiAqKiAvVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9leHBlY3QvbGliL2luZGV4LmpzXG4gKiogbW9kdWxlIGlkID0gM1xuICoqIG1vZHVsZSBjaHVua3MgPSAwXG4gKiovIiwiJ3VzZSBzdHJpY3QnO1xuXG5PYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgXCJfX2VzTW9kdWxlXCIsIHtcbiAgdmFsdWU6IHRydWVcbn0pO1xuXG52YXIgX2NyZWF0ZUNsYXNzID0gZnVuY3Rpb24gKCkgeyBmdW5jdGlvbiBkZWZpbmVQcm9wZXJ0aWVzKHRhcmdldCwgcHJvcHMpIHsgZm9yICh2YXIgaSA9IDA7IGkgPCBwcm9wcy5sZW5ndGg7IGkrKykgeyB2YXIgZGVzY3JpcHRvciA9IHByb3BzW2ldOyBkZXNjcmlwdG9yLmVudW1lcmFibGUgPSBkZXNjcmlwdG9yLmVudW1lcmFibGUgfHwgZmFsc2U7IGRlc2NyaXB0b3IuY29uZmlndXJhYmxlID0gdHJ1ZTsgaWYgKFwidmFsdWVcIiBpbiBkZXNjcmlwdG9yKSBkZXNjcmlwdG9yLndyaXRhYmxlID0gdHJ1ZTsgT2JqZWN0LmRlZmluZVByb3BlcnR5KHRhcmdldCwgZGVzY3JpcHRvci5rZXksIGRlc2NyaXB0b3IpOyB9IH0gcmV0dXJuIGZ1bmN0aW9uIChDb25zdHJ1Y3RvciwgcHJvdG9Qcm9wcywgc3RhdGljUHJvcHMpIHsgaWYgKHByb3RvUHJvcHMpIGRlZmluZVByb3BlcnRpZXMoQ29uc3RydWN0b3IucHJvdG90eXBlLCBwcm90b1Byb3BzKTsgaWYgKHN0YXRpY1Byb3BzKSBkZWZpbmVQcm9wZXJ0aWVzKENvbnN0cnVjdG9yLCBzdGF0aWNQcm9wcyk7IHJldHVybiBDb25zdHJ1Y3RvcjsgfTsgfSgpO1xuXG52YXIgX2lzRXF1YWwgPSByZXF1aXJlKCdpcy1lcXVhbCcpO1xuXG52YXIgX2lzRXF1YWwyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfaXNFcXVhbCk7XG5cbnZhciBfaXNSZWdleCA9IHJlcXVpcmUoJ2lzLXJlZ2V4Jyk7XG5cbnZhciBfaXNSZWdleDIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9pc1JlZ2V4KTtcblxudmFyIF9hc3NlcnQgPSByZXF1aXJlKCcuL2Fzc2VydCcpO1xuXG52YXIgX2Fzc2VydDIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9hc3NlcnQpO1xuXG52YXIgX1NweVV0aWxzID0gcmVxdWlyZSgnLi9TcHlVdGlscycpO1xuXG52YXIgX1Rlc3RVdGlscyA9IHJlcXVpcmUoJy4vVGVzdFV0aWxzJyk7XG5cbmZ1bmN0aW9uIF9pbnRlcm9wUmVxdWlyZURlZmF1bHQob2JqKSB7IHJldHVybiBvYmogJiYgb2JqLl9fZXNNb2R1bGUgPyBvYmogOiB7IGRlZmF1bHQ6IG9iaiB9OyB9XG5cbmZ1bmN0aW9uIF9jbGFzc0NhbGxDaGVjayhpbnN0YW5jZSwgQ29uc3RydWN0b3IpIHsgaWYgKCEoaW5zdGFuY2UgaW5zdGFuY2VvZiBDb25zdHJ1Y3RvcikpIHsgdGhyb3cgbmV3IFR5cGVFcnJvcihcIkNhbm5vdCBjYWxsIGEgY2xhc3MgYXMgYSBmdW5jdGlvblwiKTsgfSB9XG5cbi8qKlxuICogQW4gRXhwZWN0YXRpb24gaXMgYSB3cmFwcGVyIGFyb3VuZCBhbiBhc3NlcnRpb24gdGhhdCBhbGxvd3MgaXQgdG8gYmUgd3JpdHRlblxuICogaW4gYSBtb3JlIG5hdHVyYWwgc3R5bGUsIHdpdGhvdXQgdGhlIG5lZWQgdG8gcmVtZW1iZXIgdGhlIG9yZGVyIG9mIGFyZ3VtZW50cy5cbiAqIFRoaXMgaGVscHMgcHJldmVudCB5b3UgZnJvbSBtYWtpbmcgbWlzdGFrZXMgd2hlbiB3cml0aW5nIHRlc3RzLlxuICovXG5cbnZhciBFeHBlY3RhdGlvbiA9IGZ1bmN0aW9uICgpIHtcbiAgZnVuY3Rpb24gRXhwZWN0YXRpb24oYWN0dWFsKSB7XG4gICAgX2NsYXNzQ2FsbENoZWNrKHRoaXMsIEV4cGVjdGF0aW9uKTtcblxuICAgIHRoaXMuYWN0dWFsID0gYWN0dWFsO1xuXG4gICAgaWYgKCgwLCBfVGVzdFV0aWxzLmlzRnVuY3Rpb24pKGFjdHVhbCkpIHtcbiAgICAgIHRoaXMuY29udGV4dCA9IG51bGw7XG4gICAgICB0aGlzLmFyZ3MgPSBbXTtcbiAgICB9XG4gIH1cblxuICBfY3JlYXRlQ2xhc3MoRXhwZWN0YXRpb24sIFt7XG4gICAga2V5OiAndG9FeGlzdCcsXG4gICAgdmFsdWU6IGZ1bmN0aW9uIHRvRXhpc3QobWVzc2FnZSkge1xuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKHRoaXMuYWN0dWFsLCBtZXNzYWdlIHx8ICdFeHBlY3RlZCAlcyB0byBleGlzdCcsIHRoaXMuYWN0dWFsKTtcblxuICAgICAgcmV0dXJuIHRoaXM7XG4gICAgfVxuICB9LCB7XG4gICAga2V5OiAndG9Ob3RFeGlzdCcsXG4gICAgdmFsdWU6IGZ1bmN0aW9uIHRvTm90RXhpc3QobWVzc2FnZSkge1xuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKCF0aGlzLmFjdHVhbCwgbWVzc2FnZSB8fCAnRXhwZWN0ZWQgJXMgdG8gbm90IGV4aXN0JywgdGhpcy5hY3R1YWwpO1xuXG4gICAgICByZXR1cm4gdGhpcztcbiAgICB9XG4gIH0sIHtcbiAgICBrZXk6ICd0b0JlJyxcbiAgICB2YWx1ZTogZnVuY3Rpb24gdG9CZSh2YWx1ZSwgbWVzc2FnZSkge1xuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKHRoaXMuYWN0dWFsID09PSB2YWx1ZSwgbWVzc2FnZSB8fCAnRXhwZWN0ZWQgJXMgdG8gYmUgJXMnLCB0aGlzLmFjdHVhbCwgdmFsdWUpO1xuXG4gICAgICByZXR1cm4gdGhpcztcbiAgICB9XG4gIH0sIHtcbiAgICBrZXk6ICd0b05vdEJlJyxcbiAgICB2YWx1ZTogZnVuY3Rpb24gdG9Ob3RCZSh2YWx1ZSwgbWVzc2FnZSkge1xuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKHRoaXMuYWN0dWFsICE9PSB2YWx1ZSwgbWVzc2FnZSB8fCAnRXhwZWN0ZWQgJXMgdG8gbm90IGJlICVzJywgdGhpcy5hY3R1YWwsIHZhbHVlKTtcblxuICAgICAgcmV0dXJuIHRoaXM7XG4gICAgfVxuICB9LCB7XG4gICAga2V5OiAndG9FcXVhbCcsXG4gICAgdmFsdWU6IGZ1bmN0aW9uIHRvRXF1YWwodmFsdWUsIG1lc3NhZ2UpIHtcbiAgICAgIHRyeSB7XG4gICAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSgoMCwgX2lzRXF1YWwyLmRlZmF1bHQpKHRoaXMuYWN0dWFsLCB2YWx1ZSksIG1lc3NhZ2UgfHwgJ0V4cGVjdGVkICVzIHRvIGVxdWFsICVzJywgdGhpcy5hY3R1YWwsIHZhbHVlKTtcbiAgICAgIH0gY2F0Y2ggKGUpIHtcbiAgICAgICAgLy8gVGhlc2UgYXR0cmlidXRlcyBhcmUgY29uc3VtZWQgYnkgTW9jaGEgdG8gcHJvZHVjZSBhIGRpZmYgb3V0cHV0LlxuICAgICAgICBlLnNob3dEaWZmID0gdHJ1ZTtcbiAgICAgICAgZS5hY3R1YWwgPSB0aGlzLmFjdHVhbDtcbiAgICAgICAgZS5leHBlY3RlZCA9IHZhbHVlO1xuICAgICAgICB0aHJvdyBlO1xuICAgICAgfVxuXG4gICAgICByZXR1cm4gdGhpcztcbiAgICB9XG4gIH0sIHtcbiAgICBrZXk6ICd0b05vdEVxdWFsJyxcbiAgICB2YWx1ZTogZnVuY3Rpb24gdG9Ob3RFcXVhbCh2YWx1ZSwgbWVzc2FnZSkge1xuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKCEoMCwgX2lzRXF1YWwyLmRlZmF1bHQpKHRoaXMuYWN0dWFsLCB2YWx1ZSksIG1lc3NhZ2UgfHwgJ0V4cGVjdGVkICVzIHRvIG5vdCBlcXVhbCAlcycsIHRoaXMuYWN0dWFsLCB2YWx1ZSk7XG5cbiAgICAgIHJldHVybiB0aGlzO1xuICAgIH1cbiAgfSwge1xuICAgIGtleTogJ3RvVGhyb3cnLFxuICAgIHZhbHVlOiBmdW5jdGlvbiB0b1Rocm93KHZhbHVlLCBtZXNzYWdlKSB7XG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9UZXN0VXRpbHMuaXNGdW5jdGlvbikodGhpcy5hY3R1YWwpLCAnVGhlIFwiYWN0dWFsXCIgYXJndW1lbnQgaW4gZXhwZWN0KGFjdHVhbCkudG9UaHJvdygpIG11c3QgYmUgYSBmdW5jdGlvbiwgJXMgd2FzIGdpdmVuJywgdGhpcy5hY3R1YWwpO1xuXG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9UZXN0VXRpbHMuZnVuY3Rpb25UaHJvd3MpKHRoaXMuYWN0dWFsLCB0aGlzLmNvbnRleHQsIHRoaXMuYXJncywgdmFsdWUpLCBtZXNzYWdlIHx8ICdFeHBlY3RlZCAlcyB0byB0aHJvdyAlcycsIHRoaXMuYWN0dWFsLCB2YWx1ZSB8fCAnYW4gZXJyb3InKTtcblxuICAgICAgcmV0dXJuIHRoaXM7XG4gICAgfVxuICB9LCB7XG4gICAga2V5OiAndG9Ob3RUaHJvdycsXG4gICAgdmFsdWU6IGZ1bmN0aW9uIHRvTm90VGhyb3codmFsdWUsIG1lc3NhZ2UpIHtcbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSgoMCwgX1Rlc3RVdGlscy5pc0Z1bmN0aW9uKSh0aGlzLmFjdHVhbCksICdUaGUgXCJhY3R1YWxcIiBhcmd1bWVudCBpbiBleHBlY3QoYWN0dWFsKS50b05vdFRocm93KCkgbXVzdCBiZSBhIGZ1bmN0aW9uLCAlcyB3YXMgZ2l2ZW4nLCB0aGlzLmFjdHVhbCk7XG5cbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSghKDAsIF9UZXN0VXRpbHMuZnVuY3Rpb25UaHJvd3MpKHRoaXMuYWN0dWFsLCB0aGlzLmNvbnRleHQsIHRoaXMuYXJncywgdmFsdWUpLCBtZXNzYWdlIHx8ICdFeHBlY3RlZCAlcyB0byBub3QgdGhyb3cgJXMnLCB0aGlzLmFjdHVhbCwgdmFsdWUgfHwgJ2FuIGVycm9yJyk7XG5cbiAgICAgIHJldHVybiB0aGlzO1xuICAgIH1cbiAgfSwge1xuICAgIGtleTogJ3RvQmVBJyxcbiAgICB2YWx1ZTogZnVuY3Rpb24gdG9CZUEodmFsdWUsIG1lc3NhZ2UpIHtcbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSgoMCwgX1Rlc3RVdGlscy5pc0Z1bmN0aW9uKSh2YWx1ZSkgfHwgdHlwZW9mIHZhbHVlID09PSAnc3RyaW5nJywgJ1RoZSBcInZhbHVlXCIgYXJndW1lbnQgaW4gdG9CZUEodmFsdWUpIG11c3QgYmUgYSBmdW5jdGlvbiBvciBhIHN0cmluZycpO1xuXG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9UZXN0VXRpbHMuaXNBKSh0aGlzLmFjdHVhbCwgdmFsdWUpLCBtZXNzYWdlIHx8ICdFeHBlY3RlZCAlcyB0byBiZSBhICVzJywgdGhpcy5hY3R1YWwsIHZhbHVlKTtcblxuICAgICAgcmV0dXJuIHRoaXM7XG4gICAgfVxuICB9LCB7XG4gICAga2V5OiAndG9Ob3RCZUEnLFxuICAgIHZhbHVlOiBmdW5jdGlvbiB0b05vdEJlQSh2YWx1ZSwgbWVzc2FnZSkge1xuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKCgwLCBfVGVzdFV0aWxzLmlzRnVuY3Rpb24pKHZhbHVlKSB8fCB0eXBlb2YgdmFsdWUgPT09ICdzdHJpbmcnLCAnVGhlIFwidmFsdWVcIiBhcmd1bWVudCBpbiB0b05vdEJlQSh2YWx1ZSkgbXVzdCBiZSBhIGZ1bmN0aW9uIG9yIGEgc3RyaW5nJyk7XG5cbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSghKDAsIF9UZXN0VXRpbHMuaXNBKSh0aGlzLmFjdHVhbCwgdmFsdWUpLCBtZXNzYWdlIHx8ICdFeHBlY3RlZCAlcyB0byBiZSBhICVzJywgdGhpcy5hY3R1YWwsIHZhbHVlKTtcblxuICAgICAgcmV0dXJuIHRoaXM7XG4gICAgfVxuICB9LCB7XG4gICAga2V5OiAndG9NYXRjaCcsXG4gICAgdmFsdWU6IGZ1bmN0aW9uIHRvTWF0Y2gocGF0dGVybiwgbWVzc2FnZSkge1xuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKHR5cGVvZiB0aGlzLmFjdHVhbCA9PT0gJ3N0cmluZycsICdUaGUgXCJhY3R1YWxcIiBhcmd1bWVudCBpbiBleHBlY3QoYWN0dWFsKS50b01hdGNoKCkgbXVzdCBiZSBhIHN0cmluZycpO1xuXG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9pc1JlZ2V4Mi5kZWZhdWx0KShwYXR0ZXJuKSwgJ1RoZSBcInZhbHVlXCIgYXJndW1lbnQgaW4gdG9NYXRjaCh2YWx1ZSkgbXVzdCBiZSBhIFJlZ0V4cCcpO1xuXG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkocGF0dGVybi50ZXN0KHRoaXMuYWN0dWFsKSwgbWVzc2FnZSB8fCAnRXhwZWN0ZWQgJXMgdG8gbWF0Y2ggJXMnLCB0aGlzLmFjdHVhbCwgcGF0dGVybik7XG5cbiAgICAgIHJldHVybiB0aGlzO1xuICAgIH1cbiAgfSwge1xuICAgIGtleTogJ3RvTm90TWF0Y2gnLFxuICAgIHZhbHVlOiBmdW5jdGlvbiB0b05vdE1hdGNoKHBhdHRlcm4sIG1lc3NhZ2UpIHtcbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSh0eXBlb2YgdGhpcy5hY3R1YWwgPT09ICdzdHJpbmcnLCAnVGhlIFwiYWN0dWFsXCIgYXJndW1lbnQgaW4gZXhwZWN0KGFjdHVhbCkudG9Ob3RNYXRjaCgpIG11c3QgYmUgYSBzdHJpbmcnKTtcblxuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKCgwLCBfaXNSZWdleDIuZGVmYXVsdCkocGF0dGVybiksICdUaGUgXCJ2YWx1ZVwiIGFyZ3VtZW50IGluIHRvTm90TWF0Y2godmFsdWUpIG11c3QgYmUgYSBSZWdFeHAnKTtcblxuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKCFwYXR0ZXJuLnRlc3QodGhpcy5hY3R1YWwpLCBtZXNzYWdlIHx8ICdFeHBlY3RlZCAlcyB0byBub3QgbWF0Y2ggJXMnLCB0aGlzLmFjdHVhbCwgcGF0dGVybik7XG5cbiAgICAgIHJldHVybiB0aGlzO1xuICAgIH1cbiAgfSwge1xuICAgIGtleTogJ3RvQmVMZXNzVGhhbicsXG4gICAgdmFsdWU6IGZ1bmN0aW9uIHRvQmVMZXNzVGhhbih2YWx1ZSwgbWVzc2FnZSkge1xuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKHR5cGVvZiB0aGlzLmFjdHVhbCA9PT0gJ251bWJlcicsICdUaGUgXCJhY3R1YWxcIiBhcmd1bWVudCBpbiBleHBlY3QoYWN0dWFsKS50b0JlTGVzc1RoYW4oKSBtdXN0IGJlIGEgbnVtYmVyJyk7XG5cbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSh0eXBlb2YgdmFsdWUgPT09ICdudW1iZXInLCAnVGhlIFwidmFsdWVcIiBhcmd1bWVudCBpbiB0b0JlTGVzc1RoYW4odmFsdWUpIG11c3QgYmUgYSBudW1iZXInKTtcblxuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKHRoaXMuYWN0dWFsIDwgdmFsdWUsIG1lc3NhZ2UgfHwgJ0V4cGVjdGVkICVzIHRvIGJlIGxlc3MgdGhhbiAlcycsIHRoaXMuYWN0dWFsLCB2YWx1ZSk7XG5cbiAgICAgIHJldHVybiB0aGlzO1xuICAgIH1cbiAgfSwge1xuICAgIGtleTogJ3RvQmVMZXNzVGhhbk9yRXF1YWxUbycsXG4gICAgdmFsdWU6IGZ1bmN0aW9uIHRvQmVMZXNzVGhhbk9yRXF1YWxUbyh2YWx1ZSwgbWVzc2FnZSkge1xuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKHR5cGVvZiB0aGlzLmFjdHVhbCA9PT0gJ251bWJlcicsICdUaGUgXCJhY3R1YWxcIiBhcmd1bWVudCBpbiBleHBlY3QoYWN0dWFsKS50b0JlTGVzc1RoYW5PckVxdWFsVG8oKSBtdXN0IGJlIGEgbnVtYmVyJyk7XG5cbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSh0eXBlb2YgdmFsdWUgPT09ICdudW1iZXInLCAnVGhlIFwidmFsdWVcIiBhcmd1bWVudCBpbiB0b0JlTGVzc1RoYW5PckVxdWFsVG8odmFsdWUpIG11c3QgYmUgYSBudW1iZXInKTtcblxuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKHRoaXMuYWN0dWFsIDw9IHZhbHVlLCBtZXNzYWdlIHx8ICdFeHBlY3RlZCAlcyB0byBiZSBsZXNzIHRoYW4gb3IgZXF1YWwgdG8gJXMnLCB0aGlzLmFjdHVhbCwgdmFsdWUpO1xuXG4gICAgICByZXR1cm4gdGhpcztcbiAgICB9XG4gIH0sIHtcbiAgICBrZXk6ICd0b0JlR3JlYXRlclRoYW4nLFxuICAgIHZhbHVlOiBmdW5jdGlvbiB0b0JlR3JlYXRlclRoYW4odmFsdWUsIG1lc3NhZ2UpIHtcbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSh0eXBlb2YgdGhpcy5hY3R1YWwgPT09ICdudW1iZXInLCAnVGhlIFwiYWN0dWFsXCIgYXJndW1lbnQgaW4gZXhwZWN0KGFjdHVhbCkudG9CZUdyZWF0ZXJUaGFuKCkgbXVzdCBiZSBhIG51bWJlcicpO1xuXG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkodHlwZW9mIHZhbHVlID09PSAnbnVtYmVyJywgJ1RoZSBcInZhbHVlXCIgYXJndW1lbnQgaW4gdG9CZUdyZWF0ZXJUaGFuKHZhbHVlKSBtdXN0IGJlIGEgbnVtYmVyJyk7XG5cbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSh0aGlzLmFjdHVhbCA+IHZhbHVlLCBtZXNzYWdlIHx8ICdFeHBlY3RlZCAlcyB0byBiZSBncmVhdGVyIHRoYW4gJXMnLCB0aGlzLmFjdHVhbCwgdmFsdWUpO1xuXG4gICAgICByZXR1cm4gdGhpcztcbiAgICB9XG4gIH0sIHtcbiAgICBrZXk6ICd0b0JlR3JlYXRlclRoYW5PckVxdWFsVG8nLFxuICAgIHZhbHVlOiBmdW5jdGlvbiB0b0JlR3JlYXRlclRoYW5PckVxdWFsVG8odmFsdWUsIG1lc3NhZ2UpIHtcbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSh0eXBlb2YgdGhpcy5hY3R1YWwgPT09ICdudW1iZXInLCAnVGhlIFwiYWN0dWFsXCIgYXJndW1lbnQgaW4gZXhwZWN0KGFjdHVhbCkudG9CZUdyZWF0ZXJUaGFuT3JFcXVhbFRvKCkgbXVzdCBiZSBhIG51bWJlcicpO1xuXG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkodHlwZW9mIHZhbHVlID09PSAnbnVtYmVyJywgJ1RoZSBcInZhbHVlXCIgYXJndW1lbnQgaW4gdG9CZUdyZWF0ZXJUaGFuT3JFcXVhbFRvKHZhbHVlKSBtdXN0IGJlIGEgbnVtYmVyJyk7XG5cbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSh0aGlzLmFjdHVhbCA+PSB2YWx1ZSwgbWVzc2FnZSB8fCAnRXhwZWN0ZWQgJXMgdG8gYmUgZ3JlYXRlciB0aGFuIG9yIGVxdWFsIHRvICVzJywgdGhpcy5hY3R1YWwsIHZhbHVlKTtcblxuICAgICAgcmV0dXJuIHRoaXM7XG4gICAgfVxuICB9LCB7XG4gICAga2V5OiAndG9JbmNsdWRlJyxcbiAgICB2YWx1ZTogZnVuY3Rpb24gdG9JbmNsdWRlKHZhbHVlLCBjb21wYXJlVmFsdWVzLCBtZXNzYWdlKSB7XG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9UZXN0VXRpbHMuaXNBcnJheSkodGhpcy5hY3R1YWwpIHx8ICgwLCBfVGVzdFV0aWxzLmlzT2JqZWN0KSh0aGlzLmFjdHVhbCkgfHwgdHlwZW9mIHRoaXMuYWN0dWFsID09PSAnc3RyaW5nJywgJ1RoZSBcImFjdHVhbFwiIGFyZ3VtZW50IGluIGV4cGVjdChhY3R1YWwpLnRvSW5jbHVkZSgpIG11c3QgYmUgYW4gYXJyYXksIG9iamVjdCwgb3IgYSBzdHJpbmcnKTtcblxuICAgICAgaWYgKHR5cGVvZiBjb21wYXJlVmFsdWVzID09PSAnc3RyaW5nJykge1xuICAgICAgICBtZXNzYWdlID0gY29tcGFyZVZhbHVlcztcbiAgICAgICAgY29tcGFyZVZhbHVlcyA9IG51bGw7XG4gICAgICB9XG5cbiAgICAgIG1lc3NhZ2UgPSBtZXNzYWdlIHx8ICdFeHBlY3RlZCAlcyB0byBpbmNsdWRlICVzJztcblxuICAgICAgaWYgKCgwLCBfVGVzdFV0aWxzLmlzQXJyYXkpKHRoaXMuYWN0dWFsKSkge1xuICAgICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9UZXN0VXRpbHMuYXJyYXlDb250YWlucykodGhpcy5hY3R1YWwsIHZhbHVlLCBjb21wYXJlVmFsdWVzKSwgbWVzc2FnZSwgdGhpcy5hY3R1YWwsIHZhbHVlKTtcbiAgICAgIH0gZWxzZSBpZiAoKDAsIF9UZXN0VXRpbHMuaXNPYmplY3QpKHRoaXMuYWN0dWFsKSkge1xuICAgICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9UZXN0VXRpbHMub2JqZWN0Q29udGFpbnMpKHRoaXMuYWN0dWFsLCB2YWx1ZSwgY29tcGFyZVZhbHVlcyksIG1lc3NhZ2UsIHRoaXMuYWN0dWFsLCB2YWx1ZSk7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9UZXN0VXRpbHMuc3RyaW5nQ29udGFpbnMpKHRoaXMuYWN0dWFsLCB2YWx1ZSksIG1lc3NhZ2UsIHRoaXMuYWN0dWFsLCB2YWx1ZSk7XG4gICAgICB9XG5cbiAgICAgIHJldHVybiB0aGlzO1xuICAgIH1cbiAgfSwge1xuICAgIGtleTogJ3RvRXhjbHVkZScsXG4gICAgdmFsdWU6IGZ1bmN0aW9uIHRvRXhjbHVkZSh2YWx1ZSwgY29tcGFyZVZhbHVlcywgbWVzc2FnZSkge1xuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKCgwLCBfVGVzdFV0aWxzLmlzQXJyYXkpKHRoaXMuYWN0dWFsKSB8fCB0eXBlb2YgdGhpcy5hY3R1YWwgPT09ICdzdHJpbmcnLCAnVGhlIFwiYWN0dWFsXCIgYXJndW1lbnQgaW4gZXhwZWN0KGFjdHVhbCkudG9FeGNsdWRlKCkgbXVzdCBiZSBhbiBhcnJheSBvciBhIHN0cmluZycpO1xuXG4gICAgICBpZiAodHlwZW9mIGNvbXBhcmVWYWx1ZXMgPT09ICdzdHJpbmcnKSB7XG4gICAgICAgIG1lc3NhZ2UgPSBjb21wYXJlVmFsdWVzO1xuICAgICAgICBjb21wYXJlVmFsdWVzID0gbnVsbDtcbiAgICAgIH1cblxuICAgICAgbWVzc2FnZSA9IG1lc3NhZ2UgfHwgJ0V4cGVjdGVkICVzIHRvIGV4Y2x1ZGUgJXMnO1xuXG4gICAgICBpZiAoKDAsIF9UZXN0VXRpbHMuaXNBcnJheSkodGhpcy5hY3R1YWwpKSB7XG4gICAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSghKDAsIF9UZXN0VXRpbHMuYXJyYXlDb250YWlucykodGhpcy5hY3R1YWwsIHZhbHVlLCBjb21wYXJlVmFsdWVzKSwgbWVzc2FnZSwgdGhpcy5hY3R1YWwsIHZhbHVlKTtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KSghKDAsIF9UZXN0VXRpbHMuc3RyaW5nQ29udGFpbnMpKHRoaXMuYWN0dWFsLCB2YWx1ZSksIG1lc3NhZ2UsIHRoaXMuYWN0dWFsLCB2YWx1ZSk7XG4gICAgICB9XG5cbiAgICAgIHJldHVybiB0aGlzO1xuICAgIH1cbiAgfSwge1xuICAgIGtleTogJ3RvSGF2ZUJlZW5DYWxsZWQnLFxuICAgIHZhbHVlOiBmdW5jdGlvbiB0b0hhdmVCZWVuQ2FsbGVkKG1lc3NhZ2UpIHtcbiAgICAgIHZhciBzcHkgPSB0aGlzLmFjdHVhbDtcblxuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKCgwLCBfU3B5VXRpbHMuaXNTcHkpKHNweSksICdUaGUgXCJhY3R1YWxcIiBhcmd1bWVudCBpbiBleHBlY3QoYWN0dWFsKS50b0hhdmVCZWVuQ2FsbGVkKCkgbXVzdCBiZSBhIHNweScpO1xuXG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoc3B5LmNhbGxzLmxlbmd0aCA+IDAsIG1lc3NhZ2UgfHwgJ3NweSB3YXMgbm90IGNhbGxlZCcpO1xuXG4gICAgICByZXR1cm4gdGhpcztcbiAgICB9XG4gIH0sIHtcbiAgICBrZXk6ICd0b0hhdmVCZWVuQ2FsbGVkV2l0aCcsXG4gICAgdmFsdWU6IGZ1bmN0aW9uIHRvSGF2ZUJlZW5DYWxsZWRXaXRoKCkge1xuICAgICAgZm9yICh2YXIgX2xlbiA9IGFyZ3VtZW50cy5sZW5ndGgsIGV4cGVjdGVkQXJncyA9IEFycmF5KF9sZW4pLCBfa2V5ID0gMDsgX2tleSA8IF9sZW47IF9rZXkrKykge1xuICAgICAgICBleHBlY3RlZEFyZ3NbX2tleV0gPSBhcmd1bWVudHNbX2tleV07XG4gICAgICB9XG5cbiAgICAgIHZhciBzcHkgPSB0aGlzLmFjdHVhbDtcblxuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKCgwLCBfU3B5VXRpbHMuaXNTcHkpKHNweSksICdUaGUgXCJhY3R1YWxcIiBhcmd1bWVudCBpbiBleHBlY3QoYWN0dWFsKS50b0hhdmVCZWVuQ2FsbGVkV2l0aCgpIG11c3QgYmUgYSBzcHknKTtcblxuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKHNweS5jYWxscy5zb21lKGZ1bmN0aW9uIChjYWxsKSB7XG4gICAgICAgIHJldHVybiAoMCwgX2lzRXF1YWwyLmRlZmF1bHQpKGNhbGwuYXJndW1lbnRzLCBleHBlY3RlZEFyZ3MpO1xuICAgICAgfSksICdzcHkgd2FzIG5ldmVyIGNhbGxlZCB3aXRoICVzJywgZXhwZWN0ZWRBcmdzKTtcblxuICAgICAgcmV0dXJuIHRoaXM7XG4gICAgfVxuICB9LCB7XG4gICAga2V5OiAndG9Ob3RIYXZlQmVlbkNhbGxlZCcsXG4gICAgdmFsdWU6IGZ1bmN0aW9uIHRvTm90SGF2ZUJlZW5DYWxsZWQobWVzc2FnZSkge1xuICAgICAgdmFyIHNweSA9IHRoaXMuYWN0dWFsO1xuXG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9TcHlVdGlscy5pc1NweSkoc3B5KSwgJ1RoZSBcImFjdHVhbFwiIGFyZ3VtZW50IGluIGV4cGVjdChhY3R1YWwpLnRvTm90SGF2ZUJlZW5DYWxsZWQoKSBtdXN0IGJlIGEgc3B5Jyk7XG5cbiAgICAgICgwLCBfYXNzZXJ0Mi5kZWZhdWx0KShzcHkuY2FsbHMubGVuZ3RoID09PSAwLCBtZXNzYWdlIHx8ICdzcHkgd2FzIG5vdCBzdXBwb3NlZCB0byBiZSBjYWxsZWQnKTtcblxuICAgICAgcmV0dXJuIHRoaXM7XG4gICAgfVxuICB9LCB7XG4gICAga2V5OiAnd2l0aENvbnRleHQnLFxuICAgIHZhbHVlOiBmdW5jdGlvbiB3aXRoQ29udGV4dChjb250ZXh0KSB7XG4gICAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9UZXN0VXRpbHMuaXNGdW5jdGlvbikodGhpcy5hY3R1YWwpLCAnVGhlIFwiYWN0dWFsXCIgYXJndW1lbnQgaW4gZXhwZWN0KGFjdHVhbCkud2l0aENvbnRleHQoKSBtdXN0IGJlIGEgZnVuY3Rpb24nKTtcblxuICAgICAgdGhpcy5jb250ZXh0ID0gY29udGV4dDtcblxuICAgICAgcmV0dXJuIHRoaXM7XG4gICAgfVxuICB9LCB7XG4gICAga2V5OiAnd2l0aEFyZ3MnLFxuICAgIHZhbHVlOiBmdW5jdGlvbiB3aXRoQXJncygpIHtcbiAgICAgIHZhciBfYXJncztcblxuICAgICAgKDAsIF9hc3NlcnQyLmRlZmF1bHQpKCgwLCBfVGVzdFV0aWxzLmlzRnVuY3Rpb24pKHRoaXMuYWN0dWFsKSwgJ1RoZSBcImFjdHVhbFwiIGFyZ3VtZW50IGluIGV4cGVjdChhY3R1YWwpLndpdGhBcmdzKCkgbXVzdCBiZSBhIGZ1bmN0aW9uJyk7XG5cbiAgICAgIGlmIChhcmd1bWVudHMubGVuZ3RoKSB0aGlzLmFyZ3MgPSAoX2FyZ3MgPSB0aGlzLmFyZ3MpLmNvbmNhdC5hcHBseShfYXJncywgYXJndW1lbnRzKTtcblxuICAgICAgcmV0dXJuIHRoaXM7XG4gICAgfVxuICB9XSk7XG5cbiAgcmV0dXJuIEV4cGVjdGF0aW9uO1xufSgpO1xuXG52YXIgYWxpYXNlcyA9IHtcbiAgdG9CZUFuOiAndG9CZUEnLFxuICB0b05vdEJlQW46ICd0b05vdEJlQScsXG4gIHRvQmVUcnV0aHk6ICd0b0V4aXN0JyxcbiAgdG9CZUZhbHN5OiAndG9Ob3RFeGlzdCcsXG4gIHRvQmVGZXdlclRoYW46ICd0b0JlTGVzc1RoYW4nLFxuICB0b0JlTW9yZVRoYW46ICd0b0JlR3JlYXRlclRoYW4nLFxuICB0b0NvbnRhaW46ICd0b0luY2x1ZGUnLFxuICB0b05vdENvbnRhaW46ICd0b0V4Y2x1ZGUnXG59O1xuXG5mb3IgKHZhciBhbGlhcyBpbiBhbGlhc2VzKSB7XG4gIGlmIChhbGlhc2VzLmhhc093blByb3BlcnR5KGFsaWFzKSkgRXhwZWN0YXRpb24ucHJvdG90eXBlW2FsaWFzXSA9IEV4cGVjdGF0aW9uLnByb3RvdHlwZVthbGlhc2VzW2FsaWFzXV07XG59ZXhwb3J0cy5kZWZhdWx0ID0gRXhwZWN0YXRpb247XG5cblxuLyoqKioqKioqKioqKioqKioqXG4gKiogV0VCUEFDSyBGT09URVJcbiAqKiAvVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9leHBlY3QvbGliL0V4cGVjdGF0aW9uLmpzXG4gKiogbW9kdWxlIGlkID0gNFxuICoqIG1vZHVsZSBjaHVua3MgPSAwXG4gKiovIiwiJ3VzZSBzdHJpY3QnO1xuXG52YXIgd2h5Tm90RXF1YWwgPSByZXF1aXJlKCcuL3doeScpO1xuXG5tb2R1bGUuZXhwb3J0cyA9IGZ1bmN0aW9uIGlzRXF1YWwodmFsdWUsIG90aGVyKSB7XG5cdHJldHVybiB3aHlOb3RFcXVhbCh2YWx1ZSwgb3RoZXIpID09PSAnJztcbn07XG5cblxuXG4vKioqKioqKioqKioqKioqKipcbiAqKiBXRUJQQUNLIEZPT1RFUlxuICoqIC9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLWVxdWFsL2luZGV4LmpzXG4gKiogbW9kdWxlIGlkID0gNVxuICoqIG1vZHVsZSBjaHVua3MgPSAwXG4gKiovIiwiJ3VzZSBzdHJpY3QnO1xuXG52YXIgT2JqZWN0UHJvdG90eXBlID0gT2JqZWN0LnByb3RvdHlwZTtcbnZhciB0b1N0ciA9IE9iamVjdFByb3RvdHlwZS50b1N0cmluZztcbnZhciBib29sZWFuVmFsdWUgPSBCb29sZWFuLnByb3RvdHlwZS52YWx1ZU9mO1xudmFyIGhhcyA9IHJlcXVpcmUoJ2hhcycpO1xudmFyIGlzQXJyb3dGdW5jdGlvbiA9IHJlcXVpcmUoJ2lzLWFycm93LWZ1bmN0aW9uJyk7XG52YXIgaXNCb29sZWFuID0gcmVxdWlyZSgnaXMtYm9vbGVhbi1vYmplY3QnKTtcbnZhciBpc0RhdGUgPSByZXF1aXJlKCdpcy1kYXRlLW9iamVjdCcpO1xudmFyIGlzR2VuZXJhdG9yID0gcmVxdWlyZSgnaXMtZ2VuZXJhdG9yLWZ1bmN0aW9uJyk7XG52YXIgaXNOdW1iZXIgPSByZXF1aXJlKCdpcy1udW1iZXItb2JqZWN0Jyk7XG52YXIgaXNSZWdleCA9IHJlcXVpcmUoJ2lzLXJlZ2V4Jyk7XG52YXIgaXNTdHJpbmcgPSByZXF1aXJlKCdpcy1zdHJpbmcnKTtcbnZhciBpc1N5bWJvbCA9IHJlcXVpcmUoJ2lzLXN5bWJvbCcpO1xudmFyIGlzQ2FsbGFibGUgPSByZXF1aXJlKCdpcy1jYWxsYWJsZScpO1xuXG52YXIgaXNQcm90byA9IE9iamVjdC5wcm90b3R5cGUuaXNQcm90b3R5cGVPZjtcblxudmFyIGZvbyA9IGZ1bmN0aW9uIGZvbygpIHt9O1xudmFyIGZ1bmN0aW9uc0hhdmVOYW1lcyA9IGZvby5uYW1lID09PSAnZm9vJztcblxudmFyIHN5bWJvbFZhbHVlID0gdHlwZW9mIFN5bWJvbCA9PT0gJ2Z1bmN0aW9uJyA/IFN5bWJvbC5wcm90b3R5cGUudmFsdWVPZiA6IG51bGw7XG52YXIgc3ltYm9sSXRlcmF0b3IgPSByZXF1aXJlKCcuL2dldFN5bWJvbEl0ZXJhdG9yJykoKTtcblxudmFyIGNvbGxlY3Rpb25zRm9yRWFjaCA9IHJlcXVpcmUoJy4vZ2V0Q29sbGVjdGlvbnNGb3JFYWNoJykoKTtcblxudmFyIGdldFByb3RvdHlwZU9mID0gT2JqZWN0LmdldFByb3RvdHlwZU9mO1xuaWYgKCFnZXRQcm90b3R5cGVPZikge1xuXHQvKiBlc2xpbnQtZGlzYWJsZSBuby1wcm90byAqL1xuXHRpZiAodHlwZW9mICd0ZXN0Jy5fX3Byb3RvX18gPT09ICdvYmplY3QnKSB7XG5cdFx0Z2V0UHJvdG90eXBlT2YgPSBmdW5jdGlvbiAob2JqKSB7XG5cdFx0XHRyZXR1cm4gb2JqLl9fcHJvdG9fXztcblx0XHR9O1xuXHR9IGVsc2Uge1xuXHRcdGdldFByb3RvdHlwZU9mID0gZnVuY3Rpb24gKG9iaikge1xuXHRcdFx0dmFyIGNvbnN0cnVjdG9yID0gb2JqLmNvbnN0cnVjdG9yLFxuXHRcdFx0XHRvbGRDb25zdHJ1Y3Rvcjtcblx0XHRcdGlmIChoYXMob2JqLCAnY29uc3RydWN0b3InKSkge1xuXHRcdFx0XHRvbGRDb25zdHJ1Y3RvciA9IGNvbnN0cnVjdG9yO1xuXHRcdFx0XHRpZiAoIShkZWxldGUgb2JqLmNvbnN0cnVjdG9yKSkgeyAvLyByZXNldCBjb25zdHJ1Y3RvclxuXHRcdFx0XHRcdHJldHVybiBudWxsOyAvLyBjYW4ndCBkZWxldGUgb2JqLmNvbnN0cnVjdG9yLCByZXR1cm4gbnVsbFxuXHRcdFx0XHR9XG5cdFx0XHRcdGNvbnN0cnVjdG9yID0gb2JqLmNvbnN0cnVjdG9yOyAvLyBnZXQgcmVhbCBjb25zdHJ1Y3RvclxuXHRcdFx0XHRvYmouY29uc3RydWN0b3IgPSBvbGRDb25zdHJ1Y3RvcjsgLy8gcmVzdG9yZSBjb25zdHJ1Y3RvclxuXHRcdFx0fVxuXHRcdFx0cmV0dXJuIGNvbnN0cnVjdG9yID8gY29uc3RydWN0b3IucHJvdG90eXBlIDogT2JqZWN0UHJvdG90eXBlOyAvLyBuZWVkZWQgZm9yIElFXG5cdFx0fTtcblx0fVxuXHQvKiBlc2xpbnQtZW5hYmxlIG5vLXByb3RvICovXG59XG5cbnZhciBpc0FycmF5ID0gQXJyYXkuaXNBcnJheSB8fCBmdW5jdGlvbiAodmFsdWUpIHtcblx0cmV0dXJuIHRvU3RyLmNhbGwodmFsdWUpID09PSAnW29iamVjdCBBcnJheV0nO1xufTtcblxudmFyIG5vcm1hbGl6ZUZuV2hpdGVzcGFjZSA9IGZ1bmN0aW9uIG5vcm1hbGl6ZUZuV2hpdGVzcGFjZShmblN0cikge1xuXHQvLyB0aGlzIGlzIG5lZWRlZCBpbiBJRSA5LCBhdCBsZWFzdCwgd2hpY2ggaGFzIGluY29uc2lzdGVuY2llcyBoZXJlLlxuXHRyZXR1cm4gZm5TdHIucmVwbGFjZSgvXmZ1bmN0aW9uID9cXCgvLCAnZnVuY3Rpb24gKCcpLnJlcGxhY2UoJyl7JywgJykgeycpO1xufTtcblxudmFyIHRyeU1hcFNldEVudHJpZXMgPSBmdW5jdGlvbiB0cnlNYXBTZXRFbnRyaWVzKGNvbGxlY3Rpb24pIHtcblx0dmFyIGZvdW5kRW50cmllcyA9IFtdO1xuXHR0cnkge1xuXHRcdGNvbGxlY3Rpb25zRm9yRWFjaC5NYXAuY2FsbChjb2xsZWN0aW9uLCBmdW5jdGlvbiAoa2V5LCB2YWx1ZSkge1xuXHRcdFx0Zm91bmRFbnRyaWVzLnB1c2goW2tleSwgdmFsdWVdKTtcblx0XHR9KTtcblx0fSBjYXRjaCAobm90TWFwKSB7XG5cdFx0dHJ5IHtcblx0XHRcdGNvbGxlY3Rpb25zRm9yRWFjaC5TZXQuY2FsbChjb2xsZWN0aW9uLCBmdW5jdGlvbiAodmFsdWUpIHtcblx0XHRcdFx0Zm91bmRFbnRyaWVzLnB1c2goW3ZhbHVlXSk7XG5cdFx0XHR9KTtcblx0XHR9IGNhdGNoIChub3RTZXQpIHtcblx0XHRcdHJldHVybiBmYWxzZTtcblx0XHR9XG5cdH1cblx0cmV0dXJuIGZvdW5kRW50cmllcztcbn07XG5cbm1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24gd2h5Tm90RXF1YWwodmFsdWUsIG90aGVyKSB7XG5cdGlmICh2YWx1ZSA9PT0gb3RoZXIpIHsgcmV0dXJuICcnOyB9XG5cdGlmICh2YWx1ZSA9PSBudWxsIHx8IG90aGVyID09IG51bGwpIHtcblx0XHRyZXR1cm4gdmFsdWUgPT09IG90aGVyID8gJycgOiBTdHJpbmcodmFsdWUpICsgJyAhPT0gJyArIFN0cmluZyhvdGhlcik7XG5cdH1cblxuXHR2YXIgdmFsVG9TdHIgPSB0b1N0ci5jYWxsKHZhbHVlKTtcblx0dmFyIG90aGVyVG9TdHIgPSB0b1N0ci5jYWxsKHZhbHVlKTtcblx0aWYgKHZhbFRvU3RyICE9PSBvdGhlclRvU3RyKSB7XG5cdFx0cmV0dXJuICd0b1N0cmluZ1RhZyBpcyBub3QgdGhlIHNhbWU6ICcgKyB2YWxUb1N0ciArICcgIT09ICcgKyBvdGhlclRvU3RyO1xuXHR9XG5cblx0dmFyIHZhbElzQm9vbCA9IGlzQm9vbGVhbih2YWx1ZSk7XG5cdHZhciBvdGhlcklzQm9vbCA9IGlzQm9vbGVhbihvdGhlcik7XG5cdGlmICh2YWxJc0Jvb2wgfHwgb3RoZXJJc0Jvb2wpIHtcblx0XHRpZiAoIXZhbElzQm9vbCkgeyByZXR1cm4gJ2ZpcnN0IGFyZ3VtZW50IGlzIG5vdCBhIGJvb2xlYW47IHNlY29uZCBhcmd1bWVudCBpcyc7IH1cblx0XHRpZiAoIW90aGVySXNCb29sKSB7IHJldHVybiAnc2Vjb25kIGFyZ3VtZW50IGlzIG5vdCBhIGJvb2xlYW47IGZpcnN0IGFyZ3VtZW50IGlzJzsgfVxuXHRcdHZhciB2YWxCb29sVmFsID0gYm9vbGVhblZhbHVlLmNhbGwodmFsdWUpO1xuXHRcdHZhciBvdGhlckJvb2xWYWwgPSBib29sZWFuVmFsdWUuY2FsbChvdGhlcik7XG5cdFx0aWYgKHZhbEJvb2xWYWwgPT09IG90aGVyQm9vbFZhbCkgeyByZXR1cm4gJyc7IH1cblx0XHRyZXR1cm4gJ3ByaW1pdGl2ZSB2YWx1ZSBvZiBib29sZWFuIGFyZ3VtZW50cyBkbyBub3QgbWF0Y2g6ICcgKyB2YWxCb29sVmFsICsgJyAhPT0gJyArIG90aGVyQm9vbFZhbDtcblx0fVxuXG5cdHZhciB2YWxJc051bWJlciA9IGlzTnVtYmVyKHZhbHVlKTtcblx0dmFyIG90aGVySXNOdW1iZXIgPSBpc051bWJlcih2YWx1ZSk7XG5cdGlmICh2YWxJc051bWJlciB8fCBvdGhlcklzTnVtYmVyKSB7XG5cdFx0aWYgKCF2YWxJc051bWJlcikgeyByZXR1cm4gJ2ZpcnN0IGFyZ3VtZW50IGlzIG5vdCBhIG51bWJlcjsgc2Vjb25kIGFyZ3VtZW50IGlzJzsgfVxuXHRcdGlmICghb3RoZXJJc051bWJlcikgeyByZXR1cm4gJ3NlY29uZCBhcmd1bWVudCBpcyBub3QgYSBudW1iZXI7IGZpcnN0IGFyZ3VtZW50IGlzJzsgfVxuXHRcdHZhciB2YWxOdW0gPSBOdW1iZXIodmFsdWUpO1xuXHRcdHZhciBvdGhlck51bSA9IE51bWJlcihvdGhlcik7XG5cdFx0aWYgKHZhbE51bSA9PT0gb3RoZXJOdW0pIHsgcmV0dXJuICcnOyB9XG5cdFx0dmFyIHZhbElzTmFOID0gaXNOYU4odmFsdWUpO1xuXHRcdHZhciBvdGhlcklzTmFOID0gaXNOYU4ob3RoZXIpO1xuXHRcdGlmICh2YWxJc05hTiAmJiAhb3RoZXJJc05hTikge1xuXHRcdFx0cmV0dXJuICdmaXJzdCBhcmd1bWVudCBpcyBOYU47IHNlY29uZCBpcyBub3QnO1xuXHRcdH0gZWxzZSBpZiAoIXZhbElzTmFOICYmIG90aGVySXNOYU4pIHtcblx0XHRcdHJldHVybiAnc2Vjb25kIGFyZ3VtZW50IGlzIE5hTjsgZmlyc3QgaXMgbm90Jztcblx0XHR9IGVsc2UgaWYgKHZhbElzTmFOICYmIG90aGVySXNOYU4pIHtcblx0XHRcdHJldHVybiAnJztcblx0XHR9XG5cdFx0cmV0dXJuICdudW1iZXJzIGFyZSBkaWZmZXJlbnQ6ICcgKyB2YWx1ZSArICcgIT09ICcgKyBvdGhlcjtcblx0fVxuXG5cdHZhciB2YWxJc1N0cmluZyA9IGlzU3RyaW5nKHZhbHVlKTtcblx0dmFyIG90aGVySXNTdHJpbmcgPSBpc1N0cmluZyhvdGhlcik7XG5cdGlmICh2YWxJc1N0cmluZyB8fCBvdGhlcklzU3RyaW5nKSB7XG5cdFx0aWYgKCF2YWxJc1N0cmluZykgeyByZXR1cm4gJ3NlY29uZCBhcmd1bWVudCBpcyBzdHJpbmc7IGZpcnN0IGlzIG5vdCc7IH1cblx0XHRpZiAoIW90aGVySXNTdHJpbmcpIHsgcmV0dXJuICdmaXJzdCBhcmd1bWVudCBpcyBzdHJpbmc7IHNlY29uZCBpcyBub3QnOyB9XG5cdFx0dmFyIHN0cmluZ1ZhbCA9IFN0cmluZyh2YWx1ZSk7XG5cdFx0dmFyIG90aGVyVmFsID0gU3RyaW5nKG90aGVyKTtcblx0XHRpZiAoc3RyaW5nVmFsID09PSBvdGhlclZhbCkgeyByZXR1cm4gJyc7IH1cblx0XHRyZXR1cm4gJ3N0cmluZyB2YWx1ZXMgYXJlIGRpZmZlcmVudDogXCInICsgc3RyaW5nVmFsICsgJ1wiICE9PSBcIicgKyBvdGhlclZhbCArICdcIic7XG5cdH1cblxuXHR2YXIgdmFsSXNEYXRlID0gaXNEYXRlKHZhbHVlKTtcblx0dmFyIG90aGVySXNEYXRlID0gaXNEYXRlKG90aGVyKTtcblx0aWYgKHZhbElzRGF0ZSB8fCBvdGhlcklzRGF0ZSkge1xuXHRcdGlmICghdmFsSXNEYXRlKSB7IHJldHVybiAnc2Vjb25kIGFyZ3VtZW50IGlzIERhdGUsIGZpcnN0IGlzIG5vdCc7IH1cblx0XHRpZiAoIW90aGVySXNEYXRlKSB7IHJldHVybiAnZmlyc3QgYXJndW1lbnQgaXMgRGF0ZSwgc2Vjb25kIGlzIG5vdCc7IH1cblx0XHR2YXIgdmFsVGltZSA9ICt2YWx1ZTtcblx0XHR2YXIgb3RoZXJUaW1lID0gK290aGVyO1xuXHRcdGlmICh2YWxUaW1lID09PSBvdGhlclRpbWUpIHsgcmV0dXJuICcnOyB9XG5cdFx0cmV0dXJuICdEYXRlcyBoYXZlIGRpZmZlcmVudCB0aW1lIHZhbHVlczogJyArIHZhbFRpbWUgKyAnICE9PSAnICsgb3RoZXJUaW1lO1xuXHR9XG5cblx0dmFyIHZhbElzUmVnZXggPSBpc1JlZ2V4KHZhbHVlKTtcblx0dmFyIG90aGVySXNSZWdleCA9IGlzUmVnZXgob3RoZXIpO1xuXHRpZiAodmFsSXNSZWdleCB8fCBvdGhlcklzUmVnZXgpIHtcblx0XHRpZiAoIXZhbElzUmVnZXgpIHsgcmV0dXJuICdzZWNvbmQgYXJndW1lbnQgaXMgUmVnRXhwLCBmaXJzdCBpcyBub3QnOyB9XG5cdFx0aWYgKCFvdGhlcklzUmVnZXgpIHsgcmV0dXJuICdmaXJzdCBhcmd1bWVudCBpcyBSZWdFeHAsIHNlY29uZCBpcyBub3QnOyB9XG5cdFx0dmFyIHJlZ2V4U3RyaW5nVmFsID0gU3RyaW5nKHZhbHVlKTtcblx0XHR2YXIgcmVnZXhTdHJpbmdPdGhlciA9IFN0cmluZyhvdGhlcik7XG5cdFx0aWYgKHJlZ2V4U3RyaW5nVmFsID09PSByZWdleFN0cmluZ090aGVyKSB7IHJldHVybiAnJzsgfVxuXHRcdHJldHVybiAncmVndWxhciBleHByZXNzaW9ucyBkaWZmZXI6ICcgKyByZWdleFN0cmluZ1ZhbCArICcgIT09ICcgKyByZWdleFN0cmluZ090aGVyO1xuXHR9XG5cblx0dmFyIHZhbElzQXJyYXkgPSBpc0FycmF5KHZhbHVlKTtcblx0dmFyIG90aGVySXNBcnJheSA9IGlzQXJyYXkob3RoZXIpO1xuXHRpZiAodmFsSXNBcnJheSB8fCBvdGhlcklzQXJyYXkpIHtcblx0XHRpZiAoIXZhbElzQXJyYXkpIHsgcmV0dXJuICdzZWNvbmQgYXJndW1lbnQgaXMgYW4gQXJyYXksIGZpcnN0IGlzIG5vdCc7IH1cblx0XHRpZiAoIW90aGVySXNBcnJheSkgeyByZXR1cm4gJ2ZpcnN0IGFyZ3VtZW50IGlzIGFuIEFycmF5LCBzZWNvbmQgaXMgbm90JzsgfVxuXHRcdGlmICh2YWx1ZS5sZW5ndGggIT09IG90aGVyLmxlbmd0aCkge1xuXHRcdFx0cmV0dXJuICdhcnJheXMgaGF2ZSBkaWZmZXJlbnQgbGVuZ3RoOiAnICsgdmFsdWUubGVuZ3RoICsgJyAhPT0gJyArIG90aGVyLmxlbmd0aDtcblx0XHR9XG5cdFx0aWYgKFN0cmluZyh2YWx1ZSkgIT09IFN0cmluZyhvdGhlcikpIHsgcmV0dXJuICdzdHJpbmdpZmllZCBBcnJheXMgZGlmZmVyJzsgfVxuXG5cdFx0dmFyIGluZGV4ID0gdmFsdWUubGVuZ3RoIC0gMTtcblx0XHR2YXIgZXF1YWwgPSAnJztcblx0XHR2YXIgdmFsSGFzSW5kZXgsIG90aGVySGFzSW5kZXg7XG5cdFx0d2hpbGUgKGVxdWFsID09PSAnJyAmJiBpbmRleCA+PSAwKSB7XG5cdFx0XHR2YWxIYXNJbmRleCA9IGhhcyh2YWx1ZSwgaW5kZXgpO1xuXHRcdFx0b3RoZXJIYXNJbmRleCA9IGhhcyhvdGhlciwgaW5kZXgpO1xuXHRcdFx0aWYgKCF2YWxIYXNJbmRleCAmJiBvdGhlckhhc0luZGV4KSB7IHJldHVybiAnc2Vjb25kIGFyZ3VtZW50IGhhcyBpbmRleCAnICsgaW5kZXggKyAnOyBmaXJzdCBkb2VzIG5vdCc7IH1cblx0XHRcdGlmICh2YWxIYXNJbmRleCAmJiAhb3RoZXJIYXNJbmRleCkgeyByZXR1cm4gJ2ZpcnN0IGFyZ3VtZW50IGhhcyBpbmRleCAnICsgaW5kZXggKyAnOyBzZWNvbmQgZG9lcyBub3QnOyB9XG5cdFx0XHRlcXVhbCA9IHdoeU5vdEVxdWFsKHZhbHVlW2luZGV4XSwgb3RoZXJbaW5kZXhdKTtcblx0XHRcdGluZGV4IC09IDE7XG5cdFx0fVxuXHRcdHJldHVybiBlcXVhbDtcblx0fVxuXG5cdHZhciB2YWx1ZUlzU3ltID0gaXNTeW1ib2wodmFsdWUpO1xuXHR2YXIgb3RoZXJJc1N5bSA9IGlzU3ltYm9sKG90aGVyKTtcblx0aWYgKHZhbHVlSXNTeW0gIT09IG90aGVySXNTeW0pIHtcblx0XHRpZiAodmFsdWVJc1N5bSkgeyByZXR1cm4gJ2ZpcnN0IGFyZ3VtZW50IGlzIFN5bWJvbDsgc2Vjb25kIGlzIG5vdCc7IH1cblx0XHRyZXR1cm4gJ3NlY29uZCBhcmd1bWVudCBpcyBTeW1ib2w7IGZpcnN0IGlzIG5vdCc7XG5cdH1cblx0aWYgKHZhbHVlSXNTeW0gJiYgb3RoZXJJc1N5bSkge1xuXHRcdHJldHVybiBzeW1ib2xWYWx1ZS5jYWxsKHZhbHVlKSA9PT0gc3ltYm9sVmFsdWUuY2FsbChvdGhlcikgPyAnJyA6ICdmaXJzdCBTeW1ib2wgdmFsdWUgIT09IHNlY29uZCBTeW1ib2wgdmFsdWUnO1xuXHR9XG5cblx0dmFyIHZhbHVlSXNHZW4gPSBpc0dlbmVyYXRvcih2YWx1ZSk7XG5cdHZhciBvdGhlcklzR2VuID0gaXNHZW5lcmF0b3Iob3RoZXIpO1xuXHRpZiAodmFsdWVJc0dlbiAhPT0gb3RoZXJJc0dlbikge1xuXHRcdGlmICh2YWx1ZUlzR2VuKSB7IHJldHVybiAnZmlyc3QgYXJndW1lbnQgaXMgYSBHZW5lcmF0b3I7IHNlY29uZCBpcyBub3QnOyB9XG5cdFx0cmV0dXJuICdzZWNvbmQgYXJndW1lbnQgaXMgYSBHZW5lcmF0b3I7IGZpcnN0IGlzIG5vdCc7XG5cdH1cblxuXHR2YXIgdmFsdWVJc0Fycm93ID0gaXNBcnJvd0Z1bmN0aW9uKHZhbHVlKTtcblx0dmFyIG90aGVySXNBcnJvdyA9IGlzQXJyb3dGdW5jdGlvbihvdGhlcik7XG5cdGlmICh2YWx1ZUlzQXJyb3cgIT09IG90aGVySXNBcnJvdykge1xuXHRcdGlmICh2YWx1ZUlzQXJyb3cpIHsgcmV0dXJuICdmaXJzdCBhcmd1bWVudCBpcyBhbiBBcnJvdyBmdW5jdGlvbjsgc2Vjb25kIGlzIG5vdCc7IH1cblx0XHRyZXR1cm4gJ3NlY29uZCBhcmd1bWVudCBpcyBhbiBBcnJvdyBmdW5jdGlvbjsgZmlyc3QgaXMgbm90Jztcblx0fVxuXG5cdGlmIChpc0NhbGxhYmxlKHZhbHVlKSB8fCBpc0NhbGxhYmxlKG90aGVyKSkge1xuXHRcdGlmIChmdW5jdGlvbnNIYXZlTmFtZXMgJiYgd2h5Tm90RXF1YWwodmFsdWUubmFtZSwgb3RoZXIubmFtZSkgIT09ICcnKSB7XG5cdFx0XHRyZXR1cm4gJ0Z1bmN0aW9uIG5hbWVzIGRpZmZlcjogXCInICsgdmFsdWUubmFtZSArICdcIiAhPT0gXCInICsgb3RoZXIubmFtZSArICdcIic7XG5cdFx0fVxuXHRcdGlmICh3aHlOb3RFcXVhbCh2YWx1ZS5sZW5ndGgsIG90aGVyLmxlbmd0aCkgIT09ICcnKSB7XG5cdFx0XHRyZXR1cm4gJ0Z1bmN0aW9uIGxlbmd0aHMgZGlmZmVyOiAnICsgdmFsdWUubGVuZ3RoICsgJyAhPT0gJyArIG90aGVyLmxlbmd0aDtcblx0XHR9XG5cblx0XHR2YXIgdmFsdWVTdHIgPSBub3JtYWxpemVGbldoaXRlc3BhY2UoU3RyaW5nKHZhbHVlKSk7XG5cdFx0dmFyIG90aGVyU3RyID0gbm9ybWFsaXplRm5XaGl0ZXNwYWNlKFN0cmluZyhvdGhlcikpO1xuXHRcdGlmICh3aHlOb3RFcXVhbCh2YWx1ZVN0ciwgb3RoZXJTdHIpID09PSAnJykgeyByZXR1cm4gJyc7IH1cblxuXHRcdGlmICghdmFsdWVJc0dlbiAmJiAhdmFsdWVJc0Fycm93KSB7XG5cdFx0XHRyZXR1cm4gd2h5Tm90RXF1YWwodmFsdWVTdHIucmVwbGFjZSgvXFwpXFxzKlxcey8sICcpeycpLCBvdGhlclN0ci5yZXBsYWNlKC9cXClcXHMqXFx7LywgJyl7JykpID09PSAnJyA/ICcnIDogJ0Z1bmN0aW9uIHN0cmluZyByZXByZXNlbnRhdGlvbnMgZGlmZmVyJztcblx0XHR9XG5cdFx0cmV0dXJuIHdoeU5vdEVxdWFsKHZhbHVlU3RyLCBvdGhlclN0cikgPT09ICcnID8gJycgOiAnRnVuY3Rpb24gc3RyaW5nIHJlcHJlc2VudGF0aW9ucyBkaWZmZXInO1xuXHR9XG5cblx0aWYgKHR5cGVvZiB2YWx1ZSA9PT0gJ29iamVjdCcgfHwgdHlwZW9mIG90aGVyID09PSAnb2JqZWN0Jykge1xuXHRcdGlmICh0eXBlb2YgdmFsdWUgIT09IHR5cGVvZiBvdGhlcikgeyByZXR1cm4gJ2FyZ3VtZW50cyBoYXZlIGEgZGlmZmVyZW50IHR5cGVvZjogJyArIHR5cGVvZiB2YWx1ZSArICcgIT09ICcgKyB0eXBlb2Ygb3RoZXI7IH1cblx0XHRpZiAoaXNQcm90by5jYWxsKHZhbHVlLCBvdGhlcikpIHsgcmV0dXJuICdmaXJzdCBhcmd1bWVudCBpcyB0aGUgW1tQcm90b3R5cGVdXSBvZiB0aGUgc2Vjb25kJzsgfVxuXHRcdGlmIChpc1Byb3RvLmNhbGwob3RoZXIsIHZhbHVlKSkgeyByZXR1cm4gJ3NlY29uZCBhcmd1bWVudCBpcyB0aGUgW1tQcm90b3R5cGVdXSBvZiB0aGUgZmlyc3QnOyB9XG5cdFx0aWYgKGdldFByb3RvdHlwZU9mKHZhbHVlKSAhPT0gZ2V0UHJvdG90eXBlT2Yob3RoZXIpKSB7IHJldHVybiAnYXJndW1lbnRzIGhhdmUgYSBkaWZmZXJlbnQgW1tQcm90b3R5cGVdXSc7IH1cblxuXHRcdGlmIChzeW1ib2xJdGVyYXRvcikge1xuXHRcdFx0dmFyIHZhbHVlSXRlcmF0b3JGbiA9IHZhbHVlW3N5bWJvbEl0ZXJhdG9yXTtcblx0XHRcdHZhciB2YWx1ZUlzSXRlcmFibGUgPSBpc0NhbGxhYmxlKHZhbHVlSXRlcmF0b3JGbik7XG5cdFx0XHR2YXIgb3RoZXJJdGVyYXRvckZuID0gb3RoZXJbc3ltYm9sSXRlcmF0b3JdO1xuXHRcdFx0dmFyIG90aGVySXNJdGVyYWJsZSA9IGlzQ2FsbGFibGUob3RoZXJJdGVyYXRvckZuKTtcblx0XHRcdGlmICh2YWx1ZUlzSXRlcmFibGUgIT09IG90aGVySXNJdGVyYWJsZSkge1xuXHRcdFx0XHRpZiAodmFsdWVJc0l0ZXJhYmxlKSB7IHJldHVybiAnZmlyc3QgYXJndW1lbnQgaXMgaXRlcmFibGU7IHNlY29uZCBpcyBub3QnOyB9XG5cdFx0XHRcdHJldHVybiAnc2Vjb25kIGFyZ3VtZW50IGlzIGl0ZXJhYmxlOyBmaXJzdCBpcyBub3QnO1xuXHRcdFx0fVxuXHRcdFx0aWYgKHZhbHVlSXNJdGVyYWJsZSAmJiBvdGhlcklzSXRlcmFibGUpIHtcblx0XHRcdFx0dmFyIHZhbHVlSXRlcmF0b3IgPSB2YWx1ZUl0ZXJhdG9yRm4uY2FsbCh2YWx1ZSk7XG5cdFx0XHRcdHZhciBvdGhlckl0ZXJhdG9yID0gb3RoZXJJdGVyYXRvckZuLmNhbGwob3RoZXIpO1xuXHRcdFx0XHR2YXIgdmFsdWVOZXh0LCBvdGhlck5leHQsIG5leHRXaHk7XG5cdFx0XHRcdGRvIHtcblx0XHRcdFx0XHR2YWx1ZU5leHQgPSB2YWx1ZUl0ZXJhdG9yLm5leHQoKTtcblx0XHRcdFx0XHRvdGhlck5leHQgPSBvdGhlckl0ZXJhdG9yLm5leHQoKTtcblx0XHRcdFx0XHRpZiAoIXZhbHVlTmV4dC5kb25lICYmICFvdGhlck5leHQuZG9uZSkge1xuXHRcdFx0XHRcdFx0bmV4dFdoeSA9IHdoeU5vdEVxdWFsKHZhbHVlTmV4dCwgb3RoZXJOZXh0KTtcblx0XHRcdFx0XHRcdGlmIChuZXh0V2h5ICE9PSAnJykge1xuXHRcdFx0XHRcdFx0XHRyZXR1cm4gJ2l0ZXJhdGlvbiByZXN1bHRzIGFyZSBub3QgZXF1YWw6ICcgKyBuZXh0V2h5O1xuXHRcdFx0XHRcdFx0fVxuXHRcdFx0XHRcdH1cblx0XHRcdFx0fSB3aGlsZSAoIXZhbHVlTmV4dC5kb25lICYmICFvdGhlck5leHQuZG9uZSk7XG5cdFx0XHRcdGlmICh2YWx1ZU5leHQuZG9uZSAmJiAhb3RoZXJOZXh0LmRvbmUpIHsgcmV0dXJuICdmaXJzdCBhcmd1bWVudCBmaW5pc2hlZCBpdGVyYXRpbmcgYmVmb3JlIHNlY29uZCc7IH1cblx0XHRcdFx0aWYgKCF2YWx1ZU5leHQuZG9uZSAmJiBvdGhlck5leHQuZG9uZSkgeyByZXR1cm4gJ3NlY29uZCBhcmd1bWVudCBmaW5pc2hlZCBpdGVyYXRpbmcgYmVmb3JlIGZpcnN0JzsgfVxuXHRcdFx0XHRyZXR1cm4gJyc7XG5cdFx0XHR9XG5cdFx0fSBlbHNlIGlmIChjb2xsZWN0aW9uc0ZvckVhY2guTWFwIHx8IGNvbGxlY3Rpb25zRm9yRWFjaC5TZXQpIHtcblx0XHRcdHZhciB2YWx1ZUVudHJpZXMgPSB0cnlNYXBTZXRFbnRyaWVzKHZhbHVlKTtcblx0XHRcdHZhciBvdGhlckVudHJpZXMgPSB0cnlNYXBTZXRFbnRyaWVzKG90aGVyKTtcblx0XHRcdHZhciB2YWx1ZUVudHJpZXNJc0FycmF5ID0gaXNBcnJheSh2YWx1ZUVudHJpZXMpO1xuXHRcdFx0dmFyIG90aGVyRW50cmllc0lzQXJyYXkgPSBpc0FycmF5KG90aGVyRW50cmllcyk7XG5cdFx0XHRpZiAodmFsdWVFbnRyaWVzSXNBcnJheSAmJiAhb3RoZXJFbnRyaWVzSXNBcnJheSkgeyByZXR1cm4gJ2ZpcnN0IGFyZ3VtZW50IGhhcyBDb2xsZWN0aW9uIGVudHJpZXMsIHNlY29uZCBkb2VzIG5vdCc7IH1cblx0XHRcdGlmICghdmFsdWVFbnRyaWVzSXNBcnJheSAmJiBvdGhlckVudHJpZXNJc0FycmF5KSB7IHJldHVybiAnc2Vjb25kIGFyZ3VtZW50IGhhcyBDb2xsZWN0aW9uIGVudHJpZXMsIGZpcnN0IGRvZXMgbm90JzsgfVxuXHRcdFx0aWYgKHZhbHVlRW50cmllc0lzQXJyYXkgJiYgb3RoZXJFbnRyaWVzSXNBcnJheSkge1xuXHRcdFx0XHR2YXIgZW50cmllc1doeSA9IHdoeU5vdEVxdWFsKHZhbHVlRW50cmllcywgb3RoZXJFbnRyaWVzKTtcblx0XHRcdFx0cmV0dXJuIGVudHJpZXNXaHkgPT09ICcnID8gJycgOiAnQ29sbGVjdGlvbiBlbnRyaWVzIGRpZmZlcjogJyArIGVudHJpZXNXaHk7XG5cdFx0XHR9XG5cdFx0fVxuXG5cdFx0dmFyIGtleSwgdmFsdWVLZXlJc1JlY3Vyc2l2ZSwgb3RoZXJLZXlJc1JlY3Vyc2l2ZSwga2V5V2h5O1xuXHRcdGZvciAoa2V5IGluIHZhbHVlKSB7XG5cdFx0XHRpZiAoaGFzKHZhbHVlLCBrZXkpKSB7XG5cdFx0XHRcdGlmICghaGFzKG90aGVyLCBrZXkpKSB7IHJldHVybiAnZmlyc3QgYXJndW1lbnQgaGFzIGtleSBcIicgKyBrZXkgKyAnXCI7IHNlY29uZCBkb2VzIG5vdCc7IH1cblx0XHRcdFx0dmFsdWVLZXlJc1JlY3Vyc2l2ZSA9IHZhbHVlW2tleV0gJiYgdmFsdWVba2V5XVtrZXldID09PSB2YWx1ZTtcblx0XHRcdFx0b3RoZXJLZXlJc1JlY3Vyc2l2ZSA9IG90aGVyW2tleV0gJiYgb3RoZXJba2V5XVtrZXldID09PSBvdGhlcjtcblx0XHRcdFx0aWYgKHZhbHVlS2V5SXNSZWN1cnNpdmUgIT09IG90aGVyS2V5SXNSZWN1cnNpdmUpIHtcblx0XHRcdFx0XHRpZiAodmFsdWVLZXlJc1JlY3Vyc2l2ZSkgeyByZXR1cm4gJ2ZpcnN0IGFyZ3VtZW50IGhhcyBhIGNpcmN1bGFyIHJlZmVyZW5jZSBhdCBrZXkgXCInICsga2V5ICsgJ1wiOyBzZWNvbmQgZG9lcyBub3QnOyB9XG5cdFx0XHRcdFx0cmV0dXJuICdzZWNvbmQgYXJndW1lbnQgaGFzIGEgY2lyY3VsYXIgcmVmZXJlbmNlIGF0IGtleSBcIicgKyBrZXkgKyAnXCI7IGZpcnN0IGRvZXMgbm90Jztcblx0XHRcdFx0fVxuXHRcdFx0XHRpZiAoIXZhbHVlS2V5SXNSZWN1cnNpdmUgJiYgIW90aGVyS2V5SXNSZWN1cnNpdmUpIHtcblx0XHRcdFx0XHRrZXlXaHkgPSB3aHlOb3RFcXVhbCh2YWx1ZVtrZXldLCBvdGhlcltrZXldKTtcblx0XHRcdFx0XHRpZiAoa2V5V2h5ICE9PSAnJykge1xuXHRcdFx0XHRcdFx0cmV0dXJuICd2YWx1ZSBhdCBrZXkgXCInICsga2V5ICsgJ1wiIGRpZmZlcnM6ICcgKyBrZXlXaHk7XG5cdFx0XHRcdFx0fVxuXHRcdFx0XHR9XG5cdFx0XHR9XG5cdFx0fVxuXHRcdGZvciAoa2V5IGluIG90aGVyKSB7XG5cdFx0XHRpZiAoaGFzKG90aGVyLCBrZXkpICYmICFoYXModmFsdWUsIGtleSkpIHsgcmV0dXJuICdzZWNvbmQgYXJndW1lbnQgaGFzIGtleSBcIicgKyBrZXkgKyAnXCI7IGZpcnN0IGRvZXMgbm90JzsgfVxuXHRcdH1cblx0XHRyZXR1cm4gJyc7XG5cdH1cblxuXHRyZXR1cm4gZmFsc2U7XG59O1xuXG5cblxuLyoqKioqKioqKioqKioqKioqXG4gKiogV0VCUEFDSyBGT09URVJcbiAqKiAvVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9pcy1lcXVhbC93aHkuanNcbiAqKiBtb2R1bGUgaWQgPSA2XG4gKiogbW9kdWxlIGNodW5rcyA9IDBcbiAqKi8iLCJ2YXIgYmluZCA9IHJlcXVpcmUoJ2Z1bmN0aW9uLWJpbmQnKTtcblxubW9kdWxlLmV4cG9ydHMgPSBiaW5kLmNhbGwoRnVuY3Rpb24uY2FsbCwgT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eSk7XG5cblxuXG4vKioqKioqKioqKioqKioqKipcbiAqKiBXRUJQQUNLIEZPT1RFUlxuICoqIC9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2hhcy9zcmMvaW5kZXguanNcbiAqKiBtb2R1bGUgaWQgPSA3XG4gKiogbW9kdWxlIGNodW5rcyA9IDBcbiAqKi8iLCJ2YXIgaW1wbGVtZW50YXRpb24gPSByZXF1aXJlKCcuL2ltcGxlbWVudGF0aW9uJyk7XG5cbm1vZHVsZS5leHBvcnRzID0gRnVuY3Rpb24ucHJvdG90eXBlLmJpbmQgfHwgaW1wbGVtZW50YXRpb247XG5cblxuXG4vKioqKioqKioqKioqKioqKipcbiAqKiBXRUJQQUNLIEZPT1RFUlxuICoqIC9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2Z1bmN0aW9uLWJpbmQvaW5kZXguanNcbiAqKiBtb2R1bGUgaWQgPSA4XG4gKiogbW9kdWxlIGNodW5rcyA9IDBcbiAqKi8iLCJ2YXIgRVJST1JfTUVTU0FHRSA9ICdGdW5jdGlvbi5wcm90b3R5cGUuYmluZCBjYWxsZWQgb24gaW5jb21wYXRpYmxlICc7XG52YXIgc2xpY2UgPSBBcnJheS5wcm90b3R5cGUuc2xpY2U7XG52YXIgdG9TdHIgPSBPYmplY3QucHJvdG90eXBlLnRvU3RyaW5nO1xudmFyIGZ1bmNUeXBlID0gJ1tvYmplY3QgRnVuY3Rpb25dJztcblxubW9kdWxlLmV4cG9ydHMgPSBmdW5jdGlvbiBiaW5kKHRoYXQpIHtcbiAgICB2YXIgdGFyZ2V0ID0gdGhpcztcbiAgICBpZiAodHlwZW9mIHRhcmdldCAhPT0gJ2Z1bmN0aW9uJyB8fCB0b1N0ci5jYWxsKHRhcmdldCkgIT09IGZ1bmNUeXBlKSB7XG4gICAgICAgIHRocm93IG5ldyBUeXBlRXJyb3IoRVJST1JfTUVTU0FHRSArIHRhcmdldCk7XG4gICAgfVxuICAgIHZhciBhcmdzID0gc2xpY2UuY2FsbChhcmd1bWVudHMsIDEpO1xuXG4gICAgdmFyIGJvdW5kO1xuICAgIHZhciBiaW5kZXIgPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgIGlmICh0aGlzIGluc3RhbmNlb2YgYm91bmQpIHtcbiAgICAgICAgICAgIHZhciByZXN1bHQgPSB0YXJnZXQuYXBwbHkoXG4gICAgICAgICAgICAgICAgdGhpcyxcbiAgICAgICAgICAgICAgICBhcmdzLmNvbmNhdChzbGljZS5jYWxsKGFyZ3VtZW50cykpXG4gICAgICAgICAgICApO1xuICAgICAgICAgICAgaWYgKE9iamVjdChyZXN1bHQpID09PSByZXN1bHQpIHtcbiAgICAgICAgICAgICAgICByZXR1cm4gcmVzdWx0O1xuICAgICAgICAgICAgfVxuICAgICAgICAgICAgcmV0dXJuIHRoaXM7XG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICByZXR1cm4gdGFyZ2V0LmFwcGx5KFxuICAgICAgICAgICAgICAgIHRoYXQsXG4gICAgICAgICAgICAgICAgYXJncy5jb25jYXQoc2xpY2UuY2FsbChhcmd1bWVudHMpKVxuICAgICAgICAgICAgKTtcbiAgICAgICAgfVxuICAgIH07XG5cbiAgICB2YXIgYm91bmRMZW5ndGggPSBNYXRoLm1heCgwLCB0YXJnZXQubGVuZ3RoIC0gYXJncy5sZW5ndGgpO1xuICAgIHZhciBib3VuZEFyZ3MgPSBbXTtcbiAgICBmb3IgKHZhciBpID0gMDsgaSA8IGJvdW5kTGVuZ3RoOyBpKyspIHtcbiAgICAgICAgYm91bmRBcmdzLnB1c2goJyQnICsgaSk7XG4gICAgfVxuXG4gICAgYm91bmQgPSBGdW5jdGlvbignYmluZGVyJywgJ3JldHVybiBmdW5jdGlvbiAoJyArIGJvdW5kQXJncy5qb2luKCcsJykgKyAnKXsgcmV0dXJuIGJpbmRlci5hcHBseSh0aGlzLGFyZ3VtZW50cyk7IH0nKShiaW5kZXIpO1xuXG4gICAgaWYgKHRhcmdldC5wcm90b3R5cGUpIHtcbiAgICAgICAgdmFyIEVtcHR5ID0gZnVuY3Rpb24gRW1wdHkoKSB7fTtcbiAgICAgICAgRW1wdHkucHJvdG90eXBlID0gdGFyZ2V0LnByb3RvdHlwZTtcbiAgICAgICAgYm91bmQucHJvdG90eXBlID0gbmV3IEVtcHR5KCk7XG4gICAgICAgIEVtcHR5LnByb3RvdHlwZSA9IG51bGw7XG4gICAgfVxuXG4gICAgcmV0dXJuIGJvdW5kO1xufTtcblxuXG5cbi8qKioqKioqKioqKioqKioqKlxuICoqIFdFQlBBQ0sgRk9PVEVSXG4gKiogL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vZnVuY3Rpb24tYmluZC9pbXBsZW1lbnRhdGlvbi5qc1xuICoqIG1vZHVsZSBpZCA9IDlcbiAqKiBtb2R1bGUgY2h1bmtzID0gMFxuICoqLyIsIid1c2Ugc3RyaWN0JztcblxudmFyIGlzQ2FsbGFibGUgPSByZXF1aXJlKCdpcy1jYWxsYWJsZScpO1xudmFyIGZuVG9TdHIgPSBGdW5jdGlvbi5wcm90b3R5cGUudG9TdHJpbmc7XG52YXIgaXNOb25BcnJvd0ZuUmVnZXggPSAvXlxccypmdW5jdGlvbi87XG52YXIgaXNBcnJvd0ZuV2l0aFBhcmVuc1JlZ2V4ID0gL15cXChbXlxcKV0qXFwpICo9Pi87XG52YXIgaXNBcnJvd0ZuV2l0aG91dFBhcmVuc1JlZ2V4ID0gL15bXj1dKj0+LztcblxubW9kdWxlLmV4cG9ydHMgPSBmdW5jdGlvbiBpc0Fycm93RnVuY3Rpb24oZm4pIHtcblx0aWYgKCFpc0NhbGxhYmxlKGZuKSkgeyByZXR1cm4gZmFsc2U7IH1cblx0dmFyIGZuU3RyID0gZm5Ub1N0ci5jYWxsKGZuKTtcblx0cmV0dXJuIGZuU3RyLmxlbmd0aCA+IDAgJiZcblx0XHQhaXNOb25BcnJvd0ZuUmVnZXgudGVzdChmblN0cikgJiZcblx0XHQoaXNBcnJvd0ZuV2l0aFBhcmVuc1JlZ2V4LnRlc3QoZm5TdHIpIHx8IGlzQXJyb3dGbldpdGhvdXRQYXJlbnNSZWdleC50ZXN0KGZuU3RyKSk7XG59O1xuXG5cblxuLyoqKioqKioqKioqKioqKioqXG4gKiogV0VCUEFDSyBGT09URVJcbiAqKiAvVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9pcy1hcnJvdy1mdW5jdGlvbi9pbmRleC5qc1xuICoqIG1vZHVsZSBpZCA9IDEwXG4gKiogbW9kdWxlIGNodW5rcyA9IDBcbiAqKi8iLCIndXNlIHN0cmljdCc7XG5cbnZhciBmblRvU3RyID0gRnVuY3Rpb24ucHJvdG90eXBlLnRvU3RyaW5nO1xuXG52YXIgY29uc3RydWN0b3JSZWdleCA9IC9eXFxzKmNsYXNzIC87XG52YXIgaXNFUzZDbGFzc0ZuID0gZnVuY3Rpb24gaXNFUzZDbGFzc0ZuKHZhbHVlKSB7XG5cdHRyeSB7XG5cdFx0dmFyIGZuU3RyID0gZm5Ub1N0ci5jYWxsKHZhbHVlKTtcblx0XHR2YXIgc2luZ2xlU3RyaXBwZWQgPSBmblN0ci5yZXBsYWNlKC9cXC9cXC8uKlxcbi9nLCAnJyk7XG5cdFx0dmFyIG11bHRpU3RyaXBwZWQgPSBzaW5nbGVTdHJpcHBlZC5yZXBsYWNlKC9cXC9cXCpbLlxcc1xcU10qXFwqXFwvL2csICcnKTtcblx0XHR2YXIgc3BhY2VTdHJpcHBlZCA9IG11bHRpU3RyaXBwZWQucmVwbGFjZSgvXFxuL21nLCAnICcpLnJlcGxhY2UoLyB7Mn0vZywgJyAnKTtcblx0XHRyZXR1cm4gY29uc3RydWN0b3JSZWdleC50ZXN0KHNwYWNlU3RyaXBwZWQpO1xuXHR9IGNhdGNoIChlKSB7XG5cdFx0cmV0dXJuIGZhbHNlOyAvLyBub3QgYSBmdW5jdGlvblxuXHR9XG59O1xuXG52YXIgdHJ5RnVuY3Rpb25PYmplY3QgPSBmdW5jdGlvbiB0cnlGdW5jdGlvbk9iamVjdCh2YWx1ZSkge1xuXHR0cnkge1xuXHRcdGlmIChpc0VTNkNsYXNzRm4odmFsdWUpKSB7IHJldHVybiBmYWxzZTsgfVxuXHRcdGZuVG9TdHIuY2FsbCh2YWx1ZSk7XG5cdFx0cmV0dXJuIHRydWU7XG5cdH0gY2F0Y2ggKGUpIHtcblx0XHRyZXR1cm4gZmFsc2U7XG5cdH1cbn07XG52YXIgdG9TdHIgPSBPYmplY3QucHJvdG90eXBlLnRvU3RyaW5nO1xudmFyIGZuQ2xhc3MgPSAnW29iamVjdCBGdW5jdGlvbl0nO1xudmFyIGdlbkNsYXNzID0gJ1tvYmplY3QgR2VuZXJhdG9yRnVuY3Rpb25dJztcbnZhciBoYXNUb1N0cmluZ1RhZyA9IHR5cGVvZiBTeW1ib2wgPT09ICdmdW5jdGlvbicgJiYgdHlwZW9mIFN5bWJvbC50b1N0cmluZ1RhZyA9PT0gJ3N5bWJvbCc7XG5cbm1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24gaXNDYWxsYWJsZSh2YWx1ZSkge1xuXHRpZiAoIXZhbHVlKSB7IHJldHVybiBmYWxzZTsgfVxuXHRpZiAodHlwZW9mIHZhbHVlICE9PSAnZnVuY3Rpb24nICYmIHR5cGVvZiB2YWx1ZSAhPT0gJ29iamVjdCcpIHsgcmV0dXJuIGZhbHNlOyB9XG5cdGlmIChoYXNUb1N0cmluZ1RhZykgeyByZXR1cm4gdHJ5RnVuY3Rpb25PYmplY3QodmFsdWUpOyB9XG5cdGlmIChpc0VTNkNsYXNzRm4odmFsdWUpKSB7IHJldHVybiBmYWxzZTsgfVxuXHR2YXIgc3RyQ2xhc3MgPSB0b1N0ci5jYWxsKHZhbHVlKTtcblx0cmV0dXJuIHN0ckNsYXNzID09PSBmbkNsYXNzIHx8IHN0ckNsYXNzID09PSBnZW5DbGFzcztcbn07XG5cblxuXG4vKioqKioqKioqKioqKioqKipcbiAqKiBXRUJQQUNLIEZPT1RFUlxuICoqIC9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLWNhbGxhYmxlL2luZGV4LmpzXG4gKiogbW9kdWxlIGlkID0gMTFcbiAqKiBtb2R1bGUgY2h1bmtzID0gMFxuICoqLyIsIid1c2Ugc3RyaWN0JztcblxudmFyIGJvb2xUb1N0ciA9IEJvb2xlYW4ucHJvdG90eXBlLnRvU3RyaW5nO1xuXG52YXIgdHJ5Qm9vbGVhbk9iamVjdCA9IGZ1bmN0aW9uIHRyeUJvb2xlYW5PYmplY3QodmFsdWUpIHtcblx0dHJ5IHtcblx0XHRib29sVG9TdHIuY2FsbCh2YWx1ZSk7XG5cdFx0cmV0dXJuIHRydWU7XG5cdH0gY2F0Y2ggKGUpIHtcblx0XHRyZXR1cm4gZmFsc2U7XG5cdH1cbn07XG52YXIgdG9TdHIgPSBPYmplY3QucHJvdG90eXBlLnRvU3RyaW5nO1xudmFyIGJvb2xDbGFzcyA9ICdbb2JqZWN0IEJvb2xlYW5dJztcbnZhciBoYXNUb1N0cmluZ1RhZyA9IHR5cGVvZiBTeW1ib2wgPT09ICdmdW5jdGlvbicgJiYgdHlwZW9mIFN5bWJvbC50b1N0cmluZ1RhZyA9PT0gJ3N5bWJvbCc7XG5cbm1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24gaXNCb29sZWFuKHZhbHVlKSB7XG5cdGlmICh0eXBlb2YgdmFsdWUgPT09ICdib29sZWFuJykgeyByZXR1cm4gdHJ1ZTsgfVxuXHRpZiAodHlwZW9mIHZhbHVlICE9PSAnb2JqZWN0JykgeyByZXR1cm4gZmFsc2U7IH1cblx0cmV0dXJuIGhhc1RvU3RyaW5nVGFnID8gdHJ5Qm9vbGVhbk9iamVjdCh2YWx1ZSkgOiB0b1N0ci5jYWxsKHZhbHVlKSA9PT0gYm9vbENsYXNzO1xufTtcblxuXG5cbi8qKioqKioqKioqKioqKioqKlxuICoqIFdFQlBBQ0sgRk9PVEVSXG4gKiogL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vaXMtYm9vbGVhbi1vYmplY3QvaW5kZXguanNcbiAqKiBtb2R1bGUgaWQgPSAxMlxuICoqIG1vZHVsZSBjaHVua3MgPSAwXG4gKiovIiwiJ3VzZSBzdHJpY3QnO1xuXG52YXIgZ2V0RGF5ID0gRGF0ZS5wcm90b3R5cGUuZ2V0RGF5O1xudmFyIHRyeURhdGVPYmplY3QgPSBmdW5jdGlvbiB0cnlEYXRlT2JqZWN0KHZhbHVlKSB7XG5cdHRyeSB7XG5cdFx0Z2V0RGF5LmNhbGwodmFsdWUpO1xuXHRcdHJldHVybiB0cnVlO1xuXHR9IGNhdGNoIChlKSB7XG5cdFx0cmV0dXJuIGZhbHNlO1xuXHR9XG59O1xuXG52YXIgdG9TdHIgPSBPYmplY3QucHJvdG90eXBlLnRvU3RyaW5nO1xudmFyIGRhdGVDbGFzcyA9ICdbb2JqZWN0IERhdGVdJztcbnZhciBoYXNUb1N0cmluZ1RhZyA9IHR5cGVvZiBTeW1ib2wgPT09ICdmdW5jdGlvbicgJiYgdHlwZW9mIFN5bWJvbC50b1N0cmluZ1RhZyA9PT0gJ3N5bWJvbCc7XG5cbm1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24gaXNEYXRlT2JqZWN0KHZhbHVlKSB7XG5cdGlmICh0eXBlb2YgdmFsdWUgIT09ICdvYmplY3QnIHx8IHZhbHVlID09PSBudWxsKSB7IHJldHVybiBmYWxzZTsgfVxuXHRyZXR1cm4gaGFzVG9TdHJpbmdUYWcgPyB0cnlEYXRlT2JqZWN0KHZhbHVlKSA6IHRvU3RyLmNhbGwodmFsdWUpID09PSBkYXRlQ2xhc3M7XG59O1xuXG5cblxuLyoqKioqKioqKioqKioqKioqXG4gKiogV0VCUEFDSyBGT09URVJcbiAqKiAvVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9pcy1kYXRlLW9iamVjdC9pbmRleC5qc1xuICoqIG1vZHVsZSBpZCA9IDEzXG4gKiogbW9kdWxlIGNodW5rcyA9IDBcbiAqKi8iLCIndXNlIHN0cmljdCc7XG5cbnZhciB0b1N0ciA9IE9iamVjdC5wcm90b3R5cGUudG9TdHJpbmc7XG52YXIgZm5Ub1N0ciA9IEZ1bmN0aW9uLnByb3RvdHlwZS50b1N0cmluZztcbnZhciBpc0ZuUmVnZXggPSAvXlxccypmdW5jdGlvblxcKi87XG5cbm1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24gaXNHZW5lcmF0b3JGdW5jdGlvbihmbikge1xuXHRpZiAodHlwZW9mIGZuICE9PSAnZnVuY3Rpb24nKSB7IHJldHVybiBmYWxzZTsgfVxuXHR2YXIgZm5TdHIgPSB0b1N0ci5jYWxsKGZuKTtcblx0cmV0dXJuIChmblN0ciA9PT0gJ1tvYmplY3QgRnVuY3Rpb25dJyB8fCBmblN0ciA9PT0gJ1tvYmplY3QgR2VuZXJhdG9yRnVuY3Rpb25dJykgJiYgaXNGblJlZ2V4LnRlc3QoZm5Ub1N0ci5jYWxsKGZuKSk7XG59O1xuXG5cblxuXG4vKioqKioqKioqKioqKioqKipcbiAqKiBXRUJQQUNLIEZPT1RFUlxuICoqIC9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLWdlbmVyYXRvci1mdW5jdGlvbi9pbmRleC5qc1xuICoqIG1vZHVsZSBpZCA9IDE0XG4gKiogbW9kdWxlIGNodW5rcyA9IDBcbiAqKi8iLCIndXNlIHN0cmljdCc7XG5cbnZhciBudW1Ub1N0ciA9IE51bWJlci5wcm90b3R5cGUudG9TdHJpbmc7XG52YXIgdHJ5TnVtYmVyT2JqZWN0ID0gZnVuY3Rpb24gdHJ5TnVtYmVyT2JqZWN0KHZhbHVlKSB7XG5cdHRyeSB7XG5cdFx0bnVtVG9TdHIuY2FsbCh2YWx1ZSk7XG5cdFx0cmV0dXJuIHRydWU7XG5cdH0gY2F0Y2ggKGUpIHtcblx0XHRyZXR1cm4gZmFsc2U7XG5cdH1cbn07XG52YXIgdG9TdHIgPSBPYmplY3QucHJvdG90eXBlLnRvU3RyaW5nO1xudmFyIG51bUNsYXNzID0gJ1tvYmplY3QgTnVtYmVyXSc7XG52YXIgaGFzVG9TdHJpbmdUYWcgPSB0eXBlb2YgU3ltYm9sID09PSAnZnVuY3Rpb24nICYmIHR5cGVvZiBTeW1ib2wudG9TdHJpbmdUYWcgPT09ICdzeW1ib2wnO1xuXG5tb2R1bGUuZXhwb3J0cyA9IGZ1bmN0aW9uIGlzTnVtYmVyT2JqZWN0KHZhbHVlKSB7XG5cdGlmICh0eXBlb2YgdmFsdWUgPT09ICdudW1iZXInKSB7IHJldHVybiB0cnVlOyB9XG5cdGlmICh0eXBlb2YgdmFsdWUgIT09ICdvYmplY3QnKSB7IHJldHVybiBmYWxzZTsgfVxuXHRyZXR1cm4gaGFzVG9TdHJpbmdUYWcgPyB0cnlOdW1iZXJPYmplY3QodmFsdWUpIDogdG9TdHIuY2FsbCh2YWx1ZSkgPT09IG51bUNsYXNzO1xufTtcblxuXG5cbi8qKioqKioqKioqKioqKioqKlxuICoqIFdFQlBBQ0sgRk9PVEVSXG4gKiogL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vaXMtbnVtYmVyLW9iamVjdC9pbmRleC5qc1xuICoqIG1vZHVsZSBpZCA9IDE1XG4gKiogbW9kdWxlIGNodW5rcyA9IDBcbiAqKi8iLCIndXNlIHN0cmljdCc7XG5cbnZhciByZWdleEV4ZWMgPSBSZWdFeHAucHJvdG90eXBlLmV4ZWM7XG52YXIgdHJ5UmVnZXhFeGVjID0gZnVuY3Rpb24gdHJ5UmVnZXhFeGVjKHZhbHVlKSB7XG5cdHRyeSB7XG5cdFx0cmVnZXhFeGVjLmNhbGwodmFsdWUpO1xuXHRcdHJldHVybiB0cnVlO1xuXHR9IGNhdGNoIChlKSB7XG5cdFx0cmV0dXJuIGZhbHNlO1xuXHR9XG59O1xudmFyIHRvU3RyID0gT2JqZWN0LnByb3RvdHlwZS50b1N0cmluZztcbnZhciByZWdleENsYXNzID0gJ1tvYmplY3QgUmVnRXhwXSc7XG52YXIgaGFzVG9TdHJpbmdUYWcgPSB0eXBlb2YgU3ltYm9sID09PSAnZnVuY3Rpb24nICYmIHR5cGVvZiBTeW1ib2wudG9TdHJpbmdUYWcgPT09ICdzeW1ib2wnO1xuXG5tb2R1bGUuZXhwb3J0cyA9IGZ1bmN0aW9uIGlzUmVnZXgodmFsdWUpIHtcblx0aWYgKHR5cGVvZiB2YWx1ZSAhPT0gJ29iamVjdCcpIHsgcmV0dXJuIGZhbHNlOyB9XG5cdHJldHVybiBoYXNUb1N0cmluZ1RhZyA/IHRyeVJlZ2V4RXhlYyh2YWx1ZSkgOiB0b1N0ci5jYWxsKHZhbHVlKSA9PT0gcmVnZXhDbGFzcztcbn07XG5cblxuXG4vKioqKioqKioqKioqKioqKipcbiAqKiBXRUJQQUNLIEZPT1RFUlxuICoqIC9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLXJlZ2V4L2luZGV4LmpzXG4gKiogbW9kdWxlIGlkID0gMTZcbiAqKiBtb2R1bGUgY2h1bmtzID0gMFxuICoqLyIsIid1c2Ugc3RyaWN0JztcblxudmFyIHN0clZhbHVlID0gU3RyaW5nLnByb3RvdHlwZS52YWx1ZU9mO1xudmFyIHRyeVN0cmluZ09iamVjdCA9IGZ1bmN0aW9uIHRyeVN0cmluZ09iamVjdCh2YWx1ZSkge1xuXHR0cnkge1xuXHRcdHN0clZhbHVlLmNhbGwodmFsdWUpO1xuXHRcdHJldHVybiB0cnVlO1xuXHR9IGNhdGNoIChlKSB7XG5cdFx0cmV0dXJuIGZhbHNlO1xuXHR9XG59O1xudmFyIHRvU3RyID0gT2JqZWN0LnByb3RvdHlwZS50b1N0cmluZztcbnZhciBzdHJDbGFzcyA9ICdbb2JqZWN0IFN0cmluZ10nO1xudmFyIGhhc1RvU3RyaW5nVGFnID0gdHlwZW9mIFN5bWJvbCA9PT0gJ2Z1bmN0aW9uJyAmJiB0eXBlb2YgU3ltYm9sLnRvU3RyaW5nVGFnID09PSAnc3ltYm9sJztcblxubW9kdWxlLmV4cG9ydHMgPSBmdW5jdGlvbiBpc1N0cmluZyh2YWx1ZSkge1xuXHRpZiAodHlwZW9mIHZhbHVlID09PSAnc3RyaW5nJykgeyByZXR1cm4gdHJ1ZTsgfVxuXHRpZiAodHlwZW9mIHZhbHVlICE9PSAnb2JqZWN0JykgeyByZXR1cm4gZmFsc2U7IH1cblx0cmV0dXJuIGhhc1RvU3RyaW5nVGFnID8gdHJ5U3RyaW5nT2JqZWN0KHZhbHVlKSA6IHRvU3RyLmNhbGwodmFsdWUpID09PSBzdHJDbGFzcztcbn07XG5cblxuXG4vKioqKioqKioqKioqKioqKipcbiAqKiBXRUJQQUNLIEZPT1RFUlxuICoqIC9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLXN0cmluZy9pbmRleC5qc1xuICoqIG1vZHVsZSBpZCA9IDE3XG4gKiogbW9kdWxlIGNodW5rcyA9IDBcbiAqKi8iLCIndXNlIHN0cmljdCc7XG5cbnZhciB0b1N0ciA9IE9iamVjdC5wcm90b3R5cGUudG9TdHJpbmc7XG52YXIgaGFzU3ltYm9scyA9IHR5cGVvZiBTeW1ib2wgPT09ICdmdW5jdGlvbicgJiYgdHlwZW9mIFN5bWJvbCgpID09PSAnc3ltYm9sJztcblxuaWYgKGhhc1N5bWJvbHMpIHtcblx0dmFyIHN5bVRvU3RyID0gU3ltYm9sLnByb3RvdHlwZS50b1N0cmluZztcblx0dmFyIHN5bVN0cmluZ1JlZ2V4ID0gL15TeW1ib2xcXCguKlxcKSQvO1xuXHR2YXIgaXNTeW1ib2xPYmplY3QgPSBmdW5jdGlvbiBpc1N5bWJvbE9iamVjdCh2YWx1ZSkge1xuXHRcdGlmICh0eXBlb2YgdmFsdWUudmFsdWVPZigpICE9PSAnc3ltYm9sJykgeyByZXR1cm4gZmFsc2U7IH1cblx0XHRyZXR1cm4gc3ltU3RyaW5nUmVnZXgudGVzdChzeW1Ub1N0ci5jYWxsKHZhbHVlKSk7XG5cdH07XG5cdG1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24gaXNTeW1ib2wodmFsdWUpIHtcblx0XHRpZiAodHlwZW9mIHZhbHVlID09PSAnc3ltYm9sJykgeyByZXR1cm4gdHJ1ZTsgfVxuXHRcdGlmICh0b1N0ci5jYWxsKHZhbHVlKSAhPT0gJ1tvYmplY3QgU3ltYm9sXScpIHsgcmV0dXJuIGZhbHNlOyB9XG5cdFx0dHJ5IHtcblx0XHRcdHJldHVybiBpc1N5bWJvbE9iamVjdCh2YWx1ZSk7XG5cdFx0fSBjYXRjaCAoZSkge1xuXHRcdFx0cmV0dXJuIGZhbHNlO1xuXHRcdH1cblx0fTtcbn0gZWxzZSB7XG5cdG1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24gaXNTeW1ib2wodmFsdWUpIHtcblx0XHQvLyB0aGlzIGVudmlyb25tZW50IGRvZXMgbm90IHN1cHBvcnQgU3ltYm9scy5cblx0XHRyZXR1cm4gZmFsc2U7XG5cdH07XG59XG5cblxuXG4vKioqKioqKioqKioqKioqKipcbiAqKiBXRUJQQUNLIEZPT1RFUlxuICoqIC9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLXN5bWJvbC9pbmRleC5qc1xuICoqIG1vZHVsZSBpZCA9IDE4XG4gKiogbW9kdWxlIGNodW5rcyA9IDBcbiAqKi8iLCIndXNlIHN0cmljdCc7XG5cbnZhciBpc1N5bWJvbCA9IHJlcXVpcmUoJ2lzLXN5bWJvbCcpO1xuXG5tb2R1bGUuZXhwb3J0cyA9IGZ1bmN0aW9uIGdldFN5bWJvbEl0ZXJhdG9yKCkge1xuXHR2YXIgc3ltYm9sSXRlcmF0b3IgPSB0eXBlb2YgU3ltYm9sID09PSAnZnVuY3Rpb24nICYmIGlzU3ltYm9sKFN5bWJvbC5pdGVyYXRvcikgPyBTeW1ib2wuaXRlcmF0b3IgOiBudWxsO1xuXG5cdGlmICh0eXBlb2YgT2JqZWN0LmdldE93blByb3BlcnR5TmFtZXMgPT09ICdmdW5jdGlvbicgJiYgdHlwZW9mIE1hcCA9PT0gJ2Z1bmN0aW9uJyAmJiB0eXBlb2YgTWFwLnByb3RvdHlwZS5lbnRyaWVzID09PSAnZnVuY3Rpb24nKSB7XG5cdFx0T2JqZWN0LmdldE93blByb3BlcnR5TmFtZXMoTWFwLnByb3RvdHlwZSkuZm9yRWFjaChmdW5jdGlvbiAobmFtZSkge1xuXHRcdFx0aWYgKG5hbWUgIT09ICdlbnRyaWVzJyAmJiBuYW1lICE9PSAnc2l6ZScgJiYgTWFwLnByb3RvdHlwZVtuYW1lXSA9PT0gTWFwLnByb3RvdHlwZS5lbnRyaWVzKSB7XG5cdFx0XHRcdHN5bWJvbEl0ZXJhdG9yID0gbmFtZTtcblx0XHRcdH1cblx0XHR9KTtcblx0fVxuXG5cdHJldHVybiBzeW1ib2xJdGVyYXRvcjtcbn07XG5cblxuXG4vKioqKioqKioqKioqKioqKipcbiAqKiBXRUJQQUNLIEZPT1RFUlxuICoqIC9Vc2Vycy9aZW5rby9TaXRlcy9IYWNrc3Rlci9oYWNrc3Rlci9+L2lzLWVxdWFsL2dldFN5bWJvbEl0ZXJhdG9yLmpzXG4gKiogbW9kdWxlIGlkID0gMTlcbiAqKiBtb2R1bGUgY2h1bmtzID0gMFxuICoqLyIsIid1c2Ugc3RyaWN0JztcblxubW9kdWxlLmV4cG9ydHMgPSBmdW5jdGlvbiAoKSB7XG5cdHZhciBtYXBGb3JFYWNoID0gKGZ1bmN0aW9uICgpIHtcblx0XHRpZiAodHlwZW9mIE1hcCAhPT0gJ2Z1bmN0aW9uJykgeyByZXR1cm4gbnVsbDsgfVxuXHRcdHRyeSB7XG5cdFx0XHRNYXAucHJvdG90eXBlLmZvckVhY2guY2FsbCh7fSwgZnVuY3Rpb24gKCkge30pO1xuXHRcdH0gY2F0Y2ggKGUpIHtcblx0XHRcdHJldHVybiBNYXAucHJvdG90eXBlLmZvckVhY2g7XG5cdFx0fVxuXHRcdHJldHVybiBudWxsO1xuXHR9KCkpO1xuXG5cdHZhciBzZXRGb3JFYWNoID0gKGZ1bmN0aW9uICgpIHtcblx0XHRpZiAodHlwZW9mIFNldCAhPT0gJ2Z1bmN0aW9uJykgeyByZXR1cm4gbnVsbDsgfVxuXHRcdHRyeSB7XG5cdFx0XHRTZXQucHJvdG90eXBlLmZvckVhY2guY2FsbCh7fSwgZnVuY3Rpb24gKCkge30pO1xuXHRcdH0gY2F0Y2ggKGUpIHtcblx0XHRcdHJldHVybiBTZXQucHJvdG90eXBlLmZvckVhY2g7XG5cdFx0fVxuXHRcdHJldHVybiBudWxsO1xuXHR9KCkpO1xuXG5cdHJldHVybiB7IE1hcDogbWFwRm9yRWFjaCwgU2V0OiBzZXRGb3JFYWNoIH07XG59O1xuXG5cblxuLyoqKioqKioqKioqKioqKioqXG4gKiogV0VCUEFDSyBGT09URVJcbiAqKiAvVXNlcnMvWmVua28vU2l0ZXMvSGFja3N0ZXIvaGFja3N0ZXIvfi9pcy1lcXVhbC9nZXRDb2xsZWN0aW9uc0ZvckVhY2guanNcbiAqKiBtb2R1bGUgaWQgPSAyMFxuICoqIG1vZHVsZSBjaHVua3MgPSAwXG4gKiovIiwiJ3VzZSBzdHJpY3QnO1xuXG5PYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgXCJfX2VzTW9kdWxlXCIsIHtcbiAgdmFsdWU6IHRydWVcbn0pO1xuXG52YXIgX29iamVjdEluc3BlY3QgPSByZXF1aXJlKCdvYmplY3QtaW5zcGVjdCcpO1xuXG52YXIgX29iamVjdEluc3BlY3QyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfb2JqZWN0SW5zcGVjdCk7XG5cbmZ1bmN0aW9uIF9pbnRlcm9wUmVxdWlyZURlZmF1bHQob2JqKSB7IHJldHVybiBvYmogJiYgb2JqLl9fZXNNb2R1bGUgPyBvYmogOiB7IGRlZmF1bHQ6IG9iaiB9OyB9XG5cbmZ1bmN0aW9uIGFzc2VydChjb25kaXRpb24sIG1lc3NhZ2VGb3JtYXQpIHtcbiAgZm9yICh2YXIgX2xlbiA9IGFyZ3VtZW50cy5sZW5ndGgsIGV4dHJhQXJncyA9IEFycmF5KF9sZW4gPiAyID8gX2xlbiAtIDIgOiAwKSwgX2tleSA9IDI7IF9rZXkgPCBfbGVuOyBfa2V5KyspIHtcbiAgICBleHRyYUFyZ3NbX2tleSAtIDJdID0gYXJndW1lbnRzW19rZXldO1xuICB9XG5cbiAgaWYgKGNvbmRpdGlvbikgcmV0dXJuO1xuXG4gIHZhciBpbmRleCA9IDA7XG5cbiAgdGhyb3cgbmV3IEVycm9yKG1lc3NhZ2VGb3JtYXQucmVwbGFjZSgvJXMvZywgZnVuY3Rpb24gKCkge1xuICAgIHJldHVybiAoMCwgX29iamVjdEluc3BlY3QyLmRlZmF1bHQpKGV4dHJhQXJnc1tpbmRleCsrXSk7XG4gIH0pKTtcbn1cblxuZXhwb3J0cy5kZWZhdWx0ID0gYXNzZXJ0O1xuXG5cbi8qKioqKioqKioqKioqKioqKlxuICoqIFdFQlBBQ0sgRk9PVEVSXG4gKiogL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vZXhwZWN0L2xpYi9hc3NlcnQuanNcbiAqKiBtb2R1bGUgaWQgPSAyMVxuICoqIG1vZHVsZSBjaHVua3MgPSAwXG4gKiovIiwidmFyIGhhc01hcCA9IHR5cGVvZiBNYXAgPT09ICdmdW5jdGlvbicgJiYgTWFwLnByb3RvdHlwZTtcbnZhciBtYXBTaXplRGVzY3JpcHRvciA9IE9iamVjdC5nZXRPd25Qcm9wZXJ0eURlc2NyaXB0b3IgJiYgaGFzTWFwID8gT2JqZWN0LmdldE93blByb3BlcnR5RGVzY3JpcHRvcihNYXAucHJvdG90eXBlLCAnc2l6ZScpIDogbnVsbDtcbnZhciBtYXBTaXplID0gaGFzTWFwICYmIG1hcFNpemVEZXNjcmlwdG9yICYmIHR5cGVvZiBtYXBTaXplRGVzY3JpcHRvci5nZXQgPT09ICdmdW5jdGlvbicgPyBtYXBTaXplRGVzY3JpcHRvci5nZXQgOiBudWxsO1xudmFyIG1hcEZvckVhY2ggPSBoYXNNYXAgJiYgTWFwLnByb3RvdHlwZS5mb3JFYWNoO1xudmFyIGhhc1NldCA9IHR5cGVvZiBTZXQgPT09ICdmdW5jdGlvbicgJiYgU2V0LnByb3RvdHlwZTtcbnZhciBzZXRTaXplRGVzY3JpcHRvciA9IE9iamVjdC5nZXRPd25Qcm9wZXJ0eURlc2NyaXB0b3IgJiYgaGFzU2V0ID8gT2JqZWN0LmdldE93blByb3BlcnR5RGVzY3JpcHRvcihTZXQucHJvdG90eXBlLCAnc2l6ZScpIDogbnVsbDtcbnZhciBzZXRTaXplID0gaGFzU2V0ICYmIHNldFNpemVEZXNjcmlwdG9yICYmIHR5cGVvZiBzZXRTaXplRGVzY3JpcHRvci5nZXQgPT09ICdmdW5jdGlvbicgPyBzZXRTaXplRGVzY3JpcHRvci5nZXQgOiBudWxsO1xudmFyIHNldEZvckVhY2ggPSBoYXNTZXQgJiYgU2V0LnByb3RvdHlwZS5mb3JFYWNoO1xuXG5tb2R1bGUuZXhwb3J0cyA9IGZ1bmN0aW9uIGluc3BlY3RfIChvYmosIG9wdHMsIGRlcHRoLCBzZWVuKSB7XG4gICAgaWYgKCFvcHRzKSBvcHRzID0ge307XG4gICAgXG4gICAgdmFyIG1heERlcHRoID0gb3B0cy5kZXB0aCA9PT0gdW5kZWZpbmVkID8gNSA6IG9wdHMuZGVwdGg7XG4gICAgaWYgKGRlcHRoID09PSB1bmRlZmluZWQpIGRlcHRoID0gMDtcbiAgICBpZiAoZGVwdGggPj0gbWF4RGVwdGggJiYgbWF4RGVwdGggPiAwXG4gICAgJiYgb2JqICYmIHR5cGVvZiBvYmogPT09ICdvYmplY3QnKSB7XG4gICAgICAgIHJldHVybiAnW09iamVjdF0nO1xuICAgIH1cbiAgICBcbiAgICBpZiAoc2VlbiA9PT0gdW5kZWZpbmVkKSBzZWVuID0gW107XG4gICAgZWxzZSBpZiAoaW5kZXhPZihzZWVuLCBvYmopID49IDApIHtcbiAgICAgICAgcmV0dXJuICdbQ2lyY3VsYXJdJztcbiAgICB9XG4gICAgXG4gICAgZnVuY3Rpb24gaW5zcGVjdCAodmFsdWUsIGZyb20pIHtcbiAgICAgICAgaWYgKGZyb20pIHtcbiAgICAgICAgICAgIHNlZW4gPSBzZWVuLnNsaWNlKCk7XG4gICAgICAgICAgICBzZWVuLnB1c2goZnJvbSk7XG4gICAgICAgIH1cbiAgICAgICAgcmV0dXJuIGluc3BlY3RfKHZhbHVlLCBvcHRzLCBkZXB0aCArIDEsIHNlZW4pO1xuICAgIH1cbiAgICBcbiAgICBpZiAodHlwZW9mIG9iaiA9PT0gJ3N0cmluZycpIHtcbiAgICAgICAgcmV0dXJuIGluc3BlY3RTdHJpbmcob2JqKTtcbiAgICB9XG4gICAgZWxzZSBpZiAodHlwZW9mIG9iaiA9PT0gJ2Z1bmN0aW9uJykge1xuICAgICAgICB2YXIgbmFtZSA9IG5hbWVPZihvYmopO1xuICAgICAgICByZXR1cm4gJ1tGdW5jdGlvbicgKyAobmFtZSA/ICc6ICcgKyBuYW1lIDogJycpICsgJ10nO1xuICAgIH1cbiAgICBlbHNlIGlmIChvYmogPT09IG51bGwpIHtcbiAgICAgICAgcmV0dXJuICdudWxsJztcbiAgICB9XG4gICAgZWxzZSBpZiAoaXNTeW1ib2wob2JqKSkge1xuICAgICAgICB2YXIgc3ltU3RyaW5nID0gU3ltYm9sLnByb3RvdHlwZS50b1N0cmluZy5jYWxsKG9iaik7XG4gICAgICAgIHJldHVybiB0eXBlb2Ygb2JqID09PSAnb2JqZWN0JyA/ICdPYmplY3QoJyArIHN5bVN0cmluZyArICcpJyA6IHN5bVN0cmluZztcbiAgICB9XG4gICAgZWxzZSBpZiAoaXNFbGVtZW50KG9iaikpIHtcbiAgICAgICAgdmFyIHMgPSAnPCcgKyBTdHJpbmcob2JqLm5vZGVOYW1lKS50b0xvd2VyQ2FzZSgpO1xuICAgICAgICB2YXIgYXR0cnMgPSBvYmouYXR0cmlidXRlcyB8fCBbXTtcbiAgICAgICAgZm9yICh2YXIgaSA9IDA7IGkgPCBhdHRycy5sZW5ndGg7IGkrKykge1xuICAgICAgICAgICAgcyArPSAnICcgKyBhdHRyc1tpXS5uYW1lICsgJz1cIicgKyBxdW90ZShhdHRyc1tpXS52YWx1ZSkgKyAnXCInO1xuICAgICAgICB9XG4gICAgICAgIHMgKz0gJz4nO1xuICAgICAgICBpZiAob2JqLmNoaWxkTm9kZXMgJiYgb2JqLmNoaWxkTm9kZXMubGVuZ3RoKSBzICs9ICcuLi4nO1xuICAgICAgICBzICs9ICc8LycgKyBTdHJpbmcob2JqLm5vZGVOYW1lKS50b0xvd2VyQ2FzZSgpICsgJz4nO1xuICAgICAgICByZXR1cm4gcztcbiAgICB9XG4gICAgZWxzZSBpZiAoaXNBcnJheShvYmopKSB7XG4gICAgICAgIGlmIChvYmoubGVuZ3RoID09PSAwKSByZXR1cm4gJ1tdJztcbiAgICAgICAgdmFyIHhzID0gQXJyYXkob2JqLmxlbmd0aCk7XG4gICAgICAgIGZvciAodmFyIGkgPSAwOyBpIDwgb2JqLmxlbmd0aDsgaSsrKSB7XG4gICAgICAgICAgICB4c1tpXSA9IGhhcyhvYmosIGkpID8gaW5zcGVjdChvYmpbaV0sIG9iaikgOiAnJztcbiAgICAgICAgfVxuICAgICAgICByZXR1cm4gJ1sgJyArIHhzLmpvaW4oJywgJykgKyAnIF0nO1xuICAgIH1cbiAgICBlbHNlIGlmIChpc0Vycm9yKG9iaikpIHtcbiAgICAgICAgdmFyIHBhcnRzID0gW107XG4gICAgICAgIGZvciAodmFyIGtleSBpbiBvYmopIHtcbiAgICAgICAgICAgIGlmICghaGFzKG9iaiwga2V5KSkgY29udGludWU7XG4gICAgICAgICAgICBcbiAgICAgICAgICAgIGlmICgvW15cXHckXS8udGVzdChrZXkpKSB7XG4gICAgICAgICAgICAgICAgcGFydHMucHVzaChpbnNwZWN0KGtleSkgKyAnOiAnICsgaW5zcGVjdChvYmpba2V5XSkpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgICAgZWxzZSB7XG4gICAgICAgICAgICAgICAgcGFydHMucHVzaChrZXkgKyAnOiAnICsgaW5zcGVjdChvYmpba2V5XSkpO1xuICAgICAgICAgICAgfVxuICAgICAgICB9XG4gICAgICAgIGlmIChwYXJ0cy5sZW5ndGggPT09IDApIHJldHVybiAnWycgKyBvYmogKyAnXSc7XG4gICAgICAgIHJldHVybiAneyBbJyArIG9iaiArICddICcgKyBwYXJ0cy5qb2luKCcsICcpICsgJyB9JztcbiAgICB9XG4gICAgZWxzZSBpZiAodHlwZW9mIG9iaiA9PT0gJ29iamVjdCcgJiYgdHlwZW9mIG9iai5pbnNwZWN0ID09PSAnZnVuY3Rpb24nKSB7XG4gICAgICAgIHJldHVybiBvYmouaW5zcGVjdCgpO1xuICAgIH1cbiAgICBlbHNlIGlmIChpc01hcChvYmopKSB7XG4gICAgICAgIHZhciBwYXJ0cyA9IFtdO1xuICAgICAgICBtYXBGb3JFYWNoLmNhbGwob2JqLCBmdW5jdGlvbiAodmFsdWUsIGtleSkge1xuICAgICAgICAgICAgcGFydHMucHVzaChpbnNwZWN0KGtleSwgb2JqKSArICcgPT4gJyArIGluc3BlY3QodmFsdWUsIG9iaikpO1xuICAgICAgICB9KTtcbiAgICAgICAgcmV0dXJuICdNYXAgKCcgKyBtYXBTaXplLmNhbGwob2JqKSArICcpIHsnICsgcGFydHMuam9pbignLCAnKSArICd9JztcbiAgICB9XG4gICAgZWxzZSBpZiAoaXNTZXQob2JqKSkge1xuICAgICAgICB2YXIgcGFydHMgPSBbXTtcbiAgICAgICAgc2V0Rm9yRWFjaC5jYWxsKG9iaiwgZnVuY3Rpb24gKHZhbHVlICkge1xuICAgICAgICAgICAgcGFydHMucHVzaChpbnNwZWN0KHZhbHVlLCBvYmopKTtcbiAgICAgICAgfSk7XG4gICAgICAgIHJldHVybiAnU2V0ICgnICsgc2V0U2l6ZS5jYWxsKG9iaikgKyAnKSB7JyArIHBhcnRzLmpvaW4oJywgJykgKyAnfSc7XG4gICAgfVxuICAgIGVsc2UgaWYgKHR5cGVvZiBvYmogPT09ICdvYmplY3QnICYmICFpc0RhdGUob2JqKSAmJiAhaXNSZWdFeHAob2JqKSkge1xuICAgICAgICB2YXIgeHMgPSBbXSwga2V5cyA9IFtdO1xuICAgICAgICBmb3IgKHZhciBrZXkgaW4gb2JqKSB7XG4gICAgICAgICAgICBpZiAoaGFzKG9iaiwga2V5KSkga2V5cy5wdXNoKGtleSk7XG4gICAgICAgIH1cbiAgICAgICAga2V5cy5zb3J0KCk7XG4gICAgICAgIGZvciAodmFyIGkgPSAwOyBpIDwga2V5cy5sZW5ndGg7IGkrKykge1xuICAgICAgICAgICAgdmFyIGtleSA9IGtleXNbaV07XG4gICAgICAgICAgICBpZiAoL1teXFx3JF0vLnRlc3Qoa2V5KSkge1xuICAgICAgICAgICAgICAgIHhzLnB1c2goaW5zcGVjdChrZXkpICsgJzogJyArIGluc3BlY3Qob2JqW2tleV0sIG9iaikpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgICAgZWxzZSB4cy5wdXNoKGtleSArICc6ICcgKyBpbnNwZWN0KG9ialtrZXldLCBvYmopKTtcbiAgICAgICAgfVxuICAgICAgICBpZiAoeHMubGVuZ3RoID09PSAwKSByZXR1cm4gJ3t9JztcbiAgICAgICAgcmV0dXJuICd7ICcgKyB4cy5qb2luKCcsICcpICsgJyB9JztcbiAgICB9XG4gICAgZWxzZSByZXR1cm4gU3RyaW5nKG9iaik7XG59O1xuXG5mdW5jdGlvbiBxdW90ZSAocykge1xuICAgIHJldHVybiBTdHJpbmcocykucmVwbGFjZSgvXCIvZywgJyZxdW90OycpO1xufVxuXG5mdW5jdGlvbiBpc0FycmF5IChvYmopIHsgcmV0dXJuIHRvU3RyKG9iaikgPT09ICdbb2JqZWN0IEFycmF5XScgfVxuZnVuY3Rpb24gaXNEYXRlIChvYmopIHsgcmV0dXJuIHRvU3RyKG9iaikgPT09ICdbb2JqZWN0IERhdGVdJyB9XG5mdW5jdGlvbiBpc1JlZ0V4cCAob2JqKSB7IHJldHVybiB0b1N0cihvYmopID09PSAnW29iamVjdCBSZWdFeHBdJyB9XG5mdW5jdGlvbiBpc0Vycm9yIChvYmopIHsgcmV0dXJuIHRvU3RyKG9iaikgPT09ICdbb2JqZWN0IEVycm9yXScgfVxuZnVuY3Rpb24gaXNTeW1ib2wgKG9iaikgeyByZXR1cm4gdG9TdHIob2JqKSA9PT0gJ1tvYmplY3QgU3ltYm9sXScgfVxuXG52YXIgaGFzT3duID0gT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eSB8fCBmdW5jdGlvbiAoa2V5KSB7IHJldHVybiBrZXkgaW4gdGhpczsgfTtcbmZ1bmN0aW9uIGhhcyAob2JqLCBrZXkpIHtcbiAgICByZXR1cm4gaGFzT3duLmNhbGwob2JqLCBrZXkpO1xufVxuXG5mdW5jdGlvbiB0b1N0ciAob2JqKSB7XG4gICAgcmV0dXJuIE9iamVjdC5wcm90b3R5cGUudG9TdHJpbmcuY2FsbChvYmopO1xufVxuXG5mdW5jdGlvbiBuYW1lT2YgKGYpIHtcbiAgICBpZiAoZi5uYW1lKSByZXR1cm4gZi5uYW1lO1xuICAgIHZhciBtID0gZi50b1N0cmluZygpLm1hdGNoKC9eZnVuY3Rpb25cXHMqKFtcXHckXSspLyk7XG4gICAgaWYgKG0pIHJldHVybiBtWzFdO1xufVxuXG5mdW5jdGlvbiBpbmRleE9mICh4cywgeCkge1xuICAgIGlmICh4cy5pbmRleE9mKSByZXR1cm4geHMuaW5kZXhPZih4KTtcbiAgICBmb3IgKHZhciBpID0gMCwgbCA9IHhzLmxlbmd0aDsgaSA8IGw7IGkrKykge1xuICAgICAgICBpZiAoeHNbaV0gPT09IHgpIHJldHVybiBpO1xuICAgIH1cbiAgICByZXR1cm4gLTE7XG59XG5cbmZ1bmN0aW9uIGlzTWFwICh4KSB7XG4gICAgaWYgKCFtYXBTaXplKSB7XG4gICAgICAgIHJldHVybiBmYWxzZTtcbiAgICB9XG4gICAgdHJ5IHtcbiAgICAgICAgbWFwU2l6ZS5jYWxsKHgpO1xuICAgICAgICByZXR1cm4gdHJ1ZTtcbiAgICB9IGNhdGNoIChlKSB7fVxuICAgIHJldHVybiBmYWxzZTtcbn1cblxuZnVuY3Rpb24gaXNTZXQgKHgpIHtcbiAgICBpZiAoIXNldFNpemUpIHtcbiAgICAgICAgcmV0dXJuIGZhbHNlO1xuICAgIH1cbiAgICB0cnkge1xuICAgICAgICBzZXRTaXplLmNhbGwoeCk7XG4gICAgICAgIHJldHVybiB0cnVlO1xuICAgIH0gY2F0Y2ggKGUpIHt9XG4gICAgcmV0dXJuIGZhbHNlO1xufVxuXG5mdW5jdGlvbiBpc0VsZW1lbnQgKHgpIHtcbiAgICBpZiAoIXggfHwgdHlwZW9mIHggIT09ICdvYmplY3QnKSByZXR1cm4gZmFsc2U7XG4gICAgaWYgKHR5cGVvZiBIVE1MRWxlbWVudCAhPT0gJ3VuZGVmaW5lZCcgJiYgeCBpbnN0YW5jZW9mIEhUTUxFbGVtZW50KSB7XG4gICAgICAgIHJldHVybiB0cnVlO1xuICAgIH1cbiAgICByZXR1cm4gdHlwZW9mIHgubm9kZU5hbWUgPT09ICdzdHJpbmcnXG4gICAgICAgICYmIHR5cGVvZiB4LmdldEF0dHJpYnV0ZSA9PT0gJ2Z1bmN0aW9uJ1xuICAgIDtcbn1cblxuZnVuY3Rpb24gaW5zcGVjdFN0cmluZyAoc3RyKSB7XG4gICAgdmFyIHMgPSBzdHIucmVwbGFjZSgvKFsnXFxcXF0pL2csICdcXFxcJDEnKS5yZXBsYWNlKC9bXFx4MDAtXFx4MWZdL2csIGxvd2J5dGUpO1xuICAgIHJldHVybiBcIidcIiArIHMgKyBcIidcIjtcbiAgICBcbiAgICBmdW5jdGlvbiBsb3dieXRlIChjKSB7XG4gICAgICAgIHZhciBuID0gYy5jaGFyQ29kZUF0KDApO1xuICAgICAgICB2YXIgeCA9IHsgODogJ2InLCA5OiAndCcsIDEwOiAnbicsIDEyOiAnZicsIDEzOiAncicgfVtuXTtcbiAgICAgICAgaWYgKHgpIHJldHVybiAnXFxcXCcgKyB4O1xuICAgICAgICByZXR1cm4gJ1xcXFx4JyArIChuIDwgMHgxMCA/ICcwJyA6ICcnKSArIG4udG9TdHJpbmcoMTYpO1xuICAgIH1cbn1cblxuXG5cbi8qKioqKioqKioqKioqKioqKlxuICoqIFdFQlBBQ0sgRk9PVEVSXG4gKiogL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vb2JqZWN0LWluc3BlY3QvaW5kZXguanNcbiAqKiBtb2R1bGUgaWQgPSAyMlxuICoqIG1vZHVsZSBjaHVua3MgPSAwXG4gKiovIiwiJ3VzZSBzdHJpY3QnO1xuXG5PYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgXCJfX2VzTW9kdWxlXCIsIHtcbiAgdmFsdWU6IHRydWVcbn0pO1xuZXhwb3J0cy5yZXN0b3JlU3BpZXMgPSBleHBvcnRzLmlzU3B5ID0gdW5kZWZpbmVkO1xuZXhwb3J0cy5jcmVhdGVTcHkgPSBjcmVhdGVTcHk7XG5leHBvcnRzLnNweU9uID0gc3B5T247XG5cbnZhciBfYXNzZXJ0ID0gcmVxdWlyZSgnLi9hc3NlcnQnKTtcblxudmFyIF9hc3NlcnQyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfYXNzZXJ0KTtcblxudmFyIF9UZXN0VXRpbHMgPSByZXF1aXJlKCcuL1Rlc3RVdGlscycpO1xuXG5mdW5jdGlvbiBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIG9iai5fX2VzTW9kdWxlID8gb2JqIDogeyBkZWZhdWx0OiBvYmogfTsgfVxuXG4vKiBlc2xpbnQtZGlzYWJsZSBwcmVmZXItcmVzdC1wYXJhbXMgKi9cblxuXG52YXIgbm9vcCA9IGZ1bmN0aW9uIG5vb3AoKSB7fTtcblxudmFyIGlzU3B5ID0gZXhwb3J0cy5pc1NweSA9IGZ1bmN0aW9uIGlzU3B5KG9iamVjdCkge1xuICByZXR1cm4gb2JqZWN0ICYmIG9iamVjdC5fX2lzU3B5ID09PSB0cnVlO1xufTtcblxudmFyIHNwaWVzID0gW107XG5cbnZhciByZXN0b3JlU3BpZXMgPSBleHBvcnRzLnJlc3RvcmVTcGllcyA9IGZ1bmN0aW9uIHJlc3RvcmVTcGllcygpIHtcbiAgZm9yICh2YXIgaSA9IHNwaWVzLmxlbmd0aCAtIDE7IGkgPj0gMDsgaS0tKSB7XG4gICAgc3BpZXNbaV0ucmVzdG9yZSgpO1xuICB9c3BpZXMgPSBbXTtcbn07XG5cbmZ1bmN0aW9uIGNyZWF0ZVNweShmbikge1xuICB2YXIgcmVzdG9yZSA9IGFyZ3VtZW50cy5sZW5ndGggPD0gMSB8fCBhcmd1bWVudHNbMV0gPT09IHVuZGVmaW5lZCA/IG5vb3AgOiBhcmd1bWVudHNbMV07XG5cbiAgaWYgKGZuID09IG51bGwpIGZuID0gbm9vcDtcblxuICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9UZXN0VXRpbHMuaXNGdW5jdGlvbikoZm4pLCAnY3JlYXRlU3B5IG5lZWRzIGEgZnVuY3Rpb24nKTtcblxuICB2YXIgdGFyZ2V0Rm4gPSB2b2lkIDAsXG4gICAgICB0aHJvd25WYWx1ZSA9IHZvaWQgMCxcbiAgICAgIHJldHVyblZhbHVlID0gdm9pZCAwO1xuXG4gIHZhciBzcHkgPSBmdW5jdGlvbiBzcHkoKSB7XG4gICAgc3B5LmNhbGxzLnB1c2goe1xuICAgICAgY29udGV4dDogdGhpcyxcbiAgICAgIGFyZ3VtZW50czogQXJyYXkucHJvdG90eXBlLnNsaWNlLmNhbGwoYXJndW1lbnRzLCAwKVxuICAgIH0pO1xuXG4gICAgaWYgKHRhcmdldEZuKSByZXR1cm4gdGFyZ2V0Rm4uYXBwbHkodGhpcywgYXJndW1lbnRzKTtcblxuICAgIGlmICh0aHJvd25WYWx1ZSkgdGhyb3cgdGhyb3duVmFsdWU7XG5cbiAgICByZXR1cm4gcmV0dXJuVmFsdWU7XG4gIH07XG5cbiAgc3B5LmNhbGxzID0gW107XG5cbiAgc3B5LmFuZENhbGwgPSBmdW5jdGlvbiAob3RoZXJGbikge1xuICAgIHRhcmdldEZuID0gb3RoZXJGbjtcbiAgICByZXR1cm4gc3B5O1xuICB9O1xuXG4gIHNweS5hbmRDYWxsVGhyb3VnaCA9IGZ1bmN0aW9uICgpIHtcbiAgICByZXR1cm4gc3B5LmFuZENhbGwoZm4pO1xuICB9O1xuXG4gIHNweS5hbmRUaHJvdyA9IGZ1bmN0aW9uIChvYmplY3QpIHtcbiAgICB0aHJvd25WYWx1ZSA9IG9iamVjdDtcbiAgICByZXR1cm4gc3B5O1xuICB9O1xuXG4gIHNweS5hbmRSZXR1cm4gPSBmdW5jdGlvbiAodmFsdWUpIHtcbiAgICByZXR1cm5WYWx1ZSA9IHZhbHVlO1xuICAgIHJldHVybiBzcHk7XG4gIH07XG5cbiAgc3B5LmdldExhc3RDYWxsID0gZnVuY3Rpb24gKCkge1xuICAgIHJldHVybiBzcHkuY2FsbHNbc3B5LmNhbGxzLmxlbmd0aCAtIDFdO1xuICB9O1xuXG4gIHNweS5yZXNldCA9IGZ1bmN0aW9uICgpIHtcbiAgICBzcHkuY2FsbHMgPSBbXTtcbiAgfTtcblxuICBzcHkucmVzdG9yZSA9IHNweS5kZXN0cm95ID0gcmVzdG9yZTtcblxuICBzcHkuX19pc1NweSA9IHRydWU7XG5cbiAgc3BpZXMucHVzaChzcHkpO1xuXG4gIHJldHVybiBzcHk7XG59XG5cbmZ1bmN0aW9uIHNweU9uKG9iamVjdCwgbWV0aG9kTmFtZSkge1xuICB2YXIgb3JpZ2luYWwgPSBvYmplY3RbbWV0aG9kTmFtZV07XG5cbiAgaWYgKCFpc1NweShvcmlnaW5hbCkpIHtcbiAgICAoMCwgX2Fzc2VydDIuZGVmYXVsdCkoKDAsIF9UZXN0VXRpbHMuaXNGdW5jdGlvbikob3JpZ2luYWwpLCAnQ2Fubm90IHNweU9uIHRoZSAlcyBwcm9wZXJ0eTsgaXQgaXMgbm90IGEgZnVuY3Rpb24nLCBtZXRob2ROYW1lKTtcblxuICAgIG9iamVjdFttZXRob2ROYW1lXSA9IGNyZWF0ZVNweShvcmlnaW5hbCwgZnVuY3Rpb24gKCkge1xuICAgICAgb2JqZWN0W21ldGhvZE5hbWVdID0gb3JpZ2luYWw7XG4gICAgfSk7XG4gIH1cblxuICByZXR1cm4gb2JqZWN0W21ldGhvZE5hbWVdO1xufVxuXG5cbi8qKioqKioqKioqKioqKioqKlxuICoqIFdFQlBBQ0sgRk9PVEVSXG4gKiogL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vZXhwZWN0L2xpYi9TcHlVdGlscy5qc1xuICoqIG1vZHVsZSBpZCA9IDIzXG4gKiogbW9kdWxlIGNodW5rcyA9IDBcbiAqKi8iLCIndXNlIHN0cmljdCc7XG5cbk9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBcIl9fZXNNb2R1bGVcIiwge1xuICB2YWx1ZTogdHJ1ZVxufSk7XG5leHBvcnRzLnN0cmluZ0NvbnRhaW5zID0gZXhwb3J0cy5vYmplY3RDb250YWlucyA9IGV4cG9ydHMuYXJyYXlDb250YWlucyA9IGV4cG9ydHMuZnVuY3Rpb25UaHJvd3MgPSBleHBvcnRzLmlzQSA9IGV4cG9ydHMuaXNPYmplY3QgPSBleHBvcnRzLmlzQXJyYXkgPSBleHBvcnRzLmlzRnVuY3Rpb24gPSB1bmRlZmluZWQ7XG5cbnZhciBfdHlwZW9mID0gdHlwZW9mIFN5bWJvbCA9PT0gXCJmdW5jdGlvblwiICYmIHR5cGVvZiBTeW1ib2wuaXRlcmF0b3IgPT09IFwic3ltYm9sXCIgPyBmdW5jdGlvbiAob2JqKSB7IHJldHVybiB0eXBlb2Ygb2JqOyB9IDogZnVuY3Rpb24gKG9iaikgeyByZXR1cm4gb2JqICYmIHR5cGVvZiBTeW1ib2wgPT09IFwiZnVuY3Rpb25cIiAmJiBvYmouY29uc3RydWN0b3IgPT09IFN5bWJvbCA/IFwic3ltYm9sXCIgOiB0eXBlb2Ygb2JqOyB9O1xuXG52YXIgX2lzRXF1YWwgPSByZXF1aXJlKCdpcy1lcXVhbCcpO1xuXG52YXIgX2lzRXF1YWwyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfaXNFcXVhbCk7XG5cbnZhciBfaXNSZWdleCA9IHJlcXVpcmUoJ2lzLXJlZ2V4Jyk7XG5cbnZhciBfaXNSZWdleDIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9pc1JlZ2V4KTtcblxuZnVuY3Rpb24gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChvYmopIHsgcmV0dXJuIG9iaiAmJiBvYmouX19lc01vZHVsZSA/IG9iaiA6IHsgZGVmYXVsdDogb2JqIH07IH1cblxuLyoqXG4gKiBSZXR1cm5zIHRydWUgaWYgdGhlIGdpdmVuIG9iamVjdCBpcyBhIGZ1bmN0aW9uLlxuICovXG52YXIgaXNGdW5jdGlvbiA9IGV4cG9ydHMuaXNGdW5jdGlvbiA9IGZ1bmN0aW9uIGlzRnVuY3Rpb24ob2JqZWN0KSB7XG4gIHJldHVybiB0eXBlb2Ygb2JqZWN0ID09PSAnZnVuY3Rpb24nO1xufTtcblxuLyoqXG4gKiBSZXR1cm5zIHRydWUgaWYgdGhlIGdpdmVuIG9iamVjdCBpcyBhbiBhcnJheS5cbiAqL1xudmFyIGlzQXJyYXkgPSBleHBvcnRzLmlzQXJyYXkgPSBmdW5jdGlvbiBpc0FycmF5KG9iamVjdCkge1xuICByZXR1cm4gQXJyYXkuaXNBcnJheShvYmplY3QpO1xufTtcblxuLyoqXG4gKiBSZXR1cm5zIHRydWUgaWYgdGhlIGdpdmVuIG9iamVjdCBpcyBhbiBvYmplY3QuXG4gKi9cbnZhciBpc09iamVjdCA9IGV4cG9ydHMuaXNPYmplY3QgPSBmdW5jdGlvbiBpc09iamVjdChvYmplY3QpIHtcbiAgcmV0dXJuIG9iamVjdCAmJiAhaXNBcnJheShvYmplY3QpICYmICh0eXBlb2Ygb2JqZWN0ID09PSAndW5kZWZpbmVkJyA/ICd1bmRlZmluZWQnIDogX3R5cGVvZihvYmplY3QpKSA9PT0gJ29iamVjdCc7XG59O1xuXG4vKipcbiAqIFJldHVybnMgdHJ1ZSBpZiB0aGUgZ2l2ZW4gb2JqZWN0IGlzIGFuIGluc3RhbmNlb2YgdmFsdWVcbiAqIG9yIGl0cyB0eXBlb2YgaXMgdGhlIGdpdmVuIHZhbHVlLlxuICovXG52YXIgaXNBID0gZXhwb3J0cy5pc0EgPSBmdW5jdGlvbiBpc0Eob2JqZWN0LCB2YWx1ZSkge1xuICBpZiAoaXNGdW5jdGlvbih2YWx1ZSkpIHJldHVybiBvYmplY3QgaW5zdGFuY2VvZiB2YWx1ZTtcblxuICBpZiAodmFsdWUgPT09ICdhcnJheScpIHJldHVybiBBcnJheS5pc0FycmF5KG9iamVjdCk7XG5cbiAgcmV0dXJuICh0eXBlb2Ygb2JqZWN0ID09PSAndW5kZWZpbmVkJyA/ICd1bmRlZmluZWQnIDogX3R5cGVvZihvYmplY3QpKSA9PT0gdmFsdWU7XG59O1xuXG4vKipcbiAqIFJldHVybnMgdHJ1ZSBpZiB0aGUgZ2l2ZW4gZnVuY3Rpb24gdGhyb3dzIHRoZSBnaXZlbiB2YWx1ZVxuICogd2hlbiBpbnZva2VkLiBUaGUgdmFsdWUgbWF5IGJlOlxuICpcbiAqIC0gdW5kZWZpbmVkLCB0byBtZXJlbHkgYXNzZXJ0IHRoZXJlIHdhcyBhIHRocm93XG4gKiAtIGEgY29uc3RydWN0b3IgZnVuY3Rpb24sIGZvciBjb21wYXJpbmcgdXNpbmcgaW5zdGFuY2VvZlxuICogLSBhIHJlZ3VsYXIgZXhwcmVzc2lvbiwgdG8gY29tcGFyZSB3aXRoIHRoZSBlcnJvciBtZXNzYWdlXG4gKiAtIGEgc3RyaW5nLCB0byBmaW5kIGluIHRoZSBlcnJvciBtZXNzYWdlXG4gKi9cbnZhciBmdW5jdGlvblRocm93cyA9IGV4cG9ydHMuZnVuY3Rpb25UaHJvd3MgPSBmdW5jdGlvbiBmdW5jdGlvblRocm93cyhmbiwgY29udGV4dCwgYXJncywgdmFsdWUpIHtcbiAgdHJ5IHtcbiAgICBmbi5hcHBseShjb250ZXh0LCBhcmdzKTtcbiAgfSBjYXRjaCAoZXJyb3IpIHtcbiAgICBpZiAodmFsdWUgPT0gbnVsbCkgcmV0dXJuIHRydWU7XG5cbiAgICBpZiAoaXNGdW5jdGlvbih2YWx1ZSkgJiYgZXJyb3IgaW5zdGFuY2VvZiB2YWx1ZSkgcmV0dXJuIHRydWU7XG5cbiAgICB2YXIgbWVzc2FnZSA9IGVycm9yLm1lc3NhZ2UgfHwgZXJyb3I7XG5cbiAgICBpZiAodHlwZW9mIG1lc3NhZ2UgPT09ICdzdHJpbmcnKSB7XG4gICAgICBpZiAoKDAsIF9pc1JlZ2V4Mi5kZWZhdWx0KSh2YWx1ZSkgJiYgdmFsdWUudGVzdChlcnJvci5tZXNzYWdlKSkgcmV0dXJuIHRydWU7XG5cbiAgICAgIGlmICh0eXBlb2YgdmFsdWUgPT09ICdzdHJpbmcnICYmIG1lc3NhZ2UuaW5kZXhPZih2YWx1ZSkgIT09IC0xKSByZXR1cm4gdHJ1ZTtcbiAgICB9XG4gIH1cblxuICByZXR1cm4gZmFsc2U7XG59O1xuXG4vKipcbiAqIFJldHVybnMgdHJ1ZSBpZiB0aGUgZ2l2ZW4gYXJyYXkgY29udGFpbnMgdGhlIHZhbHVlLCBmYWxzZVxuICogb3RoZXJ3aXNlLiBUaGUgY29tcGFyZVZhbHVlcyBmdW5jdGlvbiBtdXN0IHJldHVybiBmYWxzZSB0b1xuICogaW5kaWNhdGUgYSBub24tbWF0Y2guXG4gKi9cbnZhciBhcnJheUNvbnRhaW5zID0gZXhwb3J0cy5hcnJheUNvbnRhaW5zID0gZnVuY3Rpb24gYXJyYXlDb250YWlucyhhcnJheSwgdmFsdWUsIGNvbXBhcmVWYWx1ZXMpIHtcbiAgaWYgKGNvbXBhcmVWYWx1ZXMgPT0gbnVsbCkgY29tcGFyZVZhbHVlcyA9IF9pc0VxdWFsMi5kZWZhdWx0O1xuXG4gIHJldHVybiBhcnJheS5zb21lKGZ1bmN0aW9uIChpdGVtKSB7XG4gICAgcmV0dXJuIGNvbXBhcmVWYWx1ZXMoaXRlbSwgdmFsdWUpICE9PSBmYWxzZTtcbiAgfSk7XG59O1xuXG4vKipcbiAqIFJldHVybnMgdHJ1ZSBpZiB0aGUgZ2l2ZW4gb2JqZWN0IGNvbnRhaW5zIHRoZSB2YWx1ZSwgZmFsc2VcbiAqIG90aGVyd2lzZS4gVGhlIGNvbXBhcmVWYWx1ZXMgZnVuY3Rpb24gbXVzdCByZXR1cm4gZmFsc2UgdG9cbiAqIGluZGljYXRlIGEgbm9uLW1hdGNoLlxuICovXG52YXIgb2JqZWN0Q29udGFpbnMgPSBleHBvcnRzLm9iamVjdENvbnRhaW5zID0gZnVuY3Rpb24gb2JqZWN0Q29udGFpbnMob2JqZWN0LCB2YWx1ZSwgY29tcGFyZVZhbHVlcykge1xuICBpZiAoY29tcGFyZVZhbHVlcyA9PSBudWxsKSBjb21wYXJlVmFsdWVzID0gX2lzRXF1YWwyLmRlZmF1bHQ7XG5cbiAgcmV0dXJuIE9iamVjdC5rZXlzKHZhbHVlKS5ldmVyeShmdW5jdGlvbiAoaykge1xuICAgIGlmIChpc09iamVjdChvYmplY3Rba10pKSB7XG4gICAgICByZXR1cm4gb2JqZWN0Q29udGFpbnMob2JqZWN0W2tdLCB2YWx1ZVtrXSwgY29tcGFyZVZhbHVlcyk7XG4gICAgfVxuXG4gICAgcmV0dXJuIGNvbXBhcmVWYWx1ZXMob2JqZWN0W2tdLCB2YWx1ZVtrXSk7XG4gIH0pO1xufTtcblxuLyoqXG4gKiBSZXR1cm5zIHRydWUgaWYgdGhlIGdpdmVuIHN0cmluZyBjb250YWlucyB0aGUgdmFsdWUsIGZhbHNlIG90aGVyd2lzZS5cbiAqL1xudmFyIHN0cmluZ0NvbnRhaW5zID0gZXhwb3J0cy5zdHJpbmdDb250YWlucyA9IGZ1bmN0aW9uIHN0cmluZ0NvbnRhaW5zKHN0cmluZywgdmFsdWUpIHtcbiAgcmV0dXJuIHN0cmluZy5pbmRleE9mKHZhbHVlKSAhPT0gLTE7XG59O1xuXG5cbi8qKioqKioqKioqKioqKioqKlxuICoqIFdFQlBBQ0sgRk9PVEVSXG4gKiogL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vZXhwZWN0L2xpYi9UZXN0VXRpbHMuanNcbiAqKiBtb2R1bGUgaWQgPSAyNFxuICoqIG1vZHVsZSBjaHVua3MgPSAwXG4gKiovIiwiJ3VzZSBzdHJpY3QnO1xuXG5PYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgXCJfX2VzTW9kdWxlXCIsIHtcbiAgdmFsdWU6IHRydWVcbn0pO1xuXG52YXIgX0V4cGVjdGF0aW9uID0gcmVxdWlyZSgnLi9FeHBlY3RhdGlvbicpO1xuXG52YXIgX0V4cGVjdGF0aW9uMiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX0V4cGVjdGF0aW9uKTtcblxuZnVuY3Rpb24gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChvYmopIHsgcmV0dXJuIG9iaiAmJiBvYmouX19lc01vZHVsZSA/IG9iaiA6IHsgZGVmYXVsdDogb2JqIH07IH1cblxudmFyIEV4dGVuc2lvbnMgPSBbXTtcblxuZnVuY3Rpb24gZXh0ZW5kKGV4dGVuc2lvbikge1xuICBpZiAoRXh0ZW5zaW9ucy5pbmRleE9mKGV4dGVuc2lvbikgPT09IC0xKSB7XG4gICAgRXh0ZW5zaW9ucy5wdXNoKGV4dGVuc2lvbik7XG5cbiAgICBmb3IgKHZhciBwIGluIGV4dGVuc2lvbikge1xuICAgICAgaWYgKGV4dGVuc2lvbi5oYXNPd25Qcm9wZXJ0eShwKSkgX0V4cGVjdGF0aW9uMi5kZWZhdWx0LnByb3RvdHlwZVtwXSA9IGV4dGVuc2lvbltwXTtcbiAgICB9XG4gIH1cbn1cblxuZXhwb3J0cy5kZWZhdWx0ID0gZXh0ZW5kO1xuXG5cbi8qKioqKioqKioqKioqKioqKlxuICoqIFdFQlBBQ0sgRk9PVEVSXG4gKiogL1VzZXJzL1plbmtvL1NpdGVzL0hhY2tzdGVyL2hhY2tzdGVyL34vZXhwZWN0L2xpYi9leHRlbmQuanNcbiAqKiBtb2R1bGUgaWQgPSAyNVxuICoqIG1vZHVsZSBjaHVua3MgPSAwXG4gKiovIl0sInNvdXJjZVJvb3QiOiIifQ==