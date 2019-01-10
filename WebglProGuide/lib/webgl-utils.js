
/**
 * 获取webgl上下文
 * @function getWebGLContext(id); 
 * @param id;canvas元素id
 */
function getWebGLContext(canvas) {
  let gl = null;
  let names = ['webgl', 'experimental-webgl', 'webkit-3d', 'moz-webgl'];
  if (canvas == null) {
    alert(`canvas = null`);
    return;
  }
  for (let i in names) {
    try {
      gl = canvas.getContext(names[i]);
    } catch (e) { }
    if (gl) break;
  }
  if (gl == null) {
    alert("无法通过getContext获取webgl")
  } else {
    return gl;
  }
}

/**
 * 初始化着色器
 * @function initShaders(gl,vshaderSource,fshaderSource);
 * @param gl ;gl
 * @param vshaderSource ;定点着色器资源代码 String
 * @param fshaderSource ;片段着色器资源代码 String
 */
function initShaders(gl, vsResource, fsResource) {
  //1.分别加载定点着色器和片段着色器
  let vertexShader = loadShader(gl, gl.VERTEX_SHADER, vsResource);
  let fragmentShader = loadShader(gl, gl.FRAGMENT_SHADER, fsResource);
  //2.创建程序对象
  let program = gl.createProgram();
  //3.编译过的着色器附加到程序对象中
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  //4.连接程序对象
  gl.linkProgram(program);
  //5.调用程序对象
  gl.useProgram(program);
  gl.program = program;
}

/**
 * 加载着色器
 * @function loadShader(gl,type,source)
 * @param gl ;gl
 * @param type;
 * 加载定点着色器 type = gl.VERTEX_SHADER
 * 加载片段着色器 type = gl.FRAGMENT_SHADER
 * @source 着色器资源代码
 */
function loadShader(gl,type,source) {
  //1.创建着色器对象
  let shader = gl.createShader(type);
  //2.把着色器代码加载到着色器对象
  gl.shaderSource(shader, source);
  //3.编译着色器
  gl.compileShader(shader);
  //getShaderParameter 检查编译状态
  let compiled = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
  if (!compiled) {
    let error = gl.getShaderInfoLog(shader);
    alert(`编译着色器失败${type}：` + error);
    gl.deleteShader(shader);
    return null;
  }
  return shader;
}