class Vec2 {
  final float x, y;
  Vec2(float x, float y) {
    this.x=x;
    this.y=y;
  }
  
  Vec2() {
    x=y=0; 
  }
  
  Vec2 add(Vec2 v) {
    return new Vec2(x+v.x, y+v.y); 
  }
  
  Vec2 sub(Vec2 v) {
    return new Vec2(x-v.x, y-v.y); 
  }
  
  Vec2 mul(float f) {
    return new Vec2(f*x, f*y); 
  }
  
  Vec2 scale(float f, float g) {
    return new Vec2(f*x, g*y); 
  }
  
  Vec2 div(float f) {
    return new Vec2(x/f, y/f);
  }
  
  float dot(Vec2 v) {
    return x*v.x + y*v.y; 
  }
  
  float magsq() {
    return x*x + y*y; 
  }
  
  float mag() {
    return sqrt(magsq());  
  }
  
  Vec2 norm() {
    return div(mag());
  }
  
  Vec2 norm(float f) {
    return mul(f/mag()); 
  }
  
  Vec2 normSafe(float epsilon) {
    float m = mag();
    return m==0? new Vec2():norm();
    //return div(mag()+epsilon);
  }
  
  Vec2 normSafe(float f, float epsilon) {
    float m = mag();
    return m==0? new Vec2():norm(f);
    //return mul(f/(mag()+epsilon));
  }
}