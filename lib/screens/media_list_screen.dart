import 'dart:developer';
import 'dart:io';
import 'dart:ui';

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
    _getMediaList();
    super.initState();
  }

  int currentPage = 0;

  List<AssetEntity> mediaList = [];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double imageSize = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              shrinkWrap: true,
              itemCount: mediaList.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                    height: imageSize,
                    width: imageSize,
                    child: MediaThumbnailPreview(media: mediaList[index]));
              },
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading || mediaList.isNotEmpty)
              IconButton(
                style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                onPressed: () {
                  setState(() {
                    currentPage++;
                    _getMediaList(page: currentPage);
                  });
                },
                icon: const Icon(Icons.add),
              )
          ],
        ),
      ),
    );
  }

  Future<void> _getMediaList({int page = 0}) async {
    isLoading = true;
    if (mounted) {
      setState(() {});
    }
    List<AssetEntity> media =
        await widget.album.getAssetListPaged(page: page, size: 50);

    mediaList.addAll(media);
    isLoading = false;

    if (mounted) {
      setState(() {});
    }
  }
}

class MediaThumbnailPreview extends StatelessWidget {
  const MediaThumbnailPreview({super.key, required this.media});
  final AssetEntity media;
  @override
  Widget build(BuildContext context) {
    final double imageSize = MediaQuery.of(context).size.width / 2;
    return FutureBuilder(
        future: media.thumbnailDataWithSize(
            ThumbnailSize(imageSize.toInt(), imageSize.toInt())),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaPreviewScreen(
                      media: media,
                    ),
                  ),
                );
              },
              child: SizedBox(
                height: imageSize,
                width: imageSize,
                child: Stack(
                  children: [
                    Image.memory(
                      snapshot.data!,
                      height: imageSize,
                      width: imageSize,
                      fit: BoxFit.cover,
                    ),
                    if (media.type == AssetType.video)
                      Container(
                        height: imageSize,
                        width: imageSize,
                        color: Colors.black54.withOpacity(.5),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 40,
                          color: Colors.white,
                        ),
                      )
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
