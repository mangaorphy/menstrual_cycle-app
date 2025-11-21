import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../providers/education_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> video;
  final Color categoryColor;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    required this.categoryColor,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();

    final videoUrl = widget.video['youtubeUrl'] as String;
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);

    print('Video URL: $videoUrl');
    print('Extracted Video ID: $videoId');

    if (videoId == null) {
      print('ERROR: Could not extract video ID from URL');
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true, // Changed to true for immediate play
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
        startAt: 0,
      ),
    );

    _controller!.addListener(_playerListener);
  }

  void _playerListener() {
    if (_controller?.value.playerState == PlayerState.ended) {
      // Mark video as watched when it ends
      _markAsWatched();
    }
  }

  void _markAsWatched() {
    Provider.of<EducationProvider>(context, listen: false).markVideoAsWatched(
      videoId: widget.video['id'] as String,
      duration: _parseDuration(widget.video['duration'] as String),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video completed! 🎉'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  int _parseDuration(String duration) {
    final parts = duration.split(':');
    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[1]);
    return minutes + (seconds / 60).round();
  }

  @override
  void dispose() {
    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final educationProvider = Provider.of<EducationProvider>(context);
    final isWatched = educationProvider.isVideoWatched(
      widget.video['id'] as String,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.categoryColor,
                widget.categoryColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
        title: Text(
          'Video Player',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isWatched)
            Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 16),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YouTube Player
            _controller == null
                ? Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load video',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'Please check your internet connection',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: widget.categoryColor,
                      aspectRatio: 16 / 9,
                      bottomActions: [
                        CurrentPosition(),
                        ProgressBar(isExpanded: true),
                        RemainingDuration(),
                        FullScreenButton(),
                      ],
                      onReady: () {
                        print('YouTube player is ready');
                      },
                      onEnded: (data) {
                        print('Video ended');
                        _markAsWatched();
                      },
                    ),
                  ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video title
                  Text(
                    widget.video['title'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Video metadata
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.video['difficulty'] as String,
                          style: TextStyle(
                            color: widget.categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.video['duration'] as String,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'About this video',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.video['description'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isWatched ? null : () => _markAsWatched(),
                          icon: Icon(
                            isWatched ? Icons.check_circle : Icons.check,
                            size: 18,
                          ),
                          label: Text(
                            isWatched ? 'Watched' : 'Mark as Watched',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isWatched
                                ? Colors.green
                                : widget.categoryColor,
                            side: BorderSide(
                              color: isWatched
                                  ? Colors.green
                                  : widget.categoryColor,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
