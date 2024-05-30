import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tetris/piece.dart';
import 'package:tetris/pixel.dart';
import 'package:tetris/values.dart';

/*
 2 X 2 grid with null representing initial values
 a non empty space will hv the color to represent the landed piece
*/

//create game board
List<List<Tetromino?>> gameBoard = List.generate(
  columnLength,
  (i) => List.generate(rowLength, (j) => null),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //current tetris piece
  Piece currentPiece = Piece(type: Tetromino.L);

  int currentScore = 0;
  bool gameOver = false;

  @override

  //initialize the piece
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();

    Duration framerate = Duration(milliseconds: (currentScore > 6) ? 300 : 500);
    gameLoop(framerate);
  }

  void gameLoop(Duration framerate) {
    Timer.periodic(framerate, (timer) {
      //gets executed every 400 ms
      setState(() {
        clearLines(); //to increase points
        //check landing
        checkLanding();
        //checck game over
        if (gameOver == true) {
          timer.cancel();
          showGameOverDialog();
        }
        //move current piece down
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  //game over msg
  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'GAME OVER',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(183, 28, 28, 1)),
        ),
        content: Text(
          'Your score: $currentScore',
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 18,
            color: Colors.deepPurple,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                resetGame();
                Navigator.pop(context);
              },
              child: const Text(
                "Play Again",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  
                  color: Colors.deepPurple,
                ),
              ))
        ],
      ),
    );
  }

  //reset game
  void resetGame() {
    gameBoard = List.generate(
      columnLength,
      (i) => List.generate(rowLength, (j) => null),
    );
    //new game reset
    gameOver = false;
    currentScore = 0;
    createNewPiece();
    startGame();
  }

  //check collision on ground
  //return true if collides
  //returns false if no collides
  bool checkCollision(Direction direction) {
    //loop thru each position of current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      //calculate row and col of current piece
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = (currentPiece.position[i] % rowLength);

      //adjust row or direction according to arguement
      if (direction == Direction.down) {
        row += 1;
      } else if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      }

      //check if its out of bounds
      if (row >= columnLength ||
          col < 0 ||
          col >= rowLength ||
          (row >= 0 && gameBoard[row][col] != null)) {
        return true;
      }
    }
    return false;
  }

  void checkLanding() {
    //check if piece has landed
    if (checkCollision(Direction.down)) {
      //stop the timer
      //check if the piece has landed
      //if landed, then initialize a new piece
      //if not, then game over
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = (currentPiece.position[i] % rowLength);
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      createNewPiece();
    }
  }

  void createNewPiece() {
    //create random
    Random rand = Random();
    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();
    // // Check if the new piece can be placed on the board
    // for (int i = 0; i < currentPiece.position.length; i++) {
    //   int row = (currentPiece.position[i] / rowLength).floor();
    //   int col = (currentPiece.position[i] % rowLength);
    //   if (row >= 0 && gameBoard[row][col] != null) {
    //     // Handle game over
    //     print("Game Over");
    //     // Stop the game loop or reset the game
    //     return;
    //   }
    // }
    if (isGameOver()) {
      gameOver = true;
    }
  }

  void moveLeft() {
    //make sure move is valid
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotate() {
    setState(() {
      currentPiece.pieceRotate();
    });
  }

  void clearLines() {
    //loop from bottom
    for (int row = columnLength - 1; row >= 0; row--) {
      //initialize a variable to check if the row is full
      bool rowIsFull = true;
      //check if the row is full
      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }
      //if the row is full, shift the row and shift rows down
      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          //copy the above row to current row
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        //set the top row to be empty
        gameBoard[0] = List.generate(row, (index) => null);
        currentScore++;
      }
    }
  }

  //GAME OVER METHOD
  bool isGameOver() {
    //check if any columns in the top are filled
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: 150,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowLength),
              itemBuilder: (context, index) {
                int row = (index / rowLength).floor();
                int col = (index % rowLength);
                if (currentPiece.position.contains(index)) {
                  //index present in current piece position list
                  return Pixel(color: currentPiece.color);
                } else if (gameBoard[row][col] != null) {
                  final Tetromino? tetrominoType = gameBoard[row][col];
                  return Pixel(color: tetrominoColors[tetrominoType]);
                } else {
                  return Pixel(color: Colors.grey[900]);
                }
              },
            ),
          ),

          //score
          Container(
            height: 50,
            width: 90,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[850],
            ),
            child: Center(
              child: Text(
                'Score: $currentScore',
                style: const TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 16),
              ),
            ),
          ),

          //game controls

          //left
          Padding(
            padding: const EdgeInsets.only(bottom: 75, top: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: moveLeft,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
                //right
                IconButton(
                  onPressed: rotate,
                  icon: const Icon(
                    Icons.rotate_right_rounded,
                    color: Colors.white,
                  ),
                ),

                //rotate
                IconButton(
                  onPressed: moveRight,
                  icon: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
