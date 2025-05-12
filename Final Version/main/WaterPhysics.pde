// WaterPhysics.pde - Handles all water physics calculations

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
