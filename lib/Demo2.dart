import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:myapp/Demo1.dart';

class Demo2 extends StatefulWidget {
  const Demo2(
      {Key? key, required this.favoriteIds, required this.favoriteItems})
      : super(key: key);

final List<String> favoriteItems;
final List<String> favoriteIds;

  @override
  State<Demo2> createState() => _Demo2State();
}

class _Demo2State extends State<Demo2> {
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              assetsAudioPlayer.stop();
              Navigator.of(context).pop();
            }),
        title: Text('Add To List'),
        actions: [
          IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                assetsAudioPlayer.stop();
                //Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Demo1(),
                  ),);
              }),
        ],
      ),
      body: ListView.separated(
        itemCount: widget.favoriteItems.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) => ListTile(
          title: Text(widget.favoriteItems[index]),
          onTap: () {
            print(widget.favoriteIds[index]);
            cal(widget.favoriteIds[index].toString());
          },
          /* trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? Colors.red : null,
                    size: 20.0,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isSaved) {
                        favoriteItems.remove(word);
                      } else {
                        favoriteItems.add(word);
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    size: 20.0,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    //   _onDeleteItemPressed(index);
                  },
                ),
              ],
            ),
            onTap: () {
              cal(index.toString());
            }*/
        ),
      ),
    );
  }

  cal(String id) {
    assetsAudioPlayer.stop();
    assetsAudioPlayer.open(Audio("assets/" + id + ".mp3"));
  }
}
