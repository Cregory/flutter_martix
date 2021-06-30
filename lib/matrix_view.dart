import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'bitmap.dart';

class MatrixView extends StatefulWidget {
  MatrixView({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => MatrixViewState();
}

class MatrixViewState extends State<MatrixView>
    with SingleTickerProviderStateMixin {
  double x = -1, y = -1;
  int displayCountX = 15, displayCountY = 15;
  int hideCountX = 0, hideCountY = 0;
  late Bitmap bitmap;
  bool isTouch = false;
  late int tempX, tempY;
  late int tempHideX,tempHideY;
  late double tempPosX, tempPosY;
  int value = 1;
  Color color = Colors.black;

  MatrixViewState() {
    bitmap = Bitmap.fillWhite(60, 60);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text('涂抹：'),
              Radio(
                  value: 1,
                  groupValue: this.value,
                  onChanged: (value) {
                    setState(() {
                      this.value = value as int;
                    });
                  }),
              SizedBox(
                width: 20,
              ),
              Text('操作：'),
              Radio(
                  value: 2,
                  groupValue: this.value,
                  onChanged: (value) {
                    setState(() {
                      this.value = value as int;
                    });
                  }),
              SizedBox(
                width: 20,
              ),
              TextButton(onPressed: () {setState(() {
                bitmap = Bitmap.fillWhite(60, 60);
              }); }, child: Text('重置'))
            ],
          ),
          buildColorSelect1(),
          buildColorSelect2(),
          Expanded(
              child: Center(
            child: buildMatrix(size, bitmap),
          )),
          // Container(
          //     padding:EdgeInsets.only(top: 20),
          //     width: size.width / 4 * 3 ,
          //     color:Colors.red,
          //     child: Slider(value: hideCountX.toDouble(),onChanged: (value){
          //       setState(() {
          //         hideCountX = value.toInt();
          //       });
          //     },max: (bitmap.column - displayCountX).toDouble(),)
          // ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: CustomPaint(
              size: Size(size.height / 5, size.height / 5),
              painter: MatrixPreviewPainter(
                  bitmap, displayCountX, displayCountY, hideCountX, hideCountY),
            ),
          )
        ],
      )),
    );
  }

  Widget buildMatrix(Size size, Bitmap bitmap) => GestureDetector(
        onPanStart: this.value == 1
                ? (detail) {
                    isTouch = true;
                  }
                : null,
        onPanUpdate: this.value == 1
                ? (detail) {
                    setState(() {
                      x = detail.localPosition.dx;
                      y = detail.localPosition.dy;
                    });
                  } : null,
        onPanEnd: this.value == 1
            ? (detail) {
                isTouch = false;
              }
            : null,
        onScaleStart: this.value == 2
            ? (detail) {
                tempX = displayCountX;
                tempY = displayCountY;
                tempPosX = detail.focalPoint.dx;
                tempPosY = detail.focalPoint.dy;
                tempHideX = hideCountX;
                tempHideY = hideCountY;
              }
            : null,
        onScaleUpdate: this.value == 2
            ? (detail) {
                setState(() {
                  double side = size.width / displayCountX;
                  int sX = tempHideX - (detail.focalPoint.dx - tempPosX) ~/ side;
                  int sY = tempHideY - (detail.focalPoint.dy - tempPosY) ~/ side;
                  if (sX >= 0 && sX <= bitmap.column - displayCountX) {
                    hideCountX = sX;
                  }
                  if (sY >= 0 && sY <= bitmap.row - displayCountY) {
                    hideCountY = sY;
                  }
                  //上面是移动操作
                  //下面是缩放操作
                  int x = tempX ~/ detail.scale;
                  int y = tempY ~/ detail.scale;
                  if (x < 1 || x > bitmap.column || y < 1 || y > bitmap.row)
                    return;
                  displayCountX = x;
                  displayCountY = y;
                  if(displayCountX + hideCountX > bitmap.column){
                    hideCountX = bitmap.column - displayCountX;
                  }
                  if(displayCountY + hideCountY > bitmap.row){
                    hideCountY = bitmap.row - displayCountY;
                  }
                });
              }
            : null,
        child: CustomPaint(
          size: Size(size.width / 4 * 3, size.width / 4 * 3),
          painter: MatrixViewPainter(x, y, bitmap, displayCountX, displayCountY,
              hideCountX, hideCountY, isTouch,color),
        ),
      );

  Widget buildColorSelect1() => Row(
      children: [
        Text('黑'),
        Radio(value: Colors.black, groupValue: this.color, onChanged: (value) {setState(() {this.color = value as Color;});}),
        Text('白'),
        Radio(value: Colors.white, groupValue: this.color, onChanged: (value) {setState(() {this.color = value as Color;});}),
        Text('红'),
        Radio(value: Colors.red, groupValue: this.color, onChanged: (value) {setState(() {this.color = value as Color;});}),
        Text('绿'),
        Radio(value: Colors.green, groupValue: this.color, onChanged: (value) {setState(() {this.color = value as Color;});}),
      ],
  );

  Widget buildColorSelect2() => Row(
    children: [
      Text('蓝'),
      Radio(value: Colors.blue, groupValue: this.color, onChanged: (value) {setState(() {this.color = value as Color;});}),
      Text('黄'),
      Radio(value: Colors.yellow, groupValue: this.color, onChanged: (value) {setState(() {this.color = value as Color;});}),
      Text('青'),
      Radio(value: Colors.cyan, groupValue: this.color, onChanged: (value) {setState(() {this.color = value as Color;});}),
      Text('紫'),
      Radio(value: Colors.purple, groupValue: this.color, onChanged: (value) {setState(() {this.color = value as Color;});}),
    ],
  );
}

