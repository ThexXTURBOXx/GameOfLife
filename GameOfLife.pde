public static final int SCALE = 4;
public static final int SIZE_X = 200;
public static final int SIZE_Y = 200;

int[] field;
boolean playing = false;
boolean step = false;
boolean stop = false;

void settings() {
  size(SIZE_X * SCALE, SIZE_Y * SCALE);
}

void setup() {
  field = new int[ceil((SIZE_X * SIZE_Y) / 32f)];
}

void draw() {
  if (!stop && (playing || step)) {
    step = false;
    nextGeneration();
  }
  background(255);
  for (int x = 0; x < SIZE_X; x++) {
    for (int y = 0; y < SIZE_Y; y++) {
      int index = getIndex(x, y);
      int col = getColor(getCell(index));
      noStroke();
      fill(col);
      rect(x * SCALE, y * SCALE, SCALE, SCALE);
    }
  }
}

public void nextGeneration() {
  int[] newField = new int[ceil((SIZE_X * SIZE_Y) / 32f)];
  for (int x = 0; x < SIZE_X; x++) {
    for (int y = 0; y < SIZE_Y; y++) {
      int index = getIndex(x, y);
      int living = getLivingNeighbours(x, y);
      if (getCell(index)) {
        //Alive
        if (living < 2 || living > 3) {
          //Over-/Underpopulation
          removeCell(newField, index);
        } else {
          //Staying alive
          setCell(newField, index);
        }
      } else {
        //Dead
        if (living == 3) {
          //Reincarnate
          setCell(newField, index);
        }
      }
    }
  }
  field = newField;
}

private void setCell(int index) {
  setCell(field, index);
}

private void setCell(int[] arr, int index) {
  arr[index / 32] |= 1 << (index % 32);
}

private void removeCell(int index) {
  removeCell(field, index);
}

private void removeCell(int[] arr, int index) {
  arr[index / 32] &= ~(1 << (index % 32));
}

private boolean getCell(int index) {
  return getCell(field, index);
}

private boolean getCell(int[] arr, int index) {
  return ((arr[index / 32] >> (index % 32)) & 1) != 0;
}

private int getIndex(int x, int y) {
    return x + y * SIZE_X;
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
  if (mouseButton == 37) {
    setCell(index);
  } else {
    removeCell(index);
  }
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
        if (getCell(index))
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
      int[] newField = new int[ceil((dimX * dimY) / 32f)];
      String line = null;
      while ((line = input.readLine()) != null) {
        setCell(newField, Integer.parseInt(line));
      }
      field = newField;
    } catch (IOException e) {
      e.printStackTrace();
    }
    stop = false;
  }
}

int getLivingNeighbours(int x, int y) {
  int living = 0;
  for (int xOff = -1; xOff <= 1; xOff++) {
    for (int yOff = -1; yOff <= 1; yOff++) {
      if ((xOff == 0 && yOff == 0)
        || x + xOff < 0 || x + xOff >= SIZE_X
        || y + yOff < 0 || y + yOff >= SIZE_Y)
        continue;
      int index = getIndex(x + xOff, y + yOff);
      if (getCell(index)) {
        living++;
      }
    }
  }
  return living;
}
