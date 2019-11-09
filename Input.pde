
Vec2 mlastPos = null;

ArrayList<Vec2> candles = new ArrayList<Vec2>();

void updateInputs() {
  if(mouseX<0 || mouseX>=width || mouseY<0 || mouseY>=height) {
    mlastPos = null;
    return; 
  }
  if(mousePressed)
    switch(mouseButton) {
      case LEFT:
        addCircle(mouseX, mouseY, width/30, vacuumMode);
        dragVelocityField(mouseX, mouseY, new Vec2(), width/30);
      break;
      case CENTER:
        candles.add(new Vec2(mouseX, mouseY));
      break;
    }
    
  for(Vec2 v : candles)
    addCircle(v.x, v.y, width/30, false);
}

void mouseDragged() {
  if(mouseX<0 || mouseX>=width || mouseY<0 || mouseY>=height) {
    mlastPos = null;
    return; 
  }
  if(mlastPos!=null) {
    Vec2 dif = new Vec2(mouseX, mouseY).sub(mlastPos);
    dragVelocityField(mouseX, mouseY, dif, width/30);
  }
  
  mlastPos = new Vec2(mouseX, mouseY);
}

void mouseReleased() {
  mlastPos = null;
}

void keyPressed() {
  switch(key) {
    case 'c':
      clearFields();
      candles.clear();
     break;
    case 'd':
      drawCheckerboard();
     break;
    case 's':
      showU = !showU;
    break;
    case 'v':
      showU = !showU;
    break;
    case 'x':
      exit();
     break;
  }
}
