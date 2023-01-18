void loadAll(){
    loadAllTextures();
    loadAllSounds();
}


void loadAllTextures(){
    loadTexturesCharacters();
    loadTexturesBackgrounds();
    loadTexturesIcons();
    loadTexturesMisc();
}
void loadAllSounds(){
    indicatorSound = new SoundFile(this, "indicator_sound.mp3");
    attackSound    = new SoundFile(this, "attack_sound.mp3");
    parrySound     = new SoundFile(this, "parry_sound.mp3");
    //gunshotSound   = new SoundFile(this, "gunshot_sound.mp3");

    windSound     = new SoundFile(this, "wind_sound.mp3");
}


void loadTexturesCharacters(){
    player1_0 = loadImage("player1_0.png");
    player2_0 = loadImage("player2_0.png");
}
void loadTexturesBackgrounds(){
    background0 = loadImage("background_0.png");
}
void loadTexturesIcons(){
    indicatorIcon   = loadImage("indicator_icon.png");
    attackIcon      = loadImage("hit_icon.png");
    parryIcon       = loadImage("parry_icon.png");
    crosshairsIcon  = loadImage("crosshairs_icon.png");
}
void loadTexturesMisc(){
    stage       = loadImage("stage.png");
    mini0Bar    = loadImage("mini0_bar.png");
}


//Textures
//-Characters
PImage player1_0;
PImage player2_0;
//-Backgrounds
PImage background0;
//-Icons
PImage indicatorIcon;
PImage attackIcon;
PImage parryIcon;
PImage crosshairsIcon;
//-Misc
PImage stage;
PImage mini0Bar;

//Sounds
SoundFile indicatorSound;
SoundFile attackSound;
SoundFile parrySound;
SoundFile gunshotSound;

SoundFile windSound;
