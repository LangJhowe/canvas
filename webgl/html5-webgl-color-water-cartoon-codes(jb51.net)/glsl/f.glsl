  uniform vec2 iResolution;
  uniform float iGlobalTime;
  
  // Some utils first

  // From Stackoveflow
  // http://stackoverflow.com/questions/15095909/from-rgb-to-hsv-in-opengl-glsl
  // hsv转rgb
  vec3 hsv2rgb(vec3 c)
  {
        /*
          shaderhsv转rgb原理
          T fract(T x)方法  返回x的小数部分
          T abs(T x)方法    返回x的绝对值
          T clamp(T x, T minVal, T maxVal)
          T clamp(T x, float minVal, flat maxVal)
            min(max(x, minVal), maxVal),返回值被限定在 minVal,maxVal之间
          T mix(T x, T y, T a)
          T mix(T x, T y, float a)
            取x,y的线性混合,x*(1-a)+y*a

          假设 vec3 c=[a, v, c]
          fract(c.xxx + K.xyz) * 6.0 - K.www
          fract([a, a, a] + [0.5, 0.5, 0.5])*6 - [3,3,3]
        */
      vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
      vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
      return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
  }

  // Simplex 2D noise
  // from https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
  vec3 permute(vec3 x) {
   /*
      permute 交换；变更；排列
      T min(T x, T y) 
      T min(T x, float y)
        取x,y的余数
   */
    // return mod(((x*a   )+ b) *x, c    );
    /*
      a,b都会影响画面的条纹数 但都有上线
    */
    // return mod(((x*34.0)+1.0)*x, 289.0);
    return mod(((x*34.0)+1.0)*x, 289.0); 

  }

  float snoise(vec2 v){
      /*
        T floor(T x) 	      返回<=x的最大整数
        float dot(T x, T y) 返回x y的点积
      */
      const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                          -0.577350269189626, 0.024390243902439);
      // const vec4 C = vec4(0.5, 0.5,0.5, 0.5);
      //[1,1] + dot([1,1], [2,2])

      vec2 i  = floor(v + dot(v, C.yy) );
      vec2 x0 = v -   i + dot(i, C.xx);
      // vec2 x0 = v- i
      vec2 i1;
      
      i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
      vec4 x12 = x0.xyxy + C.xxzz;
      x12.xy -= i1;
      i = mod(i, 289.0);
      vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 ));
      vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
      m = m*m ;
      m = m*m ;
      vec3 x = 2.0 * fract(p * C.www) - 1.0;
      vec3 h = abs(x) - 0.5;
      vec3 ox = floor(x + 0.5);
      vec3 a0 = x - ox;
      m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
      vec3 g;
      g.x  = a0.x  * x0.x  + h.x  * x0.y;
      g.yz = a0.yz * x12.xz + h.yz * x12.yw;
      return 130.0 * dot(m, g);
      // return 130.0 * 
  }

	// This is my code
  void main(void)
  {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    float xnoise = snoise(vec2(uv.x, iGlobalTime / 5.0 + 10000.0));
    float ynoise = snoise(vec2(uv.y, iGlobalTime / 5.0 + 500.0));
    vec2 t = vec2(xnoise, ynoise);
    float s1 = snoise(uv + t / 2.0 + snoise(uv + snoise(uv + t/3.0) / 5.0));
    float s2 = snoise(uv + snoise(uv + s1) / 7.0);
    vec3 hsv = vec3(s1, 1.0, 1.0-s2);
    vec3 rgb = hsv2rgb(hsv);
    // vec3 rgb = vec3(1.0-s2,1.0,1.0-s2);

		gl_FragColor = vec4(rgb, 1.0);

    //iGlobalTime全局时间
		// vec2 uv = gl_FragCoord.xy / iResolution.xy; // 将坐标转换到0-1之间

    // float xnoise = snoise(vec2(uv.x, iGlobalTime / 20.0 +10000.0));//控制变化速度
    // float ynoise = snoise(vec2(uv.y, iGlobalTime / 20.0 + 500.0));//控制变化速度


    // vec2 t = vec2(xnoise, ynoise);

    // /*
    //   细节没那么丰富 可以看到分很多块
    //   s2同时也控制着颜色  必须变化 否则全局统一颜色  
    // */
    // // float s1 = snoise(uv);
    // // float s2 = snoise(uv +t);

    // // float s1 = snoise(uv + t);
    // // float s2 = snoise(uv + t);

    // /*
    //   设置 s2 t/a 可以看到很噪点
    // */

    // // float s1 = snoise(uv + t / 2.0);
    // // float s2 = snoise((uv +t/7.0));

    // /*
    
    // */
    // // float s1 = snoise(uv + t / 2.0);
    // float s1 = snoise((uv + t / 2.0 + snoise(uv + t/3.0) / 5.0));
    // float s2 = snoise((uv + t / 7.0));


    // /*
    //   origin
    // */
    // // float s1 = snoise(uv + t / 2.0 + snoise(uv + snoise(uv + t/3.0) / 5.0));
    // // float s2 = snoise((uv + snoise(uv + s1) / 7.0));




    // // float s1 = snoise(uv + t);     
    // // float s1 = snoise(uv + t / 2.0 + snoise(uv + t/3.0) / 5.0);
    // // float s1 = snoise(uv + t / 2.0 + snoise(uv + snoise(uv + t/3.0) / 5.0));
    // // float s1 = snoise(uv + t / 2.0 + snoise(uv + snoise(uv + snoise(uv + t/3.0) / 5.0) / 5.0));
    // // float s1 = snoise(uv + t / 2.0 + snoise(uv + snoise(uv + snoise(uv +  snoise(uv + t/3.0) / 5.0) / 5.0) / 5.0));


    // // float s2 = snoise(uv);     //细节没那么丰富
    // // float s2 = snoise(uv + t / 1.0); //除几控制单个部分大小
    // // float s2 = snoise(uv + t / 7.0);
    // // float s2 = snoise(uv + snoise(uv + s1) / 7.0);

    
    // vec3 hsv = vec3(s1, 0.6, 1.0-s2);
    // vec3 rgb = hsv2rgb(hsv);

    // //给点上色
		// gl_FragColor = vec4(rgb, 1.0);
		// // gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
	}