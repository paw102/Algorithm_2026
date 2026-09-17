int[] arr;

void setup() {
  intArr(16);
  printArr();
  mergeSort(0, arr.length-1);
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

void mergeSort(int left, int right) {
  if(left < right) {
    int mid = (left + right) / 2;
    mergeSort(left, mid);
    mergeSort(mid+1, right);
    merge(left, mid, right);
  }
}

void merge(int left, int mid, int right) {
  int n1 = mid - left + 1;
  int n2 = right - mid;
  int[] leftArr = new int[n1];
  int[] rightArr = new int[n2];
  int i, j, k;

  for(i=0; i<n1; i++) {
    leftArr[i] = arr[left + i];
  }
  for(j=0; j<n2; j++) {
    rightArr[j] = arr[mid + 1 + j];
  }

  i = 0;
  j = 0;
  k = left;
  while(i < n1 && j < n2) {
    if(leftArr[i] <= rightArr[j]) {
      arr[k] = leftArr[i];
      i++;
    } else {
      arr[k] = rightArr[j];
      j++;
    }
    k++;
  }

  while(i < n1) {
    arr[k] = leftArr[i];
    i++;
    k++;
  }

  while(j < n2) {
    arr[k] = rightArr[j];
    j++;
    k++;
  }
}

void draw() {
}
