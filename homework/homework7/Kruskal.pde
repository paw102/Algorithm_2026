import java.util.ArrayList;
import java.util.Collections;

ArrayList<Node> nodes = new ArrayList<Node>();
ArrayList<Edge> edges = new ArrayList<Edge>();
ArrayList<Edge> sortedEdges = new ArrayList<Edge>();
ArrayList<Edge> mstEdges = new ArrayList<Edge>();

UnionFind uf;
int currentEdgeIndex = 0;
boolean finished = false;
String statusMessage = "";
float totalWeight = 0;

void setup() {
  size(900, 620);
  textFont(createFont("SansSerif", 14));
  generateGraph(8, 15);
}

void draw() {
  background(22, 26, 33);

  // 그래프 영역 배경
  fill(30, 35, 44);
  noStroke();
  rect(20, 20, 610, height - 40, 12);

  // 우측 정보 패널 배경
  fill(30, 35, 44);
  rect(650, 20, 230, height - 40, 12);

  // 1. 전체 간선 그리기
  for (Edge e : edges) {
    boolean inMst = mstEdges.contains(e);
    boolean isCurrent = (!finished && currentEdgeIndex < sortedEdges.size() && sortedEdges.get(currentEdgeIndex) == e);
    boolean isRejected = e.rejected;

    if (inMst) {
      stroke(72, 187, 120); // 채택된 MST 간선 (초록)
      strokeWeight(4);
    } else if (isCurrent) {
      stroke(246, 224, 94); // 현재 검사 중인 간선 (노랑)
      strokeWeight(4);
    } else if (isRejected) {
      stroke(113, 128, 150, 80); // 사이클 발생으로 제외된 간선 (흐린 회색)
      strokeWeight(1.5);
    } else {
      stroke(113, 128, 150, 160); // 대기 중인 간선
      strokeWeight(2);
    }

    Node a = nodes.get(e.u);
    Node b = nodes.get(e.v);
    line(a.x, a.y, b.x, b.y);

    // 간선 가중치 표시
    float mx = (a.x + b.x) / 2.0;
    float my = (a.y + b.y) / 2.0;
    fill(20, 24, 30, 220);
    noStroke();
    rectMode(CENTER);
    rect(mx, my, 28, 20, 5);
    rectMode(CORNER);

    fill(inMst ? color(154, 230, 180) : (isCurrent ? color(250, 240, 137) : color(203, 213, 224)));
    textAlign(CENTER, CENTER);
    textSize(12);
    text(e.weight, mx, my);
  }

  // 2. 정점(Node) 그리기
  for (Node n : nodes) {
    int compRoot = uf.find(n.id);
    color c = colorFromRoot(compRoot);

    fill(c);
    stroke(255);
    strokeWeight(2);
    ellipse(n.x, n.y, 34, 34);

    fill(18, 22, 28);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(n.id, n.x, n.y);
  }

  // 3. 우측 패널 정보 출력
  drawInfoPanel();
}

void drawInfoPanel() {
  int px = 670;
  int w = 190;

  fill(255);
  textAlign(LEFT, TOP);
  textSize(17);
  text("Kruskal's MST", px, 38);

  fill(160, 174, 192);
  textSize(12);
  text("MST Total Weight", px, 75);
  fill(72, 187, 120);
  textSize(24);
  text(nf(totalWeight, 0, 0), px, 93);

  fill(160, 174, 192);
  textSize(12);
  text("MST Edges", px, 135);
  fill(255);
  textSize(16);
  text(mstEdges.size() + " / " + max(0, nodes.size() - 1), px, 153);

  fill(160, 174, 192);
  textSize(12);
  text("Step Status", px, 192);
  fill(246, 224, 94);
  textSize(13);
  text(statusMessage, px, 212, w, 75);

  // 범례
  textSize(12);
  fill(72, 187, 120);
  text("■ MST Edge (Union)", px, 300);
  fill(246, 224, 94);
  text("■ Checking Edge", px, 322);
  fill(140, 150, 165);
  text("■ Skipped (Cycle)", px, 344);

  // 버튼 그리기
  drawButton(px, 400, w, 42, finished ? "Completed" : "Next Step (SPACE)", !finished ? color(49, 130, 206) : color(74, 85, 104));
  drawButton(px, 454, w, 42, "Reset MST (A)", color(58, 67, 84));
  drawButton(px, 508, w, 42, "New Graph (R)", color(197, 48, 48));
}

void drawButton(int x, int y, int w, int h, String label, color bg) {
  boolean hover = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  fill(hover ? lerpColor(bg, color(255), 0.15) : bg);
  noStroke();
  rect(x, y, w, h, 8);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(13);
  text(label, x + w / 2, y + h / 2);
}

