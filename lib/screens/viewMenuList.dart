import 'package:flutter/material.dart';
import 'package:myapp/Models/menuPageModel.dart';
import 'package:myapp/constants/color.dart';
import 'package:provider/provider.dart';

/*class ViewMenuList extends StatelessWidget {
  const ViewMenuList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu',),
      ),
      body: Container(
        color: kwhite,
        child: Column(
          children: [
            Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: _ViewMenuList(),
                )
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewMenuList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var menuNameStyle = Theme.of(context).textTheme.headline6;
    var menupage = context.watch<MenuPageModel>();

    return ListView.builder(
      itemCount: menupage.menus.length,
      itemBuilder: (context,index) => ListTile(
        leading: Image.asset(menupage.menus[index].image),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: (){
            menupage.remove(menupage.menus[index]);
          },
        ),
        title: Text(
          menupage.menus[index].name, style: menuNameStyle,
        ),
      ),
    );
  }
}*/
