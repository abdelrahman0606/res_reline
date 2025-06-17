import 'package:flutter/material.dart';

class ResContext{
  final BuildContext _context;

  ResContext(this._context);

  MediaQueryData get mediaQuery => MediaQuery.of(_context);

  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  double get aspectRatio => mediaQuery.size.aspectRatio;

  Size? _pageSize;

  set resize(Size? value) => _pageSize = value;
}