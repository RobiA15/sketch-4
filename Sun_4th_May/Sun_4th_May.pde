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

// Bubble Globals
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
  
  //bubbles
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

void updateWaterPhysics() {
  // Initialize previous positions on first frame
  if (firstFrameVerlet) {
    previousY = new float[nodes];
    for (int i = 0; i < nodes; i++) {
      previousY[i] = nodeY[i];
    }
    firstFrameVerlet = false;
    return;
  }
  
  // Temporary array for new positions
  float[] newY = new float[nodes];
  
  // Calculate new positions using Verlet integration
  for (int i = 0; i < nodes; i++) {
    // Calculate forces (soft-body physics)
    float springForce = -(nodeY[i] - nodeStartY[i]) * springing;
    float totalForce = springForce;
    
    // Tension forces from adjacent nodes (soft-body connections)
    if (i > 0) {
      totalForce += (nodeY[i-1] - nodeY[i]) * tension;
    }
    if (i < nodes-1) {
      totalForce += (nodeY[i+1] - nodeY[i]) * tension;
    }
    
    // Verlet integration formula: new_pos = 2*current_pos - previous_pos + acceleration*dt²
    // Since our dt=1 in frame units, this simplifies to:
    newY[i] = 2 * nodeY[i] - previousY[i] + totalForce;
    
    // Apply damping to the position change
    float positionChange = newY[i] - nodeY[i];
    positionChange *= damping;
    newY[i] = nodeY[i] + positionChange;
  }
  
  // Update positions and calculate velocities
  for (int i = 0; i < nodes; i++) {
    velocity[i] = newY[i] - nodeY[i];  // For energy calculations
    previousY[i] = nodeY[i];           // Store current as previous
    nodeY[i] = newY[i];                // Update to new position
  }
  
  // Energy cap to prevent any remaining numerical errors
  float currentEnergy = calculateSystemEnergy();
  if (currentEnergy > maxEnergy) {
    float scaleFactor = sqrt(maxEnergy / currentEnergy);
    for (int i = 0; i < nodes; i++) {
      velocity[i] *= scaleFactor;
    }
  }
}

float calculateSystemEnergy() {
  float kineticSum = 0;
  float potentialSum = 0;
  
  for (int i = 0; i < nodes; i++) {
    // Kinetic energy: 0.5 * m * v^2
    kineticSum += 0.5 * velocity[i] * velocity[i];
    
    // Potential energy: 0.5 * k * x^2
    float displacement = nodeY[i] - nodeStartY[i];
    potentialSum += 0.5 * springing * displacement * displacement;
  }
  
  return kineticSum + potentialSum;
}

void calculateEnergies() {
  kineticEnergy = 0;
  potentialEnergy = 0;
  
  for (int i = 0; i < nodes; i++) {
    // Kinetic energy: 0.5 * m * v^2
    kineticEnergy += 0.5 * velocity[i] * velocity[i];
    
    // Potential energy: 0.5 * k * x^2
    float displacement = nodeY[i] - nodeStartY[i];
    potentialEnergy += 0.5 * springing * displacement * displacement;
  }
  
  totalEnergy = kineticEnergy + potentialEnergy;
}

void updateEnergyHistory() {
  totalEnergyHistory[historyIndex] = totalEnergy;
  kineticEnergyHistory[historyIndex] = kineticEnergy;
  potentialEnergyHistory[historyIndex] = potentialEnergy;
  
  historyIndex = (historyIndex + 1) % historyLength;
}

// In drawWaterSimulation(), after drawWater():
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

void drawWater() {
  // Water surface
  fill(0, 150, 255, 200);
  stroke(0, 100, 200);
  
  beginShape();
  vertex(0, height);
  
  curveVertex(nodeX[0], nodeY[0]);
  for (int i = 0; i < nodes; i++) {
    curveVertex(nodeX[i], nodeY[i]);
  }
  curveVertex(nodeX[nodes-1], nodeY[nodes-1]);
  
  vertex(width, height);
  endShape(CLOSE);
}

