import SimpleOpenNI.*;
import voce.*;
import controlP5.*;
SimpleOpenNI  kinect;

//GLOBAL VARIABLE
float headTotal = 0;
float lastHeadX = 0;
float lastHeadY = 0;
float lastHeadZ = 0;

int frameCount = 0;
int colorFlag = 0;
int useVoice = 0;

int headThreshold = 300;

ArrayList pointList;     // arraylist to store the points in
PrintWriter OUTPUT;       // an instantiation of the JAVA PrintWriter object.
                          // This variable reappears in our custom export function

boolean _record = false;
ControlP5 cp5;  // gui library


                         
void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  // change the default font to Verdana
  
  size(640, 580);
  fill(255, 0, 0);
  //background(200,200,200);
  // GUI
  noStroke();
  cp5 = new ControlP5(this);
  PFont p = createFont("Verdana",36);
  cp5.setControlFont(p);
  
  cp5.addSlider("sliderValue")
     .setRange(0,10000)
     .setValue(0)
     .setPosition(300,530)
     .setSize(400,10)
     ;

  cp5.addButton("SSB")
    .setValue(0)
    .setPosition(50, 500)
    .setSize(100, 80);
 
  headTotal = 0;
  print("Setup up head total: ");
  print(headTotal);
  
  // paths in Processing are relative to the IDE .exe file.  Since we all have our IDE installed in different dirs,
  // we have to do a little work to make this code shareable.
  
  // copy the ONOFF.gram file in the same directory as the processing IDE .exe
  
  // Create a new file in the sketchbook (not in source control) that looks like the one below.  The voceConfigPath variable should point to 
  // the path where the voce.config.xml file resides (usually <sketchbook path>/data
  /*
    class Paths {
      String voceConfigDir = "C:/Users/avi/Documents/Processing/sketch_skeletonb/data";
    }
  */
  voce.SpeechInterface.init(new Paths().voceConfigDir, false, true, 
      "", "ONOFF");

  print("This is a speech recognition test. " 
      + "Say ON or OFF in the microphone" 
      + "Speak 'quit' to quit.");
}

public void SSB(int newValue) {
  if (_record) {
    stopRecording(); 
  }
  else {
    startRecording();
  }
}

void draw() {
  kinect.update();
  fill(100);
  image(kinect.depthImage(), 0, 0);

  IntVector userList = new IntVector();
  kinect.getUsers(userList);


  if (userList.size() > 0) {
    int userId = userList.get(0);

    if ( kinect.isTrackingSkeleton(userId)) {
      drawSkeleton(userId);
      if (_record) {
        computeHeadMovement(userId);
      }
    }
  }
  
  if(useVoice==1) {
    while (voce.SpeechInterface.getRecognizerQueueSize() > 0) {
      String s = voce.SpeechInterface.popRecognizedString();
      if(-1 != s.indexOf("lets get started")){
        startRecording();
      }
      else if(-1 != s.indexOf("time to go home")){
        stopRecording();
      }
  
        System.out.println("You said: " + s);
    }
  }
}

void startRecording() {
  println("Begin recording");
  background(0,255,0);
  headTotal = 0;
  colorFlag=0;
  cp5.getController("sliderValue").setValue(headTotal);
  fill(0,0,0);
  cp5.setColorValue(color(0, 0, 0, 128));
  _record = true;
}

void stopRecording() {
   println("End recording");
  _record = false;
  cp5.getController("sliderValue").setValue(headTotal);
}

void drawSkeleton(int userId) {
  stroke(0);
  strokeWeight(5);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD,
                          SimpleOpenNI.SKEL_NECK);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK,
                          SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER,
                          SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW,
                          SimpleOpenNI.SKEL_LEFT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK,
                          SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER,
                          SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW,
                          SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER,
                          SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER,
                          SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO,
                          SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP,
                          SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE,
                          SimpleOpenNI.SKEL_LEFT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO,
                          SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP,
                          SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE,
                          SimpleOpenNI.SKEL_RIGHT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP,
                          SimpleOpenNI.SKEL_LEFT_HIP);

  noStroke();

  fill(255,0,0);
  drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
}

void computeHeadMovement(int userId) {

  PVector head = new PVector();
  kinect.getJointPositionSkeleton(userId, kinect.SKEL_HEAD, head);

  float thisHeadDiffX = abs(lastHeadX - head.x);
  float thisHeadDiffY = abs(lastHeadY - head.y);
  float thisHeadDiffZ = abs(lastHeadZ - head.z);
    
  if(kinect.isTrackingSkeleton(userId) && head.x < 1000 && head.x > -1200)
  {
    //headTotal=headTotal+sqrt(pow(thisHeadDiffX,2)+pow(thisHeadDiffY,2)+pow(thisHeadDiffZ,2));
    headTotal=headTotal+sqrt(pow(thisHeadDiffX,2)+pow(thisHeadDiffY,2));
  } else if(head.x > 1000 || head.x < -1200) {
    //background(0,0,255);
  }
  //println("The head total is = "+headTotal+" whilst the headDiff is"+thisHeadDiffX);
  if(thisHeadDiffX > 4 || thisHeadDiffY > 4 || thisHeadDiffZ > 4) {
    println("The headDiff is = "+thisHeadDiffX+" and "+thisHeadDiffY+" and "+thisHeadDiffZ);
  }
  
  lastHeadX = head.x;
  lastHeadY = head.y;
  lastHeadZ = head.z;
  
  //DRAW A CIRCLE FOR THE HEAD
  circleForAHead(userId);
  
    cp5.getController("sliderValue").setValue(headTotal);
    if(headTotal>headThreshold && colorFlag == 0) {
       background(255,0,0);
      //cp5.setColorValue(color(255, 0, 0, 128));
      colorFlag=1;
    }
}

void drawJoint(int userId, int jointID) {
  PVector joint = new PVector();

  float confidence = kinect.getJointPositionSkeleton(userId, jointID,
joint);
  if(confidence < 0.5){
    return;
  }

  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}

// user-tracking callbacks!
void onNewUser(int userId) {
  println("start pose detection");
  kinect.startPoseDetection("Psi", userId);
}

void onEndCalibration(int userId, boolean successful) {
  if (successful) {
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  }
  else {
    println("  Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopPoseDetection(userId);
  kinect.requestCalibrationSkeleton(userId, true);
}

// draws a circle at the position of the head
void circleForAHead(int userId)
{
  // get 3D position of a joint
  PVector jointPos = new PVector();
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,jointPos);
  // println(jointPos.x);
  // println(jointPos.y);
  // println(jointPos.z);
 
  // convert real world point to projective space
  PVector jointPos_Proj = new PVector(); 
  kinect.convertRealWorldToProjective(jointPos,jointPos_Proj);
 
  // a 200 pixel diameter head
  float headsize = 100;
 
  // create a distance scalar related to the depth (z dimension)
  float distanceScalar = (525/jointPos_Proj.z);
 
  // set the fill colour to make the circle green
  fill(0,255,0); 
 
  // draw the circle at the position of the head with the head size scaled by the distance scalar
  ellipse(jointPos_Proj.x,jointPos_Proj.y, distanceScalar*headsize,distanceScalar*headsize);  
}

void exportPoints2Text(){
  Date d = new Date();
  long current = d.getTime()/1000; 
  OUTPUT = createWriter("exportedPoints.txt");
  OUTPUT.print(headTotal);  // here we export the coordinates of the vector using String concatenation!
  OUTPUT.print(",");
  OUTPUT.println(current);
  OUTPUT.flush();
  OUTPUT.close();
  println("points have been exported");
}


