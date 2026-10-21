ArrayList<Array> lists;
Array list, plist, tlist;
int type = 3, napTime = 100, len = 40, index = 0, loop = 0;
boolean autoFlag = true;
String[] titles = {"selectionSort", "bubbleSort", "insertSort", "mergeSort", "quickSort"};
PFont f;

void setup() {
  size(900, 600);
  f = createFont("Arial-BoldMT-48.vlw", 20);
  textFont(f);
  run(type);
}

void draw() {
  background(232, 236, 242);
  list = lists.get(index);
  list.draw();

  fill(35);
  textSize(22);
  text(titles[type], 20, 32);
  textSize(13);
  text("Elements: " + len + "    Step: " + index + " / " + loop
    + "    Delay: " + napTime + " ms    " + (autoFlag ? "AUTO" : "PAUSED"),
    20, height - 17);

  // Legend for the active sorting colors.
  noStroke();
  fill(255, 70, 70);
  rect(20, 48, 14, 14);
  fill(35);
  text("Current / compare", 40, 60);
  fill(255, 165, 0);
  rect(175, 48, 14, 14);
  fill(35);
  text("Merge range", 195, 60);
  fill(105, 145, 190);
  rect(290, 48, 14, 14);
  fill(35);
  text("Other values", 310, 60);

  if (autoFlag) nextStep();
}

void nextStep() {
  if (index == 0)
    delay(10 * napTime);
  else
    delay(napTime);
  if (index < loop) index++;
  else index = 0;
}

void keyPressed() {
  if (key == ' ') {
    autoFlag = !autoFlag;
  } else if (key == 'a') {
    if (napTime > 20) napTime -= 20;
  } else if (key == 's') {
    napTime += 20;
  } else if (key == 'z') {
    if (type > 0) {
      type--;
      run(type);
    }
  } else if (key == 'x') {
    if (type < 3) {
      type++;
      run(type);
    }
  } else if (key == CODED) {
    if (keyCode == LEFT) {
      autoFlag = false;
      if (index > 0) index--;
    } else if (keyCode == RIGHT) {
      autoFlag = false;
      if (index < loop) index++;
    }
  }
}

void mousePressed() {
  if (autoFlag) autoFlag = false;
  if (mouseButton == LEFT) {
    if (index > 0) index--;
  } else if (mouseButton == RIGHT) {
    if (index < loop) index++;
  }
}

void run(int type) {
  loop = index = 0;
  tlist = new Array(len, 0, -1);
  lists = new ArrayList<Array>();
  lists.add(new Array(len, 0, -1));
  list = lists.get(0);
  list.printArray();

  if (type == 0) selectionSort();
  else if (type == 1) bubbleSort();
  else if (type == 2) insertSort();
  else if (type == 3) mergeSort();

  list = lists.get(loop);
  list.printArray();
}

void addStep(int i, int j) {
  plist = lists.get(loop);
  lists.add(new Array(len, plist.arr, i, j));
  loop++;
}

void selectionSort() {
  int i, j, maxValue, maxIndex;
  int[] working = lists.get(0).arr.clone();

  for (i = 0; i < len; i++) {
    maxValue = -1;
    maxIndex = -1;
    for (j = 0; j < len - i; j++) {
      addStep(j, len - i - 1);
      list = lists.get(loop);
      if (working[j] > maxValue) {
        maxValue = working[j];
        maxIndex = j;
      }
    }
    if (maxIndex >= 0) {
      int tmp = working[maxIndex];
      working[maxIndex] = working[len - i - 1];
      working[len - i - 1] = tmp;
    }
    addStep(maxIndex, len - i - 1);
    lists.get(loop).arr = working.clone();
  }
}

void bubbleSort() {
  int[] working = lists.get(0).arr.clone();
  for (int j = 0; j < len - 1; j++) {
    for (int i = 0; i < len - j - 1; i++) {
      addStep(i, i + 1);
      if (working[i] > working[i + 1]) {
        int tmp = working[i];
        working[i] = working[i + 1];
        working[i + 1] = tmp;
      }
      lists.get(loop).arr = working.clone();
    }
  }
}

void insertSort() {
  int[] working = lists.get(0).arr.clone();
  for (int i = 1; i < len; i++) {
    int temp = working[i];
    int j = i - 1;
    addStep(i, i);
    while (j >= 0 && working[j] > temp) {
      working[j + 1] = working[j];
      addStep(j, j + 1);
      lists.get(loop).arr = working.clone();
      j--;
    }
    working[j + 1] = temp;
    addStep(j + 1, i);
    lists.get(loop).arr = working.clone();
  }
}

void mergeSort() {
  int[] working = lists.get(0).arr.clone();
  mergeSort(working, 0, len - 1);
}

void mergeSort(int[] working, int low, int high) {
  if (low < high) {
    int middle = low + (high - low) / 2;
    addStep(-(low + 1), -(high + 1));
    lists.get(loop).arr = working.clone();
    mergeSort(working, low, middle);
    mergeSort(working, middle + 1, high);
    merge(working, low, middle, high);
    addStep(-(low + 1), -(high + 1));
    lists.get(loop).arr = working.clone();
  }
}

void merge(int[] working, int low, int middle, int high) {
  int[] temp = working.clone();
  int i = low, j = middle + 1, k = low;

  while (i <= middle && j <= high) {
    addStep(i, j);
    if (temp[i] <= temp[j])
      working[k++] = temp[i++];
    else
      working[k++] = temp[j++];
    addStep(k - 1, k - 1);
    lists.get(loop).arr = working.clone();
  }
  while (i <= middle) {
    working[k++] = temp[i++];
    addStep(k - 1, k - 1);
    lists.get(loop).arr = working.clone();
  }
  while (j <= high) {
    working[k++] = temp[j++];
    addStep(k - 1, k - 1);
    lists.get(loop).arr = working.clone();
  }
}

void swap(int[] arr, int i, int j) {
  int tmp = arr[j];
  arr[j] = arr[i];
  arr[i] = tmp;
}
