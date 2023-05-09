import 'package:flutter/material.dart';
import 'package:myapp/Models/menuList.dart';
import 'package:myapp/Models/menuPageModel.dart';
import 'package:myapp/screens/viewMenuList.dart';
import 'package:provider/provider.dart';

/*class CreateMenuList extends StatelessWidget {
  const CreateMenuList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Add To Menu',),
            floating: true,
            actions: [
              IconButton(onPressed: () /*{
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMenuList(),
                    ));
              },*/
    {
      Navigator.pushNamed(context, '/menupage');
    },

                  icon: Icon(Icons.add))
            ],
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12,)),
          SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index){
                return _MyListItem(index);
              },
              childCount: 15,
              ),
          ),
        ],
      ),
    );
  }
}

class _MyListItem extends StatelessWidget {
  final int index;

  const _MyListItem(this.index, {Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    var menu = context.select<MenuList, Menu>(
        (menulist) => menulist.getByPosition(index),
    );
    var textTheme = Theme.of(context).textTheme.headline6;

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LimitedBox(
        maxHeight: 60,
        child: Row(
          children: [
            AspectRatio(
                aspectRatio: 1,
              child: Image.asset(menu.image),
            ),
            SizedBox(width: 15,),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(menu.name, style: textTheme,)
                  ],
                ),
            ),
            SizedBox(width: 24,),
            _AddButton(menu: menu),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget{
  final Menu menu;
  
  const _AddButton({required this.menu, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context){
    
    var isInViewMenuList = context.select<MenuPageModel, bool>(
        (menupage) => menupage.menus.contains(menu),
    );
    
    return IconButton(
        icon: isInViewMenuList
      ? Icon(Icons.dangerous_outlined, color: Colors.red,)
            : Icon(Icons.add_circle_outline, color: Colors.green,),
      onPressed: isInViewMenuList
        ? () {
          var menupage = context.read<MenuPageModel>();
          menupage.remove(menu);
      }
      : () {
        var menupage = context.read<MenuPageModel>();
        menupage.add(menu);
      }
    );
  }
}*/
