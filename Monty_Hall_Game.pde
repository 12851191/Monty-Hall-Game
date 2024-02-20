import java.util.Random;
import java.util.ArrayList;

PImage door;
PImage trash;
PImage treasure;
float doorwidth, doorheight, doorx1, doorx2, doorx3, doory;
Random rand;
Door Door1;
Door Door2;
Door Door3;
Door initialdoor;
Door treasuredoor;
boolean overrect = false;
boolean winner;
String state;
float stay_total = 1;
float switch_total = 1;
boolean firstplaystay = true;
boolean firstplayswitch = true;
ArrayList<Door> doors = new ArrayList<Door>();
int [][] stats = { {0, 0}, {0, 0} };

void setup() {
  size(1920, 970);
  surface.setLocation(0,0);
  surface.setResizable(true);
  background(225, 225, 225);
  door = loadImage("Door.png");
  trash = loadImage("Garbage.jpg");
  treasure = loadImage("Treasure.jpg");
  doorwidth = door.width*1.3;
  doorheight = door.height*1.3;
  doory = height/2-doorheight/2;
  doorx1 = width/4-doorwidth/2;
  doorx2 = width/2-doorwidth/2;
  doorx3 = width*3/4-doorwidth/2;
  rand = new Random();
  Door1 = new Door(door, doorx1, doory, doorwidth, doorheight);
  Door2 = new Door(door, doorx2, doory, doorwidth, doorheight);
  Door3 = new Door(door, doorx3, doory, doorwidth, doorheight);
  doors.add(Door1);
  doors.add(Door2);
  doors.add(Door3);
  state = "first press";
  treasuredoor = doors.get(rand.nextInt(3));
}

void draw() {
  background(255, 255, 255);
  Score();
  Cursor();
  Door1.init();
  Door2.init();
  Door3.init();
  
  if (Door1.active) {
    Door1.OverDoor();
  }
  if (Door2.active) {
    Door2.OverDoor();
  }
  if (Door3.active) {
    Door3.OverDoor();
  }
  
  if (state == "second press") {
    textSize(40);
    textAlign(CENTER);
    fill(0, 0, 0);
    text("Stay", initialdoor.x+initialdoor.width/2, initialdoor.y+initialdoor.height/2+20);
    doors.remove(initialdoor);
    Door finaldoor = doors.get(0);
    text("Switch", finaldoor.x+finaldoor.width/2, finaldoor.y+finaldoor.height/2+20);
    doors.add(initialdoor);
  }

  if (winner && state == "end screen") {
    textSize(250);
    textAlign(CENTER);
    fill(0, 0, 0);
    text("YOU WIN!", width/2, height/3); 
  }
  else if (!winner && state == "end screen") {
    textSize(250);
    textAlign(CENTER);
    fill(0, 0, 0);
    text("YOU LOSE!", width/2, height/3);
  }
  
  if (state == "end screen") {
    fill(255,128,43);
    float rect_x = width/2-200;
    float rect_y = height/1.25;
    float rect_width = 400;
    float rect_height = 100;
    rect(width/2-200, height/1.25, 400, 100);
    textSize(85);
    fill(255, 255, 255);
    text("Replay", width/2, height/1.25+75);
    if (mouseX>=rect_x && mouseX<=rect_x+rect_width && mouseY>=rect_y && mouseY<= rect_y+rect_height) {
      overrect = true;
    }
    else {
      overrect = false;
    }
    if (overrect && mousePressed) {
      doors.clear();
      Door1 = new Door(door, doorx1, doory, doorwidth, doorheight);
      Door2 = new Door(door, doorx2, doory, doorwidth, doorheight);
      Door3 = new Door(door, doorx3, doory, doorwidth, doorheight);
      doors.add(Door1);
      doors.add(Door2);
      doors.add(Door3);
      treasuredoor = doors.get(rand.nextInt(3));
      if (stats[0][0] > 0 || stats[0][1] > 0) {
        firstplaystay = false;
      }
      if (stats[1][0] > 0 || stats[1][1] > 0) {
        firstplayswitch = false;
      }
      state = "first press";
    }
  }
}

