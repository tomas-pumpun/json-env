import 'dart:convert';
import 'dart:html' as html;
import 'dart:io' as io;

import 'package:json_env/json_env.dart';

///Static utilities for loading and parsing the json file.
abstract class Loader {
  ///Loads the json file into an [Env] instance.
  static Future<Env> load(Env instance, String path, bool isWeb) async {
    try {
      if (isWeb) {
        await loadWeb(path, instance);
      } else {
        await loadNative(path, instance);
      }
    } catch (e, s) {
      instance.isLoaded = true;
      Error.throwWithStackTrace("Something went wrong while loading the json environment\n${e.toString()}", s);
    }
    return instance;
  }

  ///Loads the json file on web environments.
  static Future<void> loadWeb(String path, Env instance) async {
    try {
      //Create the request
      html.HttpRequest request = html.HttpRequest()
        ..open("GET", path, async: true)
        ..responseType = "blob";
      //Get the request stream
      Stream<html.ProgressEvent> requestLoadEnd = request.onLoadEnd;
      //Listen for errors
      request.onError.listen(instance.handleError);
      //Send it
      request.send();
      //Await the first result on the request stream
      await requestLoadEnd.first;
      //Create a FileReader
      html.FileReader fileReader = html.FileReader();
      fileReader.readAsText(request.response);
      Stream<html.ProgressEvent> fileReaderLoadEnd = fileReader.onLoadEnd;
      //Await the first result on the FileReader stream
      await fileReaderLoadEnd.first;
      //Parse the result into json
      String? rawString = fileReader.result as String?;
      instance.json = jsonDecode(rawString ?? "");
      instance.isLoaded = true;
    } on (html.ErrorEvent, Exception, Error) {
      instance.hasErrors = true;
    }
  }

  ///Loads the file on native platforms.
  static Future<void> loadNative(String path, Env instance) async {
    String rawString = await io.File(path).readAsString();
    instance.json = jsonDecode(rawString);
    instance.isLoaded = true;
  }
}
