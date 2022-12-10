class graphics{
    ArrayList<symbol> symbols = new ArrayList<symbol>();

    PImage p1Icon;
    PImage p2Icon;

    graphics(){
        //pass
    }

    void display(PVector p1Pos, PVector p2Pos, PVector p1Dim, PVector p2Dim, boolean gameOver){
        displayBackground();
        displayPlayers(p1Pos, p2Pos, p1Dim, p2Dim);
        displaySymbols();

        animateSymbols(gameOver);

        overlay();
    }
    void displayBackground(){
        pushStyle();

        imageMode(CENTER);

        //background(60,60,60);
        image(background0, width/2.0, height/2.0, 20.0*height/9.0, height);
        
        popStyle();
    }
    void displayPlayers(PVector p1Pos, PVector p2Pos, PVector p1Dim, PVector p2Dim){
        pushStyle();

        imageMode(CENTER);
        fill(255);

        //ellipse(p1Pos.x, p1Pos.y, p1Dim.x, p1Dim.y);
        image(stage, p1Pos.x, p1Pos.y +p1Dim.y/5.0, p1Dim.x, p1Dim.y);
        image(player1_0, p1Pos.x, p1Pos.y, p1Dim.x, p1Dim.y);

        //ellipse(p2Pos.x, p2Pos.y, p2Dim.x, p2Dim.y);
        image(stage, p2Pos.x, p2Pos.y +p2Dim.y/5.0, p2Dim.x, p2Dim.y);
        image(player2_0, p2Pos.x, p2Pos.y, p2Dim.x, p2Dim.y);

        popStyle();
    }
    void displaySymbols(){
        for(int i=0; i<symbols.size(); i++){
            symbols.get(i).display();
        }
    }


    void animateSymbols(boolean gameOver){
        /*
        Animate...
        While in play   -> All except most recent
        End of game     -> All
        */
        for(int i=0; i<symbols.size(); i++){
            symbols.get(i).calcDynamics();
        }
    }


    void createSymbol(PImage icon, PVector pos, PVector dim){
        symbol newSymbol = new symbol(icon, pos, dim);
        symbols.add(newSymbol);
    }


    void overlay(){
        pushStyle();
        fill(255);
        textAlign(CENTER,CENTER);
        textSize(20);

        text(frameRate, 40,20);

        popStyle();
    }
}