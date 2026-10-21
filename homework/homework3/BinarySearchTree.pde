import javax.swing.JOptionPane;

int n = 8;
int xstep = 400;
int ystep = 50;
int radius = 30;
int traversal = 0; // 0: inorder, 1: preorder, 2: postorder
int textcolor = 0;
PFont font;

BTree tree = new BTree();
String message = "Left-click empty space: insert | click node: delete | S: search";
String traversalOutput = "Press V or Space to display traversal order";

void setup() {
  size(1200, 600);
  font = createFont("Arial", 16, true);
  textFont(font, 16);
  textAlign(CENTER, CENTER);
  stroke(192, 0, 0);
  newTree();
}

void draw() {
  // Drawing is handled by drawTree() after each action.
}

void mousePressed() {
  if (mouseButton == LEFT) {
    tree.findNode();
    if (tree.value != -1) {
      int deleted = tree.value;
      tree.remove(deleted);
      message = "Deleted: " + deleted;
    } else {
      int value = constrain((int)(100.0 * mouseX / width), 0, 99);
      if (tree.insert(value)) message = "Inserted: " + value;
      else message = "Value already exists: " + value;
    }
    drawTree();
  }
}

void mouseMoved() {
  tree.findNode();
  drawTree();
  if (tree.value != -1) {
    fill(92);
    ellipse(tree.x, tree.y, radius, radius);
    fill(255);
    text(tree.value, tree.x, tree.y);
  }
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    tree.clear();
    message = "Tree cleared";
    drawTree();
  } else if (key == 'v' || key == 'V' || key == ' ') {
    drawTree();
    tree.printTree();
  } else if (key == 'b' || key == 'B') {
    newTree();
    message = "New random tree created";
  } else if (key == 't' || key == 'T') {
    traversal = (traversal + 1) % 3;
    traversalOutput = "Press V or Space to display " + (traversal == 0 ? "Inorder" : traversal == 1 ? "Preorder" : "Postorder") + " traversal";
    drawTree();
  } else if (key == 'd' || key == 'D') {
    textcolor = 1 - textcolor;
    drawTree();
  } else if (key == 's' || key == 'S') {
    searchValue();
  }
}

void searchValue() {
  String input = JOptionPane.showInputDialog(null, "Enter the integer to search:", "Binary Search Tree", JOptionPane.QUESTION_MESSAGE);
  if (input == null) return;
  try {
    int target = Integer.parseInt(input.trim());
    if (tree.contains(target)) message = "Search: " + target + " found";
    else message = "Search: " + target + " not found";
  } catch (NumberFormatException e) {
    message = "Invalid input: enter an integer";
  }
  println(message);
  drawTree();
}

void newTree() {
  tree.clear();
  for (int i = 0; i < n; i++) tree.insert((int)random(99));
  drawTree();
}

void drawTree() {
  background(200);
  tree.assignPosition();
  tree.drawTree();
  drawTraversalOutput();
  drawMode();
}

// Display the traversal result inside the sketch window, wrapping long results.
void drawTraversalOutput() {
  textFont(font, 15);
  textAlign(LEFT, TOP);
  noStroke();
  fill(255, 245);
  rect(8, 8, width - 16, 52, 8);
  fill(0);
  String[] words = traversalOutput.split(" ");
  String line = "";
  float x = 16;
  float y = 14;
  float maxWidth = width - 32;
  for (int i = 0; i < words.length; i++) {
    String candidate = line.length() == 0 ? words[i] : line + " " + words[i];
    if (textWidth(candidate) > maxWidth && line.length() > 0) {
      text(line, x, y);
      line = words[i];
      y += 20;
    } else {
      line = candidate;
    }
  }
  if (line.length() > 0) text(line, x, y);
  textAlign(CENTER, CENTER);
}

void drawMode() {
  textFont(font, 16);
  textAlign(LEFT, CENTER);
  noStroke();
  fill(200);
  rect(0, height - 60, width, 60);
  fill(0);
  String modeName = traversal == 0 ? "Inorder" : traversal == 1 ? "Preorder" : "Postorder";
  text("Traversal: " + modeName + " (T to change, V/Space to print)", 12, height - 46);
  text("Insert: click empty space | Delete: click a node | Search: S | Clear: C | Random tree: B | Text color: D", 12, height - 27);
  text("Status: " + message, 12, height - 9);
  stroke(192, 0, 0);
  textAlign(CENTER, CENTER);
}

class BTree {
  Node root;
  int x, y, value, index;

  void clear() { root = null; }
  boolean isEmpty() { return root == null; }

  boolean contains(int in) { return contains(in, root); }
  boolean contains(int in, Node curr) {
    if (curr == null) return false;
    if (in < curr.val) return contains(in, curr.left);
    if (in > curr.val) return contains(in, curr.right);
    return true;
  }

  boolean insert(int in) {
    if (contains(in)) return false;
    root = insertNode(in, root);
    return true;
  }

