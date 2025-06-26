import 'dart:convert';

import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/episode.dart';
import 'package:azuracastadmin/models/podcast.dart';
import 'package:azuracastadmin/screens/edit_podcast_screen.dart';
import 'package:azuracastadmin/screens/edit_episode_screen.dart';
import 'package:azuracastadmin/screens/episode_player_screen.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';

class EpisodesScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  final Podcast podcast;

  const EpisodesScreen({
    super.key,
    required this.url,
    required this.apiKey,
    required this.stationID,
    required this.podcast,
  });

  @override
  State<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends State<EpisodesScreen> {
  late Future<List<Episode>> episodes;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    if (widget.podcast.id == null) {
      // Handle case where podcast ID is null
      setState(() {
        episodes = Future.error('Podcast ID is missing');
      });
      return;
    }

    setState(() {
      episodes = fetchEpisodes(
        url: widget.url,
        apiKey: widget.apiKey,
        stationID: widget.stationID,
        podcastId: widget.podcast.id!,
      );
    });
  }

  void _createNewEpisode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEpisodeScreen(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          podcast: widget.podcast,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _editPodcast() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPodcastScreen(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          podcast: widget.podcast,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _editEpisode(Episode episode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEpisodeScreen(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          podcast: widget.podcast,
          episode: episode,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _playEpisode(Episode episode) {
    if (episode.hasMedia && episode.links.download != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EpisodePlayerScreen(
            url: widget.url,
            apiKey: widget.apiKey,
            stationID: widget.stationID,
            podcast: widget.podcast,
            episode: episode,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No media available for this episode'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatDateTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(double? length) {
    if (length == null) return 'Unknown';
    final minutes = (length / 60).floor();
    final seconds = (length % 60).floor();
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            widget.podcast.title != null
                ? utf8.decode(widget.podcast.title!.codeUnits)
                : 'Unknown Podcast',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: _editPodcast,
              icon: Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Podcast',
            ),
            IconButton(
              onPressed: _createNewEpisode,
              icon: Icon(Icons.add, color: Colors.white),
              tooltip: 'Add New Episode',
            ),
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/azu.png',
                  fit: BoxFit.fill,
                ),
              ).blurred(blur: 10, blurColor: Colors.black),
              Container(
                child: FutureBuilder<List<Episode>>(
                  future: episodes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          _refreshData();
                        },
                        backgroundColor: Colors.black54,
                        color: Colors.blue,
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error,
                                      color: Colors.red, size: 50),
                                  SizedBox(height: 16),
                                  Text(
                                    'Error loading episodes',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${snapshot.error}',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Pull down to refresh or tap retry',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _refreshData,
                                    child: Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          _refreshData();
                        },
                        backgroundColor: Colors.black54,
                        color: Colors.blue,
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.podcasts,
                                      color: Colors.grey, size: 50),
                                  SizedBox(height: 16),
                                  Text(
                                    'No episodes found',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Create your first episode or pull down to refresh',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _createNewEpisode,
                                    child: Text('Add Episode'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: () async {
                          _refreshData();
                        },
                        backgroundColor: Colors.black54,
                        color: Colors.blue,
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final episode = snapshot.data![index];
                            return Card(
                              color: Colors.black.withAlpha(30),
                              margin: EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => _editEpisode(episode),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Episode artwork
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.grey[300],
                                        ),
                                        child: episode.hasCustomArt &&
                                                episode.art != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  episode.art!,
                                                  fit: BoxFit.cover,
                                                  headers: {
                                                    'X-API-Key': widget.apiKey,
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: Colors.grey[300],
                                                      ),
                                                      child: Icon(
                                                        Icons.podcasts,
                                                        color: Colors.grey[600],
                                                        size: 30,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Icon(
                                                Icons.podcasts,
                                                color: Colors.grey[600],
                                                size: 30,
                                              ),
                                      ),
                                      SizedBox(width: 16),
                                      // Episode info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                if (episode.seasonNumber !=
                                                    null)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      'S${episode.seasonNumber}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                if (episode.episodeNumber !=
                                                    null) ...[
                                                  SizedBox(width: 4),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      'E${episode.episodeNumber}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                if (episode.explicit) ...[
                                                  SizedBox(width: 4),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      'E',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                Spacer(),
                                                if (!episode.isPublished)
                                                  Icon(
                                                    Icons.visibility_off,
                                                    color: Colors.orange,
                                                    size: 16,
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              utf8.decode(
                                                  episode.title.codeUnits),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              episode.descriptionShort
                                                      .isNotEmpty
                                                  ? utf8.decode(episode
                                                      .descriptionShort
                                                      .codeUnits)
                                                  : utf8.decode(episode
                                                      .description.codeUnits),
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                                fontSize: 12,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: Colors.grey[400],
                                                  size: 12,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  _formatDuration(
                                                      episode.media?.length),
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.grey[400],
                                                  size: 12,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  _formatDateTime(
                                                      episode.publishAt),
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                Spacer(),
                                                if (episode.hasMedia)
                                                  Icon(
                                                    Icons.audiotrack,
                                                    color: Colors.green,
                                                    size: 16,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // Play button for episodes with media, or edit arrow
                                      if (episode.hasMedia &&
                                          episode.links.download != null)
                                        IconButton(
                                          onPressed: () =>
                                              _playEpisode(episode),
                                          icon: Icon(
                                            Icons.play_circle_filled,
                                            color: Colors.green,
                                            size: 32,
                                          ),
                                          tooltip: 'Play Episode',
                                        )
                                      else
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey[400],
                                          size: 16,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
