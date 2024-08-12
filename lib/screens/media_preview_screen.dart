import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewScreen extends StatefulWidget {
  const MediaPreviewScreen({super.key, required this.media});
  final AssetEntity media;
  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  late final VideoPlayerController videoPlayerController;

  bool isLoading = false;

  @override
  void initState() {
    if (widget.media.type == AssetType.video) {
      isLoading = true;

      widget.media.file.then((File? file) {
        videoPlayerController = VideoPlayerController.file(file!)
          ..initialize().then((value) {
            isLoading = false;
            if (mounted) {
              setState(() {});
            }
          });
        videoPlayerController.addListener(() {
          setState(() {});
        });
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview"),
      ),
      body: widget.media.type == AssetType.image
          ? FutureBuilder(
              future: widget.media.file,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.file(
                      snapshot.data!,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 2 / 3,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(height: 10),
                    Text(widget.media.title!),
                  ],
                );
              },
            )
          : isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 2 / 3,
                      child: Stack(
                        children: [
                          SizedBox(child: VideoPlayer(videoPlayerController)),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black38, Colors.black54],
                              )),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  VideoProgressIndicator(videoPlayerController,
                                      allowScrubbing: true),
                                  IconButton(
                                    onPressed: () async {
                                      if (videoPlayerController
                                          .value.isPlaying) {
                                        await videoPlayerController.pause();
                                      } else if (!videoPlayerController
                                          .value.isPlaying) {
                                        await videoPlayerController.play();
                                      } else {
                                        await videoPlayerController
                                            .seekTo(const Duration(seconds: 0));
                                      }

                                      setState(() {});
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.white)),
                                      child: Icon(
                                        videoPlayerController.value.isCompleted
                                            ? Icons.restore
                                            : videoPlayerController
                                                    .value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.media.title!),
                  ],
                ),
    );
  }
}
