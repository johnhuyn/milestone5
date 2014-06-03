package processing.test.swarch_android_milestone2_tf101;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import android.content.Context; 
import android.hardware.Sensor; 
import android.hardware.SensorEvent; 
import android.hardware.SensorEventListener; 
import android.hardware.SensorManager; 
import oscP5.*; 
import netP5.*; 
import apwidgets.*; 
import android.text.InputType; 
import android.view.inputmethod.EditorInfo; 

import apwidgets.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Swarch_Android_MileStone2_TF101 extends PApplet {

// John Nguyen 
// Thomas Truong
// Anthony So
// ICS 168 Swarch on Android

// accelerometer 
               






//Networking Library



//Import additional processing function into android




APWidgetContainer widgetContainer; 
APEditText nameField, passwordField;

//using PImage to set up login
PImage login;

//Player Information
ArrayList playerInfo;

//global variables
boolean enteringInfo;

//Shape
PShape square;
PShape food;

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
public void setup()
{

  //set resolution and orientation of device
  
  orientation(LANDSCAPE);
  frameRate(60);

  //initalize the container
  widgetContainer = new APWidgetContainer(this); //create new container for widgets

  //create a name textBox
  nameField = new APEditText(displayWidth/2 - 125, displayHeight/2 - 120, 290, 45); //create a textfield from x- and y-pos., width and height
  widgetContainer.addWidget(nameField);
  nameField.setInputType(InputType.TYPE_CLASS_TEXT); //Set the input type to text
  nameField.setImeOptions(EditorInfo.IME_ACTION_NEXT); //Enables a next button, shifts to next field

  //create a password text box
  passwordField = new APEditText(displayWidth/2 - 125, displayHeight/2 - 40, 290, 45); //create a textfield from x- and y-pos., width and height
  widgetContainer.addWidget(passwordField);
  passwordField.setInputType(InputType.TYPE_CLASS_TEXT); //set input type to text
  passwordField.setImeOptions(EditorInfo.IME_ACTION_DONE);
  passwordField.setCloseImeOnDone(true);
  
  //initalize the arraylist to store playerInfo
  playerInfo = new ArrayList();
  
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
  
}

public void draw()
{
  //Load Starting Screen
  if(enteringInfo == true)
  {
    login = loadImage("login.png");
    image(login, 0, 0, displayWidth, displayHeight);
  }
  else
  {
    //after user info is entered
    //draw black background for game
     background(0);
     
     //displays username
     displayUsername(); 
     
     //unit collison.
     unitCollison();
     //Create the Player Cube
    // playerUnit();
     playerOne.run();
     
     //draw till maximum food is reached
     if(maxFood == false)
     {
        generateFood();
     }
     
     //place food around the board
     for(int i = 0; i < 4; ++i)
     {
        shape(myFood[i], xCoord[i], yCoord[i]);
     }
     
     //unit collison.
     unitCollison();
     
     //This is for testing collison and stuff remove
     //after we are finsh testing the game.
    // text(displayWidth , 500, 500);
    // text(displayHeight, 500 , 550);
    // text(x, 500, 600);
     //text(y, 500, 650);
    // text(playerOne.x, 500 , 400);
    // text(playerOne.y, 500 , 450);

  }
}

//When setCloseImeOnDone is finished it will call this which will close down the login screen
public void onClickWidget(APWidget widget)
{
  if(widget == passwordField)
  {
    widgetContainer.removeWidget(nameField);
    widgetContainer.removeWidget(passwordField);
    enteringInfo = false;
  }
}

//display User name  and score in top left and right corners
public void displayUsername()
{
  fill(255);
  textSize(25);
  text("User: " + nameField.getText(), 10, 30);
  text("Score: " + playerOne.size, displayWidth - 200, 30);
}

public void unitCollison()
{
  pOneCenter = (int)(25 + playerOne.size*10)/3; // makes sure the bounds are updated before checking for collision.
  
  for(int i = 0; i < 4; ++i)
  {
    if((playerOne.x  > xCoord[i]/2 - pOneCenter - 2 && playerOne.x < xCoord[i]/2 + pOneCenter + 2) 
        && (playerOne.y  > yCoord[i]/2 - pOneCenter - 2 && playerOne.y  < yCoord[i]/2 + pOneCenter + 2))
    {
       food = createShape(RECT, 0, 0, 10, 10);
       food.setFill(color(255,0,0));
       xCoord[i] = random(15, displayWidth - 70);
       yCoord[i] = random(15, displayHeight - 60);
       myFood[i] = food;
       print("hit! " + " xCoord[i]: " + xCoord[i] + " yCoord[i]: "+ yCoord[i]);
       
       playerOne.size = playerOne.size + 1;


    }
  }
}


//Creates the food pellets for the players to eat
public void generateFood()
{
  for(int i = 0; i < 4; ++i)
  {
   food = createShape(RECT, 0, 0, 10, 10);
   food.setFill(color(255,0,0));
   xCoord[i] = random(15, displayWidth - 70);
   yCoord[i] = random(15, displayHeight - 60);
   myFood[i] = food;
   numFood++;
   print("i: " + i + " xCoord[i]: " + xCoord[i] + " yCoord[i]: "+ yCoord[i] + "\n");
   if (numFood == 4)
   {
     maxFood = true;
   }
  }
}


   SensorManager sensorManager;       // keep track of sensor
  SensorListener sensorListener;     // special class for noting sensor changes
  Sensor accelerometer;              // Sensor object for accelerometer
  float[] accelData;                 // x,y,z sensor data
  //1196
  //768
public class Player
{
  
  float x, y, xVelo, yVelo, size;
   
  public Player()
  {
      y = displayWidth/2;
      x = displayHeight/2;
      xVelo = 0;
      yVelo = 0;
      size = 0;
  }
  
  public void move()
  {
    if(accelData != null)
    {
      xVelo = accelData[0];
      yVelo = accelData[1];
    }
    
      if(abs(xVelo) > abs(yVelo))
      {
        if(size > 0)
        {
          if(xVelo < 1)
             x -= 1 * (1 - size/20);                                                                                                                                                                                             
          else
             x += 1 * (1 - size/20);
        }
        else
        {
          if(xVelo < 1)
             x -= 1;
          else
             x += 1;
        }
      }
      else
       {
         if(size > 0)
         {
           if(yVelo < 1)
            y += 1 * (size/10);
            else
            y -=1 * (size/10);
         }
         else
         {
           if(yVelo < 1)
            y += 1;
            else
            y -=1;
         }
           
       }
  }
  
  public void display()
  {
    square = createShape(RECT, x, y, 25 + size*10, 25 + size*10);
    square.setFill(color(255,255,0));
    shapeMode(CENTER);
    shape(square, x, y);
  }
  
//    For Testing purposes:
//       player is able to move to edge; landing on the other side of the screen
//     -** Need to change later so that player dies; when hits edge.
   public void edges()
   {
    if (x - (10) > displayHeight - 140) 
    {
        x = 70;
        size = 0;
    }
    else if (x - 10 < 0)
    {
          x = displayHeight - 140;
          size = 0;
    }
    else if (y + (10)> displayWidth/3 - 60)
    {
        y = 60;
        size = 0;
    }
    else if (y - 10 < 0)
    {
        y = displayWidth/3 - 60;
        size = 0;
    }
  }
  
  public void run()
  {
    edges();
    move();
    display();
  }
}

  public void onResume()
  {
    super.onResume();
    sensorManager = (SensorManager)getSystemService(Context.SENSOR_SERVICE);
    sensorListener = new SensorListener();
    accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
    sensorManager.registerListener(sensorListener, accelerometer, SensorManager.SENSOR_DELAY_GAME);  // see top comments for speed options
  }
  
  public void onPause() 
  {
    sensorManager.unregisterListener(sensorListener);
    super.onPause();
  }

class SensorListener implements SensorEventListener 
{
  
  public void onSensorChanged(SensorEvent event) 
  {
    if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) 
    {
      accelData = event.values;
    }
  }
  
  public void onAccuracyChanged(Sensor sensor, int accuracy) 
  {
    // nothing here, but this method is required for the code to work...
  }
  
}


  public int sketchWidth() { return displayWidth; }
  public int sketchHeight() { return displayHeight; }
  public String sketchRenderer() { return P2D; }
}
