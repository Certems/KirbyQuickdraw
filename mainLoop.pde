class mainLoop{
    /*
    Breakdown of game states;
    preGame  -> Players animating in from sides of screen
    mainGame -> Waiting for indicator, then hitting as fast as possible
    miniGame -> A parry is hit causing another side game to occur
    endGame  -> Game is over and winner is calculated
    */
    boolean preGame  = true;
    boolean mainGame = false;
    boolean miniGame = false;
    boolean endGame  = false;

    boolean playedMiniGame  = false;
    boolean indicatorSent   = false;
    boolean startNextGame   = false;

    miniLoop cMiniLoop;

    int cMini   = 0;    //WHICH mini-game are you playing
    int miniMax = 1;    //**MAX number of mini games ->e.g is TotalActual# -1

    float indicatorProb = 0.05;  //Determines how long until timer goes off after grace period

    int gameTimer   = 0;      //Time through WHOLE game
    int animTime    = 1*60;   //Time to animate players in
    int graceTime   = 2*60;   //Time waiting for indicator
    int maxGameTime = 5*60;   //Maximum time before players are forced to attack
    int parryTime   = 20;         //Time between attacks for parry to occur

    int p1Score;
    int p2Score;

    PVector p1PosReq;   //Resting place for player 1
    PVector p1Dim;
    PVector p1Pos    = new PVector(0,0);
    boolean p1HasHit = false;
    int p1HitTime    = 0;

    PVector p2PosReq;   //Resting place for player 2
    PVector p2Dim;
    PVector p2Pos    = new PVector(0,0);
    boolean p2HasHit = false;
    int p2HitTime    = 0;

    float moveSpeed = 0;        //Speed when animating in

    float iconSize  = width/10.0;
    PVector iconLaunchSpd = new PVector(5.0, 15.0);     //Range of speeds icons can be launched at
    PVector iconLaunchAng = new PVector(-PI, 0);        //Range of angle icons can be launched at

    graphics cGraphics;

    mainLoop(){
        cGraphics = new graphics();

        p1PosReq = new PVector(3.0*width/10.0, 7.0*height/10.0);
        p1Dim    = new PVector(height/4.0, height/4.0);

        p2PosReq = new PVector(7.0*width/10.0, 3.0*height/10.0);
        p2Dim    = new PVector(height/4.0, height/4.0);

        p1Pos = new PVector(0     -p1Dim.x, p1PosReq.y);
        p2Pos = new PVector(width +p2Dim.x, p2PosReq.y);

        p1Score = 0;
        p2Score = 0;
    }

    void play(){
        cGraphics.display(p1Pos, p2Pos, p1Dim, p2Dim, endGame);
        if(preGame){
            //Animate in
            //println("--PreGame--");
            playPreGame();
        }
        if(mainGame){
            //Wait, then ready for hits
            //println("--MainGame--");
            playMainGame();
        }
        if(miniGame){
            //Play out mini game
            //println("--MiniGame--");
            playMiniGame();
        }
        if(endGame){
            //Show scores, reset values
            //println("--EndGame--");
            playEndGame();
        }
        showSymbols();
        showScore();
        gameTimer++;
    }
    void playPreGame(){
        if(gameTimer < animTime){
            movePlayersIn();
        }
        else{
            windSound.play();
            preGame  = false;
            mainGame = true;
        }
    }
    void playMainGame(){
        if( !allPlayersHit() ){
            //If NOT everyone has attacked..
            calcIndicator();
            if(gameTimer > maxGameTime){
                forcePlayerAttack();}
        }
        else{
            //If everyone HAS attacked...
            mainGame = false;
            determineMainStateResult(); //Is it [a mini-game] OR [a game over]
        }
    }
    void playMiniGame(){
        if(cMiniLoop.hasParried){
            parry();
        }
        if(!cMiniLoop.miniOver){
            //Play mini-game
            cMiniLoop.play();
        }
        else{
            //Mini-game over
            miniGame = false;
            endGame  = true;

            //Make most recent symbol move
            if(cGraphics.symbols.size() > 0){
                float theta = random(iconLaunchAng.x, iconLaunchAng.y);
                float speed = random(iconLaunchSpd.x, iconLaunchSpd.y);
                cGraphics.symbols.get( cGraphics.symbols.size()-1 ).inMotion = true;
                cGraphics.symbols.get( cGraphics.symbols.size()-1 ).giveVel( new PVector(cos(theta), sin(theta)), speed );
            }
        }
    }
    void playEndGame(){
        if(!startNextGame){
            showResults();
        }
        else{
            endGame = false;
            preGame = true;
            resetAllValues();
        }
    }


    void showSymbols(){
        for(int i=0; i<cGraphics.symbols.size(); i++){
            cGraphics.symbols.get(i).display();
        }
    }
    void showScore(){
        pushStyle();

        textAlign(CENTER, CENTER);
        textSize(width/50.0);

        fill(0);

        PVector posZone  = new PVector(width/2.0, 2.0*height/30.0);
        int fTime        = 10*60;
        float amp        = width/80.0;
        float constant   = width/3.0;
        float separation = constant +amp*(sin( 2.0*PI*(frameCount%fTime)/fTime ));

        text("Player1 -> "+p1Score, posZone.x -separation, posZone.y);
        text("Player2 -> "+p2Score, posZone.x +separation, posZone.y);

        popStyle();
    }


    void chooseMiniGame(int gameNumber){
        boolean valid = ( 0 <= gameNumber) && (gameNumber <= miniMax);
        //Choose game
        if(valid){
            cMini = gameNumber;}
        else{
            cMini = floor(random(0,miniMax+1));}

        //Create game
        if(cMini == 0){
            cMiniLoop = new miniLoop_0();}
        if(cMini == 1){
            cMiniLoop = new miniLoop_1();}
        //...
    }
    void movePlayersIn(){
        moveSpeed = p1PosReq.x / animTime;
        p1Pos.x += moveSpeed;
        p2Pos.x -= moveSpeed;
    }
    boolean allPlayersHit(){
        if(p1HasHit && p2HasHit){
            return true;
        }
        else{
            return false;
        }
    }
    void calcIndicator(){
        if(!indicatorSent){
            if(gameTimer > animTime + graceTime){
                float rVal = random(0.0, 1.0);
                if(rVal < indicatorProb){
                    //Indicator goes off
                    indicator();
                }
            }
        }
    }
    void forcePlayerAttack(){
        attack("p1");
        attack("p2");
    }
    void determineMainStateResult(){
        int timeDiff = abs(p1HitTime - p2HitTime);
        if((timeDiff < parryTime) && (indicatorSent)){
            parry();
        }
        else{
            determineMainWinner();
            endGame = true;
        }
    }
    void indicator(){
        indicatorSound.play();
        PVector range = new PVector(width/8.0, height/8.0);
        cGraphics.createSymbol(indicatorIcon, new PVector(width/2.0 +random(-range.x, range.x), height/2.0 +random(-range.y, range.y)), new PVector(iconSize, iconSize) );
        //Make last symbol move
        if(cGraphics.symbols.size() > 1){
            float theta = random(iconLaunchAng.x, iconLaunchAng.y);
            float speed = random(iconLaunchSpd.x, iconLaunchSpd.y);
            cGraphics.symbols.get( cGraphics.symbols.size()-2 ).inMotion = true;
            cGraphics.symbols.get( cGraphics.symbols.size()-2 ).giveVel( new PVector(cos(theta), sin(theta)), speed );
        }
        indicatorSent = true;
    }
    void parry(){
        parrySound.play();
        chooseMiniGame(-1);
        PVector range = new PVector(width/6.0, height/6.0);
        cGraphics.createSymbol(parryIcon, new PVector(width/2.0 +random(-range.x, range.x), height/2.0 +random(-range.y, range.y)), new PVector(iconSize, iconSize) );
        //Make last symbol move
        if(cGraphics.symbols.size() > 1){
            float theta = random(iconLaunchAng.x, iconLaunchAng.y);
            float speed = random(iconLaunchSpd.x, iconLaunchSpd.y);
            cGraphics.symbols.get( cGraphics.symbols.size()-2 ).inMotion = true;
            cGraphics.symbols.get( cGraphics.symbols.size()-2 ).giveVel( new PVector(cos(theta), sin(theta)), speed );
        }
        playedMiniGame = true;
        miniGame = true;
    }
    void showResults(){
        pushStyle();

        imageMode(CENTER);
        rectMode(CENTER);
        textAlign(CENTER,CENTER);

        fill(0,255,0, 150);
        stroke(0);
        strokeWeight(2);

        PVector boxPos = new PVector(width/2.0, height/2.0);
        PVector boxDim = new PVector(width/5.0, 8.0*height/10.0);

        rect(boxPos.x, boxPos.y, boxDim.x, boxDim.y);

        fill(255);
        textSize(boxDim.x/5.0);
        if(playedMiniGame){
            text("Winner"                       , boxPos.x, boxPos.y -boxDim.y/10.0);
            text("Player "+str(cMiniLoop.winner), boxPos.x, boxPos.y +boxDim.y/10.0);
        }
        else{
            text(p1HitTime, boxPos.x-boxDim.x/4.0, boxPos.y-boxDim.y/4.0);
            text(p2HitTime, boxPos.x+boxDim.x/4.0, boxPos.y+boxDim.y/4.0);
        }

        popStyle();
    }
    void resetAllValues(){
        resetRoundValues();
        resetPlayerValues();
    }
    void resetRoundValues(){
        gameTimer = 0;

        playedMiniGame= false;
        indicatorSent = false;
        startNextGame = false;

        cGraphics.symbols.clear();
    }
    void resetPlayerValues(){
        p1Pos = new PVector(0     -p1Dim.x, p1PosReq.y);
        p2Pos = new PVector(width +p2Dim.x, p2PosReq.y);

        p1HasHit = false;
        p2HasHit = false;

        p1HitTime = 0;
        p2HitTime = 0;
    }
    void calcPlayerBasicAttack(){
        if(mouseX < width/2.0){
            attack("p1");
        }
        else{
            attack("p2");
        }
    }
    void attack(String player){
        attackSound.play();
        PVector range = new PVector(p1Dim.x/3.0, p1Dim.y/3.0);
        if(player == "p1"){
            p1HasHit = true;
            if(indicatorSent){
                p1HitTime = gameTimer;}
            else{
                p1HitTime = maxGameTime +1;}
            cGraphics.createSymbol(attackIcon, new PVector(p1PosReq.x +random(-range.x, range.x), p1PosReq.y +random(-range.y, range.y)), new PVector(iconSize, iconSize) );
        }
        if(player == "p2"){
            p2HasHit = true;
            if(indicatorSent){
                p2HitTime = gameTimer;}
            else{
                p2HitTime = maxGameTime +1;}
            cGraphics.createSymbol(attackIcon, new PVector(p2PosReq.x +random(-range.x, range.x), p2PosReq.y +random(-range.y, range.y)), new PVector(iconSize, iconSize) );
        }
        //Make last symbol move
        if(cGraphics.symbols.size() > 1){
            float theta = random(iconLaunchAng.x, iconLaunchAng.y);
            float speed = random(iconLaunchSpd.x, iconLaunchSpd.y);
            cGraphics.symbols.get( cGraphics.symbols.size()-2 ).inMotion = true;
            cGraphics.symbols.get( cGraphics.symbols.size()-2 ).giveVel( new PVector(cos(theta), sin(theta)), speed );
        }
    }
    void determineMainWinner(){
        /*
        Determines the winner of the MAIN game NOT mini games
        */
        //If not a draw
        if(p1HitTime != p2HitTime){
            if(p1HitTime < p2HitTime){
                p1Score++;}
            else{
                p2Score++;}
        }
    }


    void keyPressedManager(){
        //General Keys
        //...

        //Specific keys
        if(mainGame){
            calcPlayerBasicAttack();
        }
        if(miniGame){
            if(cMini == 0){
                //...
            }
            //...
        }
        if(endGame){
            startNextGame = true;
        }
    }
    void keyReleasedManager(){
        //General Keys
        //...

        //Specific keys
        if(mainGame){
            //...
        }
        if(miniGame){
            //GENERAL click command
            cMiniLoop.clickCommand();
            if(cMini == 0){
                //Anything additional and extra specific here (PROBABLY NOT NEEDED)
                //...
            }
            //...
        }
        if(endGame){
            //...
        }
    }
    void mousePressedManager(){
        //General Clicks
        //...

        //Specific Clicks
        if(mainGame){
            calcPlayerBasicAttack();
        }
        if(miniGame){
            //GENERAL click command
            cMiniLoop.clickCommand();
            if(cMini == 0){
                //Anything additional and extra specific here (PROBABLY NOT NEEDED)
                //...
            }
            //...
        }
        if(endGame){
            startNextGame = true;
        }
    }
    void mouseReleasedManager(){
        //General clicks
        //...

        //Specific clicks
        if(mainGame){
            //...
        }
        if(miniGame){
            if(cMini == 0){
                //...
            }
            //...
        }
        if(endGame){
            //...
        }
    }
}