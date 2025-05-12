/**
 * Soft-Body Water Simulation
 * Based on Ira Greenberg's Soft Body example
 * Modified to simulate water waves
 */

// Water surface parameters
int nodes = 20;  // More nodes = more detailed waves
float[] nodeX = new float[nodes];
float[] nodeY = new float[nodes];
float[] nodeStartY;  // Rest position Y-coordinates
float[] velocity = new float[nodes];  // Velocity of each node
float[] acceleration = new float[nodes];  // Acceleration of each node

// Physics parameters
float waterLevel;  // Y-position of calm water
float springing = 0.02;  // Spring constant
float damping = 0.98;  // Damping constant
float tension = 0.8;  // Tension between adjacent nodes

// Wave parameters
float waveHeight = 50;  // Maximum wave height

void setup() {
  size(640, 360);
  
  // Initialize water level at 2/3 down the screen
  waterLevel = height * 2/3;
  
  // Initialize node positions
  nodeStartY = new float[nodes];
  for (int i = 0; i < nodes; i++) {
    // Distribute nodes evenly across the width
    nodeX[i] = map(i, 0, nodes-1, 0, width);
    nodeStartY[i] = waterLevel;
    nodeY[i] = nodeStartY[i];
  }
  
  // Visual settings
  strokeWeight(2);
  frameRate(60);
}

void draw() {
  // Clear the background
  background(0, 130, 230);  // Blue background
  
  // Update water physics
  updateWaterPhysics();
  
  // Draw the water
  drawWater();
  
  // Draw calm water line for reference
  stroke(255, 100);
  line(0, waterLevel, width, waterLevel);
  
  // Add instructions
  fill(255);
  textSize(12);
  text("Press SPACEBAR to create waves", 20, 30);
}

void updateWaterPhysics() {
  // Apply forces and update positions
  for (int i = 0; i < nodes; i++) {
    // Calculate spring force (difference from rest position)
    float springForce = (nodeStartY[i] - nodeY[i]) * springing;
    
    // Apply spring force to acceleration
    acceleration[i] = springForce;
    
    // Apply tension forces from adjacent nodes
    if (i > 0) {
      float tensionForce = (nodeY[i-1] - nodeY[i]) * tension;
      acceleration[i] += tensionForce;
    }
    if (i < nodes-1) {
      float tensionForce = (nodeY[i+1] - nodeY[i]) * tension;
      acceleration[i] += tensionForce;
    }
    
    // Update velocity and position
    velocity[i] += acceleration[i];
    velocity[i] *= damping;
    nodeY[i] += velocity[i];
  }
}

void drawWater() {
  // Draw the water surface as a filled shape
  fill(0, 150, 255, 200);  // Semi-transparent blue
  stroke(0, 100, 200);
  
  beginShape();
  // Include the bottom corners to close the shape
  vertex(0, height);
  
  // Draw the water surface using curveVertex for smoothness
  for (int i = 0; i < nodes; i++) {
    curveVertex(nodeX[i], nodeY[i]);
  }
  
  vertex(width, height);
  endShape(CLOSE);
}

void keyPressed() {
  if (key == ' ') {
    // Create waves on spacebar press
    createWaves();
  }
}

void createWaves() {
  // Apply random forces to nodes to create waves
  for (int i = 0; i < nodes; i++) {
    // Create two wave sources at approximately 1/4 and 3/4 of the width
    float distFromLeftSource = abs(nodeX[i] - width/4);
    float distFromRightSource = abs(nodeX[i] - 3*width/4);
    
    // Apply force based on distance from wave sources
    if (distFromLeftSource < width/8) {
      velocity[i] -= random(5, 15) * map(distFromLeftSource, 0, width/8, 1, 0);
    }
    
    if (distFromRightSource < width/8) {
      velocity[i] -= random(5, 15) * map(distFromRightSource, 0, width/8, 1, 0);
    }
  }
}
