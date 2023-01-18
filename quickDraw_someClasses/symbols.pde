class symbol{
    boolean inMotion = false;
    PVector pos;
    PVector vel = new PVector(0,0);
    PVector acc = new PVector(0,9.81*0.05);
    PVector dim;

    PImage icon;

    float rotLim = PI/3.0;
    float rot;

    symbol(PImage symbolIcon, PVector position, PVector dimension){
        icon = symbolIcon;
        pos = position;
        dim = dimension;
        rot = random(-rotLim, rotLim);
    }

    void display(){
        pushStyle();
        pushMatrix();

        imageMode(CENTER);
        fill(255);
        stroke(0);

        translate(pos.x, pos.y);
        rotate(rot);

        image(icon, 0, 0, dim.x, dim.y);

        popMatrix();
        popStyle();
    }
    void giveVel(PVector dir, float mag){
        /*
        Call once to give a burst of speed
        */
        dir.normalize();
        vel.x = dir.x*mag;
        vel.y = dir.y*mag;
    }
    void calcDynamics(){
        if(inMotion){
            calcVel();
            calcPos();

            //calcWindowCollision();
        }
    }
    void calcVel(){
        vel.x += acc.x;
        vel.y += acc.y;

        rot += PI/128.0;
    }
    void calcPos(){
        pos.x += vel.x;
        pos.y += vel.y;
    }
    void calcWindowCollision(){
        boolean withinX = (0 < (pos.x +vel.x)) && ((pos.x +vel.x) < width);
        boolean withinY = (0 < (pos.y +vel.y)) && ((pos.y +vel.y) < height);
        float eCoeff = 0.6;
        if(!withinX){
            vel.x *= -eCoeff;}
        if(!withinY){
            vel.y *= -eCoeff;}
    }
}