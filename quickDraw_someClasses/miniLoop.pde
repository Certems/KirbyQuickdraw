/*
**
How to add a new mini game loop;
**
1. Create a new sub-class for miniLoop called 'miniLoop_...'
2. Go to the mainLoop and increase the 'miniMax' by 1
3. Add another if in the 'ChooseMiniGame' function for the new miniLoop
4. Add whatever click command is needed in 'mainLoop' for 'cMini == ...'
5. Ensure any new functions created in your sub-class have ALSO been entered into
    the original 'miniLoop' class but empty (so they can be used in the program)
*/
class miniLoop{
    boolean miniOver   = false; //When a mini game ends with a WINNER
    boolean hasParried = false; //When a mini game ends with a PARRY

    int winner = 0;

    miniLoop(){
        //pass
    }

    void play(){
        //What should happen in the main loop of the game
    }
    void clickCommand(){
        /*
        What should happen when the play clicks in this game
        For mousePressed AND keyPressed
        */
    }
}
class miniLoop_0 extends miniLoop{
    /*
    Game 0; Counter for both players, 
            mash until filled for a winner, 
            another parry if within X points of each other
    */
    int p1Score = 1;    //1 not 0 so the players can see the scoer bar
    int p2Score = 1;
    int scoreMax;       //Score to win
    int parryScore;     //Score difference that causes a parry to occur

    PVector boxPos;
    PVector boxDim;

    miniLoop_0(){
        boxPos = new PVector(width/2.0, height/2.0);
        boxDim = new PVector(width/18.0, 6.0*height/10.0);
        scoreMax   = floor(random(20,31));
        parryScore = ceil(scoreMax*0.05);
    }

    @Override
    void play(){
        drawBox();

        int result = checkWinner();
        determineMiniResult(result);
    }
    @Override
    void clickCommand(){
        if(mouseX < width/2.0){
            //For p1
            p1Score++;
        }
        else{
            //For p2
            p2Score++;
        }
    }
    void determineMiniResult(int result){
        if(result == -1){   //No winners
            //Do nothing, continue mini game
        }
        if(result == 0){    //Parry
            cLoop.chooseMiniGame(-1);
            hasParried = true;
        }
        if(result == 1){    //P1 win
            cLoop.p1Score++;
            winner = 1;
            miniOver = true;
        }
        if(result == 2){    //P2 win
            cLoop.p2Score++;
            winner = 2;
            miniOver = true;
        }
    }
    Integer checkWinner(){
        boolean p1Wins = p1Score >= scoreMax;
        boolean p2Wins = p2Score >= scoreMax;
        if(p1Wins || p2Wins){
            //Is a winner...
            boolean parryOccurs = abs(p1Score-p2Score) <= parryScore;
            if(parryOccurs){
                //Is a parry...
                return 0;
            }
            else{
                //Is no parry...
                if(p1Wins){
                    return 1;}
                else{
                    return 2;}
            }
        }
        else{
            //Is no winner...
            return -1;
        }
    }
    void drawBox(){
        pushStyle();
        
        imageMode(CENTER);
        rectMode(CENTER);

        fill(255);
        stroke(0);
        strokeWeight(2);

        //Full shell
        image(mini0Bar, boxPos.x, boxPos.y, boxDim.x, boxDim.y);

        rectMode(CORNERS);
        noStroke();
        //P1 progress bar
        fill(255,0,0);
        rect(boxPos.x -boxDim.x/2.0 , boxPos.y +boxDim.y/2.0, boxPos.x              , boxPos.y +boxDim.y/2.0 -boxDim.y*( float(p1Score)/float(scoreMax) ) );
        //P2 progress bar
        fill(0,255,0);
        rect(boxPos.x               , boxPos.y +boxDim.y/2.0, boxPos.x +boxDim.x/2.0, boxPos.y +boxDim.y/2.0 -boxDim.y*( float(p2Score)/float(scoreMax) ) );

        popStyle();
    }
}
class miniLoop_1 extends miniLoop{
    /*
    Game 1; Shoots 2 sets X bullet holes into the board, each 
        coloured in either red or blue.
        The game ends when either colour is fully removed, where 
        the winner is the player associated with that colour
        The colours are initially introduced to the corresponding colour

        Sound is played as the bullet holes are placed in turn
    */
    boolean preGame  = true;
    boolean mainGame = false;

    float colCentre = 255.0 / 2.0;
    float colRange  = 50.0;
    PVector p1Col = new PVector( random(colCentre -colRange, colCentre +colRange), random(colCentre -colRange, colCentre +colRange), 255 );
    PVector p2Col = new PVector( 255, random(colCentre -colRange, colCentre +colRange), random(colCentre -colRange, colCentre +colRange) );

    int preTimer = 0;

    int waitTime = 2*60;
    int animTime = 80;

    float bulletSize = height/6.0;
    int bulletNum = 5;
    ArrayList<PVector> p1Bullets = new ArrayList<PVector>();
    ArrayList<PVector> p2Bullets = new ArrayList<PVector>();

    int parryQuantity = ceil(bulletNum/15.0);

    miniLoop_1(){
        //pass
    }

