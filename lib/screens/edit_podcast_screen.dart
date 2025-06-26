import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/podcast.dart';
import 'package:azuracastadmin/models/api_response.dart';
import 'package:blur/blur.dart';
import 'package:image/image.dart' as img;

class EditPodcastScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  final int stationID;
  final Podcast? podcast; // null for create mode, podcast object for edit mode

  const EditPodcastScreen({
    super.key,
    required this.url,
    required this.apiKey,
    required this.stationID,
    this.podcast,
  });

  @override
  State<EditPodcastScreen> createState() => _EditPodcastScreenState();
}

class _EditPodcastScreenState extends State<EditPodcastScreen> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionShortController = TextEditingController();
  final _authorController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isEnabled = true;
  bool _isPublished = false;
  String _selectedLanguage = 'en';
  int? _selectedStorageLocationId;
  List<String> _selectedCategories = [];
  File? _selectedImageFile;
  bool _shouldRemoveArt = false;
  String? _currentArtworkUrl;

  List<StorageLocation> _storageLocations = [];
  bool _storageLocationsLoading = true;

  // Language options
  final Map<String, String> _languages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'el': 'Greek',
  };

  // Predefined podcast categories
  final List<String> _availableCategories = [
    'Arts|Design',
    'Arts|Fashion & Beauty',
    'Arts|Food',
    'Arts|Literature',
    'Arts|Performing Arts',
    'Arts|Visual Arts',
    'Business|Careers',
    'Business|Entrepreneurship',
    'Business|Investing',
    'Business|Management',
    'Business|Marketing',
    'Business|Non-Profit',
    'Comedy|Comedy Interviews',
    'Comedy|Improv',
    'Comedy|Stand-Up',
    'Education|Courses',
    'Education|How To',
    'Education|Language Learning',
    'Education|Self-Improvement',
    'Fiction|Comedy Fiction',
    'Fiction|Drama',
    'Fiction|Science Fiction',
    'Government',
    'Health & Fitness|Alternative Health',
    'Health & Fitness|Fitness',
    'Health & Fitness|Medicine',
    'Health & Fitness|Mental Health',
    'Health & Fitness|Nutrition',
    'Health & Fitness|Sexuality',
    'History',
    'Kids & Family|Education for Kids',
    'Kids & Family|Parenting',
    'Kids & Family|Pets & Animals',
    'Kids & Family|Stories for Kids',
    'Leisure|Animation & Manga',
    'Leisure|Automotive',
    'Leisure|Aviation',
    'Leisure|Crafts',
    'Leisure|Games',
    'Leisure|Hobbies',
    'Leisure|Home & Garden',
    'Leisure|Video Games',
    'Music|Music Commentary',
    'Music|Music History',
    'Music|Music Interviews',
    'News|Business News',
    'News|Daily News',
    'News|Entertainment News',
    'News|News Commentary',
    'News|Politics',
    'News|Sports News',
    'News|Tech News',
    'Religion & Spirituality|Buddhism',
    'Religion & Spirituality|Christianity',
    'Religion & Spirituality|Hinduism',
    'Religion & Spirituality|Islam',
    'Religion & Spirituality|Judaism',
    'Religion & Spirituality|Religion',
    'Religion & Spirituality|Spirituality',
    'Science|Astronomy',
    'Science|Chemistry',
    'Science|Earth Sciences',
    'Science|Life Sciences',
    'Science|Mathematics',
    'Science|Natural Sciences',
    'Science|Nature',
    'Science|Physics',
    'Science|Social Sciences',
    'Society & Culture|Documentary',
    'Society & Culture|Personal Journals',
    'Society & Culture|Philosophy',
    'Society & Culture|Places & Travel',
    'Society & Culture|Relationships',
    'Sports|Baseball',
    'Sports|Basketball',
    'Sports|Cricket',
    'Sports|Fantasy Sports',
    'Sports|Football',
    'Sports|Golf',
    'Sports|Hockey',
    'Sports|Rugby',
    'Sports|Running',
    'Sports|Soccer',
    'Sports|Swimming',
    'Sports|Tennis',
    'Sports|Volleyball',
    'Sports|Wilderness',
    'Sports|Wrestling',
    'Technology',
    'True Crime',
    'TV & Film|After Shows',
    'TV & Film|Film History',
    'TV & Film|Film Interviews',
    'TV & Film|Film Reviews',
    'TV & Film|TV Reviews',
  ];

  @override
  void initState() {
    super.initState();
    _loadStorageLocations();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.podcast != null) {
      final podcast = widget.podcast!;
      _titleController.text =
          podcast.title != null ? utf8.decode(podcast.title!.codeUnits) : '';
      _linkController.text = podcast.link ?? '';
      _descriptionController.text = podcast.description != null
          ? utf8.decode(podcast.description!.codeUnits)
          : '';
      _descriptionShortController.text = podcast.descriptionShort != null
          ? utf8.decode(podcast.descriptionShort!.codeUnits)
          : '';
      _authorController.text =
          podcast.author != null ? utf8.decode(podcast.author!.codeUnits) : '';
      _emailController.text = podcast.email ?? '';
      _isEnabled = podcast.isEnabled ?? true;
      _isPublished = podcast.isPublished ?? false;
      _selectedLanguage = podcast.language ?? 'en';
      _selectedStorageLocationId = podcast.storageLocationId;
      _selectedCategories = podcast.categories
              ?.map((c) => c.category ?? '')
              .where((c) => c.isNotEmpty)
              .toList() ??
          [];
      _currentArtworkUrl = podcast.art;
    }
  }

  Future<void> _loadStorageLocations() async {
    try {
      final locations = await fetchStorageLocations(widget.url, widget.apiKey);
      setState(() {
        _storageLocations = locations.podcastsStorageLocation ?? [];
        _storageLocationsLoading = false;

        // Set default storage location if none selected
        if (_selectedStorageLocationId == null &&
            _storageLocations.isNotEmpty) {
          _selectedStorageLocationId = _storageLocations.first.value;
        }
      });
    } catch (e) {
      setState(() {
        _storageLocationsLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading storage locations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        // Process the image to fix orientation and color issues
        final processedFile = await _processImage(File(image.path));

        setState(() {
          _selectedImageFile = processedFile;
          _shouldRemoveArt = false;
        });
      } catch (e) {
        print('Error processing image: $e');
        // Fallback to original file if processing fails
        setState(() {
          _selectedImageFile = File(image.path);
          _shouldRemoveArt = false;
        });
      }
    }
  }

  // Process image to fix rotation and color space issues
  Future<File> _processImage(File imageFile) async {
    try {
      // Read the image bytes
      final bytes = await imageFile.readAsBytes();

      // Decode the image
      img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        // Fix orientation based on EXIF data - this fixes 90-degree rotation issues
        image = img.bakeOrientation(image);

        // Convert image to RGB format to fix green tint and color space issues
        final rgbImage = img.Image(
          width: image.width,
          height: image.height,
          format: img.Format.uint8,
          numChannels: 3, // RGB only, no alpha channel
        );

        // Copy pixel data to ensure proper RGB color space
        for (int y = 0; y < image.height; y++) {
          for (int x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            rgbImage.setPixel(
                x,
                y,
                img.ColorRgb8(
                  pixel.r.toInt(),
                  pixel.g.toInt(),
                  pixel.b.toInt(),
                ));
          }
        }

        // Resize if too large (max 1024x1024 for podcast art)
        img.Image finalImage = rgbImage;
        if (rgbImage.width > 1024 || rgbImage.height > 1024) {
          finalImage = img.copyResize(
            rgbImage,
            width: rgbImage.width > rgbImage.height ? 1024 : null,
            height: rgbImage.height > rgbImage.width ? 1024 : null,
            maintainAspect: true,
          );
        }

        // Encode back to JPEG with proper quality settings
        final processedBytes = img.encodeJpg(finalImage, quality: 90);

        // Create a new file with processed image
        final directory = imageFile.parent;
        final processedFile = File(
            '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await processedFile.writeAsBytes(processedBytes);

        return processedFile;
      }
    } catch (e) {
      print('Image processing error: $e');
      // If processing fails, still try to fix basic rotation
      try {
        final bytes = await imageFile.readAsBytes();
        img.Image? image = img.decodeImage(bytes);
        if (image != null) {
          image = img.bakeOrientation(image);
          final processedBytes = img.encodeJpg(image, quality: 90);
          final directory = imageFile.parent;
          final processedFile = File(
              '${directory.path}/fallback_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await processedFile.writeAsBytes(processedBytes);
          return processedFile;
        }
      } catch (fallbackError) {
        print('Fallback image processing also failed: $fallbackError');
      }
    }

    // Return original file if all processing fails
    return imageFile;
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _shouldRemoveArt = true;
    });
  }

  String _getArtworkStatusText() {
    if (_selectedImageFile != null) {
      return 'New image selected';
    } else if (_shouldRemoveArt) {
      return 'Image will be removed';
    } else if (_currentArtworkUrl != null && _currentArtworkUrl!.isNotEmpty) {
      return 'Current image';
    } else {
      return 'No image';
    }
  }

  Future<void> _savePodcast() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (_titleController.text.trim().isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Title is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedStorageLocationId == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Storage location is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final podcastData = <String, dynamic>{
        'storage_location_id': _selectedStorageLocationId,
        'source': 'manual',
        'title': _titleController.text.trim(),
        'link': _linkController.text.trim(),
        'description': _descriptionController.text.trim(),
        'description_short': _descriptionShortController.text.trim(),
        'is_enabled': _isEnabled,
        'language': _selectedLanguage,
        'author': _authorController.text.trim(),
        'email': _emailController.text.trim(),
        'is_published': _isPublished,
        'categories': _selectedCategories,
        'branding_config': {
          'public_custom_html': '',
        },
      };

      // Step 1: Create or update the podcast first
      ApiResponse response;
      String? podcastId;

      if (widget.podcast != null) {
        // Update existing podcast
        response = await updatePodcast(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          podcastId: widget.podcast!.id!,
          podcastData: podcastData,
        );
        podcastId = widget.podcast!.id!;
      } else {
        // Create new podcast
        response = await createPodcast(
          url: widget.url,
          apiKey: widget.apiKey,
          stationID: widget.stationID,
          podcastData: podcastData,
        );
        // Extract podcast ID from response
        if (response.success && response.extraData != null) {
          podcastId = response.extraData!['id']?.toString();
        }
      }

      if (!response.success) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Step 2: Handle artwork if needed and we have a podcast ID
      if (podcastId != null) {
        if (_shouldRemoveArt) {
          // Remove existing artwork
          final artResponse = await deletePodcastArt(
            url: widget.url,
            apiKey: widget.apiKey,
            stationID: widget.stationID,
            podcastId: podcastId,
          );
          if (!artResponse.success) {
            print('Warning: Failed to remove artwork: ${artResponse.message}');
          }
        } else if (_selectedImageFile != null) {
          // Upload new artwork
          final artResponse = await uploadPodcastArt(
            url: widget.url,
            apiKey: widget.apiKey,
            stationID: widget.stationID,
            podcastId: podcastId,
            imageFile: _selectedImageFile!,
          );
          if (!artResponse.success) {
            print('Warning: Failed to upload artwork: ${artResponse.message}');
            // Don't fail the entire operation for artwork issues
          }
        }
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withAlpha(200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withAlpha(10),
            width: 1,
          ),
        ),
        title: const Text(
          'Delete Podcast',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.podcast?.title ?? 'this podcast'}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade400,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _deletePodcast,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePodcast() async {
    if (widget.podcast == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(); // Close the confirmation dialog

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await deletePodcast(
        url: widget.url,
        apiKey: widget.apiKey,
        stationID: widget.stationID,
        podcastId: widget.podcast!.id!,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context)
              .pop(true); // Return to podcast list with refresh
        }
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.podcast != null;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            isEditMode ? 'Edit Podcast' : 'Create Podcast',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            else ...[
              if (isEditMode)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _showDeleteConfirmation,
                ),
              TextButton(
                onPressed: _savePodcast,
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
              _storageLocationsLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Artwork Section
                          _buildArtworkSection(),
                          const SizedBox(height: 24),

                          // Basic Information
                          _buildSectionTitle('Basic Information'),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _titleController,
                            label: 'Title',
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _linkController,
                            label: 'Link',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _descriptionShortController,
                            label: 'Short Description',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 24),

                          // Author Information
                          _buildSectionTitle('Author Information'),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _authorController,
                            label: 'Author',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),

                          // Settings
                          _buildSectionTitle('Settings'),
                          const SizedBox(height: 16),
                          _buildLanguageDropdown(),
                          const SizedBox(height: 16),
                          _buildStorageLocationDropdown(),
                          const SizedBox(height: 16),
                          _buildCategoriesSection(),
                          const SizedBox(height: 16),
                          _buildSwitchRow('Enabled', _isEnabled, (value) {
                            setState(() {
                              _isEnabled = value;
                            });
                          }),
                          const SizedBox(height: 16),
                          _buildSwitchRow('Published', _isPublished, (value) {
                            setState(() {
                              _isPublished = value;
                            });
                          }),
                          const SizedBox(
                              height: 100), // Extra space for scrolling
                        ],
                      ),
                    ),
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
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

  Widget _buildArtworkSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(10),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Artwork',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Artwork preview
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade600),
                ),
                child: _buildArtworkPreview(),
              ),
              const SizedBox(width: 16),
              // Artwork controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload button
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload),
                      label: Text(_selectedImageFile != null
                          ? 'Change Image'
                          : 'Upload Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Remove button (show if there's a selected file or existing artwork)
                    if (_selectedImageFile != null ||
                        (_currentArtworkUrl != null && !_shouldRemoveArt))
                      TextButton.icon(
                        onPressed: _removeImage,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Remove Image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    // Status indicator
                    const SizedBox(height: 4),
                    Text(
                      _getArtworkStatusText(),
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkPreview() {
    // Show the newly selected image first
    if (_selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      );
    }
    // Show existing artwork if not removing and not replaced
    else if (_currentArtworkUrl != null &&
        _currentArtworkUrl!.isNotEmpty &&
        !_shouldRemoveArt) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _currentArtworkUrl!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          headers: {
            'X-API-Key': widget.apiKey,
            'accept': 'image/*',
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.podcasts,
                color: Colors.grey,
                size: 40,
              ),
            );
          },
        ),
      );
    }
    // Show placeholder
    else {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.podcasts,
          color: Colors.grey,
          size: 40,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(10),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(
            color: isRequired ? Colors.blue : Colors.grey.shade400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(10),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedLanguage,
        style: const TextStyle(color: Colors.white),
        dropdownColor: Colors.grey.shade800,
        decoration: InputDecoration(
          labelText: 'Language',
          labelStyle: TextStyle(color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
        items: _languages.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedLanguage = value!;
          });
        },
      ),
    );
  }

  Widget _buildStorageLocationDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(10),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedStorageLocationId,
        style: const TextStyle(color: Colors.white),
        dropdownColor: Colors.grey.shade800,
        decoration: InputDecoration(
          labelText: 'Storage Location *',
          labelStyle: const TextStyle(color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
        items: _storageLocations.map((location) {
          return DropdownMenuItem<int>(
            value: location.value,
            child: Text(location.text ?? 'Unknown'),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedStorageLocationId = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(10),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            // Selected categories
            if (_selectedCategories.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedCategories.map((category) {
                  final displayText = category.split('|').join(' - ');
                  return Chip(
                    label: Text(
                      displayText,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.blue,
                    deleteIcon:
                        const Icon(Icons.close, color: Colors.white, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedCategories.remove(category);
                      });
                    },
                  );
                }).toList(),
              ),
            if (_selectedCategories.isNotEmpty) const SizedBox(height: 12),
            // Add category button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showCategorySelector,
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(10),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            activeTrackColor: Colors.blue.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  void _showCategorySelector() {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCategories = _availableCategories
                .where((category) =>
                    !_selectedCategories.contains(category) &&
                    category.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              backgroundColor: Colors.black.withAlpha(200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withAlpha(10),
                  width: 1,
                ),
              ),
              title: const Text(
                'Select Category',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // Search field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(70),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withAlpha(10),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search categories...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon:
                              Icon(Icons.search, color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Categories list
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(70),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withAlpha(10),
                            width: 1,
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            final displayText = category.split('|').join(' - ');
                            return ListTile(
                              title: Text(
                                displayText,
                                style: const TextStyle(color: Colors.white),
                              ),
                              hoverColor: Colors.blue.withValues(alpha: 0.1),
                              onTap: () {
                                setState(() {
                                  _selectedCategories.add(category);
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    _descriptionShortController.dispose();
    _authorController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
