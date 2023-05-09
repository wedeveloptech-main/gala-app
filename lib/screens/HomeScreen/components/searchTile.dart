import 'package:flutter/material.dart';
import 'package:myapp/Models/SearchData.dart';

class SearchTile extends StatelessWidget {
  final SearchData search;

  const SearchTile({Key? key, required this.search}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SearchData>(
      builder: (context, snapshot) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: Hero(
                  tag: search,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data!.data[index].thumb.toString()),
                  ),
                ),
                title: Text(snapshot.data!.data[index].prodName),
                onTap: () {},
              );
            },
          ),
        );
      },
    );
  }
}
