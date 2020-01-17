import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

List<String> animeStatuses = new List.from(
    ["Watching", "On Hold", "Dropped", "Completed", "Plan To Watch"]);

List<String> mangaStatuses = new List.from(
    ["Reading", "On Hold", "Completed", "Dropped", "Plan To Read"]);

// ANIMANGAS 
Future<String> getAniMangaValue(
    String aniMangaName, bool anime, String value) async {
  String collection = (anime) ? "animes" : "mangas";
  DocumentSnapshot result = await Firestore.instance
      .collection(collection)
      .document(aniMangaName)
      .get();
  if (result.exists == false) {
    return "Not Found";
  }
  return result.data[value].toString();
}

Future<dynamic> getAniMangaValueB(
    String aniMangaName, bool anime, String value) async {
  String collection = (anime) ? "animes" : "mangas";
  DocumentSnapshot result = await Firestore.instance
      .collection(collection)
      .document(aniMangaName)
      .get();
  if (result.exists == false) {
    return "Not Found";
  }
  return result.data[value];
}


Future<bool> setAniMangaValue(
    String aniMangaName, bool anime, String valueName, dynamic value) async {
  String collection = (anime) ? "animes" : "mangas";
  DocumentSnapshot result = await Firestore.instance
      .collection(collection)
      .document(aniMangaName)
      .get();
  if (result.exists == false) {
    return false;
  }

  var data = result.data;
  data[valueName] = value;
  await result.reference.updateData(data);
  return true;
}

// ANIMANGAS INSIDE USER NODE
Future<String> getAniMangaUserValue(
    String userName, String aniMangaName, bool anime, String value) async {
  String collection = (anime) ? "animes" : "mangas";
  DocumentSnapshot result = await Firestore.instance
      .collection("users")
      .document(userName)
      .collection(collection)
      .document(aniMangaName)
      .get();
  if (result.exists == false) {
    return "Not Found";
  }
  return result.data[value].toString();
}

Future<dynamic> getAniMangaUserValueB(
    String userName, String aniMangaName, bool anime, String value) async {
  String collection = (anime) ? "animes" : "mangas";
  DocumentSnapshot result = await Firestore.instance
      .collection("users")
      .document(userName)
      .collection(collection)
      .document(aniMangaName)
      .get();
  if (result.exists == false) {
    return 0;
  }
  return result.data[value];
}


Future<bool> setAniMangaUserValue(String userName, String aniMangaName,
    bool anime, String valueName, dynamic value) async {
  String collection = (anime) ? "animes" : "mangas";
  DocumentSnapshot result = await Firestore.instance
      .collection("users")
      .document(userName)
      .collection(collection)
      .document(aniMangaName)
      .get();
  if (result.exists == false) {
    return false;
  }

  var data = result.data;
  data[valueName] = value;
  await result.reference.updateData(data);
  return true;
}

Future<List<DocumentSnapshot>> getAnimeListUser(String userName) async {
  QuerySnapshot result = await Firestore.instance
      .collection("users")
      .document(userName)
      .collection("animes")
      .getDocuments();
  return result.documents;
}

Future<List<DocumentSnapshot>> getMangaListUser(String userName) async {
  QuerySnapshot result = await Firestore.instance
      .collection("users")
      .document(userName)
      .collection("mangas")
      .getDocuments();
  return result.documents;
}

// Other type of helpers
bool isAnimeFromPath(String fullPath) {
  String discriminator = fullPath.substring(0, fullPath.indexOf("/"));
  return discriminator == 'animes';
}

String getScoreString(double score) {
  return (score > 0) ? score.toString() : "-";
}
