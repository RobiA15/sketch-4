// WaterDrawing.pde - Handles visual rendering of water

void drawWater() {
  // Water surface
  fill(0, 150, 255, 200);
  stroke(0, 100, 200);
  
  beginShape();
  
  // Extend the left side beyond the screen
  vertex(-2, height);
  vertex(-2, nodeY[0]);
  
  // Add extra control points for better edge behavior
  curveVertex(-2, nodeY[0]);
  curveVertex(nodeX[0], nodeY[0]);
  
  // Draw all the regular nodes
  for (int i = 0; i < nodes; i++) {
    curveVertex(nodeX[i], nodeY[i]);
  }
  
  // Add extra control points at the end
  curveVertex(nodeX[nodes-1], nodeY[nodes-1]);
  curveVertex(width + 2, nodeY[nodes-1]);
  
  // Extend the right side beyond the screen
  vertex(width + 2, nodeY[nodes-1]);
  vertex(width + 2, height);
  
  endShape(CLOSE);
}
