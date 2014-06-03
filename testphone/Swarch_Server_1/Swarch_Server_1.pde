// John Nguyen 
// Thomas Truong
// Anthony So
// ICS 168 Swarch on Androi - Java Server

/*
 * OscP5 and NetP5 Protocols used to setup the server
 * @NetAddressList - stores players IP
 */
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddressList myNetAddressList = new NetAddressList();

/*
 * SQLite DB
 * Uses BezierSQLib for Processing
 */
import java.sql.*;
import de.bezier.data.sql.*;
SQLite db;

/*
 * @int myListeningPort - set server incoming message port to 32000
 */
int myListeningPort = 32000;


/*
 * @String myConnectPattern - Message server look for from client to connect
 * @String myDisconnectPattern - Message server look for from client to disconnect
 */
String myConnectPattern = "Connecting...";
String myDisconnectPattern = "Disconnecting...";

/*
 * @String userName - string variable that store userName from db.getString()
 * @String passWord - string variable that stores password from db.getString()
 */
String userName;
String passWord;

//food coordinate
float[] xCoord;
float[] yCoord;

//cube position
float[] xCube;
float[] yCube;

int[] players;
int[] dir;
boolean started;
int s;

float[] rgb;


void setup() 
{

  started = false;
  players = new int[3];
  dir = new int[3];
  dir[0] = 0; 
  dir[1] = 0; 
  dir[2]=0;
  /*
   * Creates a new oscP5 Instance using myListening Port
   * and is in TCP mode
   */
  oscP5 = new OscP5(this, myListeningPort, OscP5.TCP);
  frameRate(60);

  /*
   * Creates a instance of SQLite that opens
   * an account database file which currently
   * holds a table "table1" and "player" 
   * and "password" columns
   */
  db = new SQLite(this, "account.db"); //opens the account database file

  if (db.connect())
  {

    //Example of how to insert into table
    //db.query(" insert into table1 values ('anthony', '123')");

    //How to delete the entire table1
    //db.query("delete from table1");

    //list table names
    db.query( "SELECT name as \"Name\" FROM SQLITE_MASTER where type=\"table\"" );

    while (db.next ())
    {
      println(db.getString("Name") );
    }

    //read from "table1"
    db.query( "SELECT * FROM table1" );

    //print out user and password in the database when server starts up.
    while (db.next ())
    {
      print("Username: " + db.getString("Player") + " Password: " + db.getString("Password"));
      println();
    }
  }

  xCoord = new float[4];
  yCoord = new float[4];

  for (int i = 0; i < 4; ++i)
  {
    xCoord[i] = random(15, displayWidth - 70);
    yCoord[i] = random(15, displayHeight - 60);
  }

  xCube = new float[2];
  yCube = new float[2];

  for (int i = 0; i < 2; ++i)
  {
    xCube[i] = random(15, displayWidth - 70);
    yCube[i] = random(15, displayHeight - 60);
  }

  rgb = new float[6];
  for (int i = 0; i < 6; ++i)
  {
    rgb[i] = random(255);
  }
}

void draw() 
{

  background(0);
  if (started)
  {
    move();
    unitCollison();
    OscMessage m2 = new OscMessage("Moveshit");
    m2.add(myNetAddressList.list().size());
    for (int k = 0; k < myNetAddressList.list ().size(); k++)
    {
      m2.add(xCube[k]);
    }    
    for (int l = 0; l < myNetAddressList.list ().size(); l++)
    {
      m2.add(yCube[l]);
    }
    oscP5.send(m2);

    unitCollison();
  }
}

void move()
{
  for (int i = 1; i < myNetAddressList.list ().size()+1; i++)
  {

    if (dir[i] == 1)
    {
      xCube[i-1] -= 2;
    } 
    else if (dir[i] == -1)
    {
      xCube[i-1] += 2;
    } 
    else if (dir[i] == -2)
    {
      yCube[i-1] -= 2;
    } 
    else if (dir[i] == 2)
    {
      yCube[i-1] += 2;
    }
  }//end for
}

