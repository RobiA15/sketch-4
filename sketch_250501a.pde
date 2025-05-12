ArrayList<PVector> nodes = new ArrayList<PVector>();
ArrayList<int[]> edges = new ArrayList<int[]>();
ArrayList<Spider> spiders = new ArrayList<Spider>();

int spokes = 8, layers = 1;
float layerDist = 40;

void setup() {
  size(400, 400);
  nodes.add(new PVector(width/2, height/2));
  makeLayer();
}

void draw() {
  drawScenery();

  stroke(0);
  for (int[] e : edges)
    line(nodes.get(e[0]).x, nodes.get(e[0]).y, nodes.get(e[1]).x, nodes.get(e[1]).y);

  for (Spider s : spiders)
    s.update().show();
}


void mousePressed() {
  int base = nodes.size() - spokes;
  spiders.add(new Spider(base));
  spiders.add(new Spider(base));
  makeLayer();
}

void makeLayer() {
  int base = nodes.size();
  float r = layerDist * layers++;
  for (int i = 0; i < spokes; i++) {
    float angle = TWO_PI * i / spokes;
    PVector p = new PVector(width/2 + cos(angle)*r, height/2 + sin(angle)*r);
    nodes.add(p);
    edges.add(new int[]{(layers == 2 ? 0 : base - spokes + i), base + i});
    edges.add(new int[]{base + i, base + (i + 1) % spokes});
  }
}

class Spider {
  int from, to;
  float t = 0;

  Spider(int start) {
    from = start;
    to = pickNeighbor(from);
  }

  Spider update() {
    if (to == -1) return this;
    t += 0.01;
    if (t >= 1) {
      from = to;
      to = pickNeighbor(from);
      t = 0;
    }
    return this;
  }

void show() {
  if (to == -1) return;
  PVector a = nodes.get(from), b = nodes.get(to);
  float x = lerp(a.x, b.x, t), y = lerp(a.y, b.y, t);

  fill(0);
  noStroke();
  ellipse(x, y, 10, 10); // spider body

  stroke(0);
  float legLen = 9;  
  for (int i = 0; i < 4; i++) {
    float angle = radians(45 + i * 20);
    line(x, y, x + cos(angle) * legLen, y + sin(angle) * legLen);          // right legs
    line(x, y, x + cos(PI - angle) * legLen, y + sin(PI - angle) * legLen); // left legs
  }
}

  int pickNeighbor(int idx) {
    ArrayList<Integer> n = new ArrayList<Integer>();
    for (int[] e : edges) {
      if (e[0] == idx) n.add(e[1]);
      if (e[1] == idx) n.add(e[0]);
    }
    return n.size() == 0 ? -1 : n.get((int)random(n.size()));
  }
}

void drawScenery() {
  drawSkyGradient();
  drawSun();
  drawGrass();
  drawCloud(80, 100);
  drawCloud(250, 70);
  drawCloud(180, 140);
}

void drawSkyGradient() {
  for (int y = 0; y < height * 0.75; y++) {
    float inter = map(y, 0, height * 0.75, 255, 180);  
    stroke(135, 206, inter);  
    line(0, y, width, y);
  }
}

void drawSun() {
  noStroke();
  fill(255, 223, 0);
  ellipse(width - 60, 60, 50, 50);
}
void drawGrass() {
  noStroke();
  fill(60, 179, 113);
  rect(0, height * 0.75, width, height * 0.25);

  // darker strips of grass
  fill(34, 139, 34);
  for (int i = 0; i < 16; i++) {
    rect(0, height * 0.75 + i * 6, width, 3);
  }
}
void drawCloud(float x, float y) {
  noStroke();
  fill(255);
  ellipse(x, y, 40, 40);
  ellipse(x + 20, y + 10, 50, 50);
  ellipse(x - 20, y + 10, 45, 45);
  ellipse(x, y + 15, 35, 35);
}
