// BubbleSystem.pde - Manages bubble spawning and drawing

void drawBubbles() {
  // Spawn new bubbles at nodes
  for (int i = 0; i < nodes; i++) {
    // Decrease timer
    bubbleTimers[i]--;
    
    // When timer reaches zero, maybe spawn a bubble
    if (bubbleTimers[i] <= 0) {
      // Random chance to actually spawn
      if (random(1) < bubbleSpawnChance) {
        // Create bubble slightly below the node
        float bubbleX = nodeX[i] + random(-5, 5);  // Slight random offset
        
        // FIXED: Spawn bubble BELOW the surface, not above it
        float bubbleY = nodeY[i] + random(20, 100);   // Start below surface (plus means down)
        
        bubbles.add(new Bubble(bubbleX, bubbleY, i, nodeY[i]));
      }
      
      // Reset timer with random delay
      bubbleTimers[i] = random(120, 240);  // Frames until next possible spawn
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
  if (!showDashboard) {
    fill(255);
    textSize(12);
    text("Active bubbles: " + bubbles.size(), 20, height - 20);
  }
}
