// John Nguyen 
// Thomas Truong
// Anthony So
// ICS 168 Swarch on Android

//MD5 encryption
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Formatter;

// accelerometer 
import android.content.Context;               
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

//key event
import android.view.InputEvent;
import android.view.KeyEvent;

//Networking Library
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myBroadcastLocation; 

//Import additional processing function into android
import apwidgets.*;
import android.text.InputType;
import android.view.inputmethod.EditorInfo;

APWidgetContainer widgetContainer; 
APEditText nameField, passwordField;

//using PImage to set up login
PImage login;

//Player Information
String userName;
String passWord;
String failPass;

//global variables
boolean enteringInfo;

//Shape
PShape square;
PShape food;
PShape player2;

//movement
float x, y;

//Variable for food
int numFood;
boolean maxFood;
PShape[] myFood; 
float[] xCoord;
float[] yCoord;
Player playerOne;
int pOneCenter;
int playerNumber;
int numOfPlayers;
//multithread
ThreadThing tt;

//player
boolean maxPlayer;
PShape player1;
int playerNum;
int playSize;
PShape[] myPlayer;

float[] rgb;
int p1score;
int p2score;
void setup()
{

  //set resolution and orientation of device
  size(displayWidth, displayHeight, P2D); 
  orientation(LANDSCAPE);
  frameRate(60);

  //initalize the container
  widgetContainer = new APWidgetContainer(this); //create new container for widgets

    //create a name textBox
  nameField = new APEditText(displayWidth/2 - 190, displayHeight/2 - 185, 450, 85); //create a textfield from x- and y-pos., width and height
  widgetContainer.addWidget(nameField);
  nameField.setInputType(InputType.TYPE_CLASS_TEXT); //Set the input type to text
  nameField.setImeOptions(EditorInfo.IME_ACTION_NEXT); //Enables a next button, shifts to next field

  //create a password text box
  passwordField = new APEditText(displayWidth/2 - 190, displayHeight/2 - 65, 450, 85); //create a textfield from x- and y-pos., width and height
  widgetContainer.addWidget(passwordField);
  passwordField.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD); //set input type to text
  passwordField.setImeOptions(EditorInfo.IME_ACTION_DONE);
  passwordField.setCloseImeOnDone(true);


  //initalize array to hold Shapes and their x, y coord
  myFood = new PShape[4];  
  xCoord = new float[4];
  yCoord = new float[4];

  //initalize maxFood
  maxFood = false;

  //initalize enteringInfo
  enteringInfo = true;

  //start a player at a random location
  x = random(15, displayWidth - 70);
  y = random(15, displayHeight - 60);

  playerOne = new Player();
  pOneCenter = (int)(25 + playerOne.size*10)/3;

  //Initialize network settings

  //listens for incoming messages
  oscP5 = new OscP5(this, "169.234.109.240", 32000, OscP5.TCP);
  //Connect to Server on start up
  OscMessage m3;
  m3 = new OscMessage("Connecting...", new Object[0]);
  oscP5.send(m3);// myBroadcastLocation);

  //Initalize Playerinfo
  userName = "";
  passWord = "";
  failPass = "";

  //init threading
  tt = new ThreadThing(this);

  //player
  maxPlayer = false;
  playerNum = 0;
  myPlayer = new PShape[2];
  playSize = 0;
  p1score = 0;
  p2score = 0;

  rgb = new float[6];
}

void draw()
{
  //Load Starting Screen
  if (enteringInfo == true)
  {
    login = loadImage("login.png");
    image(login, 0, 0, displayWidth, displayHeight);

    //display failed attempt at login
    fill(255);
    textSize(25);
    text(failPass, 10, 30);
  }
  else
  {
    if (p1score > p2score + 7|| p1score == 15)
    {
      login = loadImage("victory.jpg");
      image(login, 0, 0, displayWidth, displayHeight);
      textSize(45);
      text("Player 1 WInS", displayWidth/2, displayHeight/2 - 100);
    }
    else if(p2score > p1score +7 || p2score == 15)
    {
      login = loadImage("victory.jpg");
      image(login, 0, 0, displayWidth, displayHeight);
      textSize(25);
      text("Player 2 WInS", displayWidth/2, displayHeight/2 - 100);
    }
    else
    {
      background(0);
      //after user info is entered
      //draw black background for game


      //displays username
      displayUsername(); 

      //Create the Player Cube
      playerOne.run();

      if (!maxFood)
      {
        generateFood();
      }
      //place food around the board
      for (int i = 0; i < 4; ++i)
      {
        shape(myFood[i], xCoord[i], yCoord[i]);
      }

      generatePlayer();

      for (int i = 0; i < numOfPlayers; ++i)
      {
        shape(myPlayer[i], xCube[i], yCube[i]);
      }
    }
  }
}

//When setCloseImeOnDone is finished it will call this which will close down the login screen
void onClickWidget(APWidget widget)
{
  if (widget == passwordField)
  { 
    widgetContainer.removeWidget(nameField);
    widgetContainer.removeWidget(passwordField);
    //start a new thread to handle username being sent to server
    //while android handles the key press event
    tt.start();
  }
}

//display User name  and score in top left and right corners
void displayUsername()
{
  fill(255);
  textSize(25);
  text("User: " + nameField.getText(), 10, 30);
  text("Player 1 Score: " + p1score, displayWidth - 300, 30);
  if (numOfPlayers > 1)
  {
    text("Player 2 Score: " + p2score, displayWidth - 300, 70);
  }
}

