final int WORDSIZE = 9; //designed to cap at 12, currenly goes from 3 to 9
int boxSize = 100; //could change for larger letter counts
char keyboard[] = {'Q','W','E','R','T','Y','U','I','O','P','A','S','D','F','G','H','J','K','L','Z','X','C','V','B','N','M'};
int timesLetterWasGuessed[] = new int[26]; //brute force method of checking for duplicates
int timesLetterIsPresent[] = new int[26]; //brute force method of checking for duplicates
KeyColor keyColors[] = new KeyColor[26];

LetterBlock [][] grid = new LetterBlock[6][WORDSIZE];

char [] word;
String [] words;
char [] guess = new char[WORDSIZE];
char [] lettersFound = new char[WORDSIZE]; //for checking repeat letters
int guessIndex = 0;
int foundLetterIndex = 0; //index of most recent letter added to correct guesses
//int guessedLetterIndex = 0; //index of letter being currently checked for duplication
int currentLine = 0;
char [] guessedLetters = new char[WORDSIZE]; //temporary for holding guessed letters to check for duplicates

void setup()
{
  size(1200,1000);
  textSize(35);
  rectMode(CENTER);
  for(int i = 0; i < WORDSIZE; i++)
    for(int j = 0; j < 6; j++)
      grid[j][i] = new LetterBlock();
  for(int i = 0; i < keyColors.length; i++)
    keyColors[i] = KeyColor.NONE;//color(#AAA897);
  
  word = new char[WORDSIZE];
  words = loadStrings(WORDSIZE + ".txt");
  for( int i = 0; i < words.length; i++ )
  {
    if( words[i].contains("-") )
    {
      String tempWord = "";
      for(int j = 0; j < words[i].length(); j++)
        if(words[i].charAt(j) != '-')
          tempWord += words[i].charAt(j);
      words[i] = tempWord;
    }
  }
  word = chooseRandomWord().toUpperCase().toCharArray();
  
  for(int i = 0; i < lettersFound.length; i++)
    lettersFound[i] = ' ';
  for(int i = 0; i < WORDSIZE; i++)
  {
    timesLetterIsPresent[ word[i]-65 ]++;
    guessedLetters[i] = ' ';
  }
  println(word);
  println(timesLetterIsPresent);
  
  resetGuess();
}

void draw()
{
  background(155);
  strokeWeight(2);
  stroke(50);
  drawGrid();
  drawKeyboard();
}

