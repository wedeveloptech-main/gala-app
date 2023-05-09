import 'package:flutter/material.dart';

class RatingDialogBox extends StatefulWidget {
  @override
  _RatingDialogBoxState createState() => _RatingDialogBoxState();
}

class _RatingDialogBoxState extends State<RatingDialogBox> {
  int _stars = 0;

  Widget _buildStar(int starCount) {
    return InkWell(
      child: Icon(
        Icons.star,
        // size: 30.0,
        color: _stars >= starCount ? Colors.orange : Colors.grey,
      ),
      onTap: () {
        setState(() {
          _stars = starCount;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Rate This App'),),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildStar(1),
          _buildStar(2),
          _buildStar(3),
          _buildStar(4),
          _buildStar(5),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: Navigator.of(context).pop,
        ),
        TextButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop(_stars);
          },
        )
      ],
    );
  }
}