import 'package:flutter/material.dart';

enum Tetromino{
  L,
  J,
  I,
  O,
  S,
  Z,
  T,
}

enum Direction{
  left,
  right,
  down,
}


  //grid dimentions
  int rowLength = 10;
  int columnLength = 15;

  const Map<Tetromino, Color> tetrominoColors = {
    Tetromino.L: Colors.orange,
    Tetromino.J: Colors.blue,
    Tetromino.I: Colors.cyan,
    Tetromino.O: Colors.yellow,
    Tetromino.S: Colors.green,
    Tetromino.Z: Colors.red,
    Tetromino.T: Color.fromARGB(255, 255, 83, 140),
  };