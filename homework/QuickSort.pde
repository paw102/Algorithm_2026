int[] arr;

void setup() {
  intArr(16);
  printArr();
  quickSort(0, arr.length-1);
  printArr();
}

void intArr(int n) {
  int i;
  arr = new int[n];
  for(i=0; i<arr.length; i++) {
    arr[i] = (int) random(100);
  }
}

void printArr() {
  int i;
  for(i=0; i<arr.length; i++) {
    print(arr[i], " ");
  }
  println();
}

void quickSort(int left, int right) {
  if(left < right) {
    int pivotIndex = partition(left, right);
    quickSort(left, pivotIndex-1);
    quickSort(pivotIndex+1, right);
  }
}

int partition(int left, int right) {
  int pivot = arr[right];
  int i = left - 1;
  int j;

  for(j=left; j<right; j++) {
    if(arr[j] < pivot) {
      i++;
      swap(i, j);
    }
  }
  swap(i+1, right);
  return i+1;
}

void swap(int i, int j) {
  int tmp;
  tmp = arr[j];
  arr[j] = arr[i];
  arr[i] = tmp;
}

void draw() {
}
