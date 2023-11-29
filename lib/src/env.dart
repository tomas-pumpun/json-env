import 'dart:html';

import 'package:json_env/src/loader.dart';

///Simple json environment class
///Allows loading environment variables from a json file and parses it's results to a [Map]
class Env {
  ///The resulting json encoded as a [Map]
  Map<String, dynamic> json;

  ///Whether the current Env file was loaded
  bool isLoaded;

  ///Whether an error occurred while loading the Env file.
  bool hasErrors;

  Env._internal()
      : json = {},
        isLoaded = false,
        hasErrors = false;

  ///Asynchronously creates an instance from the provided path.
  ///The [isWeb] argument is required to properly load the json file with the methods available from a browser.
  static Future<Env> fromPath({required String path, required bool isWeb}) async {
    return await Loader.load(Env._internal(), path, isWeb);
  }

  ///Gets a value from the contained [Map] representation of the loaded json and parses it into the given type [T], if possible.
  T? getValue<T>(String key) {
    if (json[key] is T?) {
      return json[key] as T?;
    } else {
      try {
        return json[key].cast<T?>();
      } catch (e, s) {
        Error.throwWithStackTrace(
            "Provided type to getValue was not corresponding to the key fetched on it\nProvided type was:${T.runtimeType}\nFound type was: ${json[key].runtimeType}",
            s);
      }
    }
  }

  void handleError(ProgressEvent event) {
    hasErrors = true;
  }
}