void drawDashboard() {
  background(20);  // Dark background for dashboard
  
  // Dashboard title
  fill(255);
  textSize(24);
  text("Energy Analysis Dashboard", 20, 40);
  
  textSize(14);
  text("Press 'D' to return to water simulation", 20, 70);
  
  // Draw current energy values
  drawEnergyMeters(50, 120);
  
  // Draw energy history graph
  drawEnergyGraph(50, 320, 700, 200);
  
  // Draw energy distribution pie chart
  drawEnergyPieChart(600, 120, 150);
  
  // Draw system parameters
  drawSystemParameters(50, 550);
}

void drawEnergyMeters(float x, float y) {
  // Title
  fill(255);
  textSize(18);
  text("Current Energy Levels", x, y);
  
  // Energy bars
  float barWidth = 300;
  float barHeight = 20;
  float spacing = 40;
  
  // Total Energy
  drawEnergyBar("Total Energy", totalEnergy, maxEnergy, 
                x, y + 30, barWidth, barHeight, color(255, 200, 0));
  
  // Kinetic Energy
  drawEnergyBar("Kinetic Energy", kineticEnergy, maxEnergy/2, 
                x, y + 30 + spacing, barWidth, barHeight, color(255, 100, 100));
  
  // Potential Energy
  drawEnergyBar("Potential Energy", potentialEnergy, maxEnergy/2, 
                x, y + 30 + spacing*2, barWidth, barHeight, color(100, 200, 255));
  
  // Numerical values
  textSize(12);
  fill(255);
  text(String.format("%.1f J", totalEnergy), x + barWidth + 10, y + 35);
  text(String.format("%.1f J", kineticEnergy), x + barWidth + 10, y + 35 + spacing);
  text(String.format("%.1f J", potentialEnergy), x + barWidth + 10, y + 35 + spacing*2);
}

void drawEnergyBar(String label, float value, float maxValue, 
                   float x, float y, float w, float h, color c) {
  // Label
  fill(255);
  textSize(12);
  text(label, x, y - 5);
  
  // Background bar
  fill(50);
  rect(x, y, w, h);
  
  // Value bar
  float fillWidth = map(value, 0, maxValue, 0, w);
  fill(c);
  rect(x, y, fillWidth, h);
  
  // Border
  noFill();
  stroke(255);
  rect(x, y, w, h);
}

void drawEnergyGraph(float x, float y, float w, float h) {
  // Title
  fill(255);
  textSize(18);
  text("Energy Over Time", x, y - 10);
  
  // Graph background
  fill(30);
  stroke(255);
  rect(x, y, w, h);
  
  // Grid lines
  stroke(70);
  for (int i = 1; i < 5; i++) {
    float lineY = y + (h * i / 5);
    line(x, lineY, x + w, lineY);
  }
  
  // Draw energy histories
  noFill();
  strokeWeight(2);
  
  // Total energy (yellow)
  stroke(255, 200, 0);
  beginShape();
  for (int i = 0; i < historyLength; i++) {
    int index = (historyIndex + i) % historyLength;
    float xPos = map(i, 0, historyLength-1, x, x + w);
    float yPos = map(totalEnergyHistory[index], 0, maxEnergy, y + h, y);
    vertex(xPos, yPos);
  }
  endShape();
  
  // Kinetic energy (red)
  stroke(255, 100, 100);
  beginShape();
  for (int i = 0; i < historyLength; i++) {
    int index = (historyIndex + i) % historyLength;
    float xPos = map(i, 0, historyLength-1, x, x + w);
    float yPos = map(kineticEnergyHistory[index], 0, maxEnergy, y + h, y);
    vertex(xPos, yPos);
  }
  endShape();
  
  // Potential energy (blue)
  stroke(100, 200, 255);
  beginShape();
  for (int i = 0; i < historyLength; i++) {
    int index = (historyIndex + i) % historyLength;
    float xPos = map(i, 0, historyLength-1, x, x + w);
    float yPos = map(potentialEnergyHistory[index], 0, maxEnergy, y + h, y);
    vertex(xPos, yPos);
  }
  endShape();
  
  strokeWeight(1);
  
  // Legend
  float legendX = x + w - 150;
  float legendY = y + 20;
  
  fill(255, 200, 0);
  rect(legendX, legendY, 10, 10);
  fill(255);
  text("Total", legendX + 15, legendY + 10);
  
  fill(255, 100, 100);
  rect(legendX, legendY + 15, 10, 10);
  fill(255);
  text("Kinetic", legendX + 15, legendY + 25);
  
  fill(100, 200, 255);
  rect(legendX, legendY + 30, 10, 10);
  fill(255);
  text("Potential", legendX + 15, legendY + 40);
}

