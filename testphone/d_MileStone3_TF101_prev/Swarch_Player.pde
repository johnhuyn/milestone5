
SensorManager sensorManager;       // keep track of sensor
SensorListener sensorListener;     // special class for noting sensor changes
Sensor accelerometer;              // Sensor object for accelerometer
float[] accelData;                 // x,y,z sensor data
float[] xCube;
float[] yCube;



int dir;
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
    xCube = new float[2];
    yCube = new float[2];
  }
  
  int direction()
  { 
    return dir;
  }
  float getX()
  {
    return x;
  }
  float getY()
  {
    return y;
  }
  
  void setX(float xpos)
  {
    //x = xpos;
  }
  
  void setY(float ypos)
  {
    //y = ypos;
  }

  void move()
  {  
    if(accelData != null)
    {
      xVelo = accelData[1];
      yVelo = accelData[0];
    }
    for(int i = 0; i < xCube.length; i++)
    {
       if(abs(xVelo) > abs(yVelo))
       {
         if(size > 0)
         {
           if(xVelo < 1)
           {
             dir = 1; //moving left
           }
           else
           {
             dir = -1; //moving right
           }
         }
         else
         {
           if(xVelo < 1)
           {
           dir = 1; // moving left
            // println("moving left");
           }
           else
           {
             dir = -1; // moving right
            // println("moving right");
           }
         }
       }
       else
       {
         if(size > 0)
         {
           if(yVelo < 1)
           {
             dir = -2;//moving up
           }
           else
           {
             dir = 2;//moving down
           }
         }
         else
         {
           if(yVelo < 1)
           {
             dir = -2;//moving up
             //println("moving up");
           }
           else
           {
             dir = 2;//moving down
             //println("moving down");
           }
         }
       }
    }//end for   
  }


  void display()
  {
    //for(int i = 0; i < numOfPlayers; i++)
    //{
    //  square = createShape(RECT, 25, 25, 25 + size*10, 25 + size*10);
    //  square.setFill(color(255, 255, 0));
      //shapeMode(CENTER);
    //  shape(square, xCube[i], yCube[i]);
    //}
      OscMessage m = new OscMessage("Direction shit");
      m.add(playerNumber);
      m.add(dir);
      oscP5.send(m);
  }

 
  void run()
  {
    move();
    display();
  }
}

void onResume()
{
  super.onResume();
  sensorManager = (SensorManager)getSystemService(Context.SENSOR_SERVICE);
  sensorListener = new SensorListener();
  accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
  sensorManager.registerListener(sensorListener, accelerometer, SensorManager.SENSOR_DELAY_GAME);  // see top comments for speed options
}

void onPause() 
{
  sensorManager.unregisterListener(sensorListener);
  super.onPause();
}

class SensorListener implements SensorEventListener 
{

  void onSensorChanged(SensorEvent event) 
  {
    if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) 
    {
      accelData = event.values;
    }
  }

  void onAccuracyChanged(Sensor sensor, int accuracy) 
  {
    // nothing here, but this method is required for the code to work...
  }
}

