import 'dart:async';
import 'dart:convert';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/ftpusers.dart';
import 'package:azuracastadmin/models/api_response.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';

class FTPUsersScreen extends StatefulWidget {
  final String url;
  final int stationID;
  final String apiKey;
  const FTPUsersScreen(
      {super.key,
      required this.url,
      required this.apiKey,
      required this.stationID});

  @override
  State<FTPUsersScreen> createState() => _FTPUsersScreenState();
}

class _FTPUsersScreenState extends State<FTPUsersScreen>
    with TickerProviderStateMixin {
  late Future<List<FtpUsers>> ftpusers;
  bool _isRefreshing = false;
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _refreshUsersList();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _refreshUsersList() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final newFtpUsers = fetchFTPUsers(
          widget.url, widget.stationID, 'sftp-users', widget.apiKey);

      setState(() {
        ftpusers = newFtpUsers;
      });

      await newFtpUsers;
    } catch (e) {
      print('Error refreshing FTP users: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _showEditUserDialog(FtpUsers user) {
    TextEditingController usernameController = TextEditingController(
        text:
            user.username != null ? utf8.decode(user.username!.codeUnits) : '');
    TextEditingController passwordController = TextEditingController();
    bool obscurePassword = true;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Color.fromARGB(255, 42, 42, 42),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit FTP User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    style: TextStyle(color: Colors.white),
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Password should be strong with mixed characters',
                            style: TextStyle(
                              color: Colors.blue.shade300,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateUser(
                    user.id!,
                    usernameController.text.trim(),
                    passwordController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Update', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(FtpUsers user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 42, 42, 42),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              'Delete FTP User',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete the FTP user "${utf8.decode(user.username!.codeUnits)}"?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. The user will lose FTP access immediately.',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteUser(user.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog() {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    bool obscurePassword = true;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Color.fromARGB(255, 42, 42, 42),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Create New FTP User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    style: TextStyle(color: Colors.white),
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Password should be strong with mixed characters',
                            style: TextStyle(
                              color: Colors.blue.shade300,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _createUser(
                    usernameController.text.trim(),
                    passwordController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Create', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  void _updateUser(int userId, String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      ApiResponse response = await updateFTPUser(
        url: widget.url,
        apiKey: widget.apiKey,
        stationID: widget.stationID,
        userID: userId,
        username: username,
        password: password,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.green.withValues(alpha: 0.2),
          ),
        );
        _refreshUsersList();
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      _showErrorMessage('Error updating user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteUser(int userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      ApiResponse response = await deleteFTPUser(
        url: widget.url,
        apiKey: widget.apiKey,
        stationID: widget.stationID,
        userID: userId,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.green.withValues(alpha: 0.2),
          ),
        );
        _refreshUsersList();
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      _showErrorMessage('Error deleting user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createUser(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      ApiResponse response = await createFTPUser(
        url: widget.url,
        apiKey: widget.apiKey,
        stationID: widget.stationID,
        username: username,
        password: password,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.green.withValues(alpha: 0.2),
          ),
        );
        _refreshUsersList();
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      _showErrorMessage('Error creating user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.red)),
        backgroundColor: Colors.red.withValues(alpha: 0.2),
      ),
    );
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
            'FTP Users',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _isLoading ? null : _showCreateUserDialog,
              tooltip: 'Create New FTP User',
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: _isRefreshing ? null : _refreshUsersList,
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
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      if (_isRefreshing)
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Refreshing users...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: FutureBuilder<List<FtpUsers>>(
                          future: ftpusers,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !_isRefreshing) {
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
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 64,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Error loading FTP users',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${snapshot.error}',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _refreshUsersList,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      child: Text('Retry'),
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
                                      Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Icon(
                                          Icons.folder_shared,
                                          color: Colors.grey,
                                          size: 64,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No FTP users available',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'FTP users allow file management access to your station',
                                        style: TextStyle(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 16),
                                      // Container(
                                      //   padding: EdgeInsets.all(12),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.blue
                                      //         .withValues(alpha: 0.1),
                                      //     borderRadius:
                                      //         BorderRadius.circular(8),
                                      //     border: Border.all(
                                      //         color: Colors.blue
                                      //             .withValues(alpha: 0.3)),
                                      //   ),
                                      //   child: Row(
                                      //     mainAxisSize: MainAxisSize.min,
                                      //     children: [
                                      //       Icon(Icons.lightbulb_outline,
                                      //           color: Colors.blue, size: 16),
                                      //       SizedBox(width: 8),
                                      //       Text(
                                      //         'Create FTP users from the web interface',
                                      //         style: TextStyle(
                                      //           color: Colors.blue.shade300,
                                      //           fontSize: 12,
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                );
                              }

                              return RefreshIndicator(
                                onRefresh: _refreshUsersList,
                                color: Colors.blue,
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return _buildUserCard(
                                        snapshot.data![index]);
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
                    ],
                  ),
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

  Widget _buildUserCard(FtpUsers user) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      color: Colors.black.withValues(alpha: 0.6),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username != null
                            ? utf8.decode(user.username!.codeUnits)
                            : 'Unknown',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'ID: ' + (user.id?.toString() ?? 'N/A'),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              'SFTP',
                              style: TextStyle(
                                color: Colors.green.shade300,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  color: Color.fromARGB(255, 42, 42, 42),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditUserDialog(user);
                        break;
                      case 'delete':
                        _showDeleteUserDialog(user);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Edit User',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Delete User',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'FTP Connection Info',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Use these credentials with any FTP client to manage files on your station.',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 12,
                    ),
                  ),
                  if (user.publicKeys != null) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.vpn_key, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'SSH Keys configured',
                          style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
