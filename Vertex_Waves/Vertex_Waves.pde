/**
 * Wave Simulation using Oscillating Vertices
 * Based on mathematical wave functions
 */

// Number of points along the water surface
int pointCount = 1000;
float[] waveHeight;  // Height of the wave at each point

// Wave parameters
ArrayList<Wave> waves;
float waterLevel;

void setup() {
  size(640, 360);
  
  // Initialize water level at 2/3 down the screen
  waterLevel = height * 2/3;
  
  // Initialize wave heights
  waveHeight = new float[pointCount];
  
  // Initialize waves list
  waves = new ArrayList<Wave>();
  
  frameRate(60);
}

void draw() {
  // Clear the background
  background(0, 130, 230);  // Blue background
  
  // Reset wave heights
  for (int i = 0; i < pointCount; i++) {
    waveHeight[i] = 0;
  }
  
  // Update all active waves
  for (int i = waves.size() - 1; i >= 0; i--) {
    Wave wave = waves.get(i);
    wave.update();
    
    // Remove waves that have dissipated
    if (wave.amplitude < 0.1) {
      waves.remove(i);
    } else {
      // Add this wave's contribution to the total height
      for (int j = 0; j < pointCount; j++) {
        float x = map(j, 0, pointCount - 1, 0, width);
        waveHeight[j] += wave.getHeightAt(x);
      }
    }
  }
  
  // Draw water
  fill(0, 150, 255, 200);
  stroke(0, 100, 200);
  beginShape();
  
  // Bottom left corner
  vertex(0, height);
  
  // Draw the wave surface
  for (int i = 0; i < pointCount; i++) {
    float x = map(i, 0, pointCount - 1, 0, width);
    float y = waterLevel + waveHeight[i];
    vertex(x, y);
  }
  
  // Bottom right corner
  vertex(width, height);
  endShape(CLOSE);
  
  // Draw calm water line for reference
  stroke(255, 100);
  line(0, waterLevel, width, waterLevel);
  
  // Add instructions
  fill(255);
  textSize(12);
  text("Press SPACEBAR to create waves", 20, 30);
  text("Active waves: " + waves.size(), 20, 50);
}

void keyPressed() {
  if (key == ' ') {
    // Create two new waves
    waves.add(new Wave(width/4, 40, 0.2, 2));
    waves.add(new Wave(3*width/4, 30, 0.15, -2));
  }
}

// Wave class to represent a single wave
class Wave {
  float sourceX;      // X position of wave source
  float amplitude;    // Wave height
  float frequency;    // Wave frequency
  float speed;        // Wave speed (pixels per frame)
  float phase;        // Current phase
  float wavelength;   // Distance between wave peaks
  float damping;      // How quickly the wave dissipates
  
  Wave(float sourceX, float amplitude, float frequency, float speed) {
    this.sourceX = sourceX;
    this.amplitude = amplitude;
    this.frequency = frequency;
    this.speed = speed;
    this.phase = 0;
    this.wavelength = 100;
    this.damping = 0.99;
  }
  
  void update() {
    // Update phase
    phase += speed * 0.05;
    
    // Dampen amplitude over time
    amplitude *= damping;
  }
  
  float getHeightAt(float x) {
    // Calculate distance from source
    float distance = abs(x - sourceX);
    
    // Calculate wave height using sine function with distance and phase
    float waveEffect = sin(TWO_PI * frequency * (distance/wavelength - phase));
    
    // Reduce amplitude with distance from source (circular wave dissipation)
    float distanceFactor = max(0, 1 - distance/(width*0.8));
    
    return amplitude * waveEffect * distanceFactor;
  }
}
