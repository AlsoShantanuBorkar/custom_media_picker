import 'package:custom_media_picker/screens/media_list_screen.dart';
import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

class AlbumListScreen extends StatelessWidget {
  const AlbumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Album List"),
      ),
      body: FutureBuilder(
        future: _getAlbumList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<AssetPathEntity> albumList = snapshot.data!;
            return ListView.builder(
                shrinkWrap: true,
                itemCount: albumList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () {
                        // Navigate to MediaListScreen to display Album Contents.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MediaListScreen(
                              album: albumList[index],
                            ),
                          ),
                        );
                      },
                      title: Text(albumList[index].name),
                    ),
                  );
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<List<AssetPathEntity>> _getAlbumList() async {
    PermissionState permissionState =
        await PhotoManager.requestPermissionExtend();
    if (permissionState.hasAccess || permissionState.isAuth) {
      List<AssetPathEntity> albumList =
          await PhotoManager.getAssetPathList(type: RequestType.common);
      return albumList;
    } else {
      await PhotoManager.openSetting();
      return await _getAlbumList();
    }
  }
}
