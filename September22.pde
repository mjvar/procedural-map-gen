// Procedural map generation using Voronoi tesellations.
// Distance from each point is calculated using Manhattan
// distance rather than Euclidean distance.

// INSTRUCTIONS:
// Click on the map to draw a rough shape;
// press ENTER to generate the map.

boolean startGen = false;

int dotDim = 30;
int dotCount = dotDim * dotDim;
PVector[] pts = new PVector[dotCount];

IntList land;

ArrayList<PVector> params = new ArrayList<PVector>();

java.awt.Polygon poly = new java.awt.Polygon();

//The PointContainer class exists solely to
//work with findNearest. When finding the
//point nearest any given pixel, we can use
//PointContainer to return both the point's
//index in pts[] and its distance from the pixel
//in one fell swoop.
class PointContainer{
  int index;
  float dist;
  
  PointContainer(int i, float d){
    this.index = i;
    this.dist = d;
  }
}

//Find the nearest point from array pts to any given pixel (x/y value).
PointContainer findNearest(PVector[] pts, float x, float y){
  float minDist = width*2;
  float tempDist = 0;
  int index = 0;
  for(int i = index; i < pts.length; i++){
    //tempDist = dist(pts[i].x, pts[i].y, x, y); // Using Euclidean distance calculation
    tempDist = abs(pts[i].x - x) + abs(pts[i].y - y); // Using Manhattan distance calculation
    if(tempDist < minDist){
      minDist = tempDist;
      index = i;
    }
  }
  return(new PointContainer(index, minDist));
}

java.awt.Polygon generateShape(){
  for(PVector p : params){
    poly.addPoint(int(p.x), int(p.y));
  }
  return poly;
}

//Figure out which points should represent land.
//This can be done a multitude of ways. For simplicity,
//this version will generate land from a circle at the
//center of the canvas.
IntList chooseLand(PVector[] pts){
  java.awt.Polygon shape = generateShape();
  IntList land = new IntList();
  int i = 0;
  float randomFactor = 0.98;
  float edgeFactor = 0.1;
  for(PVector p : pts){
    //In this if statement we can add a random value
    //to "skip" some land tiles, and turn them into 
    //inland bodies of water, like lakes!
    if(shape.contains(p.x, p.y) && random(0,1)<randomFactor){
      land.append(i);
    }
    else if(p.x < width * (1-edgeFactor) && p.y < height * (1-edgeFactor) && p.x > width * edgeFactor && p.y  > height * edgeFactor && random(0,1)>randomFactor){
      land.append(i);
    }
    i++;
  }
  return(land);
}

void printWater(){
  float noiseOffset = 0.008;
  loadPixels();
  for(int x = 0; x < width; x++){
    for(int y = 0; y < height; y++){
      int pixelI = x + y * width;
      pixels[pixelI] = color(30,30,map(noise(x*noiseOffset, y*noiseOffset),0,1,140,250));
    }
  }
  updatePixels();
}

//Prints land pixels based on land tiles
//chosen in chooseLand().
void printLand(){
  loadPixels();
  float noiseOffset = 0.008;
  for(int x = 0; x < width; x++){
     for(int y = 0; y < height; y++){
       int pixelI = x + y * width;
       PointContainer current = findNearest(pts,x,y);
       if(land.hasValue(current.index)){
         pixels[pixelI] = color(0,map(noise(x*noiseOffset, y*noiseOffset),0,1,120,200),0);
       }
     }
  }
  updatePixels();
}

void printPoints(){
  for(PVector p : params){
    strokeWeight(8);
    stroke(255,0,0);
    point(p.x, p.y);
  }
}

void setup(){
  size(1300,800);
  float scaleFactor = width/dotDim * 1.2; 
  float randomFactor = 20;
  for(int x = 0; x < dotDim; x++){
    for(int y = 0; y < dotDim; y++){
      // Here we initialize points on a grid with x and y values based on scaling, but agitate them by a small noise factor.
      //pts[x + y * dotDim] = new PVector(x * scaleFactor + random(-randomFactor,randomFactor), y * scaleFactor + random(-randomFactor,randomFactor));
      pts[x + y * dotDim] = new PVector(random(width),random(height));
    }
  }
}

void draw(){
  background(50,100,255);
  //We print the water first, on top of which the land will fall.
  printWater();
    
  if(startGen == false){
    printPoints();
  }
  else{
    //First, we choose which points are "land" values.
    land = chooseLand(pts);
    
    //Then, given these values, we use the Voronoi diagram to
    //print land in "tiles", based on their closest point.
    printLand();
    
    //strokeWeight(5);
    //stroke(255,0,0);
    //for(PVector v : pts){
    //  point(v.x, v.y);
    //}
    noLoop();
  }
}

void mouseReleased(){
  if(startGen == false){
    params.add(new PVector(mouseX, mouseY));
  }
}

void keyPressed(){
  if(keyCode == ENTER){
    startGen = true;    
  }
}