    @Override
    void play(){
        if(preGame){
            playPreGame();}
        if(mainGame){
            playMainGame();}
    }
    @Override
    void clickCommand(){
        for(int i=0; i<p1Bullets.size(); i++){
            float dist = sqrt( pow(p1Bullets.get(i).x -mouseX,2) + pow(p1Bullets.get(i).y -mouseY,2) );
            if(dist <= bulletSize/2.0){
                p1Bullets.remove(i);
                break;
            }
        }
        for(int i=0; i<p2Bullets.size(); i++){
            float dist = sqrt( pow(p2Bullets.get(i).x -mouseX,2) + pow(p2Bullets.get(i).y -mouseY,2) );
            if(dist <= bulletSize/2.0){
                p2Bullets.remove(i);
                break;
            }
        }
    }
    void playPreGame(){
        /*
        1. Wait for a some time and show each player's colour
        2. Start placing bullet holes
        */
        showPlayerColour();
        showBullets();
        if( (0 <= preTimer) && (preTimer < waitTime) ){
            countdown();}
        else if( (waitTime <= preTimer) && (preTimer < waitTime+animTime) ){
            placeBulletHoles();}
        else{
            preGame  = false;
            mainGame = true;
        }
        preTimer++;
    }
    void playMainGame(){
        //Let players click bullet holes until all of 1 set are gone
        showPlayerColour();
        showBullets();

        int result = checkWinner();
        determineMiniResult(result);
    }
    void showPlayerColour(){
        pushStyle();

        int alphaLvl = 200;
        float bMulti = 1.2;
        fill(p1Col.x, p1Col.y, p1Col.z, alphaLvl);
        ellipse(cLoop.p1Pos.x, cLoop.p1Pos.y, bMulti*cLoop.p1Dim.x, bMulti*cLoop.p1Dim.y);
        fill(p2Col.x, p2Col.y, p2Col.z, alphaLvl);
        ellipse(cLoop.p2Pos.x, cLoop.p2Pos.y, bMulti*cLoop.p2Dim.x, bMulti*cLoop.p2Dim.y);

        popStyle();
    }
    void countdown(){
        pushStyle();

        imageMode(CENTER);
        textAlign(CENTER, CENTER);
        textSize(width/60.0);

        fill(0);
        stroke(0);
        strokeWeight(2);

        text(waitTime -preTimer, width/2.0, height/2.0);

        popStyle();
    }
    void placeBulletHoles(){
        float border = height/20.0;
        if(preTimer % (animTime/(2*bulletNum)) == 0){
            //gunshotSound.play();
            p1Bullets.add( new PVector(random(border, width-border), random(border, height-border)) );}
        if(preTimer % (animTime/(2*bulletNum)) == animTime/(4*bulletNum)){
            //gunshotSound.play();
            p2Bullets.add( new PVector(random(border, width-border), random(border, height-border)) );}
    }
    void showBullets(){
        pushStyle();
        imageMode(CENTER);
        noStroke();
        for(int i=0; i<p1Bullets.size(); i++){
            fill(p1Col.x, p1Col.y, p1Col.z, 120);
            image(crosshairsIcon, p1Bullets.get(i).x, p1Bullets.get(i).y, bulletSize, bulletSize);    //## CHANGE TO BULLET ICON ##
            ellipse(p1Bullets.get(i).x, p1Bullets.get(i).y, bulletSize, bulletSize);
        }
        for(int i=0; i<p2Bullets.size(); i++){
            fill(p2Col.x, p2Col.y, p2Col.z, 120);
            image(crosshairsIcon, p2Bullets.get(i).x, p2Bullets.get(i).y, bulletSize, bulletSize);    //## CHANGE TO BULLET ICON ##
            ellipse(p2Bullets.get(i).x, p2Bullets.get(i).y, bulletSize, bulletSize);
        }
        popStyle();
    }
    void determineMiniResult(int result){
        if(result == -1){   //No winners
            //Do nothing, continue mini game
        }
        if(result == 0){    //Parry
            cLoop.chooseMiniGame(-1);
            hasParried = true;
        }
        if(result == 1){    //P1 win
            cLoop.p1Score++;
            winner = 1;
            miniOver = true;
        }
        if(result == 2){    //P2 win
            cLoop.p2Score++;
            winner = 2;
            miniOver = true;
        }
    }
    Integer checkWinner(){
        boolean p1Wins = p1Bullets.size() == 0;
        boolean p2Wins = p2Bullets.size() == 0;
        if(p1Wins || p2Wins){
            //Is a winner...
            boolean parryOccurs = abs(p1Bullets.size() - p2Bullets.size()) < parryQuantity;
            if(parryOccurs){
                //Is a parry...
                return 0;
            }
            else{
                //Is no parry...
                if(p1Wins){
                    return 1;}
                else{
                    return 2;}
            }
        }
        else{
            //Is no winner...
            return -1;
        }
    }
}
class miniLoop_2 extends miniLoop{
    /*
    Game 2; ?
    */
    //pass

    miniLoop_2(){
        //pass
    }

    @Override
    void play(){
        //pass
    }
    @Override
    void clickCommand(){
        //pass
    }
}