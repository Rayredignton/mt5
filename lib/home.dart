

import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'amplifyconfiguration.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
 bool _isAmplifyConfigured = false;
  String _uploadFileResult = '';
  String _getUrlResult = '';
  String _removeResult = '';
  Amplify amplify = new Amplify();

  @override
  void initState() {
    super.initState();
    configureAmplify();
  }

  void configureAmplify() async {

    AmplifyStorageS3 storage = new AmplifyStorageS3();
    AmplifyAuthCognito auth = new AmplifyAuthCognito();
    amplify.addPlugin(authPlugins: [auth], storagePlugins: [storage]);
    // Configure
    await amplify.configure(amplifyconfig);
    setState(() {
      _isAmplifyConfigured = true;
    });
  }

  void upload() async {
    try {
      print('In upload');
    
      File local = await FilePicker.getFile(type: FileType.any);
      final key = new DateTime.now().toString();
      Map<String, String> metadata = <String, String>{};
      metadata['name'] = 'filename';
      metadata['desc'] = 'A test file';
      S3UploadFileOptions options = S3UploadFileOptions(
          accessLevel: StorageAccessLevel.guest, metadata: metadata);
      UploadFileResult result = await Amplify.Storage.uploadFile(
          key: key, local: local, options: options);
      setState(() {
        _uploadFileResult = result.key;
      });
    } catch (e) {
      print('UploadFile Err: ' + e.toString());
    }
  }

  void getUrl() async {
    try {
      print('In getUrl');
      String key = _uploadFileResult;
      S3GetUrlOptions options = S3GetUrlOptions(
          accessLevel: StorageAccessLevel.guest, expires: 10000);
      GetUrlResult result =
      await Amplify.Storage.getUrl(key: key, options: options);

      setState(() {
        _getUrlResult = result.url;
      });
    } catch (e) {
      print('GetUrl Err: ' + e.toString());
    }
  }

  void remove() async {
    try {
      print('In remove');
      String key = _uploadFileResult;
      RemoveOptions options =
      RemoveOptions(accessLevel: StorageAccessLevel.guest);
      RemoveResult result =
      await Amplify.Storage.remove(key: key, options: options);

      setState(() {
        _removeResult = result.key;
      });
      print('_removeResult:' + _removeResult);
    } catch (e) {
      print('Remove Err: ' + e.toString());
    }
  }

  void list() async {
    try {
      print('In list');
      S3ListOptions options =
      S3ListOptions(accessLevel: StorageAccessLevel.guest);
      ListResult result = await Amplify.Storage.list(options: options);
      print('List Result:');
      for (StorageItem item in result.items) {
        print(
            'Item: { key:${item.key}, eTag:${item.eTag}, lastModified:${item.lastModified}, size:${item.size}');
      }
    } catch (e) {
      print('List Err: ' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('AWS s3 crud '),
          backgroundColor: Colors.amberAccent,
        ),
        body: ListView(
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(padding: EdgeInsets.all(10.0)),
                  ElevatedButton(
                    onPressed: _isAmplifyConfigured ? null : configureAmplify,
                    child: const Text(
                        'Configure AWS s3 Bucket'),
                  ),
                  const Padding(padding: EdgeInsets.all(5.0)),
                  Text(
                    'Status Amplify Configured: $_isAmplifyConfigured',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const Padding(padding: EdgeInsets.all(10.0)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightGreen, // background
                    ),
                    onPressed: upload,
                    child: const Text('Upload File'),
                  ),
                  const Padding(padding: EdgeInsets.all(5.0)),
                  Text(
                    'Uploaded File Name: $_uploadFileResult',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const Padding(padding: EdgeInsets.all(5.0)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // background
                    ),
                    onPressed: remove,
                    child: const Text('Remove Uploaded File '),
                  ),
                  const Padding(padding: EdgeInsets.all(5.0)),
                  Text(
                    'Removed File: $_removeResult',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const Padding(padding: EdgeInsets.all(5.0)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange, // background
                    ),
                    onPressed: list,
                    child: const Text('List Files'),
                  ),
                  const Padding(padding: EdgeInsets.all(5.0)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black54, // background
                    ),
                    onPressed: getUrl,
                    child: const Text('GetUrl or Display for uploaded File'),
                  ),
                  const Padding(padding: EdgeInsets.all(5.0)),
                  Image.network(_getUrlResult),
                ])
          ],
        ),
      
    );
  }
 }