class Door {
  PImage img;
  float x;
  float y;
  float width;
  float height;
  boolean overdoor;
  boolean active;
  
  Door(PImage img, float x, float y, float width, float height) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    overdoor = false;
    active = true;
  }
  
  void init() {
      image(img, x, y, width, height);
  }
  
  void replace(PImage image) {
    this.img = image;
  }
  
  void OverDoor() {
    if (mouseX>=x && mouseX<=x+width && mouseY>=y && mouseY<= y+height) {
      overdoor = true;
    }
    else {
      overdoor = false;
    }
  }
}

void mousePressed() {
  if (Door1.overdoor || Door2.overdoor || Door3.overdoor) {
    if (state == "first press") {
      Door clickeddoor = getClickedDoor();
      doors.remove(treasuredoor);
      try {
        doors.remove(clickeddoor);
      }
      catch (Exception e) {
        ;
      }
    
      if (doors.size() == 1) {
        doors.get(0).active = false;
        doors.get(0).replace(trash);
        doors.remove(0);
        doors.add(treasuredoor);
        doors.add(clickeddoor);
      }
      else {
        int rand_int = rand.nextInt(2);
        doors.get(rand_int).active = false;
        doors.get(rand_int).replace(trash);
        doors.remove(rand_int);
        doors.add(treasuredoor);
      }
      
      initialdoor = clickeddoor;
      state = "second press";
  }
    else if (state == "second press") {
      Door clickeddoor = getClickedDoor();
      treasuredoor.replace(treasure);
      treasuredoor.active = false;
      String method;
      
      if (clickeddoor == initialdoor) {
        method = "stay";
        if (!firstplaystay) {
          stay_total++; 
        }
      }
      else {
        method = "switch";
        if (!firstplayswitch) {
          switch_total++;
        }
      }
      
      if (clickeddoor == treasuredoor) {
        doors.remove(treasuredoor);
        doors.get(0).active = false; 
        doors.get(0).replace(trash);
        winner = true;
        if (method == "stay") {
          stats[0][0]++;
        }
        else if (method == "switch") {
          stats[1][0]++;
        }
      }
      else {
        clickeddoor.active= false;
        clickeddoor.replace(trash);
        winner = false;
        if (method == "stay") {
          stats[0][1]++;
        }
        else if (method == "switch") {
          stats[1][1]++;
        }
      }
      state = "end screen";
    }
  }
}


Door getClickedDoor() {
  if (Door1.overdoor) {
    return Door1;
  }
  else if (Door2.overdoor) {
    return Door2;
  }
  else if (Door3.overdoor) {
    return Door3;
  }
  else {
    return null;
  }
}

void Cursor() {
  if (Door1.active || Door2.active || Door3.active) {
    if (Door1.overdoor || Door2.overdoor || Door3.overdoor) {
      cursor(HAND);
    }
    else {
      cursor(ARROW);
    }
  }
  else if (overrect) {
    cursor(HAND);
  }
  else {
    cursor(ARROW);
  } 
}

void Score () {
  fill(0, 0, 0);
  textSize(30);
  textAlign(LEFT);
  text("Wins", width/1.17, height/13);
  text("Losess", width/1.1, height/13);
  textAlign(RIGHT);
  text("Stay", width/1.2, height/8.5);
  text("Switch", width/1.2, height/6);
  textAlign(CENTER);
  float percent1 = stats[0][0]/stay_total*100;
  float percent2 = stats[0][1]/stay_total*100;
  float percent3 = stats[1][0]/switch_total*100;
  float percent4 = stats[1][1]/switch_total*100;
  text(stats[0][0] + " (" + Math.round(percent1) + "%)", width/1.15, height/8.5);
  text(stats[0][1] + " (" + Math.round(percent2) + "%)", width/1.075, height/8.5);
  text(stats[1][0] + " (" + Math.round(percent3) + "%)", width/1.15, height/6);
  text(stats[1][1] + " (" + Math.round(percent4) + "%)", width/1.075, height/6);
}
