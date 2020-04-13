import 'package:flutter/material.dart';

class PageIndicatorProvider extends ChangeNotifier{
  int _selectedIndex = 0;

  void setSelectedIndex(int index){
    _selectedIndex = index;
    notifyListeners();
  }

  int get selectedIndex => _selectedIndex;
}