(function() {
  var Waveform,
	__bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Waveform = Waveform = (function() {

	Waveform.name = 'Waveform';

	function Waveform(options) {
	  this.redraw = __bind(this.redraw, this);
	  this.container = options.container;
	  this.wrapper = options.wrapper;
	  this.canvas = options.canvas;
	  this.progressWave = options.progressWave;
	  this.progressCanvas = options.progressCanvas;
	  this.data = options.data || [];
	  this.outerColor = options.outerColor || "transparent";
	  this.innerColor = options.innerColor || "#000000";
	  this.progressColor = options.progressColor || this.innerColor;
	  this.cursorColor = options.cursorColor || this.progressColor;
	  this.interpolate = true;
	  if (options.interpolate === false) {
		this.interpolate = false;
	  }
	  if (this.wrapper == null) {
		if (this.container) {
		  this.wrapper = this.createWrapper(this.container, options.width || this.container.clientWidth, options.height || this.container.clientHeight);
		} else {
		  throw "Either wrapper or container option must be passed";
		}
	  }
	  if (this.canvas == null) {
		if (this.wrapper) {
		  this.canvas = this.createCanvas(this.wrapper, options.width || this.container.clientWidth, options.height || this.container.clientHeight);
		} else {
		  throw "Either canvas or wrapper option must be passed";
		}
	  }
	  if (this.progressWave == null) {
		if (this.wrapper) {
		  this.progressWave = this.createProgressWave(this.wrapper, options.width || this.container.clientWidth, options.height || this.container.clientHeight);
		} else {
		  throw "Either progressWave or wrapper option must be passed";
		}
	  }
	  if (this.progressCanvas == null) {
		if (this.progressWave) {
		  this.progressCanvas = this.createProgressCanvas(this.progressWave, options.width || this.container.clientWidth, options.height || this.container.clientHeight);
		} else {
		  throw "Either progressCanvas or progressWave option must be passed";
		}
	  }
	  this.patchCanvasForIE(this.canvas);
	  this.patchCanvasForIE(this.progressCanvas);
	  this.context = this.canvas.getContext("2d");
	  this.width = parseInt(this.context.canvas.width, 10);
	  this.height = parseInt(this.context.canvas.height, 10);
	  this.contextProgress = this.progressCanvas.getContext("2d");

	  if (options.data) {
		this.update(options);
	  }
	}

	Waveform.prototype.setData = function(data) {
	  return this.data = data;
	};

	Waveform.prototype.setDataInterpolated = function(data) {
	  return this.setData(this.interpolateArray(data, this.width));
	};

	Waveform.prototype.setDataCropped = function(data) {
	  return this.setData(this.expandArray(data, this.width));
	};

	Waveform.prototype.update = function(options) {
	  if (options.interpolate != null) {
		this.interpolate = options.interpolate;
	  }
	  if (this.interpolate === false) {
		this.setDataCropped(options.data);
	  } else {
		this.setDataInterpolated(options.data);
	  }
	  return this.redraw();
	};

	Waveform.prototype.redraw = function() {
	  var d, i, middle, t, _i, _len, _ref, _results;
	  this.clear();
	  this.clearProgress();
	  if (typeof this.innerColor === "function") {
		this.context.fillStyle = this.innerColor();
	  } else {
		this.context.fillStyle = this.innerColor;
	  }
	  if (typeof this.progressColor === "function") {
		this.contextProgress.fillStyle = this.progressColor();
	  } else {
		this.contextProgress.fillStyle = this.progressColor;
	  }
	  middle = this.height / 2;
	  i = 0;
	  _ref = this.data;
	  _results = [];
	  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
		d = _ref[_i];
		t = this.width / this.data.length;
		if (typeof this.innerColor === "function") {
		  this.context.fillStyle = this.innerColor(i / this.width, d);
		}
		this.context.clearRect(t * i, middle - middle * d, t, middle * d * 2);
		this.context.fillRect(t * i, middle - middle * d, t, middle * d * 2);
		if (typeof this.progressColor === "function") {
		  this.contextProgress.fillStyle = this.progressColor(i / this.width, d);
		}
		this.contextProgress.clearRect(t * i, middle - middle * d, t, middle * d * 2);
		this.contextProgress.fillRect(t * i, middle - middle * d, t, middle * d * 2);
		_results.push(i++);
	  }
	  return _results;
	};

	Waveform.prototype.clear = function() {
	  this.context.fillStyle = this.outerColor;
	  this.context.clearRect(0, 0, this.width, this.height);
	  return this.context.fillRect(0, 0, this.width, this.height);
	};

	Waveform.prototype.clearProgress = function() {
	  this.contextProgress.fillStyle = this.outerColor;
	  this.contextProgress.clearRect(0, 0, this.width, this.height);
	  return this.contextProgress.fillRect(0, 0, this.width, this.height);
	};

	Waveform.prototype.patchCanvasForIE = function(canvas) {
	  var oldGetContext;
	  if (typeof window.G_vmlCanvasManager !== "undefined") {
		canvas = window.G_vmlCanvasManager.initElement(canvas);
		oldGetContext = canvas.getContext;
		return canvas.getContext = function(a) {
		  var ctx;
		  ctx = oldGetContext.apply(canvas, arguments);
		  canvas.getContext = oldGetContext;
		  return ctx;
		};
	  }
	};

	Waveform.prototype.createWrapper = function(container, width, height) {
	  var wrapper = container.appendChild(
			document.createElement("wave")
	  );	
	  this.style(wrapper, {
		display: "block",
		position: "relative",
		userSelect: "none",
		webkitUserSelect: "none",
		width: width + "px",
		height: height + "px",
		overflowX: "auto",
		overflowY: "hidden"
	  });
	  return wrapper;
	};

	Waveform.prototype.createCanvas = function(wrapper, width, height) {
	  var canvas = wrapper.appendChild(
			document.createElement("canvas")
	  );
	  this.style(canvas, {
		position: "absolute",
		zIndex: 1,
		left: 0,
		top: 0,
		bottom: 0
	  });
	  canvas.width = width;
	  canvas.height = height;
	  return canvas;
	};

	Waveform.prototype.createProgressWave = function(wrapper, width, height) {
	  var wave = wrapper.appendChild(
			document.createElement("wave")
	  );
	  this.style(wave, {
		position: "absolute",
		zIndex: 2,
		left: 0,
		top: 0,
		bottom: 0,
		overflow: "hidden",
		width: "0",
		//display: "none",
		boxSizing: "border-box",
		borderRightStyle: "solid",
		borderRightWidth: "1px",
		borderRightColor: this.cursorColor
	  });
	  return wave;
	};

	Waveform.prototype.createProgressCanvas = function(wave, width, height) {
	  var canvas = wave.appendChild(
			document.createElement("canvas")
	  );
	  this.style(canvas, {
		width: width+"px"
	  });
	  canvas.width = width;
	  canvas.height = height;
	  return canvas;
	};	

	Waveform.prototype.expandArray = function(data, limit, defaultValue) {
	  var i, newData, _i, _ref;
	  if (defaultValue == null) {
		defaultValue = 0.0;
	  }
	  newData = [];
	  if (data.length > limit) {
		newData = data.slice(data.length - limit, data.length);
	  } else {
		for (i = _i = 0, _ref = limit - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
		  newData[i] = data[i] || defaultValue;
		}
	  }
	  return newData;
	};

	Waveform.prototype.linearInterpolate = function(before, after, atPoint) {
	  return before + (after - before) * atPoint;
	};

	Waveform.prototype.interpolateArray = function(data, fitCount) {
	  var after, atPoint, before, i, newData, springFactor, tmp;
	  newData = new Array();
	  springFactor = new Number((data.length - 1) / (fitCount - 1));
	  newData[0] = data[0];
	  i = 1;
	  while (i < fitCount - 1) {
		tmp = i * springFactor;
		before = new Number(Math.floor(tmp)).toFixed();
		after = new Number(Math.ceil(tmp)).toFixed();
		atPoint = tmp - before;
		newData[i] = this.linearInterpolate(data[before], data[after], atPoint);
		i++;
	  }
	  newData[fitCount - 1] = data[data.length - 1];
	  return newData;
	};

	Waveform.prototype.style = function (el, styles) {
		Object.keys(styles).forEach(function (prop) {
			if (el.style[prop] !== styles[prop]) {
				el.style[prop] = styles[prop];
			}
		});
		return el;
	};

	return Waveform;

  })();

}).call(this);