class MatrixViewPainter extends CustomPainter {
  late double width, height;
  late double side; //矩阵格边长
  int displayX; //X轴显示的格数
  int displayY; //Y轴显示的格数
  double margin = 2; //格子边宽
  late Paint mRedPaint;
  Paint matrixPaint = Paint()..color = Colors.black;
  Bitmap bitmap;
  late double x, y;
  int hideCountX, hideCountY;
  bool isTouch;
  Color pixelColor;

  MatrixViewPainter(this.x, this.y, this.bitmap, this.displayX, this.displayY,
      this.hideCountX, this.hideCountY, this.isTouch,this.pixelColor) {
    mRedPaint = Paint()
      ..isAntiAlias = true
      ..color = Color(0xFF202020)
      ..style = PaintingStyle.stroke
      ..strokeWidth = margin;
  }

  @override
  void paint(Canvas canvas, Size size) {
    width = size.width;
    side = width / displayX;
    margin = side / 10;
    drawMatrix(canvas);
    addPixel(size);
    drawPixels(canvas);
  }

  void drawMatrix(Canvas canvas) {
    double lastX = 0;
    for (int i = 0; i <= displayX; i++) {
      canvas.drawLine(
          Offset(lastX, 0), Offset(lastX, displayY * side), mRedPaint);
      lastX += side;
    }
    double lastY = 0;
    for (int i = 0; i <= displayY; i++) {
      canvas.drawLine(
          Offset(0, lastY), Offset(displayX * side, lastY), mRedPaint);
      lastY += side;
    }
  }

  void drawPixels(Canvas canvas) {
    Paint transPaint = Paint();
    for (int i = hideCountX; i < hideCountX + displayX; i++) {
      for (int j = hideCountY; j < hideCountY + displayY; j++) {
        transPaint.color = bitmap.getPixel(i, j);
        canvas.drawRect(
            Rect.fromLTRB(
                (i - hideCountX) * side + margin / 2,
                (j - hideCountY) * side + margin / 2,
                (i - hideCountX + 1) * side - margin / 2,
                (j - hideCountY + 1) * side - margin / 2),
            transPaint);
      }
    }
  }

  void addPixel(Size size) {
    if (x >= size.width || y >= size.height || x <= 0 || y <= 0 || !isTouch)
      return;
    int focusX = x ~/ side;
    int focusY = y ~/ side;
    bitmap.setPixel(focusX + hideCountX, focusY + hideCountY, this.pixelColor);
  }

  @override
  bool shouldRepaint(MatrixViewPainter oldDelegate) => true;
}

class MatrixPreviewPainter extends CustomPainter {
  Bitmap bitmap;
  int displayCountX, displayCountY;
  int hideCountX, hideCountY;

  MatrixPreviewPainter(this.bitmap, this.displayCountX, this.displayCountY,
      this.hideCountX, this.hideCountY);

  @override
  void paint(Canvas canvas, Size size) {
    double sideX = size.width / bitmap.column;
    double sideY = size.height / bitmap.row;
    double side = math.min(sideX, sideY);
    double trueWidth = side * bitmap.column;
    double trueHeight = side * bitmap.row;
    double paddingX = (size.width - trueWidth) / 2;
    double paddingY = (size.height - trueHeight) / 2;

    Paint pixelPainter = Paint();
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        pixelPainter..color = Color(0xFF202020));
    for (int i = 0; i < bitmap.column; i++) {
      for (int j = 0; j < bitmap.row; j++) {
        pixelPainter.color = bitmap.getPixel(i, j);
        canvas.drawRect(
            Rect.fromLTWH(i * side + paddingX, j * side + paddingY, side, side),
            pixelPainter);
      }
    }
    pixelPainter.color = Colors.green;
    canvas.drawLine(
        Offset(paddingX + hideCountX * side, paddingY + hideCountY * side),
        Offset(paddingX + hideCountX * side,
            paddingY + (hideCountY + displayCountY) * side),
        pixelPainter);
    canvas.drawLine(
        Offset(paddingX + (hideCountX + displayCountX) * side,
            paddingY + hideCountY * side),
        Offset(paddingX + (hideCountX + displayCountX) * side,
            paddingY + (hideCountY + displayCountY) * side),
        pixelPainter);
    canvas.drawLine(
        Offset(paddingX + hideCountX * side, paddingY + hideCountY * side),
        Offset(paddingX + (hideCountX + displayCountX) * side,
            paddingY + hideCountY * side),
        pixelPainter);
    canvas.drawLine(
        Offset(paddingX + hideCountX * side,
            paddingY + (hideCountY + displayCountY) * side),
        Offset(paddingX + (hideCountX + displayCountX) * side,
            paddingY + (hideCountY + displayCountY) * side),
        pixelPainter);
  }

  @override
  bool shouldRepaint(MatrixPreviewPainter oldDelegate) => true;
}

class TracePath {
  List<Offset> offsets = [];
}
