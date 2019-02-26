import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(App());

final baseUrl = "https://picsum.photos/200/200?image=";

class App extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.amber,),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Img>> imgList;

  @override
  void initState() {
    super.initState();
    imgList = fetchImages();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: FutureBuilder<List<Img>>(
        future: imgList,
        builder: (ctx, snapshot) {
          Widget bodyContentSliver;
          if(snapshot.hasData) {
            final List<Img> images = snapshot.data;
            bodyContentSliver = SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (BuildContext ctx, int index) {
                  return GestureDetector(child: GridTile(
                    child: Hero(
                      tag: 'IMG_${images[index].id}',
                      child: Image.network(
                        baseUrl + '${images[index].id}',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      )
                    ),
                  ),
                  onTap: () {
                    Navigator.push(ctx,
                      MaterialPageRoute(builder: (ctx) => Details(
                          images: images, currImgIdx: index,)
                      )
                    );
                  },);
                },
                childCount: images.length
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              )
            );
          } else {
            bodyContentSliver = SliverToBoxAdapter(
              child: Container(
                height: 500.0,
                child: Center(
                  child: snapshot.hasError ? Text("Something went wrong.")
                    : CircularProgressIndicator(),
                )
              )
            );
          }

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Image Gallery'),
                  centerTitle: true,
                ),
              ),
              bodyContentSliver
            ],
          );
        },
      ),
    );
  }

  Future<List<Img>> fetchImages() async {
    final response = await http.get('https://picsum.photos/list');

    if (response.statusCode == 200) {
      List images = json.decode(response.body);
      return images.map((m) => new Img.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }
}

class Details extends StatefulWidget {
  Details({Key key, this.images, this.currImgIdx}) : super(key: key);

  final List<Img> images;
  final int currImgIdx;

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext ctx) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      body: PageView.builder(
        itemCount: widget.images.length,
        controller: PageController(
          initialPage: widget.currImgIdx,
        ),
        itemBuilder: (ctx, position) {
          final Img currImg = widget.images[position];
          return Center(
            child: Hero(
              tag: 'IMG_${currImg.id}',
              child: Image.network(
                baseUrl + '${currImg.id}',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
              )
            ),
          );
        }
      ),
    ));
  }
}

class Img {
  final int id;

  Img({this.id});

  factory Img.fromJson(Map<String, dynamic> json) {
    return Img(id: json['id'],);
  }
}
