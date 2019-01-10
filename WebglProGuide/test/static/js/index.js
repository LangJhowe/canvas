main();
function main(){
  var gl = getGL('canvas');
  var vsFile = "static/shader/vertex.glsl";
  var fsFile = "static/shader/fragment.glsl";
  initShader(gl, vsFile, fsFile, function (sp) {
    var n = initVertexBuffers(gl, sp);

    // 设置入射光
    var u_LightColor = gl.getUniformLocation(sp, "u_LightColor");
    gl.uniform3f(u_LightColor, 1.0, 1.0, 1.0);
    var u_LightPosition = gl.getUniformLocation(sp, "u_LightPosition");
    gl.uniform3f(u_LightPosition, 2.3, 4.0, 3.5);

    // 设置环境光
    var u_LightColorAmbient = gl.getUniformLocation(sp, "u_LightColorAmbient");
    gl.uniform3f(u_LightColorAmbient, 0.2, 0.2, 0.2);

    // mvp矩阵
    var u_ModelMatrix = gl.getUniformLocation(sp, "u_ModelMatrix");
    var u_MvpMatrix = gl.getUniformLocation(sp, "u_MvpMatrix");

    // 逆转置矩阵
    var u_NormalMatrix = gl.getUniformLocation(sp, "u_NormalMatrix");


    var viewMat = lookAt(6, 6, 14, 0, 0, 0, 0, 1, 0);
    var projMat = getPerspectiveProjection(30, 16 / 9, 1, 100);

    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.enable(gl.DEPTH_TEST);

    var speed = Math.PI/4;// 角速度
    var rad = 0.0;// 启始角度
    var tick = function (timestamp) {
        var delta = g_LastTime ? (timestamp - g_LastTime) / 1000 : 0;// 上次绘制到本次绘制过去的时间(单位转换算成秒)
        g_LastTime = timestamp;// 保存本次时间
        rad = (rad + speed * delta) % (2 * Math.PI);// 当前的弧度
        draw(gl, n, rad, u_ModelMatrix, u_MvpMatrix, u_NormalMatrix, viewMat, projMat);
        requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
});
}


function getGL(id){
  if(!id)return
  var canvas = document.getElementById(id)
  return canvas.getContext('webgl')||canvas.getContext("experimental-webgl");
}
function initShader(gl, vsFile, fsFile, cb) {
  var vs = null;
  var fs = null;

  var onShaderLoaded = function () {
      if(vs && fs) {
          var sp = createProgram(gl, vs, fs);
          gl.useProgram(sp);
          cb(sp);
      }
  };

  loadShaderFromFile(vsFile, function (vsContent) {
      vs = vsContent;
      onShaderLoaded();
  });

  loadShaderFromFile(fsFile, function (fsContent) {
      fs = fsContent;
      onShaderLoaded();
  });
}

function loadShaderFromFile(filename, onLoadShader) {
  var request = new XMLHttpRequest();
  request.onreadystatechange = function () {
      if(request.readyState === 4 && request.status === 200) {
        console.log(request.responseText)
          onLoadShader(request.responseText);
      }
  };
  request.open("GET", filename, true);
  request.send();
}

function createProgram(gl, vs, fs){
  var prg = gl.createProgram()
  
}