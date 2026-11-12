int[][] graph = {
  {1, 3},         // 1번 노드 연결선
  {0, 2, 4},      // 2번 노드 연결선
  {1, 5},         // 3번 노드 연결선
  {0, 6},         // 4번 노드 연결선
  {1, 6, 7},      // 5번 노드 연결선
  {2, 7},         // 6번 노드 연결선
  {3, 4, 7},      // 7번 노드 연결선
  {4, 5, 6}       // 8번 노드 연결선
};

String[] names = {
  "1", "2", "3", "4", "5", "6", "7", "8"
};

float[][] pos = {
  {500, 100},  // 1번 노드 위치
  {320, 220},  // 2번 노드 위치
  {180, 380},  // 3번 노드 위치
  {680, 220},  // 4번 노드 위치
  {400, 400},  // 5번 노드 위치
  {200, 560},  // 6번 노드 위치
  {620, 480},  // 7번 노드 위치
  {450, 580}   // 8번 노드 위치
};

int[] order = new int[8];
String currentMode = "DFS"; 

void setup() {
  size(1000, 700);
  PFont font = createFont("Malgun Gothic", 16);
  textFont(font);
  
  runDFS(0); // 기본 시작
}

void draw() {
  background(40, 44, 52); // 다크 모드 배경
  
  // 1. 엣지(선) 그리기
  strokeWeight(3);
  for (int i = 0; i < graph.length; i++) {
    for (int j = 0; j < graph[i].length; j++) {
      int next = graph[i][j];
      if (i < next) { 
        stroke(120, 130, 150, 180); // 깔끔한 회색톤 엣지
        line(pos[i][0], pos[i][1], pos[next][0], pos[next][1]);
      }
    }
  }
  
  // 2. 노드(원과 번호) 그리기 - 모든 노드를 통일된 세련된 하늘색 계열로 설정
  for (int i = 0; i < pos.length; i++) {
    fill(100, 180, 230); // 통일된 노드 채우기 색상
    stroke(255);         // 흰색 테두리
    strokeWeight(2);
    ellipse(pos[i][0], pos[i][1], 65, 65);
    
    // 노드 번호 텍스트
    fill(30, 30, 30);
    textSize(22);
    textAlign(CENTER, CENTER);
    text(names[i], pos[i][0], pos[i][1]);
  }
  
  // 3. 조작 안내 및 탐색 결과 텍스트 출력
  textAlign(LEFT, BASELINE);
  fill(255);
  textSize(16);
  text("b: BFS   d: DFS   r: reset", 50, 40);
  
  String resultStr = currentMode + " 결과: ";
  for (int i = 0; i < order.length; i++) {
    resultStr += names[order[i]];
    if (i < order.length - 1) {
      resultStr += " -> ";
    }
  }
  text(resultStr, 50, 650);
}

// 키 입력 이벤트 (b: BFS, d: DFS, r: 리셋)
void keyPressed() {
  if (key == 'b' || key == 'B') {
    currentMode = "BFS";
    runBFS(0);
  } else if (key == 'd' || key == 'D') {
    currentMode = "DFS";
    runDFS(0);
  } else if (key == 'r' || key == 'R') {
    currentMode = "DFS";
    runDFS(0);
  }
}

// DFS 함수
void runDFS(int startNode) {
  boolean[] visited = new boolean[graph.length];
  IntList stack = new IntList();
  IntList resultList = new IntList();
  
  stack.append(startNode);
  
  while (stack.size() > 0) {
    int curr = stack.remove(stack.size() - 1);
    
    if (!visited[curr]) {
      visited[curr] = true;
      resultList.append(curr);
      
      for (int i = graph[curr].length - 1; i >= 0; i--) {
        int next = graph[curr][i];
        if (!visited[next]) {
          stack.append(next);
        }
      }
    }
  }
  
  for (int i = 0; i < resultList.size(); i++) {
    order[i] = resultList.get(i);
  }
}

// BFS 함수
void runBFS(int startNode) {
  boolean[] visited = new boolean[graph.length];
  IntList queue = new IntList();
  IntList resultList = new IntList();
  
  queue.append(startNode);
  visited[startNode] = true;
  
  while (queue.size() > 0) {
    int curr = queue.remove(0);
    resultList.append(curr);
    
    for (int i = 0; i < graph[curr].length; i++) {
      int next = graph[curr][i];
      if (!visited[next]) {
        visited[next] = true;
        queue.append(next);
      }
    }
  }
  
  for (int i = 0; i < resultList.size(); i++) {
    order[i] = resultList.get(i);
  }
}
