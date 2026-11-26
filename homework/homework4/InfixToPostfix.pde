import java.util.ArrayList;
import java.util.Stack;

String infixInput = "3 + 4 * (2 - 1)";
String postfixDisplay = "";
String resultDisplay = "";

ArrayList<Button> buttons = new ArrayList<Button>();

void setup() {
  size(420, 620);
  textFont(createFont("SansSerif", 20));
  initButtons();
  updateCalculation();
}

void draw() {
  background(24, 27, 34);

  // 디스플레이 영역 배경
  fill(35, 40, 50);
  noStroke();
  rect(20, 20, width - 40, 175, 12);

  // 1. Infix 식 표시
  fill(160, 174, 192);
  textAlign(LEFT, TOP);
  textSize(13);
  text("INFIX", 35, 32);

  fill(255);
  textSize(22);
  text(infixInput.length() > 0 ? infixInput : "0", 35, 52);

  // 2. Postfix 식 표시
  fill(129, 230, 217);
  textSize(13);
  text("POSTFIX", 35, 92);

  fill(203, 213, 224);
  textSize(17);
  text(postfixDisplay.length() > 0 ? postfixDisplay : "-", 35, 112);

  // 3. 계산 결과 표시
  fill(246, 224, 94);
  textSize(13);
  text("RESULT", 35, 145);

  fill(255, 243, 176);
  textSize(22);
  text(resultDisplay.length() > 0 ? resultDisplay : "-", 35, 163);

  // 버튼 렌더링
  for (Button b : buttons) {
    b.display();
  }
}

void mousePressed() {
  for (Button b : buttons) {
    if (b.isHovered(mouseX, mouseY)) {
      handleInput(b.label);
      break;
    }
  }
}

void keyPressed() {
  if ((key >= '0' && key <= '9') || key == '+' || key == '-' || key == '*' || key == '/' || key == '(' || key == ')' || key == '.') {
    handleInput(str(key));
  } else if (key == BACKSPACE) {
    handleInput("DEL");
  } else if (key == ENTER || key == RETURN || key == '=') {
    updateCalculation();
  } else if (key == 'c' || key == 'C') {
    handleInput("C");
  }
}

void handleInput(String token) {
  if (token.equals("C")) {
    infixInput = "";
  } else if (token.equals("DEL")) {
    if (infixInput.length() > 0) {
      infixInput = infixInput.substring(0, infixInput.length() - 1);
    }
  } else if (token.equals("=")) {
    updateCalculation();
    return;
  } else {
    infixInput += token;
  }
  updateCalculation();
}

void updateCalculation() {
  String trimmed = infixInput.trim();
  if (trimmed.isEmpty()) {
    postfixDisplay = "";
    resultDisplay = "";
    return;
  }

  try {
    ArrayList<String> postfixTokens = infixToPostfix(trimmed);
    postfixDisplay = join(postfixTokens.toArray(new String[0]), " ");
    double val = evaluatePostfix(postfixTokens);

    if (Double.isNaN(val) || Double.isInfinite(val)) {
      resultDisplay = "Error (Div/0)";
    } else if (Math.abs(val - Math.round(val)) < 1e-9) {
      resultDisplay = str((long) Math.round(val));
    } else {
      resultDisplay = nf((float) val, 0, 4);
    }
  } catch (Exception e) {
    postfixDisplay = "Invalid expression";
    resultDisplay = "Error";
  }
}

// --- 1. Shunting-yard 알고리즘: Infix -> Postfix ---
ArrayList<String> infixToPostfix(String expr) {
  ArrayList<String> output = new ArrayList<String>();
  Stack<String> ops = new Stack<String>();
  ArrayList<String> tokens = tokenize(expr);

  for (String token : tokens) {
    if (isNumber(token)) {
      output.add(token);
    } else if (token.equals("(")) {
      ops.push(token);
    } else if (token.equals(")")) {
      while (!ops.isEmpty() && !ops.peek().equals("(")) {
        output.add(ops.pop());
      }
      if (ops.isEmpty()) {
        throw new IllegalArgumentException("Mismatched parentheses");
      }
      ops.pop(); // '(' 제거
    } else if (isOperator(token)) {
      while (!ops.isEmpty() && isOperator(ops.peek()) &&
             precedence(ops.peek()) >= precedence(token)) {
        output.add(ops.pop());
      }
      ops.push(token);
    } else {
      throw new IllegalArgumentException("Unknown token: " + token);
    }
  }

  while (!ops.isEmpty()) {
    String top = ops.pop();
    if (top.equals("(") || top.equals(")")) {
      throw new IllegalArgumentException("Mismatched parentheses");
    }
    output.add(top);
  }

  return output;
}

