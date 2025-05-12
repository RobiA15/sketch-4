// Bubble.pde - Bubble class definition

class Bubble {
  float x, y;          // Position
  float size;          // Bubble radius
  float speed;         // Upward speed
  float wobble;        // For slight horizontal movement
  float wobblePhase;   // Where in the wobble cycle we are
  float transparency;  // For visual appeal
  int birthNode;       // Which node spawned this bubble
  float surfaceY;      // Y position of the surface at creation
  
  Bubble(float x, float y, int node, float surfaceY) {
    this.x = x;
    this.y = y;
    this.birthNode = node;
    this.surfaceY = surfaceY;  // Store the surface position at creation
    
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
    // Check if bubble has reached the surface
    // Since bubbles start below the surface and move up, they die when they reach the surface
    return y < surfaceY - 5;  // Small offset to make them pop just at the surface
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
