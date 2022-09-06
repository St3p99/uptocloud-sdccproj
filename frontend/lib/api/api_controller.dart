import 'dart:convert';
import 'dart:html';

import 'package:admin/models/authentication_data.dart';
import 'package:admin/models/document.dart';
import 'package:http/http.dart';

import '../managers/rest_manager.dart';
import '../models/file_data_model.dart';
import '../models/tag.dart';
import '../models/user.dart';
import '../support/constants.dart';

class ApiController {
  static final ApiController _singleton = ApiController._internal();

  factory ApiController() {
    return _singleton;
  }

  ApiController._internal();

  RestManager _restManager = new RestManager();


  Future<AuthenticationData> login(String email, String password) async {
      Map<String, dynamic> params = Map();
      params["grant_type"] = "password";
      params["client_id"] = CLIENT_ID;
      params["client_secret"] = CLIENT_SECRET;
      params["username"] = email;
      params["password"] = password;
      String result = (await _restManager.makePostRequest(
          ADDRESS_AUTHENTICATION_SERVER, REQUEST_LOGIN, params,
          type: TypeHeader.urlencoded))
          .body;
      AuthenticationData _authenticationData = AuthenticationData.fromJson(jsonDecode(result));
      _restManager.token = _authenticationData.accessToken!;
      return _authenticationData;
  }

  Future<AuthenticationData> refreshToken(String refreshToken) async {
    Map<String, dynamic> params = Map();
    params["grant_type"] = "refresh_token";
    params["client_id"] = CLIENT_ID;
    params["client_secret"] = CLIENT_SECRET;
    params["refresh_token"] = refreshToken;
    Response response = await _restManager.makePostRequest(
        ADDRESS_AUTHENTICATION_SERVER, REQUEST_LOGIN, params,
        type: TypeHeader.urlencoded);
    String result = response.body;
    AuthenticationData _authenticationData = AuthenticationData.fromJson(jsonDecode(result));
    _restManager.token = _authenticationData.accessToken!;
    if(response.statusCode == HttpStatus.badRequest)
      _authenticationData.error = "BAD REQUEST";
    return _authenticationData;
  }

  Future<Response> logout(String refreshToken) async {
    Map<String, dynamic> params = Map();
    _restManager.token = null;
    // _persistentStorageManager.setString('token', null);
    params["client_id"] = CLIENT_ID;
    params["client_secret"] = CLIENT_SECRET;
    params["refresh_token"] = refreshToken;
    Response response = await _restManager.makePostRequest(
        ADDRESS_AUTHENTICATION_SERVER, REQUEST_LOGOUT, params,
        type: TypeHeader.urlencoded);
    return response;
  }

  Future<Response> deleteAccount() async {
    Response response = await _restManager.makeDeleteRequest(
        ADDRESS_STORE_SERVER, REQUEST_DELETE);
    return response;
  }

  // USER
  Future<Response?> newUser(User user, String pwd) async {
    Map<String, String> params = Map();
    params["pwd"] = pwd;
    try {
      Response response = await _restManager.makePostRequest(
          ADDRESS_STORE_SERVER, REQUEST_NEW_USER, user,
          value: params);
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<User?> loadUserLoggedData() async {
    Response? response;
    try {
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_LOAD_USER);
      if (response.statusCode == HttpStatus.notFound) return null;
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('statusCode: '+ response!.statusCode.toString());
      print("loadUserLoggedData: " + e.toString());
    }
  }

  Future<List<Document>?> loadRecentFilesOwned() async {
    Response? response;
    try {
      response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_LOAD_RECENT_FILES);
      if (response.statusCode == HttpStatus.noContent) return List.empty(growable: false);
      return List<Document>.from(json
            .decode(response.body)
            .map((i) => Document.fromJson(i))
            .toList());
    } catch (e) {
      print('statusCode: '+ response!.statusCode.toString());
      print("loadRecentFilesOwned: " + e.toString());
    }
    return null;
  }

  Future<List<Document>?> loadRecentFilesReadOnly() async {
    Response? response;
    try {
      response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_LOAD_RECENT_FILES_READ_ONLY);
      if (response.statusCode == HttpStatus.noContent) return List.empty(growable: false);
      return List<Document>.from(json
          .decode(response.body)
          .map((i) => Document.fromJson(i))
          .toList());
    } catch (e) {
      print('statusCode: '+ response!.statusCode.toString());
      print("loadRecentFilesReadOnly: " + e.toString());
    }
    return null;
  }


