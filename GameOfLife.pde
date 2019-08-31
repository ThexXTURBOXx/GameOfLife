public static final int SCALE = 4;
public static final int SIZE_X = 200;
public static final int SIZE_Y = 200;

boolean[] field;
boolean playing = false;
boolean step = false;
boolean stop = false;

void settings() {
  size(SIZE_X * SCALE, SIZE_Y * SCALE);
}

void setup() {
  field = new boolean[SIZE_X * SIZE_Y];
}

void draw() {
  if (!stop && (playing || step)) {
    step = false;
    nextGeneration();
  }
  background(255);
  for (int x = 0; x < SIZE_X; x++) {
    for (int y = 0; y < SIZE_Y; y++) {
      int col = getColor(field[getIndex(x, y)]);
      noStroke();
      fill(col);
      rect(x * SCALE, y * SCALE, SCALE, SCALE);
    }
  }
}

public void nextGeneration() {
  boolean[] newField = new boolean[SIZE_X * SIZE_Y];
  for (int x = 0; x < SIZE_X; x++) {
    for (int y = 0; y < SIZE_Y; y++) {
      int index = getIndex(x, y);
      int living = getLivingNeighbours(x, y);
      boolean newState = false;
      if (field[index]) {
        //Alive
        if (living < 2 || living > 3) {
          //Staying alive
          newState = false;
        } else {
        //Over-/Underpopulation
        newState = true;
        }
      } else {
        //Dead
        if (living == 3) {
          //Reincarnate
          newState = true;
        }
      }
      newField[index] = newState;
    }
  }
  field = newField;
}

private int getColor(boolean alive) {
  if (alive)
    return 0;
  else
    return 255;
}

void mouseDragged() {
  onMouseEvent();
}

void mousePressed() {
  onMouseEvent();
}

void onMouseEvent() {
  if (mouseX < 0 || mouseX >= width || mouseY < 0 || mouseY >= height)
    return;
  int index = getIndex(mouseX / SCALE, mouseY / SCALE);
  field[index] = mouseButton == 37;
}

void keyPressed() {
  if (keyCode == 32) {
    playing = !playing;
  } else if (keyCode == 39) {
    step = true;
  } else if (keyCode == 83) {
    //Save
    stop = true;
    PrintWriter output = createWriter("state.gol");
    output.println(SIZE_X + "," + SIZE_Y);
    for (int x = 0; x < SIZE_X; x++) {
      for (int y = 0; y < SIZE_Y; y++) {
        int index = getIndex(x, y);
        if (field[index])
          output.println(index);
      }
    }
    output.flush();
    output.close();
    stop = false;
  } else if (keyCode == 79) {
    //Load
    stop = true;
    BufferedReader input = createReader("state.gol");
    try {
      String[] dims = input.readLine().split(",");
      int dimX = Integer.parseInt(dims[0]);
      int dimY = Integer.parseInt(dims[1]);
      if (dimX != SIZE_X || dimY != SIZE_Y) {
        println("Expected dimensions " + dimX + "x" + dimY + ", got " + SIZE_X + "x" + SIZE_Y + ". Aborting load...");
        return;
      }
      boolean[] newField = new boolean[dimX * dimY];
      String line = null;
      while ((line = input.readLine()) != null) {
        newField[Integer.parseInt(line)] = true;
      }
      field = newField;
    } catch (IOException e) {
      e.printStackTrace();
    }
    stop = false;
  }
}

int getIndex(int x, int y) {
  return x + y * SIZE_X;
}

int getLivingNeighbours(int x, int y) {
  int sum = 0;
  for (int xOff = -1; xOff <= 1; xOff++) {
    for (int yOff = -1; yOff <= 1; yOff++) {
      if ((xOff == 0 && yOff == 0)
       || x + xOff < 0 || x + xOff >= SIZE_X
       || y + yOff < 0 || y + yOff >= SIZE_Y)
       continue;
      if (field[getIndex(x + xOff, y + yOff)]) {
        sum++;
      }
    }
  }
  return sum;
}
