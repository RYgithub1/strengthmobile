import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';


void main() async{
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode)
      exit(1);
  };
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(StrengthMobile());
}


//【アプリ全体】
class StrengthMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Strength Recruiting Mobile',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StrengthListPage(),
    );

  }
}



//【一覧画面】
class StrengthListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STRENGTH  RECRUITING  MOBILE'),
      ),
      body: StreamBuilder<QuerySnapshot>(  // StreamBuilderで受け取り
          stream: FirebaseFirestore.instance.collection("videos").snapshots(),
          builder: (context, snapshot) {  // snapshots()を指定 -> 更新時にbuilderの中身が動く
            if (snapshot.connectionState == ConnectionState.active){

              return ListView.builder(  // builder:データを元に、ListViewを作成buildする
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {

                  final video = snapshot.data.docs[index].data();  // docsドキュメントに複数データ
                  // video変数から中身を取り出して、ListView。（キー）保存時videoUrlやtext
                  // video["videoUrl"]
                  // video["text"]

                  return Card(
                    child: ListTile(
                      title: Text(video["text"]),
                      trailing: Icon(Icons.play_circle_filled),
                      onTap: () async{
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return VideoPage();
                          }),
                        );
                      },
                    ),
                  );
                },
              );
            }else{
              return Center(child: CircularProgressIndicator());
            }
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return StrengthAddPage();
            }),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}



//【追加画面】
class StrengthAddPage extends StatefulWidget {
  @override
  _StrengthAddPageState createState() => _StrengthAddPageState();
}

class _StrengthAddPageState extends State<StrengthAddPage> {
  String _text = '';  // textデータ格納用
  File _videoFile;  // File形式で定義

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ADD  STRENGTH'),
      ),
      body: Container(
        padding: EdgeInsets.all(64),
        child: ListView(
          children: <Widget>[

            // ----- データ追加 -----
            // 《動画選択ボタン(imagePicker)》
            RaisedButton(
              color: Colors.orange,
              child: Text("input > video", style: TextStyle(color: Colors.white)),
              onPressed:() async{
                final pickedVideo = await ImagePicker().getVideo(source: ImageSource.gallery);  // ギャラリーから取得
                _videoFile = File(pickedVideo.path);  // path指定 -> File取得
                setState((){});  // State変更通知 -> ファイル形式でfirebaseへ
              },
            ),

            // 《テキスト記入内容》
            Text(_text, style: TextStyle(color: Colors.orange),),


            // 《テキスト記入》
            TextField(
              onChanged: (String value) {  // 記入テキストをvalueで受け取り
                setState(() {  // データ変更通知と画面更新
                  _text = value;  // データ変更
                });
              },
              decoration: InputDecoration(
                labelText: "input > text",
                hintText: "Hint: Strength",
              ),
            ),

            // 《選択動画と記入テキストを、Firebaseのコレクションに追加するボタン》
            Container(
              width: double.infinity,
              child: RaisedButton(
                color: Colors.orange,
                onPressed: () async{
                  // [Idの定義]
                  final videoId = FirebaseFirestore.instance.collection("videos").doc().id;  // ランダム文字列idをvideoId ->名
                  // [Storage]
                  final ref = FirebaseStorage().ref().child("videos/$videoId.mp4");
                  final task = ref.putFile(  // putFileでFileのメタデータ拡張子修正
                    _videoFile,
                    StorageMetadata(contentType: "video/mp4"),
                  );
                  await task.onComplete;  // Storageへ保存完了(mp4)
                  // [FireStore]
                  final url = await ref.getDownloadURL();  //Firebase上での動画の場所を示すURLを取得
                  await FirebaseFirestore.instance.collection("videos").doc(videoId)
                      .set({  // add -> set に修正
                        "text": _text,
                        "videoUrl": url,
                      });  // FireStoreへの保存完了(text,videoUrl)
                  Navigator.of(context).pop();
                },
                child: Text('add', style: TextStyle(color: Colors.white)),
              ),
            ),


            // ----- キャンセル -----
            Container(
              width: double.infinity,
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// 【動画画面】
class VideoPage extends StatefulWidget {
  VideoPage({Key key}) : super(key: key);
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  // 《initState()》
  @override
  void initState() {
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    super.initState();
  }

  // 《build()》
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STRENGTH  VIDEO'),
      ),
      body: FutureBuilder(  // FutureBuilder：VideoPlayerControllerの初期化中にloading spinnerを表示
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {  // 動画の再生休止状態について変更通知
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  // 《dispose()》
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
