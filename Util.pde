
void dragVelocityField(float x, float y, Vec2 v, float pixelSize) {
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) {
      float d = sqrt(pow(x-(i+0.5)*SCALE,2)+pow(y-(j+0.5)*SCALE,2));
      if(d < pixelSize) {
        Vec2 u_ = u[i][j].add(v.mul(1*d/pixelSize*noise(i*h,j*h,millis())));
        if(u_.mag() < n*h)
          u[i][j] = u_;
      }
    }
}

void addCircle(float x, float y, float pixelSize, boolean vacuum) {
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++)
      if(sqrt(pow(x-(i+0.5)*SCALE,2)+pow(y-(j+0.5)*SCALE,2)) < pixelSize)
        c[i][j] = vacuum? 0 : constrain(c[i][j]+0.15, 0, 1);
}

void clearFields() {
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++) {
      c[i][j] = p[i][j] = 0;
      u[i][j] = new Vec2();
    }
}

void drawCheckerboard() {
  for(int i=0; i<n; i++)
    for(int j=0; j<n; j++)
      c[i][j] = 0.5*((i/10+ j/10)%2);
}
