
//advected velocity field 
Vec2 [][] u_a;

//forward and reverse advected color field 
float [][] c0_a,
           c1_a,
//divergence field
           d,
//pressure field
//TODO: investigate if this extra copy of p is needed
           p0,
           p;

void initSim() {
  c = new float[n][n];
  u = new Vec2[n][n];
  u_a = new Vec2[n][n];
  d = new float[n][n];
  p = new float[n][n];
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) 
      u[i][j] = u_a[i][j] = new Vec2();//new Vec2(sin(4*PI*j*h), sin(4*PI*i*h));
  //drawCheckerboard();
}

void simStep(float dt) {
  ///u_a = u;
  advectVelocity(dt);
  
  calculateDivergence(dt);
  calculatePressure();
  //u = u_a;
  updateVelocity(dt);
  advectColor(dt);
}


//

void advectVelocity(float dt) {
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) {
      Vec2 v = u[i][j];
      float t = c[i][j],
            dif = max(0,t-ambientTemp);
      u_a[i][j] = bilerpU(i*h - dt*v.x, j*h - dt*v.y)
            .add(new Vec2(0, max(0,(1-dif))*density*gravity-max(0,density*dt*buoyancy*dif)))
            .add(
              new Vec2(
                (curlu(i,j-1)) - (curlu(i,j+1)),
                (curlu(i+1,j)) - (curlu(i-1,j))
              ).normSafe(h*vorticity, Float.MIN_NORMAL)
            );
    }
}

void calculateDivergence(float dt) {
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) 
      //d[i][j] = (getu_a(i+1,j).x - getu_a(i-1,j).x + getu_a(i,j+1).y - getu_a(i,j-1).y)/(2*dt*h);
      d[i][j] = -2*h*density/dt*(getu_a(i+1,j).x - getu_a(i-1,j).x + getu_a(i,j+1).y - getu_a(i,j-1).y);
}

void calculatePressure() {
  //TODO: investigate if this extra copy of p is needed
  ///p0 = p;
  //p = new float[n][n];
  for(int k=0; k<PRESSURE_CALC_ITERS; k++) {  
    //p = new float[n][n];
    for(int i=0; i<n; i++)
      for(int j=0; j<n; j++)
        //p[i][j] = (-h*h*getd(i,j)+getp0(i+1,j)+getp0(i-1,j)+getp0(i,j+1)+getp0(i,j-1))/4;
        //p[i][j] = (getd(i,j)+getp0(i+2,j)+getp0(i-2,j)+getp0(i,j+2)+getp0(i,j-2))/4;
        p[i][j] = (1-sor_omega)*p[i][j] + sor_omega*(getd(i,j)+getp(i+2,j)+getp(i-2,j)+getp(i,j+2)+getp(i,j-2))/4;
    //p0 = p;
  }   
}

void updateVelocity(float dt) {
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) 
      u[i][j] = 
        u_a[i][j]
          
          .sub(
            new Vec2(
              getp(i+1,j)-getp(i-1,j), 
              getp(i,j+1)-getp(i,j-1)
            )
            .mul(dt/(2*density*h))
          );
            //.add(new Vec2(0, dt*(gravity*density - buoyancy*((c[i][j]-ambientTemp))*density)));
  //for(int i=0; i<n; i++)
  //  u[i][0] = u[i][n-1] = u[0][i] = u[n-1][i] = new Vec2();
}

void advectColor(float dt) {
  c1_a = new float[n][n];
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) {
      Vec2 v = u[i][j];
      c1_a[i][j] = bilerpScalarField(c, i*h - dt*v.x, j*h - dt*v.y);
    }
  c0_a = new float[n][n];
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) {
      Vec2 v = u[i][j];
      c0_a[i][j] = c1_a[i][j] + 0.1*(c[i][j] - bilerpScalarField(c1_a, i*h + dt*v.x, j*h + dt*v.y));
    }
  //reusing
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) {
      Vec2 v = u[i][j];
      c1_a[i][j] = 0.999*clampFromScalarField(c, c0_a[i][j], i*h - dt*v.x, j*h - dt*v.y);
    }
  c = c1_a;
  //for(int i=0; i<n; i++)
  //  c[i][0] = c[i][n-1] = c[0][i] = c[n-1][i] = 0;
}

float curlu(int i, int j) {
  return getu(i,j+1).x - getu(i,j-1).x + getu(i-1,j).y - getu(i+1,j).y;
}

float curlu_a(int i, int j) {
  return getu_a(i,j+1).x - getu_a(i,j-1).x + getu_a(i-1,j).y - getu_a(i+1,j).y;
}