void unitCollison()
{
  int pOneCenter = (int)(25 /3); // makes sure the bounds are updated before checking for collision.

  for (int h = 0; h < myNetAddressList.list ().size(); h++)
  {
    for (int i = 0; i < 4; i++)
    {
      if ((xCube[h]  >= xCoord[i] - pOneCenter - 15 && xCube[h]  <= xCoord[i] + pOneCenter + 15) 
        && (yCube[h]   >= yCoord[i] - pOneCenter - 15 && yCube[h]   <= yCoord[i] + pOneCenter + 15))
      {
        OscMessage food = new OscMessage("Food respawn");
        xCoord[i] = random(15, displayWidth - 70);
        yCoord[i] = random(15, displayHeight - 60);
        food.add(i);
        food.add(xCoord[i]);
        food.add(yCoord[i]);
        food.add(h);
        //score += 1;
        food.add(1);
        oscP5.send(food);
        println("hit! " + " xCoord[i]: " + xCoord[i] + " yCoord[i]: "+ yCoord[i]);
      }
      else if ( (xCube[h] - 10 > 1920 - 15) || (xCube[h] - 10 < 0) || (yCube[h] + 10 > 1200 - 95) || (yCube[h] - 10 < 0))
      {
        OscMessage edge = new OscMessage("Edge Collison");
        xCube[h] = random(25, displayWidth - 70);
        yCube[h] = random(25, displayHeight - 60);
        edge.add(xCube[h]);
        edge.add(yCube[h]);
        edge.add(h);
       // score = 0;
        edge.add(0);
        oscP5.send(edge);
      }
      else
      {
        if (((xCube[0] >= xCube[1] - pOneCenter - 5 && xCube[0] <= xCube[1] + pOneCenter + 5) &&
          (yCube[0] >= yCube[1] - pOneCenter - 5 && yCube[0] <= yCube[1] + pOneCenter + 5)))
        {
          OscMessage playerC = new OscMessage("Player Collison");
          xCube[h] = random(25, displayWidth - 70);
          yCube[h] = random(25, displayHeight - 60);
          playerC.add(xCube[0]);
          playerC.add(yCube[0]);
          playerC.add(0);
          //size += 10;
          playerC.add(10);
          oscP5.send(playerC);
       
        }
        else if (((xCube[1] >= xCube[0] - pOneCenter - 5 && xCube[1] <= xCube[0] + pOneCenter + 5) &&
          (yCube[1] >= yCube[0] - pOneCenter - 5 && yCube[1] <= yCube[0] + pOneCenter + 5)))
        {
          OscMessage playerC = new OscMessage("Player Collison");
          xCube[h] = random(25, displayWidth - 70);
          yCube[h] = random(25, displayHeight - 60);
          playerC.add(xCube[1]);
          playerC.add(yCube[1]);
          playerC.add(1);
          // size += 10;
          playerC.add(10);
          oscP5.send(playerC);
        }
      }
    }
  }
}

