import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

List<String> animeStatuses = new List.from(
  [
    "Watching",
    "On Hold",
    "Dropped",
    "Completed",
    "Plan To Watch"
  ]
); 

List<String> mangaStatuses = new List.from(
  [
    "Reading",
    "On Hold",
    "Completed",
    "Dropped",
    "Plan To Read"
  ]
); 


 Future<String> getAniMangaUserValue(String userName, String aniMangaName, bool anime, String value) async
  {
    String collection = (anime) ? "animes" : "mangas"; 
    DocumentSnapshot result = await Firestore.instance.collection("users").document(userName).collection(collection).document(aniMangaName).get(); 
    if(result.exists == false)
    {
      return "Not Found"; 
    }
    return result.data[value].toString(); 
  }

  
 Future<int> getAniMangaUserValueB(String userName, String aniMangaName, bool anime, String value) async
  {
    String collection = (anime) ? "animes" : "mangas"; 
    DocumentSnapshot result = await Firestore.instance.collection("users").document(userName).collection(collection).document(aniMangaName).get(); 
    if(result.exists == false)
    {
      return 0; 
    }
    return result.data[value]; 
  }

// Other type of helpers
  bool isAnimeFromPath(String fullPath)
  {
    String discriminator = fullPath.substring(0, fullPath.indexOf("/"));
    return discriminator == 'animes'; 
  }

  String getScoreString(int score)
  {
    return (score > 0) ? score.toString() : "-"; 
  }