import 'dart:async';
import 'dart:convert';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/users.dart';
import 'package:azuracastadmin/models/roles.dart';
import 'package:azuracastadmin/models/user_account.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class UsersScreen extends StatefulWidget {
  final String url;
  final String apiKey;
  const UsersScreen({
    super.key,
    required this.url,
    required this.apiKey,
  });

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<Users>> users;
  late Future<List<RoleModel>> roles;
  late Future<UserAccount> currentUserAccount;
  bool _isLoading = false;

  @override
  void initState() {
    users = fetchUsers(widget.url, 'admin/users', widget.apiKey);
    roles = fetchRoles(widget.url, widget.apiKey);
    currentUserAccount = fetchUserAccount(widget.url, widget.apiKey);
    super.initState();
  }

  void _refreshUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(
          Duration(milliseconds: 100)); // Small delay to show loading state
      setState(() {
        users = fetchUsers(widget.url, 'admin/users', widget.apiKey);
        currentUserAccount = fetchUserAccount(widget.url, widget.apiKey);
      });

      // Wait for the future to complete before stopping loading
      await users;
    } catch (e) {
      // Handle any errors
      print('Error refreshing users: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            'Users Management',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () => _showCreateUserDialog(),
              icon: Icon(
                Icons.person_add,
                color: Colors.white,
              ),
              tooltip: 'Create User',
            ),
            IconButton(
              onPressed: _isLoading ? null : _refreshUsers,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      color: Colors.white,
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
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: FutureBuilder<List<dynamic>>(
                  future: Future.wait([users, currentUserAccount]),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var usersList = snapshot.data![0] as List<Users>;
                      var userAccount = snapshot.data![1] as UserAccount;

                      // Sort users to show current user first
                      usersList.sort((a, b) {
                        if (a.isMe == true) return -1;
                        if (b.isMe == true) return 1;
                        return 0;
                      });

                      return ListView.builder(
                        itemCount: usersList.length,
                        itemBuilder: (context, index) {
                          var user = usersList[index];
                          return _buildUserCard(user, userAccount);
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 60,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load users',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Error: ${snapshot.error}',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: _refreshUsers,
                              child: Text(
                                'Retry',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading users...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
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

  Widget _buildUserCard(Users user, UserAccount userAccount) {
    bool isCurrentUser = user.isMe == true;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        color: isCurrentUser ? Colors.blue.withAlpha(25) : Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isCurrentUser
              ? BorderSide(color: Colors.blue, width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and current user indicator
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrentUser ? Colors.blue : Colors.white70,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: ClipOval(
                        child: FadeInImage.memoryNetwork(
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: kTransparentImage,
                          image:
                              _getAvatarUrl(user, userAccount, isCurrentUser),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.email ?? 'No email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isCurrentUser) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'You',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (user.name != null && user.name!.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            utf8.decode(user.name!.codeUnits),
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // User details
              _buildInfoRow('ID', user.id?.toString() ?? 'N/A', Icons.badge),
              if (user.locale != null)
                _buildInfoRow('Locale', user.locale!, Icons.language),
              if (user.show24HourTime != null)
                _buildInfoRow('24h Time', user.show24HourTime.toString(),
                    Icons.access_time),

              _buildInfoRow(
                'Created',
                user.createdAt != null
                    ? DateFormat.yMMMEd().add_jm().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            user.createdAt! * 1000))
                    : 'N/A',
                Icons.calendar_today,
              ),

              _buildInfoRow(
                'Updated',
                user.updatedAt != null
                    ? DateFormat.yMMMEd().add_jm().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            user.updatedAt! * 1000))
                    : 'N/A',
                Icons.update,
              ),

              SizedBox(height: 12),

              // Roles section
              if (user.roles != null && user.roles!.isNotEmpty) ...[
                Text(
                  'Roles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user.roles!
                      .map((role) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: role.name == 'Super Administrator'
                                  ? Colors.red.withAlpha(51)
                                  : Colors.blue.withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: role.name == 'Super Administrator'
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                            child: Text(
                              role.name ?? 'Unknown Role',
                              style: TextStyle(
                                color: role.name == 'Super Administrator'
                                    ? Colors.red.shade300
                                    : Colors.blue.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],

              // API Keys section (show count)
              if (user.apiKeys != null && user.apiKeys!.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withAlpha(76)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.key, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Text(
                        '${user.apiKeys!.length} API Key${user.apiKeys!.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.green.shade300,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              if (!isCurrentUser) ...[
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showEditUserDialog(user),
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteUserDialog(user),
                      icon: Icon(Icons.delete, size: 16),
                      label: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getAvatarUrl(
      Users user, UserAccount userAccount, bool isCurrentUser) {
    // For current user, try to use avatar from UserAccount (which comes from /api/frontend/account/me)
    if (isCurrentUser && userAccount.avatar?.url64 != null) {
      return userAccount.avatar!.url64!;
    }

    // For any user, try to use avatar from Users model (which comes from /api/admin/users)
    if (user.avatar?.url64 != null) {
      return user.avatar!.url64!;
    }

    // Fallback to default avatar
    return 'https://www.azuracast.com/img/avatar.png';
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 16),
          SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Users user) {
    TextEditingController nameController =
        TextEditingController(text: user.name ?? '');
    TextEditingController emailController =
        TextEditingController(text: user.email ?? '');
    TextEditingController localeController =
        TextEditingController(text: user.locale ?? '');
    bool show24HourTime = user.show24HourTime == true;
    Set<String> selectedRoleIds =
        user.roles?.map((role) => role.id.toString()).toSet() ?? {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Color.fromARGB(255, 42, 42, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Edit User',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Email field (read-only)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withAlpha(76)),
                    ),
                    child: TextField(
                      controller: emailController,
                      enabled: false,
                      style: TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.email, color: Colors.grey),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Name field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withAlpha(76)),
                    ),
                    child: TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.blue.shade300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Locale field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withAlpha(76)),
                    ),
                    child: TextField(
                      controller: localeController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Locale',
                        labelStyle: TextStyle(color: Colors.blue.shade300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.language, color: Colors.blue),
                        hintText: 'e.g., en_US.UTF-8',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // 24 hour time toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withAlpha(76)),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        '24 Hour Time Format',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Use 24-hour time display',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      value: show24HourTime,
                      onChanged: (value) {
                        setState(() {
                          show24HourTime = value;
                        });
                      },
                      activeColor: Colors.blue,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Roles multi-selection
                  FutureBuilder<List<RoleModel>>(
                    future: roles,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.blue.withAlpha(76)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.admin_panel_settings,
                                        color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text(
                                      'Roles',
                                      style: TextStyle(
                                        color: Colors.blue.shade300,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...snapshot.data!.map((role) {
                                String roleId = role.id.toString();
                                bool isSelected =
                                    selectedRoleIds.contains(roleId);

                                return CheckboxListTile(
                                  title: Text(
                                    role.name ?? 'Unknown Role',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: role.isSuperAdmin == true
                                      ? Text(
                                          'Super Administrator',
                                          style: TextStyle(
                                              color: Colors.red.shade300,
                                              fontSize: 12),
                                        )
                                      : null,
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedRoleIds.add(roleId);
                                      } else {
                                        selectedRoleIds.remove(roleId);
                                      }
                                    });
                                  },
                                  activeColor: Colors.blue,
                                  checkColor: Colors.white,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                );
                              }).toList(),
                              SizedBox(height: 8),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.blue.withAlpha(76)),
                          ),
                          child: Row(
                            children: [
                              CircularProgressIndicator(
                                  color: Colors.blue, strokeWidth: 2),
                              SizedBox(width: 16),
                              Text(
                                'Loading roles...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => _updateUser(user, nameController.text,
                  localeController.text, show24HourTime, selectedRoleIds),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateUserDialog() {
    TextEditingController emailController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController localeController =
        TextEditingController(text: 'en_US');
    bool show24HourTime = false;
    Set<String> selectedRoleIds = {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Color.fromARGB(255, 42, 42, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.person_add, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Create User',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Email field (required)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withAlpha(76)),
                    ),
                    child: TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        labelStyle: TextStyle(color: Colors.green.shade300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.email, color: Colors.green),
                        hintText: 'user@example.com',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Password field (required)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withAlpha(76)),
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password *',
                        labelStyle: TextStyle(color: Colors.green.shade300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.lock, color: Colors.green),
                        hintText: 'Minimum 8 characters',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Name field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withAlpha(76)),
                    ),
                    child: TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.green.shade300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.person, color: Colors.green),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Locale field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withAlpha(76)),
                    ),
                    child: TextField(
                      controller: localeController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Locale',
                        labelStyle: TextStyle(color: Colors.green.shade300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.language, color: Colors.green),
                        hintText: 'e.g., en_US',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // 24 hour time toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withAlpha(76)),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        '24 Hour Time Format',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Use 24-hour time display',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      value: show24HourTime,
                      onChanged: (value) {
                        setState(() {
                          show24HourTime = value;
                        });
                      },
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Roles multi-selection
                  FutureBuilder<List<RoleModel>>(
                    future: roles,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.green.withAlpha(76)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.admin_panel_settings,
                                        color: Colors.green),
                                    SizedBox(width: 8),
                                    Text(
                                      'Roles',
                                      style: TextStyle(
                                        color: Colors.green.shade300,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...snapshot.data!.map((role) {
                                String roleId = role.id.toString();
                                bool isSelected =
                                    selectedRoleIds.contains(roleId);

                                return CheckboxListTile(
                                  title: Text(
                                    role.name ?? 'Unknown Role',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: role.isSuperAdmin == true
                                      ? Text(
                                          'Super Administrator',
                                          style: TextStyle(
                                              color: Colors.red.shade300,
                                              fontSize: 12),
                                        )
                                      : null,
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedRoleIds.add(roleId);
                                      } else {
                                        selectedRoleIds.remove(roleId);
                                      }
                                    });
                                  },
                                  activeColor: Colors.green,
                                  checkColor: Colors.white,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                );
                              }).toList(),
                              SizedBox(height: 8),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.green.withAlpha(76)),
                          ),
                          child: Row(
                            children: [
                              CircularProgressIndicator(
                                  color: Colors.green, strokeWidth: 2),
                              SizedBox(width: 16),
                              Text(
                                'Loading roles...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => _createUser(
                emailController.text,
                passwordController.text,
                nameController.text,
                localeController.text,
                show24HourTime,
                selectedRoleIds,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                'Create',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createUser(
    String email,
    String password,
    String name,
    String locale,
    bool show24HourTime,
    Set<String> selectedRoleIds,
  ) async {
    // Validation
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 8 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> userData = {
      'email': email,
      'new_password': password,
      'name': name.isNotEmpty ? name : null,
      'locale': locale.isNotEmpty ? locale : null,
      'show_24_hour_time': show24HourTime,
    };

    if (selectedRoleIds.isNotEmpty) {
      userData['roles'] = selectedRoleIds.toList();
    }

    try {
      var response = await createUser(
        url: widget.url,
        apiKey: widget.apiKey,
        userData: userData,
      );

      Navigator.pop(context);

      if (response.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create user: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteUser(Users user) async {
    if (user.id == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid user ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      var response = await deleteUser(
        url: widget.url,
        apiKey: widget.apiKey,
        userId: user.id!,
      );

      Navigator.pop(context);

      if (response.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteUserDialog(Users user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 42, 42, 42),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Delete User',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this user?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withAlpha(76)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email: ${user.email ?? 'N/A'}',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  if (user.name != null && user.name!.isNotEmpty)
                    Text(
                      'Name: ${user.name}',
                      style: TextStyle(color: Colors.grey.shade300),
                    ),
                  Text(
                    'ID: ${user.id?.toString() ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              '⚠️ This action cannot be undone!',
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => _deleteUser(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _updateUser(Users user, String name, String locale, bool show24HourTime,
      Set<String> selectedRoleIds) async {
    if (user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid user ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> updateData = {
      'name': name.isNotEmpty ? name : null,
      'locale': locale.isNotEmpty ? locale : null,
      'show_24_hour_time': show24HourTime,
    };

    if (selectedRoleIds.isNotEmpty) {
      updateData['roles'] = selectedRoleIds.toList();
    }

    try {
      var response = await updateUser(
        url: widget.url,
        apiKey: widget.apiKey,
        userId: user.id!,
        userData: updateData,
      );

      Navigator.pop(context);

      if (response.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
