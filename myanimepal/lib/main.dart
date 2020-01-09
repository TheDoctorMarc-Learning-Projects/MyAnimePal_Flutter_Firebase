import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart'; 


 _loadAnimeData() async
 {
  QuerySnapshot animesSnapshot = await Firestore.instance.collection("animes").getDocuments(); 
  return animesSnapshot.documents; 
 }

  _loadMangaData() async
 {
  QuerySnapshot mangasSnapshot = await Firestore.instance.collection("mangas").getDocuments(); 
  return mangasSnapshot.documents; 
 }

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  var animeData = await _loadAnimeData(); 
  var mangaData = await _loadMangaData(); 
  runApp(MyAnimePal(animeData: animeData, mangaData: mangaData));
} 
 

class MyAnimePal extends StatelessWidget {

  List<DocumentSnapshot> animeData, mangaData; 
  MyAnimePal({@required this.animeData, @required this.mangaData}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Anime Pal',
      home: SingIn(animeData: animeData, mangaData: mangaData)
     
    );
  }
}
