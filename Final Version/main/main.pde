//Main sketch file
/**
 * Water Wave Simulation with Energy Dashboard
 * Uses Verlet integration for stable soft-body physics
 * Press 'D' to toggle between water view and energy dashboard
 * Press SPACEBAR to add energy waves
 */

// Screen modes
boolean showDashboard = false;

// Water surface parameters
int nodes = 80;
float[] nodeX = new float[nodes];
float[] nodeY = new float[nodes];
float[] nodeStartY = new float[nodes];
float[] velocity = new float[nodes];
float[] acceleration = new float[nodes];

// Verlet integration variables  
float[] previousY;
boolean firstFrameVerlet = true;

// Physics parameters
float waterLevel;
float springing = 0.02;
float damping = 0.99;
float tension = 0.020;

// Energy tracking
float totalEnergy = 0;
float kineticEnergy = 0;
float potentialEnergy = 0;
float energyPerPress = 500;
float maxEnergy = 2000;

// Energy history for graphs
int historyLength = 300;  // 5 seconds at 60 fps
float[] totalEnergyHistory = new float[historyLength];
float[] kineticEnergyHistory = new float[historyLength];
float[] potentialEnergyHistory = new float[historyLength];
int historyIndex = 0;

// Bubble system
ArrayList<Bubble> bubbles;
float[] bubbleTimers;  // Track when each node should spawn next bubble
float bubbleSpawnChance = 0.5;  // Adjust this to control bubble frequency

void setup() {
  size(800, 600);  // Larger canvas for dashboard
  
  waterLevel = height * 2/3;
  
  // Initialize node positions
  for (int i = 0; i < nodes; i++) {
    nodeX[i] = map(i, 0, nodes-1, 0, width);
    nodeStartY[i] = waterLevel;
    nodeY[i] = nodeStartY[i];
  }
  
  // Initialize energy history arrays
  for (int i = 0; i < historyLength; i++) {
    totalEnergyHistory[i] = 0;
    kineticEnergyHistory[i] = 0;
    potentialEnergyHistory[i] = 0;
  }
  
  frameRate(60);
  
  // Initialize bubble system
  bubbles = new ArrayList<Bubble>();
  bubbleTimers = new float[nodes];
  
  // Initialize timers with random values
  for (int i = 0; i < nodes; i++) {
    bubbleTimers[i] = random(60, 300);  // Random delay before first bubble
  }
}

void draw() {
  // Always update physics, regardless of view
  updateWaterPhysics();
  calculateEnergies();
  updateEnergyHistory();
  
  // Show appropriate screen
  if (showDashboard) {
    drawDashboard();
  } else {
    drawWaterSimulation();
  }
}

void drawWaterSimulation() {
  background(0, 130, 230);
  
  // Draw water
  drawWater();
  
  // Draw bubbles (after water so they appear on top)
  drawBubbles();
  
  // Basic UI
  fill(255);
  textSize(14);
  text("Press SPACEBAR to add waves", 20, 30);
  text("Press 'D' to view energy dashboard", 20, 50);
  text(String.format("Current Energy: %.1f", totalEnergy), 20, 70);
}

void keyPressed() {
  if (key == ' ') {
    // Make sure Verlet is initialized before adding waves
    if (!firstFrameVerlet && totalEnergy < maxEnergy - energyPerPress) {
      addEnergyToSystem();
    }
  } else if (key == 'd' || key == 'D') {
    showDashboard = !showDashboard;
  }
}
