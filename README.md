# README

## アプリケーション

<img width="595" alt="strengthMobile_topImagev2" src="https://user-images.githubusercontent.com/62828568/93035661-9389a000-f678-11ea-8983-16a33df52065.png">

![dart](https://img.shields.io/badge/-Dart-blue)
![flutter](https://img.shields.io/badge/-Flutter-lightblue)
![firebase](https://img.shields.io/badge/-Firebase-yellow)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/RYgithub1/strengthmobile)

## アプリケーション名

_Strength Recruiting Mobile!_  
（ストレングス リクルーティング モバイル！： 強み採用のプラットフォームアプリ(モバイル版)）  
※iOS端末、及びAndroid端末にて、実機検証済みです。

## 概要

求職者やプロジェクトパートナーを探している方が、自らの"強み"を説明文と動画でアピールできます。  
気になる人がいたらメッセージを送付できます。

## コンセプトと思い

これからの世の中は更に、やる気と実力のある個人が世界中のコミュニティと繋がり、自らの特徴を活かして社会貢献する時代になると考えます。  
しかしながら、世の中に採用サイトは数多くあるものの、強みのみに注目する採用サイトが見当たらない状況です。  
他の事はなんら出来ないけど、ある特定の事に物凄く秀でた方が世の中に沢山おり、私にとって魅力的な存在です。  
採用の多様性を広げ、一人でも多くの人が輝ける・楽しめる社会をつくりたいと思っています。  
そこで今回、人の強みだけに集中して採用活動が行えるWebサイトの構築へ挑戦しています。  
まだまだ実装したい機能が沢山ありますが、土台部分を実装したためβ版とします。  

---

## 内容

### トップページ(pre)

<img width="502" alt="strengthMobile_topPage_pre" src="https://user-images.githubusercontent.com/62828568/93035038-e1050d80-f676-11ea-8b86-92d1c3c895d7.png">

- トップページにて、全候補者のプロフィール「名前/アピールポイント/連絡先」を一覧で確認できます。
- (プロフィールを掲示したい)候補者は、右下のプラスアイコンを押下することで、アピールポイント作成ページに遷移します。

### アピールポイント作成ページ

<img width="477" alt="strengthMobile_addPage" src="https://user-images.githubusercontent.com/62828568/93035060-f11ced00-f676-11ea-943f-2936b8a06808.png">


- アピールポイント(自らの強み)を表現するため、説明文と動画(赤枠)の投稿が可能です。
- 説明文の記入内容は、上方にオレンジ色の文字で表示されます。
- 「add」ボタンを押下すると、Firebaseへデータを保存できます。
- 「cancel」ボタンを押下すると、トップページに遷移します。

### トップページ(post)

<img width="473" alt="strengthMobile_topPage_post" src="https://user-images.githubusercontent.com/62828568/93035085-fda14580-f676-11ea-8fff-23387df0b422.png">

- 赤枠のように、作成したアピールポイントがトップページ(一覧画面)に追加されます。
- 各投稿の右方にある動画アイコンを押下すると、動画再生ページに遷移します。

### 動画再生ページ

<img width="475" alt="strengthMobile_videoPage" src="https://user-images.githubusercontent.com/62828568/93340874-626fc200-f868-11ea-88df-0d354a6736de.png">

- トップページで選択したプロフィールに紐づいている動画が表示されます。
- 右下のアイコンから再生と休止が可能です。


## 工夫

- 拡張性を考慮

  - データの管理に際して、アプリの拡張性を考慮してFirebaseを活用しています。
  - データベースは「Cloud FireStore」、ストレージは「Cloud Storage」を利用しています。
  
- 動画の取り扱い

  - 動画の取得に、Image Pickerライブラリを活用しています。
  - 動画の保存に、FirebaseのCloud Storageを用いています。
  - 動画の再生に、Video Playerライブラリを活用しています。

## 今後の実装予定

1. □ ユーザー管理
2. □ メッセージ交換
3. □ フォロー・フォロワー

---

## 開発環境

- Dart（2.10.0）
- Flutter（1.22.0-10.0）
- Git（2.26.0）

## DB 設計

### Videos Table

| Column   | Type   | Options     |
| -------- | ------ | ----------- |
| text     | string | null: False |
| videoUrl | string | null: False |

#### Association(Videos)

- xxx

---

## 著者

- 製作者：R.O.
- [GitHub](https://github.com/RYgithub1)