Vec2 bilerpU(float x, float y) {
  x /= h;
  y /= h;
  
  int i0 = floor(x),//round(x),
      j0 = floor(y),//round(y),
      i1 = i0+1,//x<i0 ? i0-1 : i0+1,
      j1 = j0+1;//y<j0 ? j0-1 : j0+1;
      
  Vec2 u00 = getu(i0,j0),
       u10 = getu(i1,j0),
       u11 = getu(i1,j1),
       u01 = getu(i0,j1);
        
  //x-lerp
  Vec2 lerpj0 = u10.sub(u00).mul((x-i0)/(i1-i0)).add(u00),
       lerpj1 = u11.sub(u01).mul((x-i0)/(i1-i0)).add(u01);
  
  return lerpj1.sub(lerpj0).mul((y-j0)/(j1-j0)).add(lerpj0);
}

float bilerpScalarField(float[][] f, float x, float y) {
  x /= h;
  y /= h;
  
  int i0 = floor(x),//round(x),
      j0 = floor(y),//round(y),
      i1 = i0+1,//x<i0 ? i0-1 : i0+1,
      j1 = j0+1;//y<j0 ? j0-1 : j0+1;
      
  float u00 = getFromScalarField(f, i0,j0),
        u10 = getFromScalarField(f, i1,j0),
        u11 = getFromScalarField(f, i1,j1),
        u01 = getFromScalarField(f, i0,j1);
        
  //x-lerp
  float lerpj0 = (u10-u00)/(i1-i0)*(x-i0) + u00,
        lerpj1 = (u11-u01)/(i1-i0)*(x-i0) + u01;
  
  return (lerpj1-lerpj0)/(j1-j0)*(y-j0) + lerpj0;
}

float clampFromScalarField(float[][]f, float v, float x, float y) {
  x /= h;
  y /= h;
  
  int i0 = floor(x),//round(x),
      j0 = floor(y),//round(y),
      i1 = i0+1,//x<i0 ? i0-1 : i0+1,
      j1 = j0+1;//y<j0 ? j0-1 : j0+1;
      
  float sq [] = new float[] {
        getFromScalarField(f, i0,j0),
        getFromScalarField(f, i1,j0),
        getFromScalarField(f, i1,j1),
        getFromScalarField(f, i0,j1),
  };
        
  return constrain(v, min(sq), max(sq));
}

float getFromScalarField(float[][] f, int i, int j) {
  i = (i<n) ? (i<0) ? abs(i)-1 : i : (2*n-i-1);
  j = (j<n) ? (j<0) ? abs(j)-1 : j : (2*n-j-1);
  return f[i][j];
}

float getc(int i, int j) {
  i = (i<n) ? (i<0) ? abs(i)-1 : i : (2*n-i-1);
  j = (j<n) ? (j<0) ? abs(j)-1 : j : (2*n-j-1);
  return c[i][j];
}

Vec2 getu(int i, int j) {
  float rx = (i<0 || i>=n) ? -1 : 1,
        ry = (j<0 || j>=n) ? -1 : 1;
  i = (i<n) ? (i<0) ? abs(i)-1 : i : (2*n-i-1);
  j = (j<n) ? (j<0) ? abs(j)-1 : j : (2*n-j-1);
  return u[i][j].scale(rx, ry);
}

Vec2 getu_a(int i, int j) {
  float rx = (i<0 || i>=n) ? -1 : 1,
        ry = (j<0 || j>=n) ? -1 : 1;
  i = (i<n) ? (i<0) ? abs(i)-1 : i : (2*n-i-1);
  j = (j<n) ? (j<0) ? abs(j)-1 : j : (2*n-j-1);
  return u_a[i][j].scale(rx, ry);
}

float getd(int i, int j) {
  i = (i<n) ? (i<0) ? abs(i)-1 : i : (2*n-i-1);
  j = (j<n) ? (j<0) ? abs(j)-1 : j : (2*n-j-1);
  return d[i][j]; 
}

float getp(int i, int j) {
  i = (i<n) ? (i<0) ? abs(i)-1 : i : (2*n-i-1);
  j = (j<n) ? (j<0) ? abs(j)-1 : j : (2*n-j-1);
  return p[i][j]; 
}

float getp0(int i, int j) {
  i = (i<n) ? (i<0) ? abs(i)-1 : i : (2*n-i-1);
  j = (j<n) ? (j<0) ? abs(j)-1 : j : (2*n-j-1);
  return p0[i][j]; 
}

//float getc(int i, int j) {
//  return c[(i+n)%n][(j+n)%n];
//}

//Vec2 getu(int i, int j) {
//  return u[(i+n)%n][(j+n)%n];
//}

//Vec2 getu_a(int i, int j) {
//  return u_a[(i+n)%n][(j+n)%n];
//}

//float getd(int i, int j) {
//  return d[(i+n)%n][(j+n)%n]; 
//}

//float getp(int i, int j) {
//  return p[(i+n)%n][(j+n)%n]; 
//}

//float getp0(int i, int j) {
//  return p0[(i+n)%n][(j+n)%n]; 
//}
