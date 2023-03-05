import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  ImageScreen({Key? key, required this.image, required this.index})
      : super(key: key);
  Widget image;
  int index;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Hero(
            tag: widget.index.toString(),
            child:
                Material(type: MaterialType.transparency, child: widget.image)),
      ),
    );
  }
}
