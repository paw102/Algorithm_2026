class Array {
  int i0, j0, len, max, w;
  int[] arr;

  Array(int len, int i0, int j0) {
    max = 100;
    this.i0 = i0;
    this.j0 = j0;
    this.len = len;
    arr = new int[len];
    w = Math.max(1, (width - 4) / len);
    shuffle();
  }

  Array(int len, int[] arr, int i0, int j0) {
    this.i0 = i0;
    this.j0 = j0;
    this.len = len;
    this.arr = new int[len];
    w = Math.max(1, (width - 4) / len);
    for (int i = 0; i < len; i++)
      this.arr[i] = arr[i];
  }

  void draw() {
    int x, y, h;
    boolean mergeRange = (i0 < 0 && j0 < 0);
    int rangeLow = mergeRange ? -i0 - 1 : -1;
    int rangeHigh = mergeRange ? -j0 - 1 : -1;

    // Draw the bars with clear contrast between active and inactive values.
    noStroke();
    for (int i = 0; i < len; i++) {
      if (mergeRange && i >= rangeLow && i <= rangeHigh) {
        fill(255, 165, 0);       // merge range: orange
      } else if (i == i0 && i == j0) {
        fill(255, 70, 70);       // current item
      } else if (i == i0 || i == j0) {
        fill(255, 70, 70);       // active comparison / insertion positions
      } else {
        fill(105, 145, 190);     // other values
      }

      x = i * w + 2;
      h = arr[i];
      y = height - 5 * h - 78;
      rect(x, y, Math.max(1, w - 2), 5 * h);
    }

    // Highlight the active index labels under the bars.
    textAlign(CENTER);
    textSize(11);
    for (int i = 0; i < len; i++) {
      if (i == i0 || i == j0)
        fill(190, 25, 25);
      else
        fill(55);
      if (w >= 15)
        text(i, i * w + w / 2, height - 48);
    }
    textAlign(LEFT);
  }

  void shuffle() {
    for (int i = 0; i < len; i++)
      arr[i] = (int) random(max);
  }

  void printArray() {
    print("(" + nf(i0, 2) + "," + nf(j0, 2) + ")- ");
    for (int i = 0; i < len; i++)
      print(nf(arr[i], 2) + " ");
    println();
  }
}
