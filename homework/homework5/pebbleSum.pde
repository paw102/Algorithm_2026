int Value[][] = new int[4][101];   
int DP[][] = new int[5][101];      
int cnt = 3;                       

int pat[][] = { {1,0,0}, {0,1,0}, {0,0,1}, {1,0,1}, {0,0,0} };

int score(int p, int j) {
  int s = 0;
  for (int r = 0; r < 3; r++)
    if (pat[p][r] == 1) s += Value[r][j];
  return s;
}

boolean ok(int p, int q) {
  for (int r = 0; r < 3; r++)
    if (pat[p][r] == 1 && pat[q][r] == 1) return false;
  return true;
}

void setup() {
  int i, j, p, q;

  for (i = 0; i < 3; i++) {
    for (j = 0; j < cnt; j++) {
      Value[i][j] = (int) random(-10, 10);
      print(nfp(Value[i][j], 4) + " ");
    }
    println();
  }

  for (p = 0; p < 5; p++)
    DP[p][0] = score(p, 0);

  for (j = 1; j < cnt; j++) {
    for (p = 0; p < 5; p++) {
      int best = -9999;
      for (q = 0; q < 5; q++) {
        if (ok(p, q) && DP[q][j-1] > best)
          best = DP[q][j-1];
      }
      DP[p][j] = best + score(p, j);
    }
  }

  int ans = -9999;
  for (p = 0; p < 5; p++)
    if (DP[p][cnt-1] > ans) ans = DP[p][cnt-1];

  println("max = " + ans);
}