  Node insertNode(int in, Node curr) {
    if (curr == null) return new Node(in);
    if (in < curr.val) curr.left = insertNode(in, curr.left);
    else if (in > curr.val) curr.right = insertNode(in, curr.right);
    return curr;
  }

  void remove(int in) { root = removeNode(in, root); }
  Node removeNode(int in, Node curr) {
    if (curr == null) return null;
    if (in < curr.val) curr.left = removeNode(in, curr.left);
    else if (in > curr.val) curr.right = removeNode(in, curr.right);
    else {
      if (curr.left == null) return curr.right;
      if (curr.right == null) return curr.left;
      Node successor = findMinNode(curr.right);
      curr.val = successor.val;
      curr.right = removeNode(successor.val, curr.right);
    }
    return curr;
  }

  Node findMinNode(Node curr) {
    while (curr != null && curr.left != null) curr = curr.left;
    return curr;
  }

  int findMin() {
    Node node = findMinNode(root);
    if (node == null) throw new IllegalStateException("Tree is empty");
    return node.val;
  }

  Node findMaxNode(Node curr) {
    while (curr != null && curr.right != null) curr = curr.right;
    return curr;
  }

  int findMax() {
    Node node = findMaxNode(root);
    if (node == null) throw new IllegalStateException("Tree is empty");
    return node.val;
  }

  int treeHeight() { return treeHeight(root); }
  int treeHeight(Node curr) {
    if (curr == null) return -1;
    return 1 + max(treeHeight(curr.left), treeHeight(curr.right));
  }

  void assignPosition() {
    if (!isEmpty()) assignPosition(root, 0, 0);
  }

  void assignPosition(Node curr, float dx, float dy) {
    if (curr == null) return;
    assignPosition(curr.left, dx - 1.0 / pow(2.0, dy + 1), dy + 1);
    curr.x = dx;
    curr.y = dy;
    assignPosition(curr.right, dx + 1.0 / pow(2.0, dy + 1), dy + 1);
  }

  void printTree() {
    index = 0;
    if (isEmpty()) {
      traversalOutput = "The tree is empty";
      println(traversalOutput);
      drawTree();
      return;
    }

    String name = traversal == 0 ? "Inorder" : traversal == 1 ? "Preorder" : "Postorder";
    traversalOutput = name + " traversal: ";
    StringBuilder result = new StringBuilder();
    collectTraversal(root, result);
    traversalOutput += result.toString();
    println(traversalOutput);
    drawTree();
  }

  void collectTraversal(Node curr, StringBuilder result) {
    if (curr == null) return;
    if (traversal == 0) {
      collectTraversal(curr.left, result);
      appendValue(curr, result);
      collectTraversal(curr.right, result);
    } else if (traversal == 1) {
      appendValue(curr, result);
      collectTraversal(curr.left, result);
      collectTraversal(curr.right, result);
    } else {
      collectTraversal(curr.left, result);
      collectTraversal(curr.right, result);
      appendValue(curr, result);
    }
  }

  void appendValue(Node curr, StringBuilder result) {
    if (result.length() > 0) result.append(" ");
    result.append(curr.val);
    index++;
  }

  void findNode() {
    x = y = value = -1;
    if (!isEmpty()) findNode(root);
  }

  void findNode(Node curr) {
    if (curr == null || value != -1) return;
    findNode(curr.left);
    if (value != -1) return;
    int cx = (int)(curr.x * xstep + width / 2);
    int cy = (int)(curr.y * ystep + radius);
    int dx = mouseX - cx;
    int dy = mouseY - cy;
    if (dx * dx + dy * dy < radius * radius / 4) {
      x = cx;
      y = cy;
      value = curr.val;
      return;
    }
    findNode(curr.right);
  }

  void drawTree() {
    if (isEmpty()) return;
    drawTreeLines(root);
    drawNodes(root);
  }

  void drawTreeLines(Node curr) {
    if (curr == null) return;
    int cx = (int)(curr.x * xstep + width / 2);
    int cy = (int)(curr.y * ystep + radius);
    if (curr.left != null) {
      line(cx, cy, (int)(curr.left.x * xstep + width / 2), (int)(curr.left.y * ystep + radius));
    }
    if (curr.right != null) {
      line(cx, cy, (int)(curr.right.x * xstep + width / 2), (int)(curr.right.y * ystep + radius));
    }
    drawTreeLines(curr.left);
    drawTreeLines(curr.right);
  }

  void drawNodes(Node curr) {
    if (curr == null) return;
    drawNodes(curr.left);
    fill(255);
    ellipse(curr.x * xstep + width / 2, curr.y * ystep + radius, radius, radius);
    fill(textcolor == 0 ? 0 : 255);
    text(curr.val, curr.x * xstep + width / 2, curr.y * ystep + radius);
    drawNodes(curr.right);
  }
}

class Node {
  int val;
  float x, y;
  Node left, right;
  Node(int v) { val = v; }
  Node(int v, Node l, Node r) { val = v; left = l; right = r; }

  public String toString() {
    if (left == null && right == null) return "N(" + val + ")";
    return "N(" + val + ", " + left + ", " + right + ")";
  }
}
