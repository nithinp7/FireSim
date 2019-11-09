
final int n = 400,
          SCALE = 2,
          FPS = 30,
          
          PRESSURE_CALC_ITERS = 8,
          
          BLUR_RADIUS=30;

final float h = 1f/n,
            timescale = 1,
            density = 0.5,
            vorticity = 0.5,
            viscosity = 1,
            buoyancy = 1,
            ambientTemp = 0.1,
            gravity = 0,
            sor_omega = 1.1,
            
            bloom_threshold=0.4;

final float bloomBufA [][] = new float[n][n],
            bloomBufB [][] = new float[n][n]; 

boolean showU = false,
        vacuumMode = false;

//color field
float[][] c; 
//velocity fieldc
Vec2[][] u;

void settings() {
  size(n*SCALE, n*SCALE);
}

void setup() {
  colorMode(HSB, 360, 100, 100);
  frameRate(FPS);
  initSim();
  
  gaussBlur = new float[BLUR_RADIUS*2+1];
  for(int i=-BLUR_RADIUS; i<=BLUR_RADIUS; i++)
    gaussBlur[i+BLUR_RADIUS] = 0.01*exp(-i*i*1f/BLUR_RADIUS/BLUR_RADIUS)/sqrt(PI);
    
  //noCursor();
}

void draw() {
  updateInputs();
  simStep(timescale/FPS);
  render();
  
  text(frameRate, 10, 10);
}
