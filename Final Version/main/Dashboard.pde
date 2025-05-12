// Dashboard.pde - Handles energy dashboard visualization

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
