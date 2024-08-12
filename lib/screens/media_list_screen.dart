import 'dart:developer';
import 'dart:io';

import 'package:custom_media_picker/screens/media_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaListScreen extends StatefulWidget {
  const MediaListScreen({super.key, required this.album});

  final AssetPathEntity album;

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  @override
  void initState() {
    isLoading = true;
    _getImageList();
    super.initState();
  }

  int currentPage = 0;

  List<AssetEntity> imageList = [];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double imageSize = MediaQuery.of(context).size.width / 2;

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.album.name),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              shrinkWrap: true,
              itemCount: imageList.length,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder(
                    future: imageList[index].thumbnailDataWithSize(
                        ThumbnailSize(imageSize.toInt(), imageSize.toInt())),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MediaPreviewScreen(
                                  media: imageList[index],
                                ),
                              ),
                            );
                          },
                          child: Image.memory(
                            snapshot.data!,
                            height: imageSize,
                            width: imageSize,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    });
              },
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading || imageList.isNotEmpty)
              ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                  onPressed: () {
                    setState(() {
                      currentPage++;
                      _getImageList(page: currentPage);
                    });
                  },
                  child: const Icon(Icons.add))
          ]),
        ));
  }

  Future<void> _getImageList({int page = 0}) async {
    isLoading = true;
    if (mounted) {
      setState(() {});
    }
    List<AssetEntity> images =
        await widget.album.getAssetListPaged(page: page, size: 50);

    imageList.addAll(images);
    isLoading = false;

    if (mounted) {
      setState(() {});
    }
  }
}
