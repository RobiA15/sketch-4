/**
 * Combined Water Wave Simulation
 * Merges soft-body physics with wave functions
 */

// Water surface parameters
int nodes = 40;  // Number of horizontal points
float[] nodeX = new float[nodes];
float[] nodeY = new float[nodes];
float[] nodeStartY = new float[nodes];
float[] velocity = new float[nodes];
float[] acceleration = new float[nodes];

// Physics parameters
float waterLevel;
float springing = 0.01;
float damping = 0.99;
float tension = 0.030;

// Wave parameters
ArrayList<WaveSource> waveSources;

void setup() {
  size(640, 360);
  
  // Initialize water level at 2/3 down the screen
  waterLevel = height * 2/3;
  
  // Initialize node positions
  for (int i = 0; i < nodes; i++) {
    nodeX[i] = map(i, 0, nodes-1, 0, width);
    nodeStartY[i] = waterLevel;
    nodeY[i] = nodeStartY[i];
  }
  
  // Initialize wave sources list
  waveSources = new ArrayList<WaveSource>();
  
  frameRate(60);
  strokeWeight(2);
}

void draw() {
  // Clear the background with a gradient
  drawBackground();
  
  // Update physics
  updateWaterPhysics();
  
  // Apply active wave sources
  for (int i = waveSources.size() - 1; i >= 0; i--) {
    WaveSource source = waveSources.get(i);
    source.update();
    
    // Apply this wave's force to nodes
    source.applyToNodes();
    
    // Remove dissipated sources
    if (source.strength < 0.1) {
      waveSources.remove(i);
    }
  }
  
  // Draw water
  drawWater();
  
  // Add instructions
  fill(255);
  textSize(12);
  text("Press SPACEBAR to create waves", 20, 30);
  text("Active wave sources: " + waveSources.size(), 20, 50);
}

void drawBackground() {
  // Sky gradient
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    color skyColor = lerpColor(color(100, 150, 255), color(200, 230, 255), inter);
    stroke(skyColor);
    line(0, y, width, y);
  }
}

void updateWaterPhysics() {
  // Apply forces and update positions
  for (int i = 0; i < nodes; i++) {
    // Spring force (towards rest position)
    float springForce = (nodeStartY[i] - nodeY[i]) * springing;
    acceleration[i] = springForce;
    
    // Apply tension with adjacent nodes
    if (i > 0) {
      float tensionForceLeft = (nodeY[i-1] - nodeY[i]) * tension;
      acceleration[i] += tensionForceLeft;
    }
    if (i < nodes-1) {
      float tensionForceRight = (nodeY[i+1] - nodeY[i]) * tension;
      acceleration[i] += tensionForceRight;
    }
    
    // Update velocity and position
    velocity[i] += acceleration[i];
    velocity[i] *= damping;
    nodeY[i] += velocity[i];
  }
}

void drawWater() {
  // Water surface
  fill(0, 100, 180, 200);
  noStroke();
  
  // Top surface with smoothed curves
  beginShape();
  vertex(0, height);
  curveVertex(nodeX[0], nodeY[0]);
  
  for (int i = 0; i < nodes; i++) {
    curveVertex(nodeX[i], nodeY[i]);
  }
  
  curveVertex(nodeX[nodes-1], nodeY[nodes-1]);
  vertex(width, height);
  endShape(CLOSE);
  
  // Add wave details/highlights
  stroke(255, 150);
  noFill();
  beginShape();
  for (int i = 0; i < nodes; i++) {
    curveVertex(nodeX[i], nodeY[i]);
  }
  endShape();
  
  // Add underwater caustics (light patterns)
  drawCaustics();
}

void drawCaustics() {
  // Simple underwater light patterns
  noStroke();
  for (int i = 0; i < 20; i++) {
    float x = random(width);
    float y = random(waterLevel, height);
    fill(200, 230, 255, 50);
    ellipse(x, y, 30, 10);
  }
}

void keyPressed() {
  if (key == ' ') {
    // Create two colliding waves
    waveSources.add(new WaveSource(width/4, 40, 0.08));
    waveSources.add(new WaveSource(3*width/4, 30, 0.06));
  }
}

// Wave source class
class WaveSource {
  float sourceX;      // X position of wave source
  float strength;     // Wave strength/amplitude
  float frequency;    // Wave frequency
  float phase;        // Current phase
  float damping;      // How quickly the wave dissipates
  
  WaveSource(float sourceX, float strength, float frequency) {
    this.sourceX = sourceX;
    this.strength = strength;
    this.frequency = frequency;
    this.phase = 0;
    this.damping = 0.99;
  }
  
  void update() {
    phase += 0.1;
    strength *= damping;
  }
  
  void applyToNodes() {
    for (int i = 0; i < nodes; i++) {
      // Distance from wave source
      float distance = abs(nodeX[i] - sourceX);
      
      // Calculate circular wave effect
      float distanceFactor = max(0, 1 - distance/(width*0.8));
      float waveEffect = sin(distance * frequency - phase) * distanceFactor;
      
      // Apply force to node
      velocity[i] += waveEffect * strength * 0.05;
    }
  }
}
