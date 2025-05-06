 part of 'main_helper.dart';


mixin MyResFont on _BaseResHelper {
  double scaleFraction = 1;
  double setWith(double w, {double? scaleFraction}) {
    scaleFraction = scaleFraction ?? this.scaleFraction;
    return  w * scaleFraction * (width / 375);
  }
  double setHeight(double h, {double? scaleFraction}) {
    scaleFraction = scaleFraction ?? this.scaleFraction;
    return  h * scaleFraction * (height  /700);
  }
  /// **Convert font size from design reference to scaled size**
  double setSp(double fontSize, {double? scaleFraction}) {
    final scaleText = min(width / 375, height / 300);
    final scaleFont = fontSize * scaleText;
    scaleFraction = scaleFraction ?? this.scaleFraction;
    return scaleFont * scaleFraction;
  }
  /// **Convert px to scalable font size (Step-based)**
  double setSpWithRange(double fontSize, { double maxFontSize = 24,
    double? scaleFraction
  }) {
    final scaleText = min(width / 500, min( height / 300,( 50*maxFontSize) /height));
    final scaleFont = fontSize * scaleText;
    scaleFraction = scaleFraction ?? this.scaleFraction;
    return ( scaleFont * scaleFraction );
  }



}


// part of 'main_helper.dart';
//
//
// mixin MyResFont on _BaseResHelper {
//   double scaleFraction = 0.5;
//   double setSp(double fontSize,{double? scaleFraction}) {
//     final scaleText =  min(width, height) ;
//     final scaleFont = fontSize * scaleText / 375;
//     scaleFraction =scaleFraction?? this.scaleFraction;
//     return (scaleFont * scaleFraction).floor() / scaleFraction;
//   }
//
//   /// **Convert px to scalable font size (Step-based)**
//    double setSpFromPx(num px, {double step = 0.5}) {
//      final scaleText =  min(width, height) ;
//      double dpValue = px / 3;
//     double scaledSize = dpValue * scaleText;
//
//     // Apply step control for smooth scaling
//     double adjustedSize = ((scaledSize / step).floor() * step).toDouble();
//
//     return adjustedSize;
//   }
//
// }
//



