import 'dart:convert';

import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/podcast.dart';
import 'package:azuracastadmin/screens/edit_podcast_screen.dart';
import 'package:azuracastadmin/screens/episodes_screen.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';

class PodcastsScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;

  const PodcastsScreen({
    super.key,
    required this.url,
    required this.apiKey,
    required this.stationID,
  });

  @override
  State<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen> {
  late Future<List<Podcast>> podcasts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      podcasts = fetchPodcasts(widget.url, widget.apiKey, widget.stationID);
    });
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
            'Podcasts',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: _createNewPodcast,
                icon: Icon(Icons.add, color: Colors.white),
              ),
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
                child: FutureBuilder<List<Podcast>>(
                  future: podcasts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 50),
                            SizedBox(height: 16),
                            Text(
                              'Error loading podcasts',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.podcasts_outlined,
                                  color: Colors.blue, size: 80),
                              SizedBox(height: 20),
                              Text(
                                'No podcasts found',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No podcasts have been created yet',
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => _refreshData(),
                        color: Colors.blue,
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return _buildPodcastCard(snapshot.data![index]);
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      );
                    }
                  },
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.blue),
                          SizedBox(height: 16),
                          Text(
                            'Processing...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodcastCard(Podcast podcast) {
    return GestureDetector(
      onTap: () => _navigateToEpisodes(podcast),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(70),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withAlpha(10),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with art and basic info
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Podcast art
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: podcast.art != null && podcast.art!.isNotEmpty
                          ? Image.network(
                              podcast.art!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              headers: {
                                'X-API-Key': widget.apiKey,
                                'accept': 'image/*',
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.podcasts,
                                    color: Colors.grey.shade400,
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.podcasts,
                                color: Colors.grey.shade400,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Podcast details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          podcast.title != null
                              ? utf8.decode(podcast.title!.codeUnits)
                              : 'Untitled Podcast',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        // Author
                        if (podcast.author != null) ...[
                          Text(
                            'by ${utf8.decode(podcast.author!.codeUnits)}',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                        ],
                        // Episodes count and status
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${podcast.episodes ?? 0} episodes',
                                style: TextStyle(
                                  color: Colors.blue.shade300,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (podcast.isEnabled == true)
                                    ? Colors.green.withAlpha(30)
                                    : Colors.red.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (podcast.isEnabled == true)
                                    ? 'Enabled'
                                    : 'Disabled',
                                style: TextStyle(
                                  color: (podcast.isEnabled == true)
                                      ? Colors.green.shade300
                                      : Colors.red.shade300,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Visual indicator that the card is clickable
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                ],
              ),
            ),
            // Description
            if (podcast.description != null &&
                podcast.description!.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  utf8.decode(podcast.description!.codeUnits),
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            // Categories
            if (podcast.categories != null &&
                podcast.categories!.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: podcast.categories!.take(3).map((category) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.text ?? '',
                        style: TextStyle(
                          color: Colors.purple.shade300,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToEpisodes(Podcast podcast) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EpisodesScreen(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          podcast: podcast,
        ),
      ),
    );

    // Refresh the list if needed
    if (result == true) {
      _refreshData();
    }
  }

  void _createNewPodcast() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPodcastScreen(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          podcast: null, // null means create mode
        ),
      ),
    );

    // Refresh the list if a podcast was created
    if (result == true) {
      _refreshData();
    }
  }
}