void drawKeyboard()
{
  for(int i = 0; i < 10; i++)
  {
    fill( getColor(keyColors[keyboard[i]-65]) );
    rect(60+(120*i),695,100,100,10);
    fill(0);
    text(keyboard[i],48+(120*i),705);
  }
  for(int i = 0; i < 9; i++)
  {
    fill( getColor(keyColors[keyboard[i+10]-65]) );
    rect(90+(120*i),815,100,100,10);
    fill(0);
    text(keyboard[i+10],78+(120*i),825);
  }
  for(int i = 0; i < 9; i++)
  {
    fill(#AAA897);
    if(i < 8)
    {
      fill( getColor(keyColors[keyboard[i+18]-65]) );
      if(i == 0) fill(#AAA897);
      rect(60+(120*i),935,100,100,10);
    }
    else
    {
      rect(60+(120*i)+60,935,200,100,10);
    }
  }
  fill(0);
  for(int i = 0; i < 7; i++)
    text(keyboard[i+19],168+(120*i),945);
  text("ENTER",1030,945);
  noFill(); stroke(0);
  beginShape();
  vertex(30,935);
  vertex(45,915);
  vertex(85,915);
  vertex(85,955);
  vertex(45,955);
  vertex(30,935);
  endShape();
  line(53,925,73,945);
  line(53,945,73,925);
}

void drawGrid()
{
  for(int i = 0; i < 6; i++)
  {
    if(currentLine==i)
      drawGuessBlocks(i,true);
    else
      drawGuessBlocks(i,false);
  }
}

void drawGuessBlocks( int row, boolean currentRow )
{
  if(currentRow)
    for(int i = 0; i < WORDSIZE; i++)
      grid[row][i].drawSingleBlock((width/2)-((WORDSIZE-1)*((boxSize)/2))+(i*(boxSize)),boxSize*(row+1)-20,guess[i]);
  else
    for(int i = 0; i < WORDSIZE; i++)
      grid[row][i].drawSingleBlock((width/2)-((WORDSIZE-1)*((boxSize)/2))+(i*(boxSize)),boxSize*(row+1)-20,grid[row][i].letter);
}

String chooseRandomWord()
{
  return words[int(random(words.length))].toUpperCase();
}

void mousePressed()
{
  println(mouseX + " " + mouseY);
}

void keyPressed()
{
  addLetter(key);
}

void addLetter( char c )
{
  if( c >= 97 && c <= 122 && guessIndex < WORDSIZE )
  {
    guess[guessIndex] = (char)(c-32);
    guessIndex++;
  }
  if( c == 8 && guessIndex > 0 )
  {
    guessIndex--;
    guess[guessIndex] = ' ';
  }
  if( c == ENTER && currentLine < 6 )
  {
    if(guessIndex==WORDSIZE && checkGuess() )
    {
      for(int i = 0; i < WORDSIZE; i++) //<>//
        grid[currentLine-1][i].letter = guess[i];
    }
    resetGuess();
    guessIndex = 0;
  }
}

void resetGuess()
{
  for(int i = 0; i < WORDSIZE; i++)
    guess[i] = ' ';
  foundLetterIndex = 0;
}

boolean checkGuess()
{
  if( isAWord(guess) )
  {
    for(int i = 0;i < timesLetterWasGuessed.length; i++)
      timesLetterWasGuessed[i]=0;
    for(int i = 0; i < WORDSIZE; i++)
    {
      if(guess[i] == word[i])
      {
        grid[currentLine][i].makeGreen();
        keyColors[guess[i]-65] = KeyColor.GREEN;
        lettersFound[foundLetterIndex] = guess[i];
        foundLetterIndex++;
        timesLetterWasGuessed[guess[i]-65]++;
      }
    }
    for(int i = 0; i < WORDSIZE; i++)
    {
      if( yellowFound( guess[i] ) && timesLetterWasGuessed[guess[i]-65] < timesLetterIsPresent[guess[i]-65])
      {
        grid[currentLine][i].makeYellow();
        if(keyColors[guess[i]-65] != KeyColor.GREEN)
          keyColors[guess[i]-65] = KeyColor.YELLOW;
        timesLetterWasGuessed[guess[i]-65]++;
      }
      else
      {
        grid[currentLine][i].makeGrey();
        if(keyColors[guess[i]-65] != KeyColor.GREEN && keyColors[guess[i]-65] != KeyColor.YELLOW)
          keyColors[guess[i]-65] = KeyColor.GREY;
      }
    }
    currentLine++;
    return true;
  }
  return false;
}

boolean isAWord( char [] w )
{
  String strWord = ""; //<>//
  for(int i = 0; i < w.length; i++)
    strWord += w[i];
  strWord = strWord.toLowerCase();
  for( String s: words )
    if( strWord.equals(s.toLowerCase()) )
      return true;
  return false;
}

boolean yellowFound( char c )
{
  for(int i = 0; i < WORDSIZE; i++)
    if( word[i] == c )
      return true;
  return false;
}

color getColor( KeyColor c )
{
  if( c == KeyColor.GREY )
    return color(100);
  if( c == KeyColor.YELLOW )
    return color(200,200,0);
  if( c == KeyColor.GREEN )
    return color(0,200,0);
  if( c == KeyColor.WHITE )
    return color(255);
  return color(#AAA897);
}

enum KeyColor
{
  NONE, GREY, YELLOW, GREEN, WHITE
}

class LetterBlock
{
  char letter;
  KeyColor col;
  
  public LetterBlock()
  {
    letter = ' ';
    col = KeyColor.WHITE;
  }
  
  void drawSingleBlock( float x, int y, char test )
  {
    fill( getColor(col) );
    rect(x,y,boxSize-1,boxSize-1,10);
    fill(9);
    text(test,x-12,y+10);
  }
  
  void makeYellow()
  {
    if( col != KeyColor.GREEN )
      col = KeyColor.YELLOW;
  }
  
  void makeGreen()
  {
    col = KeyColor.GREEN;
  }
  
  void makeGrey()
  {
    if( col != KeyColor.GREEN )
      col = KeyColor.GREY;
  }
}