void drawEnergyPieChart(float x, float y, float diameter) {
  // Title
  fill(255);
  textSize(18);
  text("Energy Distribution", x - diameter/2, y - diameter/2 - 10);
  
  // Only draw pie chart if there's energy in the system
  if (totalEnergy > 0.1) {
    float kineticAngle = map(kineticEnergy, 0, totalEnergy, 0, TWO_PI);
    
    // Kinetic portion (red)
    fill(255, 100, 100);
    arc(x, y, diameter, diameter, 0, kineticAngle);
    
    // Potential portion (blue)
    fill(100, 200, 255);
    arc(x, y, diameter, diameter, kineticAngle, TWO_PI);
    
    // Percentages
    fill(255);
    textSize(12);
    float kineticPercent = (kineticEnergy / totalEnergy) * 100;
    float potentialPercent = (potentialEnergy / totalEnergy) * 100;
    
    text(String.format("Kinetic: %.1f%%", kineticPercent), x - diameter/2, y + diameter/2 + 20);
    text(String.format("Potential: %.1f%%", potentialPercent), x - diameter/2, y + diameter/2 + 35);
  } else {
    // No energy state
    fill(50);
    ellipse(x, y, diameter, diameter);
    fill(255);
    textAlign(CENTER);
    text("No Energy", x, y);
    textAlign(LEFT);
  }
}

void drawSystemParameters(float x, float y) {
  fill(255);
  textSize(18);
  text("System Parameters", x, y);
  
  textSize(14);
  text(String.format("Spring Constant: %.3f", springing), x, y + 25);
  text(String.format("Damping Factor: %.3f", damping), x, y + 45);
  text(String.format("Surface Tension: %.3f", tension), x, y + 65);
  text(String.format("Energy per Press: %.1f J", energyPerPress), x, y + 85);
}

