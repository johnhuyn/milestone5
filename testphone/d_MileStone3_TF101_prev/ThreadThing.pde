String pwMD5 = "";
//Thread class to allow both key event and sending to happen at same time.
public class ThreadThing implements Runnable 
{
  Thread thread;
  public ThreadThing(PApplet parent) 
  {
    parent.registerDispose(this);
  }

  public void start()
  {
    thread = new Thread(this);
    thread.start();
  }

  public void run()
  {
    // runs the msg send to server
    userName = nameField.getText();
    passWord = passwordField.getText();
    //encrypts password
    passWord = md5Java(passWord);
    OscMessage m = new OscMessage("");
    m.add(userName);
    m.add(passWord);
    oscP5.send(m);//, myBroadcastLocation);
  }

  public void stop() {
    thread = null;
  }

  // this will magically be called by the parent once the user hits stop
  // this functionality hasn't been tested heavily so if it doesn't work, file a bug
  public void dispose() 
  {
    stop();
  }
}