void oscEvent(OscMessage theOscMessage)
{
  /* Check to see if client messages fits any of the server patterns */
  if (theOscMessage.addrPattern().equals(myConnectPattern)) 
  {
    connect(theOscMessage.netAddress().address());

    //testing send message was successful
    OscMessage m = new OscMessage("Connection Successful!");
    //This sends the above message to all clients connected.
    oscP5.send(m, theOscMessage.tcpConnection());
  } 
  else if (theOscMessage.addrPattern().equals("Direction shit"))
  {
    dir[theOscMessage.get(0).intValue()] = theOscMessage.get(1).intValue();
  }
  //handles user registration
  //check that if incoming message is not blank run the code inside
  else if (!theOscMessage.get(0).stringValue().equals(""))
  {
    if (db.connect())
    {
      //Look for userName in Player and store it in userName
      db.query("SELECT * FROM table1 where player = '" +theOscMessage.get(0).stringValue() +"'");
      userName = db.getString("Player");
      //Query for a player and password that matches in both columns and store in passWord
      db.query("SELECT * FROM table1 where player = '" +theOscMessage.get(0).stringValue() +"' and password = '" + theOscMessage.get(1).stringValue() + "'");
      passWord = db.getString("Password");
      println(userName + " " + passWord);

      /*
       * if Player doesn't exist in the database
       * print out a comment to console giving current state
       * Insert into table the current userName/Password from client
       * Send to client a Successful registration and start the game
       */
      if (userName == null) 
      {
        println("Player is not in the database yet");
        //add player
        db.query("INSERT into table1 values ('"+theOscMessage.get(0).stringValue()+"', '"+theOscMessage.get(1).stringValue()+"')");
        println("addded " + theOscMessage.get(0).stringValue() + " " + theOscMessage.get(1).stringValue());

        OscMessage m2 = new OscMessage("Authenticated");
        for (int i = 0; i < 4; ++i)
        {
          m2.add(xCoord[i]);
          println("x:" + xCoord[i]);
        }
        for (int j = 0; j < 4; ++j)
        {
          m2.add(yCoord[j]);
          println("y:" + yCoord[j]);
        }
        m2.add(myNetAddressList.list().size());
        for (int k = 0; k < myNetAddressList.list ().size(); k++)
        {
          m2.add(xCube[k]);
          println("x cube:" + xCube[k]);
        }    
        for (int l = 0; l < myNetAddressList.list ().size(); l++)
        {
          m2.add(yCube[l]);
          println("y cube:" + yCube[l]);
        }
        for (int i = 0; i < 6; ++i)
        {
          m2.add(rgb[i]);
        }

        oscP5.send(m2, theOscMessage.tcpConnection());
        started = true;
      }
      /*
       * if both userName and Password are correct
       * print to console giving current state
       * then the player exist in the database that matches the criteria
       * authenticate the player and continue on to the game
       */
      else if (userName != null && passWord != null)
      {
        println("Player Exist and Password Match");
        //authenticate player

        OscMessage m2 = new OscMessage("Authenticated");
        for (int i = 0; i < 4; ++i)
        {
          m2.add(xCoord[i]);
          println("x:" + xCoord[i]);
        }
        for (int j = 0; j < 4; ++j)
        {
          m2.add(yCoord[j]);
          println("y:" + yCoord[j]);
        }
        m2.add(myNetAddressList.list ().size());
        for (int k = 0; k < myNetAddressList.list ().size(); k++)
        {
          m2.add(xCube[k]);
          println("x cube:" + xCube[k]);
        }    
        for (int l = 0; l < myNetAddressList.list ().size(); l++)
        {
          m2.add(yCube[l]);
          println("y cube:" + yCube[l]);
        }
        for (int i = 0; i < 6; ++i)
        {
          m2.add(rgb[i]);
        }

        oscP5.send(m2, theOscMessage.tcpConnection());
        started = true;
      }
      /*
       * If player exist but the incorrect password is given
       * print to console giving current state
       * send to client that an incorrect password was given
       * client will handle a try again password field
       */
      else if (userName != null && passWord == null)
      {
        println("Player Exist, but Password Doesn't Match");
        //send login screen again
        OscMessage m3 = new OscMessage("Incorrect Password");
        oscP5.send(m3, theOscMessage.tcpConnection());
      }
    }
  }

  //commented out for milestone 4
  /*//Disocnnection function
   else if (theOscMessage.addrPattern().equals(myDisconnectPattern)) 
   {
   disconnect(theOscMessage.netAddress().address());
   }
   //if none of above match than message all clients.
   else 
   {
   oscP5.send(theOscMessage, theOscMessage.tcpConnection());
   }*/
}


/*
 * Handles new players connecting
 * If player isn't in the player ip address list
 * they are added. Otherwise they are connected.
 */
private void connect(String theIPaddress) 
{
  if (!myNetAddressList.contains(theIPaddress, myListeningPort)) 
  {
    myNetAddressList.add(new NetAddress(theIPaddress, myListeningPort));
    println("### adding "+theIPaddress+" to the player list.");
  } 
  else 
  {
    println("### "+theIPaddress+" is already connected.");
  }
  println("### currently there are "+myNetAddressList.list().size()+" remote locations connected.");
}


/*
private void disconnect(String theIPaddress) 
 {
 if (myNetAddressList.contains(theIPaddress, myListeningPort)) 
 { 
 myNetAddressList.remove(theIPaddress, myListeningPort);
 println("### removing "+theIPaddress+" from the list.");
 } 
 else 
 {
 println("### "+theIPaddress+" is not connected.");
 }
 println("### currently there are "+myNetAddressList.list().size());
 }*/
