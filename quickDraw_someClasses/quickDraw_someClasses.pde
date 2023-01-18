import processing.sound.*;

mainLoop cLoop;

void setup(){
    //size(600,600);
    fullScreen(P2D);
    orientation(LANDSCAPE);

    loadAll();
    
    cLoop = new mainLoop();
}
void draw(){
    cLoop.play();
}
void keyPressed(){
    cLoop.keyPressedManager();}
void keyReleased(){
    cLoop.keyReleasedManager();}
void mousePressed(){
    cLoop.mousePressedManager();}
void mouseReleased(){
    cLoop.mouseReleasedManager();}
