int[] list = new int[100];
int i, j, index, tmp, max;
for(i = 0; i<list.length; i++) {
  list[i] = ((int)random(1000));
}

println(list.length);

for(i = 0; i<list.length; i++) {
  print(list[i], " ");
}

//line(0,0, 100,100);

for(i = 0; i < list.length; i++) {
  max = index = - 1;
  for(j = 0; j<list.length-i-1; j++) {
    if(max < list[j]) {
      max = list[j];
      index = j;
    }
  }
  if(index !=  -1) {
    tmp = list[j];
    list[j] = max;
    list[index] = tmp;
  }
}

println(" ");
println(" ");

for(i = 0; i<list.length; i++) {
  print(list[i], " ");
}
