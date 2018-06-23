// import 'dart:math';
// import 'dart:html';

// import 'package:color/color.dart';

// class Control {
//   Point position;
//   RgbColor color;
//   num radius;

//   static const defaultColor = RgbColor(89, 79, 79);

//   Control(
//     this.position, {
//     this.color = defaultColor,
//     this.radius = 20,
//   });

//   void drawToContext(CanvasRenderingContext2D context) {
//     context.save();
//     context.fillStyle = color.toCssString();
//     context.beginPath();
//     context.arc(position.x, position.y, radius, 0, 2 * pi);
//     context.closePath();
//     context.fill();
//     context.restore();
//   }

//   bool hitTest(Point test) => this.position.distanceTo(test) <= this.radius;
// }
