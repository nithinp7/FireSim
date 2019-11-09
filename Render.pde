//float gaussBlur [] = new float[] {0.016216, 0.054054, 0.1216216, 0.1945946, 0.227027, 0, 0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216};
float gaussBlur [];

void render() {
  background(0);
  /*
  //copy temperature field for bloom
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) {
      bloomBufA[i][j] = c[i][j];
      //float f = c[i][j];
      //bloomBufA[i][j] = bloomBufB[i][j] = f<0.6 ? 0.6*f : f*f;
    }
  
  //apply bloom blur
  //horizontal
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) {
      float f = c[i][j];
      //f = f<0.6 ? 0.6*f : f*f;
      if(f>bloom_threshold)
        for(int k=-BLUR_RADIUS; k<=BLUR_RADIUS; k++) 
          if((i+k)>=0 && (i+k)<n)
            bloomBufA[i+k][j] += gaussBlur[k+BLUR_RADIUS]*f;
    }
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) 
      bloomBufB[i][j] = bloomBufA[i][j];
  //vertical
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) {
      float f = bloomBufA[i][j];
      //f = f<0.6 ? 0.6*f : f*f;
      if(f>bloom_threshold)
        for(int k=-BLUR_RADIUS; k<=BLUR_RADIUS; k++) 
          if((j+k)>=0 && (j+k)<n)
            bloomBufB[i][j+k] += gaussBlur[k+BLUR_RADIUS]*f;
    }
    
  */
  loadPixels();
  for(int i=0; i<width; i++)
    for(int j=0; j<height; j++) {
      float f = c[i/SCALE][j/SCALE];//bloomBufB[i/SCALE][j/SCALE];//u[i/SCALE][j/SCALE].mag();
   
      f = f<0.6 ? 0.6*f : f*f;
      float hue = 40*(f*f)+6;
      pixels[j*width + i] = color(hue<40? hue*0.5 : hue, 90*f, 100*(hue<40?f:f));
    }
  updatePixels();
  noStroke();
  fill(0,100,100);
  for(int i=0; i<n; i+=n/20)
    for(int j=0; j<n; j+=n/20) {
      Vec2 v = u[i][j];
      float a=40, b=10;
      textSize(10);
      if(showU)
        triangle(i*SCALE + a*v.x,         j*SCALE + a*v.y,
                 i*SCALE - a*v.x + b*v.y, j*SCALE - a*v.y - b*v.x, 
                 i*SCALE - a*v.x - b*v.y, j*SCALE - a*v.y + b*v.x);
    }
}
