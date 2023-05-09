import 'package:flutter/material.dart';
import 'package:myapp/Models/menuList.dart';

/*class MenuPageModel extends ChangeNotifier{
  late MenuList _menuList;

  final List<int> _menuIds =[];

  MenuList get menulist => _menuList;

  set menulist(MenuList newList){
    _menuList = newList;
    notifyListeners();
  }

  List<Menu> get menus =>
      _menuIds.map((id) => _menuList.getById(id)).toList();

  void add(Menu menu){
    _menuIds.add(menu.id);
    notifyListeners();
  }

  void remove(Menu menu){
    _menuIds.remove(menu.id);
    notifyListeners();
  }

}*/