Future<User?> searchUserByEmail(String email) async {
    try {
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_SEARCH_USER_BY_EMAIL + "/" + email.trim());
      if (response.statusCode == HttpStatus.notFound) return null;
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      print("searchUserByEmail exception: " + e.toString());
      return null;
    }
  }

  Future<User?> searchUserByEmailContains(String email) async {
    try {
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_SEARCH_USER_BY_EMAIL_CONTAINS + "/" + email.trim());
      if (response.statusCode == HttpStatus.notFound) return null;
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      print("searchUserByEmail exception: " + e.toString());
      return null;
    }
  }

  Future<StreamedResponse?> uploadFiles(List<FileDataModel> files) async{
    late StreamedResponse response;
    try {
       response = await _restManager.makePostMultiPartRequest(
          ADDRESS_STORE_SERVER, REQUEST_UPLOAD_FILES, files);
    }catch(e){
      print("uploadFiles exception: "+e.toString());
      return null;
    }
    return response;
  }

  Future<Response?> deleteFile(Document d) async{
    late Response response;
    try {
      response = await _restManager.makeDeleteRequest(
          ADDRESS_STORE_SERVER, REQUEST_DELETE_FILE + "/" + d.id.toString());
    }catch(e){
      print("deleteFile exception: "+e.toString());
      return null;
    }
    return response;
  }

  Future<Response?> deleteFiles(List<Document> docs) async{
    try {
      Map<String, dynamic> params = Map();
      params["docs_id"] = docs.map((d) => d.id.toString());
      Response response = await _restManager.makeDeleteRequest(
          ADDRESS_STORE_SERVER, REQUEST_DELETE_FILE, params);
      if (response.statusCode == HttpStatus.notFound) return null;
      return response;
    } catch (e) {
      print("deleteFiles exception: " + e.toString());
      return null;
    }
  }

  Future<StreamedResponse?> uploadFile(FileDataModel file) async{
    late StreamedResponse response;
    try {
      response = await _restManager.makePostMultiPartRequest(
          ADDRESS_STORE_SERVER, REQUEST_UPLOAD_FILE, file);
    }catch(e){
      print("uploadFile exception: "+e.toString());
      return null;
    }
    return response;
  }

  Future<StreamedResponse?> downloadFile(Document d) async{
    late StreamedResponse response;
    try {
      response = await _restManager.makeGetMultiPartRequest(
          ADDRESS_STORE_SERVER, REQUEST_DOWNLOAD_FILE + "/" + d.id.toString());
    }catch(e){
      print("downloadFile exception: "+e.toString());
      return null;
    }
    return response;
  }


  Future<Response?> setMetadata(int docID, String filename, String description, List<String> tags) async{
    try {
      Map<String, dynamic> params = Map();
      params["filename"] = filename;
      params["description"] = description;
      params["tags"] = tags;
      Response response = await _restManager.makePostRequest(
          ADDRESS_STORE_SERVER, REQUEST_SET_METADATA + "/" + docID.toString(), null, value: params);
      if (response.statusCode == HttpStatus.notFound) return null;
      return response;
    } catch (e) {
      print("setMetadata exception: " + e.toString());
      return null;
    }
  }

  Future<Response?> addReaders(Document document, List<User> user) async{
    try {
      Map<String, dynamic> params = Map();
      params["file_id"] = document.id.toString();
      params["readers_id"] = user.map((u) => u.id);
      Response response = await _restManager.makePutRequest(
        ADDRESS_STORE_SERVER, REQUEST_ADD_READERS, params);
      if (response.statusCode == HttpStatus.notFound) return null;
      return response;
    } catch (e) {
      print("addReaders exception: " + e.toString());
      return null;
    }
  }

  Future<Response?> deleteReaders(Document document, List<User> user) async{
    try {
      Map<String, dynamic> params = Map();
      params["file_id"] = document.id.toString();
      params["readers_id"] = user.map((u) => u.id);
      Response response = await _restManager.makePutRequest(
          ADDRESS_STORE_SERVER, REQUEST_REMOVE_READERS, params);
      if (response.statusCode == HttpStatus.notFound) return null;
      return response;
    } catch (e) {
      print("deleteReaders exception: " + e.toString());
      return null;
    }
  }

  Future<List<User>?> getReadersByDoc(int docID) async{
    try {
      Map<String, dynamic> params = Map();
      params["file_id"] = docID.toString();
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_GET_READERS_BY_DOC, params);
      if (response.statusCode == HttpStatus.notFound) return null;
      if (response.statusCode == HttpStatus.noContent) return List.empty(growable: false);
      return List<User>.from(json.decode(response.body)
          .map((i) => User.fromJson(i))
          .toList()
      );
    } catch (e) {
      print("getReadersByDoc exception: " + e.toString());
      return null;
    }
  }

  Future<List<User>?> getShareSuggestions() async{
    try {
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_SHARE_SUGGESTIONS);
      if (response.statusCode == HttpStatus.notFound) return null;
      if (response.statusCode == HttpStatus.noContent) return List.empty(growable: true);
      return List<User>.from(json
          .decode(response.body)
          .map((i) => User.fromJson(i))
          .toList());
    } catch (e) {
      print("getShareSuggestions exception: " + e.toString());
      return null;
    }
  }

  Future<List<Document>?> searchAnyFieldsContains(String text, {bool searchInContent = false}) async{
    try {
      Map<String, dynamic> params = Map();
      params["text"] = text;
      params["searchInContent"] = searchInContent;
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_SEARCH_ANY_FIELDS_CONTAINS, params);
      if (response.statusCode == HttpStatus.notFound) return null;
      if (response.statusCode == HttpStatus.noContent) return List.empty(growable: true);
      return List<Document>.from(json
          .decode(response.body)
          .map((i) => Document.fromJson(i))
          .toList());
    } catch (e) {
      print("searchAnyFieldsContains exception: " + e.toString());
      return null;
    }
  }

  Future<List<Document>?> search(String text, List<String> tags, {bool searchInContent = false}) async{
    try {
      Map<String, dynamic> params = Map();
      params["text"] = text;
      String requestAddress = "";
      if(tags!=null && tags.isNotEmpty){
        params["tags"] = tags;
        requestAddress = REQUEST_SEARCH_ANY_FIELDS_CONTAINS_AND_TAGS;
      }
      else requestAddress = REQUEST_SEARCH_ANY_FIELDS_CONTAINS;
      params["searchInContent"] = jsonEncode(searchInContent);
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER,
          requestAddress, params);
      if (response.statusCode == HttpStatus.notFound) return null;
      if (response.statusCode == HttpStatus.noContent) return List.empty(growable: true);
      return List<Document>.from(json
          .decode(response.body)
          .map((i) => Document.fromJson(i))
          .toList());
    } catch (e) {
      print("search exception: " + e.toString());
      return null;
    }
  }
  Future<List<Document>?> searchByTags(List<String> tags) async{
    try {
      Map<String, dynamic> params = Map();
      params["tags"] = tags;
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER,
          REQUEST_SEARCH_BY_TAGS, params);
      if (response.statusCode == HttpStatus.notFound) return null;
      if (response.statusCode == HttpStatus.noContent) return List.empty(growable: true);
      return List<Document>.from(json
          .decode(response.body)
          .map((i) => Document.fromJson(i))
          .toList());
    } catch (e) {
      print("search exception: " + e.toString());
      return null;
    }
  }


    Future<List<String>?> autocomplete(String text) async{
      try {
        Map<String, dynamic> params = Map();
        params["text"] = text;
        Response response = await _restManager.makeGetRequest(
            ADDRESS_STORE_SERVER, REQUEST_SEARCH_AUTOCOMPLETE, params);
        if (response.statusCode == HttpStatus.notFound) return null;
        if (response.statusCode == HttpStatus.noContent) return List.empty(growable: true);
        return List<String>.from(json
            .decode(response.body)
            .map((i) => i)
            .toList());
      } catch (e) {
        print("autocomplete exception: " + e.toString());
        return null;
      }
    }

  Future<List<String>?> getTagSuggestions() async{
    try {
      Response response = await _restManager.makeGetRequest(
          ADDRESS_STORE_SERVER, REQUEST_SEARCH_TAG_SUGGESTIONS);
      if (response.statusCode == HttpStatus.notFound) return null;
      if (response.statusCode == HttpStatus.noContent) return List.empty(growable: true);
      return List<String>.from(json
          .decode(response.body)
          .map((tag) => Tag.fromJson(tag).name).toList());
    } catch (e) {
      print("getTagSuggestions exception: " + e.toString());
      return null;
    }
  }
}

