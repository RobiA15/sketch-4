/**
 * Soft Body 
 * by Ira Greenberg.  
 * 
 * Softbody dynamics simulation using curveVertex() and curveTightness().
 */
 
// center point
float startX = 0, startY = 0;

float radius = 100, rotAngle = 0;
float accelX, accelY;
float springing = .0009, damping = .98;

//corner nodes
int nodes = 4;
float nodeStartX[] = new float[nodes];
float nodeStartY[] = new float[nodes];
float[]nodeX = new float[nodes];
float[]nodeY = new float[nodes];
float[]angle = new float[nodes];
float[]frequency = new float[nodes];

// soft-body dynamics
float organicConstant = 1;

void setup() {
  size(640, 360);
  //Start the first shape in the bottom left
  startX = 320;
  startY = 200;
  // iniitalize frequencies for corner nodes
  for (int i=0; i<nodes; i++){
    frequency[i] = random(5, 12);
  }
  noStroke();
  frameRate(60);
}

void draw() {
  //fade background
  fill(0, 100);
  rect(0,0,width, height);
  drawShape();
  moveShape();
}

void drawShape() {
  //  calculate node  starting positions
  for (int i=0; i<nodes; i++){
    nodeStartX[i] = startX+cos(radians(rotAngle))*radius;
    nodeStartY[i] = startY+sin(radians(rotAngle))*radius;
    rotAngle += 360.0/nodes;
  }
  
  // draw polygon
  curveTightness(organicConstant);
  fill(255);
  beginShape();
  for (int i=0; i<nodes; i++){
    curveVertex(nodeX[i], nodeY[i]);
  }
  for (int i=0; i<nodes-1; i++){
    curveVertex(nodeX[i], nodeY[i]);
  }
  endShape(CLOSE);
  
  for (int j=0; j<nodes; j++){
    nodeStartX[j] = startX+cos(radians(rotAngle))*radius;
    nodeStartY[j] = startY+sin(radians(rotAngle))*radius;
    rotAngle += 360.0/nodes;
  }

  // draw polygon
  curveTightness(organicConstant);
  fill(255);
  beginShape();
  for (int j=0; j<nodes; j++){
    curveVertex(nodeX[j], nodeY[j]);
  }
  for (int j=0; j<nodes-1; j++){
    curveVertex(nodeX[j], nodeY[j]);
  }
  endShape(CLOSE);
}

void moveShape() {
  //move center point
  float deltaX = mouseX-startX;
  float deltaY = mouseY-startY;

  // create springing effect
  deltaX *= springing;
  deltaY *= springing;
  accelX += deltaX;
  accelY += deltaY;

  // move predator's center
  //startX += accelX;
  //startY += accelY;

  // slow down springing
  accelX *= damping;
  accelY *= damping;

  // change curve tightness
  organicConstant = 1-((abs(accelX)+abs(accelY))*.1);

  //move nodes
  for (int i=0; i<nodes; i++){
    nodeX[i] = nodeStartX[i]+sin(radians(angle[i]))*(accelX*2);
    nodeY[i] = nodeStartY[i]+sin(radians(angle[i]))*(accelY*2);
    angle[i]+=frequency[i];
  }
}