void mousePressed() {
  int px = 670;
  int w = 190;

  if (mouseX >= px && mouseX <= px + w) {
    if (mouseY >= 400 && mouseY <= 442) {
      stepKruskal();
    } else if (mouseY >= 454 && mouseY <= 496) {
      resetKruskalState();
    } else if (mouseY >= 508 && mouseY <= 550) {
      generateGraph(8, 15);
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    stepKruskal();
  } else if (key == 'a' || key == 'A') {
    resetKruskalState();
  } else if (key == 'r' || key == 'R') {
    generateGraph(8, 15);
  }
}

void generateGraph(int nodeCount, int edgeCount) {
  nodes.clear();
  edges.clear();

  float centerX = 325;
  float centerY = height / 2.0;
  float radius = 210;

  for (int i = 0; i < nodeCount; i++) {
    float angle = TWO_PI * i / nodeCount - HALF_PI;
    float nx = centerX + cos(angle) * radius + random(-25, 25);
    float ny = centerY + sin(angle) * radius + random(-25, 25);
    nodes.add(new Node(i, nx, ny));
  }

  for (int i = 0; i < nodeCount - 1; i++) {
    int w = int(random(2, 20));
    edges.add(new Edge(i, i + 1, w));
  }

  int safety = 0;
  while (edges.size() < edgeCount && safety < 500) {
    safety++;
    int u = int(random(nodeCount));
    int v = int(random(nodeCount));
    if (u == v) continue;
    if (!hasEdge(u, v)) {
      int w = int(random(2, 25));
      edges.add(new Edge(u, v, w));
    }
  }

  resetKruskalState();
}

boolean hasEdge(int u, int v) {
  for (Edge e : edges) {
    if ((e.u == u && e.v == v) || (e.u == v && e.v == u)) {
      return true;
    }
  }
  return false;
}

void resetKruskalState() {
  mstEdges.clear();
  sortedEdges = new ArrayList<Edge>(edges);
  Collections.sort(sortedEdges);

  for (Edge e : edges) {
    e.rejected = false;
  }

  uf = new UnionFind(nodes.size());
  currentEdgeIndex = 0;
  totalWeight = 0;
  finished = false;
  statusMessage = "간선 가중치 오름차순 정렬 완료. Next Step을 누르세요.";
}

void stepKruskal() {
  if (finished) return;

  if (mstEdges.size() >= nodes.size() - 1 || currentEdgeIndex >= sortedEdges.size()) {
    finished = true;
    statusMessage = "MST 완성! 총 가중치: " + int(totalWeight);
    return;
  }

  Edge e = sortedEdges.get(currentEdgeIndex);
  int rootU = uf.find(e.u);
  int rootV = uf.find(e.v);

  if (rootU != rootV) {
    uf.union(rootU, rootV);
    mstEdges.add(e);
    totalWeight += e.weight;
    statusMessage = "간선 (" + e.u + " - " + e.v + ", w=" + e.weight + ") 채택: 두 집합 병합";
  } else {
    e.rejected = true;
    statusMessage = "간선 (" + e.u + " - " + e.v + ", w=" + e.weight + ") 제외: 사이클 발생";
  }

  currentEdgeIndex++;

  if (mstEdges.size() >= nodes.size() - 1 || currentEdgeIndex >= sortedEdges.size()) {
    finished = true;
    statusMessage += " | MST 완료!";
  }
}

color colorFromRoot(int root) {
  colorMode(HSB, 360, 100, 100);
  float hue = (root * 67) % 360;
  color c = color(hue, 75, 95);
  colorMode(RGB, 255);
  return c;
}

class Node {
  int id;
  float x, y;

  Node(int id, float x, float y) {
    this.id = id;
    this.x = x;
    this.y = y;
  }
}

class Edge implements Comparable<Edge> {
  int u, v, weight;
  boolean rejected = false;

  Edge(int u, int v, int weight) {
    this.u = u;
    this.v = v;
    this.weight = weight;
  }

  int compareTo(Edge other) {
    return Integer.compare(this.weight, other.weight);
  }
}

class UnionFind {
  int[] parent;
  int[] rank;

  UnionFind(int n) {
    parent = new int[n];
    rank = new int[n];
    for (int i = 0; i < n; i++) {
      parent[i] = i;
      rank[i] = 0;
    }
  }

  int find(int x) {
    if (parent[x] != x) {
      parent[x] = find(parent[x]); // 경로 압축 (Path Compression)
    }
    return parent[x];
  }

  void union(int a, int b) {
    int rootA = find(a);
    int rootB = find(b);
    if (rootA == rootB) return;

    // 랭크 기반 합치기 (Union by Rank)
    if (rank[rootA] < rank[rootB]) {
      parent[rootA] = rootB;
    } else if (rank[rootA] > rank[rootB]) {
      parent[rootB] = rootA;
    } else {
      parent[rootB] = rootA;
      rank[rootA]++;
    }
  }
}