void addEnergyToSystem() {
  float totalEnergyToAdd = energyPerPress;
  
  // Adjustable parameters
  float spatialFrequency = 0.1;  // How "zoomed in" the noise is
  float timeVariation = 0.001;   // How much patterns change over time
  float animationSpeed = 0.02;   // Speed of wave animation
  
  // Choose which type of noise to use
  int noiseType = int(random(3));  // 0, 1, or 2
  
  float[] velocityChanges = new float[nodes];
  float totalVelocitySquared = 0;
  
  for (int i = 0; i < nodes; i++) {
    float noiseValue;
    
    switch(noiseType) {
      case 0:  // Static spatial noise
        noiseValue = noise(i * spatialFrequency);
        break;
        
      case 1:  // Time-varying noise
        noiseValue = noise(i * spatialFrequency, millis() * timeVariation);
        break;
        
      case 2:  // Animated wave noise
        float phase = frameCount * animationSpeed;
        noiseValue = noise(i * spatialFrequency - phase);
        break;
        
      default:
        noiseValue = 0.5;
    }
    
    // Convert from [0,1] to [-1,1]
    velocityChanges[i] = map(noiseValue, 0, 1, -1, 1);
    
    // Optional: Add some randomness for more organic feel
    velocityChanges[i] *= random(0.8, 1.2);
    
    totalVelocitySquared += velocityChanges[i] * velocityChanges[i];
  }
  
  // Scale to match energy budget
  float scaleFactor = sqrt(totalEnergyToAdd * 2 / totalVelocitySquared);
  
  // Apply to previous positions for Verlet integration
  for (int i = 0; i < nodes; i++) {
    float velocityChange = velocityChanges[i] * scaleFactor;
    previousY[i] = nodeY[i] - velocityChange;
  }
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

void createWaveAtPosition(float xPos, float energy) {
  // Find the node closest to xPos
  int centerNode = 0;
  float minDist = width;
  
  for (int i = 0; i < nodes; i++) {
    float dist = abs(nodeX[i] - xPos);
    if (dist < minDist) {
      minDist = dist;
      centerNode = i;
    }
  }
  
  // Distribute energy across neighboring nodes (Gaussian distribution)
  float totalVelocitySquared = 0;
  float[] waveProfile = new float[nodes];
  
  for (int i = 0; i < nodes; i++) {
    float distance = abs(i - centerNode);
    float gaussian = exp(-distance * distance / 25.0);
    waveProfile[i] = gaussian;
    totalVelocitySquared += gaussian * gaussian;
  }
  
  // Calculate the velocity we want to impart
  float velocityScale = sqrt(2 * energy / totalVelocitySquared);
  
  // For Verlet integration, modify previous positions to create velocity
  for (int i = 0; i < nodes; i++) {
    float desiredVelocity = -waveProfile[i] * velocityScale;  // Negative for downward
    
    // Adjust previous position to create the desired velocity
    previousY[i] = nodeY[i] - desiredVelocity;
  }
}

// Add this class to your code
class Bubble {
  float x, y;          // Position
  float size;          // Bubble radius
  float speed;         // Upward speed
  float wobble;        // For slight horizontal movement
  float wobblePhase;   // Where in the wobble cycle we are
  float transparency;  // For visual appeal
  int birthNode;       // Which node spawned this bubble
  
  Bubble(float x, float y, int node) {
    this.x = x;
    this.y = y;
    this.birthNode = node;
    
    // Randomize bubble properties for natural variation
    this.size = random(2, 6);
    this.speed = random(0.5, 2.0);
    this.wobble = random(0.5, 2.0);
    this.wobblePhase = random(TWO_PI);
    this.transparency = random(100, 200);
  }
  
  void update() {
    // Move upward
    y -= speed;
    
    // Add slight horizontal wobble for realism
    wobblePhase += 0.05;
    x += sin(wobblePhase) * wobble * 0.1;
    
    // Optional: bubbles expand slightly as they rise
    size += 0.01;
  }
  
  boolean isDead() {
    // Check if bubble has risen above its birth node
    return y < nodeY[birthNode];
  }
  
  void display() {
    // Draw the bubble with transparency
    noStroke();
    fill(255, 255, 255, transparency);
    ellipse(x, y, size * 2, size * 2);
    
    // Optional: add a highlight for more realism
    fill(255, 255, 255, transparency * 1.5);
    ellipse(x - size * 0.3, y - size * 0.3, size * 0.5, size * 0.5);
  }
}

void drawBubbles() {
  // Spawn new bubbles at nodes
  for (int i = 0; i < nodes; i++) {
    // Decrease timer
    bubbleTimers[i]--;
    
    // When timer reaches zero, maybe spawn a bubble
    if (bubbleTimers[i] <= 0) {
      // Random chance to actually spawn
      //if (random(1) < bubbleSpawnChance) {
        if (1 == 1) {
        // Create bubble slightly below the node
        float bubbleX = nodeX[i] + random(-5, 5);  // Slight random offset
        float bubbleY = nodeY[i] - random(0, 200);   // Start below surface
        
        bubbles.add(new Bubble(bubbleX, bubbleY, i));
      }
      
      // Reset timer with random delay
      bubbleTimers[i] = random(5, 10);  // Frames until next possible spawn
    }
  }
  
  // Update and draw all bubbles
  for (int i = bubbles.size() - 1; i >= 0; i--) {
    Bubble b = bubbles.get(i);
    
    // Update bubble position
    b.update();
    
    // Remove dead bubbles
    if (b.isDead()) {
      bubbles.remove(i);
      continue;
    }
    
    // Draw bubble
    b.display();
  }
  
  // Optional: Display bubble count for debugging
  if (showDashboard) {
    fill(255);
    textSize(12);
    text("Active bubbles: " + bubbles.size(), 20, height - 20);
  }
}