//Creates the food pellets for the players to eat
void generateFood()
{
  for (int i = 0; i < 4; ++i)
  {
    food = createShape(RECT, 0, 0, 35, 35);
    food.setFill(color(255, 255, 0));
    myFood[i] = food;
    numFood++;

    if (numFood == 4)
    {
      maxFood = true;
    }
  }
}

void generatePlayer()
{
  for (int i = 0; i < 2; ++i)
  {

    player1 = createShape(RECT, 0, 0, 50 + p1score * 10, 50 + p1score * 10);
    player1.setFill(color(rgb[0], rgb[1], rgb[2]));
    player2 = createShape(RECT, 0, 0, 50 + p2score * 10, 50 + p2score * 10);
    player2.setFill(color(rgb[3], rgb[4], rgb[5]));
    shapeMode(CENTER);
    myPlayer[0] = player1;
    myPlayer[1] = player2;
    if (i == 2)
    {
      maxPlayer = true;
    }
  }
}

//listens for incoming messages from the server
void oscEvent(OscMessage theOscMessage) 
{
  /* get and print the address pattern and the typetag of the received OscMessage */
  //println("### received an osc message with addrpattern "+theOscMessage.addrPattern());

  if (theOscMessage.addrPattern().equals("Authenticated"))
  { 
    playerNumber = theOscMessage.get(8).intValue();

    for (int i = 0; i < 4; ++i)
    {
      xCoord[i] = theOscMessage.get(i).floatValue();
      yCoord[i] = theOscMessage.get(4+i).floatValue();
    }

    if (theOscMessage.get(8).intValue() == 1)
    {
      xCube[0] = theOscMessage.get(9).floatValue();
      yCube[0] = theOscMessage.get(10).floatValue();
      rgb[0] = theOscMessage.get(11).floatValue();
      rgb[1] = theOscMessage.get(12).floatValue();
      rgb[2] = theOscMessage.get(13).floatValue();
      rgb[3] = theOscMessage.get(14).floatValue();
      rgb[4] = theOscMessage.get(15).floatValue();
      rgb[5] = theOscMessage.get(16).floatValue();
    }
    else
    {
      xCube[0] = theOscMessage.get(9).floatValue();
      yCube[0] = theOscMessage.get(11).floatValue();
      xCube[1] = theOscMessage.get(10).floatValue();
      yCube[1] = theOscMessage.get(12).floatValue();

      rgb[0] = theOscMessage.get(13).floatValue();
      rgb[1] = theOscMessage.get(14).floatValue();
      rgb[2] = theOscMessage.get(15).floatValue();

      rgb[3] = theOscMessage.get(16).floatValue();
      rgb[4] = theOscMessage.get(17).floatValue();
      rgb[5] = theOscMessage.get(18).floatValue();
    }

    println("sW:" + displayWidth);
    println("sH:" + displayHeight);
    enteringInfo = false;
  }
  else if (theOscMessage.addrPattern().equals("Food respawn"))
  {
    int element = theOscMessage.get(0).intValue();
    xCoord[element] = theOscMessage.get(1).floatValue();
    yCoord[element] = theOscMessage.get(2).floatValue();
    shape(myFood[element], xCoord[element], yCoord[element]);
    if (theOscMessage.get(3).intValue()+1 == 2)
    {  
      p2score += 1;
    }
    else if (theOscMessage.get(3).intValue()+1 == 1)
    {
      p1score += 1;
    }
  }
  else if (theOscMessage.addrPattern().equals("Incorrect Password"))
  {
    failPass = "Incorrect Password";
    enteringInfo = true;
    widgetContainer.addWidget(nameField);
    widgetContainer.addWidget(passwordField);
  }
  else if (theOscMessage.addrPattern().equals("Moveshit"))
  {
    numOfPlayers = theOscMessage.get(0).intValue();

    if ( numOfPlayers == 1)
    {
      xCube[0] = theOscMessage.get(1).floatValue();
      yCube[0] = theOscMessage.get(2).floatValue();
    }
    else
    {
      xCube[0] = theOscMessage.get(1).floatValue();
      xCube[1] = theOscMessage.get(2).floatValue();
      yCube[0] = theOscMessage.get(3).floatValue();
      yCube[1] = theOscMessage.get(4).floatValue();
    }
  }
  else if (theOscMessage.addrPattern().equals("Edge Collison"))
  {
    if (theOscMessage.get(2).intValue()+1 == 2)
    { 
      xCube[theOscMessage.get(2).intValue()] = theOscMessage.get(0).floatValue();
      yCube[theOscMessage.get(2).intValue()] = theOscMessage.get(1).floatValue();
      p2score = 0;
    }
    else if (theOscMessage.get(2).intValue()+1 == 1)
    {
      xCube[theOscMessage.get(2).intValue()] = theOscMessage.get(0).floatValue();
      yCube[theOscMessage.get(2).intValue()] = theOscMessage.get(1).floatValue();
      p1score = 0;
    }
  }
  else if (theOscMessage.addrPattern().equals("Player Collison"))
  {
    if (theOscMessage.get(2).intValue()+1 == playerNumber)
    { 
      xCube[theOscMessage.get(2).intValue()] = theOscMessage.get(0).floatValue();
      yCube[theOscMessage.get(2).intValue()] = theOscMessage.get(1).floatValue();
      playerOne.size += 10;
    }
  }
}

