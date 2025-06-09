//sounds zombie https://www.sounds-resource.com/mobile/plantsvszombies2/sound/47238/
//sounds katze https://www.sounds-resource.com/3ds/nintendogscats/sound/7473/
//sprite cat https://www.spriters-resource.com/pc_computer/stardewvalley/sheet/124813/
//sprite wool https://t4.ftcdn.net/jpg/07/46/33/85/360_F_746338585_sExSTcga7vI4pvVNoCkjBU6I3tH2d0Mj.jpg
//sprite zombie: drawn by me
//hintergrundsounds https://orangefreesounds.com/

import netP5.*;
import oscP5.*;

OscP5 osc;
NetAddress meineAdresse;

OscMessage catMessage = new OscMessage("hitCat");
OscMessage zombMessage = new OscMessage("hitZomb");
OscMessage shotMessage = new OscMessage("shot");
OscMessage ambientMessage = new OscMessage("background");

PImage bg; //background 
PImage end; //end screen 
PImage catFront; 
PImage wool;

float gunX = 350;  //Gun/Player Position
float gunY = 100;
float bulletY = 110;  // bullet Position
float bulletX = 355;     

float zomX = 350;   // zombie Position
float zomY = 950;

boolean moveUp = true;  // zombie starts moving up
boolean moveDown = false;  // bullet starts off not moving (moves when true)
boolean showCatFront = true;  //shows default cat, when  player is not moving to left or right
boolean ambientOn = true;  // background-music on

int countZ = 0;  //score for zombies
int countY = 0;  //score for player

PFont font1;  
PFont font2;

int state = 1;  //state for died screen

//Animation
PImage[] catRight;  //cat walks to right side
PImage[] catLeft;    //cat walks to left side
int numOfFrames;
int f; //Frames for cat
int t; //Frames for zombies 
PImage[] zombie;

void setup() {
  
  size(700, 950);  
  background(255);
  font1 = loadFont("GillSansMT-ExtraCondensedBold-70.vlw");
  font2 = loadFont("GillSansMT-ExtraCondensedBold-46.vlw");
  bg = loadImage("back.jpg");
  end = loadImage("cat.jpg");
  
  //Animation
  numOfFrames = 2;   
  catRight = new PImage[numOfFrames];
  catLeft = new PImage[numOfFrames];
  zombie = new PImage[numOfFrames];
                                          
  for(int i = 0; i < numOfFrames ; i++) {
    catRight[i] = loadImage("right_" + i + ".png");
  }
  
  for(int i = 0; i < numOfFrames ; i++) {
    catLeft[i] = loadImage("left_" + i + ".png");
  }
  
  for(int i = 0; i < numOfFrames ; i++) {
    zombie[i] = loadImage("zombie_" + i + ".png");
  } 
  
  osc = new OscP5(this, 12000);
  meineAdresse = new NetAddress("192.168.1.14", 12345);
  
  if (ambientOn == true) {
    osc.send(ambientMessage, meineAdresse);
  }
}

void draw() {
  
  background(bg); 
  textFont(font2);
  fill(205, 12, 0);
  text("Walk with arrow key & shoot with space. Kill all zombies!!", 39, 50);
  
  textFont(font1);
  //Zombie aimation, every eigth frame the picture changes and the zombie walks
  image(zombie[t], zomX, zomY, 90, 90);
    if (frameCount % 8 == 0) {
      t++;
    }
    if (t == numOfFrames) { //starts again with first picture
      t = 0;
    }
  fill(205, 12, 0);
  text("Zombies", 50, 890);
  text(countZ, 290, 890);  //score zombies
  
  //player
  fill(0);
  if (showCatFront == true) {
    catFront = loadImage("catFront.png");
    image(catFront, gunX + 50, gunY + 20, 60, 80);
  }
  text("You", 490, 890);
  text(countY, 600, 890);  //score you
  
  //place and picture of the bullet
  bulletX = gunX + 5;
  wool = loadImage("wool.png");
  image(wool, bulletX + 50, bulletY, 50, 50);  //cat carries wool on head
  
  //walk left + animation
  if (keyPressed == true && key == CODED && keyCode == LEFT) {
    gunX = gunX - 9; 
    image(catLeft[f], gunX + 50, gunY + 30, 90, 70);
    if (frameCount % 8 == 0) f++;
    if (f == numOfFrames) f = 0;
    showCatFront = false;
    
  }
  
  //walk right + animation
  if (keyPressed == true && key == CODED && keyCode == RIGHT) {
    gunX = gunX + 6;
    image(catRight[f], gunX + 50, gunY + 30, 90, 70);
    if (frameCount % 8 == 0) f++;
    if (f == numOfFrames) f = 0;
    showCatFront = false;
  }
  
  //border
  if (gunX > 600) {
    gunX = 600;
  }
  
  if (gunX < -20) {
    gunX = -20;
  }
  
  if (moveUp == true) {
    zomY = zomY - 6;
  }
  
  if (zomY <= 950) {
    moveUp = true;
  }
  //if zombie is leaving the screen, a new one appears
  if (zomY < 0) {
    zomY = 950;
    zomX = random(30, 350);
    moveUp = true;
    countZ++;
  }
  
  // bullet shoots with space
  if (keyPressed && key == ' ') {
    moveDown = true;
    osc.send(shotMessage, meineAdresse);
  }
  
  if (moveDown == true) {  // bullet moves down
    bulletY = bulletY + 10;
  }
  
  if (bulletY > 950) {   // resets bullet
    bulletY = 110;
    moveDown = false;
  }
 //if zombie is hit -> new one spawns 
  if (bulletY < zomY + 50 && bulletY > zomY - 50 && bulletX < zomX + 50 && bulletX > zomX - 50) {
    zomY = 950; 
    zomX = random(30, 650);
    moveUp = true;
    countY++;
    osc.send(zombMessage, meineAdresse);
  }
 
  //if two zombies are not shot by the cat -> end screen
  if (countZ == 2) {
    state = 2;
    ambientOn = false;
  }
  //game ends when cat is hit
  if (state == 2) {
    background(end);
    fill(205, 12, 0);
    text("Your Score: " + countY, 240, 350);
  }
  
  //if zombies hit cat -> end screen
  if (zomX > gunX && zomX < gunX + 100 && zomY > gunY && zomY < gunY + 100) {
    state = 2;
    osc.send(catMessage, meineAdresse);
    ambientOn = false;
  }
}

void keyReleased() {
  showCatFront = true;
}
