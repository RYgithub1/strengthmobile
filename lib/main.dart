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
      title: 'StrengthRecruitingMobile',
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
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active){

              return ListView.builder(  // builderでデータを元にListViewを作成
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {

                  final video = snapshot.data.docs[index].data();  // docsドキュメントに複数データ
                  return Card(  // video変数の中身をListView。（キー）保存時videoUrlやtext
                    child: ListTile(
                      title: Text(video["text"]),
                      trailing: Icon(Icons.play_circle_filled),
                      onTap: () async{
                        await Navigator.of(context).push(
                          // context,
                          MaterialPageRoute(builder: (context) {
                            return VideoPage(videoU: video["videoUrl"]);  // namedパラメーター
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
  String _text = '';
  File _videoFile;

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
                final pickedVideo = await ImagePicker().getVideo(source: ImageSource.gallery);  // ギャラリー指定
                _videoFile = File(pickedVideo.path);  // path指定、File取得
                setState((){});  // State変更通知
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
                  final videoId = FirebaseFirestore.instance.collection("videos").doc().id;  // ランダム文字列idをvideoId->名
                  // [Storage]
                  final ref = FirebaseStorage().ref().child("videos/$videoId.mp4");
                  final task = ref.putFile(  // Storageへアップロード開始(mp4)
                    _videoFile,
                    StorageMetadata(contentType: "video/mp4"),
                  );
                  await task.onComplete;  // Storageへアップロー完了(mp4)
                  // [FireStore]
                  final url = await ref.getDownloadURL();  //Firebase上での動画の場所を示すURLを取得
                  await FirebaseFirestore.instance.collection("videos").doc(videoId)
                      .set({
                        "text": _text,
                        "videoUrl": url,
                      });  // FireStoreへの保存完了(text,videoUrl)
                  Navigator.of(context).pop();
                },
                child: Text('add', style: TextStyle(color: Colors.white),),
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
  VideoPage({Key key, @required this.videoU}) : super(key: key);
  final String videoU;
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  // 《initState()》
  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.videoU);
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
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
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
