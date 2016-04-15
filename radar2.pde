/* BUG LIST

 - New bogey locations will draw before line locate reaches if frameCount is still in draw cycle.
   + Solved with signature variable in bogey object.

*/

// Global Declarations
int x = 0 ;   // Angle for radar line in degrees
int c = 10 ;  // Number of circles
int bg = 0 ;  // Edge background
int red = 200 ;  // Default tone of red
int n = red;
int m = -300;

int lastSignature = -1;

int fps = 60 ;
int[] squadSig = new int[5]; 

Bogey[] squadron = new Bogey[5]; 
Bogey b1 = new Bogey(0,-90,1);

void setup() {  // setup() runs once
  size(800, 800);  // This only works well as a square for now
  frameRate(fps);
  
  for (int i = 0 ; i < 5 ; i++) {
   squadron[i] = new Bogey() ;
  }  
}

void draw() {  // draw() loops forever, until stopped
  translate(width/2, height/2);
  background(bg);
    
  //Draws
  strokeWeight(1) ;
  stroke(0,215,0);
  fill(0,65,0);
  for (int i = 0 ; i < c ; i++ ) {
    ellipse(0,0, width - (i*(width/c)), height - (i*(height/c)) );
  }
  DrawGridTrig(12);
  
  //
  if ( (x) == b1.BogeyGetDegrees()) {
    print("Located Bogey at coordinates(",b1.xCoord,",",b1.yCoord,") bearing", b1.angle ,"degrees! Distance of" , nf(b1.distance,0,2) , "[",b1.signature, "]" , b1.scanframe ,"\n"  );
    lastSignature = b1.signature;
    b1.setFrame(frameCount) ;
    b1.setRed(red);
  }
  
  if ((frameCount <= b1.scanframe + fps) && (lastSignature == b1.signature)) {
    if (frameCount <= b1.scanframe + (fps/2) ) {
        b1.DrawBogey();
    }
    else {
        b1.dotFade();
        b1.DrawBogey();
    }
  }
  
  // Squadron
  for ( int i = 0 ; i < 5 ; i++ ) {
     if ( (x) == squadron[i].BogeyGetDegrees()) {
     squadSig[1] = squadron[i].signature;
     squadron[i].setFrame(frameCount) ;
    }
    if ((frameCount <= squadron[i].scanframe + fps) && (squadSig[1] == squadron[i].signature)) {
      if (frameCount <= squadron[i].scanframe + (fps/2) ) {
        squadron[i].setRed(red);
        squadron[i].DrawBogey();   
      }
      else {
        squadron[i].dotFade() ;
        squadron[i].DrawBogey();
      }
    } 
  } // End squadron
  
  // Draw line and increment x
  DrawRadarLine(x++, width/2, 0,0, bg);
  x %= 360; 
  
  if (frameCount % 1011 == 0) {b1 = new Bogey(); print ("Bogey is on the move." , "\n"); 

  }
} // End draw()

void DrawRadarLine(int degrees, int radius, int x, int y, int c) {
  stroke(c);
  strokeWeight(2);
  rotate( ((degrees * PI) / 180) ) ;
  line(x,y, radius, y) ;
}

// Draw grids
void DrawGridTrig(int s)
{
  float arc = 0.0 ;
  float x = (sin(arc) * (width/2)) ;
  float y = (cos(arc) * (height/2));
  int q = s ;
  if ( q % 4 != 0 ) {
    q = 8 ;
  }

  for (int i=0; i <= q ; i++) {
    line(0,0,x,y);
    arc = i * (PI/(q/2)) ;
    x = sin(arc) * (width/2);
    y = cos(arc) * (height/2);
  }
}

// Classes
class Bogey {
  // Local Declarations
  int xCoord, yCoord, angle ;
  float distance;
  int signature ;
  int scanframe ; 
  int redTone ;
  
  // Constructors 
  Bogey() { // Default without arguments
    do {
      xCoord = int (random(-(width/2), width/2)) ;
      yCoord = int (random(-(width/2), width/2)) ;
      distance = this.getDistanceFromRadar();
      // print (distance, float (width/2),"\n");
    } while ( (distance > float(width/2))  );
    angle = this.BogeyGetDegrees() ;
    this.setSignature();
    this.scanframe = frameCount ;
    this.redTone = red ;
  } 
  Bogey(int x, int y, int f) { // Passed in arguments
     xCoord = x;
     yCoord = y;
     angle = this.BogeyGetDegrees() ;
     distance = this.getDistanceFromRadar() ;
     this.setSignature();
     // print (distance,"\n");
     this.scanframe = frameCount ;
     this.redTone = red ;
  }
  
 // Class Bogey functions
 void DrawBogey() {
   int size = 10; 
   stroke(this.redTone,0,0) ;
   fill(this.redTone,0,0);
   ellipse(this.xCoord,this.yCoord, size, size) ;
  }
  
  // Pythagorea's Theorem
  float getDistanceFromRadar() {
    return (sqrt ( float((this.xCoord * this.xCoord) + (this.yCoord * this.yCoord)) )); 
  }
  
  int BogeyGetDegrees() {
    float r = ( atan((float(this.yCoord))/(float(this.xCoord))) ) * (180/PI) ; 
    if ( (this.yCoord < 0) && (this.xCoord >= 0)  ) {
      r += 360.0; // Quad 4
    }
    else if ((this.xCoord < 0) ) {
      r += 180.0; // Quad 2,3
    }
    return int(r) ;
  }
  
  void setAngle(int d) {
    this.angle = d;
  }
  
  void setDistance(float d) {
     this.distance = d;
  }
  
  void setSignature() {
     this.signature = int(random(1000)+this.angle); 
  }
  
  void setFrame(int f) {
      this.scanframe = f;
  }
  
  void setRed(int r) {
      this.redTone = r ;
  }
  
  void dotFade() {
      this.redTone -= 3;
  }
   
} // End Bogey

void mousePressed() {
 b1 = new Bogey(mouseX - (width/2), mouseY - (height/2), frameCount); 
 print ("Bogey moved moved to", b1.xCoord, b1.yCoord , "\n");
}
