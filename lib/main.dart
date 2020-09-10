import 'package:flutter/material.dart';

void main() {
  runApp(StrengthMobile());
}

//【アプリ全体】【レス】
class StrengthMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,    //against debug label
      title: 'Strength Recruiting Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StrengthListPage(),
    );
  }
}



//【一覧画面widget】【フル】入力したテキストを扱う -> 状態ありWidget
class StrengthListPage extends StatefulWidget {
  @override
  _StrengthListPageState createState() => _StrengthListPageState();
}

class _StrengthListPageState extends State<StrengthListPage> {
  List<String> strengthList = [];   // strength格納用リスト
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STRENGTH RECRUITING MOBILE'),
      ),
      body: ListView.builder(   // builder:データを元にListView作成
        itemCount: strengthList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(strengthList[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 画面間のデータの受け渡しは Navigator（追加画面からの値を受け取る）
          final newListText = await Navigator.of(context).push(   // Navigatorのpushで新規画面に遷移
            MaterialPageRoute(builder: (context) {    // MaterialPageRoute
              return StrengthAddPage();   // 遷移先画面の指定
            }),
          );
          if (newListText != null) {    // キャンセル時は newListText が null
            setState(() {
              strengthList.add(newListText);    // 追加情報をリストに格納
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}



//【追加画面Widget】【フル】入力したテキストを扱う -> 状態ありWidget
class StrengthAddPage extends StatefulWidget {
  @override
  _StrengthAddPageState createState() => _StrengthAddPageState();
}
//【フル_state】
class _StrengthAddPageState extends State<StrengthAddPage> {
  String _text = '';    // 入力データ格納
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ADD STRENGTH'),
      ),
      body: Container(
        padding: EdgeInsets.all(64),    // 余白
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_text, style: TextStyle(color: Colors.blue)),    // 入力されたテキストを表示
            TextField(    // テキスト入力欄
              onChanged: (String value) {   // 入力されたテキストをvalueで受け取る
                setState(() {   // データ変更通知と画面更新
                  _text = value;    // データ変更
                });
              },
            ),
            Container(
              width: double.infinity,
              child: RaisedButton(
                color: Colors.blue,
                onPressed: () {
                  // 画面間のデータの受け渡しは Navigator（pop(引数)で前画面にデータを渡す）
                  Navigator.of(context).pop(_text);   // Navigatorのpop前画面遷移
                },
                child: Text('add', style: TextStyle(color: Colors.white)),
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();   // Navigatorのpop前画面遷移
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