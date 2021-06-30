
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Bitmap {
  late List<Color> pixels;
  int row;//行
  int column;//列

  Bitmap.fillWhite(this.column,this.row){
    pixels = List.filled(row * column, Colors.white);
  }

  Bitmap.fillBlack(this.column,this.row){
    pixels = List.filled(row * column, Colors.black);
  }

  Color getPixel(int x,int y){
    return pixels[y * column + x];
  }

  void setPixel(int x,int y,Color color){
    pixels[y * column + x] = color;
  }
}