// --- 2. 후위 표기법 계산 ---
double evaluatePostfix(ArrayList<String> tokens) {
  Stack<Double> stack = new Stack<Double>();

  for (String token : tokens) {
    if (isNumber(token)) {
      stack.push(Double.parseDouble(token));
    } else if (isOperator(token)) {
      if (stack.size() < 2) {
        throw new IllegalArgumentException("Invalid postfix expression");
      }
      double b = stack.pop(); // 두 번째 피연산자
      double a = stack.pop(); // 첫 번째 피연산자

      if (token.equals("+")) stack.push(a + b);
      else if (token.equals("-")) stack.push(a - b);
      else if (token.equals("*")) stack.push(a * b);
      else if (token.equals("/")) {
        if (b == 0) return Double.NaN;
        stack.push(a / b);
      }
    }
  }

  if (stack.size() != 1) {
    throw new IllegalArgumentException("Invalid expression");
  }
  return stack.pop();
}

// --- 문자열을 숫자/연산자/괄호 토큰으로 분리 (음수 부호 지원) ---
ArrayList<String> tokenize(String expr) {
  ArrayList<String> tokens = new ArrayList<String>();
  int i = 0;
  int n = expr.length();

  while (i < n) {
    char c = expr.charAt(i);
    if (Character.isWhitespace(c)) {
      i++;
      continue;
    }

    // 음수 판별: 식의 시작이거나, 이전 토큰이 연산자 또는 '(' 인 경우의 '-'
    boolean isNegativeSign = false;
    if (c == '-') {
      if (tokens.isEmpty()) {
        isNegativeSign = true;
      } else {
        String prev = tokens.get(tokens.size() - 1);
        if (isOperator(prev) || prev.equals("(")) {
          isNegativeSign = true;
        }
      }
    }

    if (Character.isDigit(c) || c == '.' || (isNegativeSign && i + 1 < n && (Character.isDigit(expr.charAt(i + 1)) || expr.charAt(i + 1) == '.'))) {
      StringBuilder num = new StringBuilder();
      if (isNegativeSign) {
        num.append('-');
        i++;
      }
      boolean dotSeen = false;
      while (i < n) {
        char ch = expr.charAt(i);
        if (Character.isDigit(ch)) {
          num.append(ch);
          i++;
        } else if (ch == '.' && !dotSeen) {
          dotSeen = true;
          num.append(ch);
          i++;
        } else {
          break;
        }
      }
      tokens.add(num.toString());
    } else if (c == '+' || c == '-' || c == '*' || c == '/' || c == '(' || c == ')') {
      tokens.add(str(c));
      i++;
    } else {
      throw new IllegalArgumentException("Unexpected char: " + c);
    }
  }

  return tokens;
}

boolean isOperator(String s) {
  return s.equals("+") || s.equals("-") || s.equals("*") || s.equals("/");
}

int precedence(String op) {
  if (op.equals("*") || op.equals("/")) return 2;
  if (op.equals("+") || op.equals("-")) return 1;
  return 0;
}

boolean isNumber(String s) {
  try {
    Double.parseDouble(s);
    return true;
  } catch (NumberFormatException e) {
    return false;
  }
}

// --- 버튼 레이아웃 초기화 ---
void initButtons() {
  String[][] layout = {
    {"C", "(", ")", "/"},
    {"7", "8", "9", "*"},
    {"4", "5", "6", "-"},
    {"1", "2", "3", "+"},
    {"0", ".", "DEL", "="}
  };

  float margin = 20;
  float gap = 10;
  float startY = 215;
  int cols = 4;
  int rows = 5;
  float btnW = (width - margin * 2 - gap * (cols - 1)) / cols;
  float btnH = (height - startY - margin - gap * (rows - 1)) / rows;

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      String label = layout[r][c];
      float x = margin + c * (btnW + gap);
      float y = startY + r * (btnH + gap);
      buttons.add(new Button(x, y, btnW, btnH, label));
    }
  }
}

class Button {
  float x, y, w, h;
  String label;

  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }

  boolean isHovered(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }

  void display() {
    boolean hovered = isHovered(mouseX, mouseY);

    if (label.equals("=")) {
      fill(hovered ? color(66, 153, 225) : color(49, 130, 206));
    } else if (label.equals("C") || label.equals("DEL")) {
      fill(hovered ? color(229, 62, 62) : color(197, 48, 48));
    } else if (isOperator(label) || label.equals("(") || label.equals(")")) {
      fill(hovered ? color(74, 85, 104) : color(58, 67, 84));
    } else {
      fill(hovered ? color(63, 71, 86) : color(45, 52, 64));
    }

    noStroke();
    rect(x, y, w, h, 10);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(20);
    text(label, x + w / 2, y + h / 2);
  }
}
