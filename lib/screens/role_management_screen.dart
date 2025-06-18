import 'dart:async';
import 'dart:convert';
import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/api_response.dart';
import 'package:azuracastadmin/models/roles.dart';
import 'package:azuracastadmin/models/permissions.dart';
import 'package:azuracastadmin/models/station.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';

class RoleManagementScreen extends StatefulWidget {
  final String url;
  final String apiKey;

  const RoleManagementScreen({
    super.key,
    required this.url,
    required this.apiKey,
  });

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen>
    with TickerProviderStateMixin {
  late Future<List<RoleModel>> roles;
  late Future<PermissionsModel> permissions;
  late Future<List<Station>> stations;
  bool _isRefreshing = false;
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

    _loadData();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      roles = fetchRoles(widget.url, widget.apiKey);
      permissions = fetchPermissions(widget.url, widget.apiKey);
      stations = fetchStations(widget.url, widget.apiKey).then((stationsData) =>
          stationsData.map((data) => Station.fromJson(data)).toList());

      // Wait for all futures to complete
      await Future.wait([roles, permissions, stations]);
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _showCreateRoleDialog() {
    TextEditingController nameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    Set<String> selectedGlobalPermissions = {};
    Map<int, Set<String>> selectedStationPermissions = {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Create New Role',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role Name
                          TextFormField(
                            controller: nameController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Role Name',
                              labelStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a role name';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 20),

                          // Permissions
                          FutureBuilder<PermissionsModel>(
                            future: permissions,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return _buildPermissionsSection(
                                  snapshot.data!,
                                  selectedGlobalPermissions,
                                  selectedStationPermissions,
                                  setDialogState,
                                );
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error loading permissions: ${snapshot.error}',
                                  style: TextStyle(color: Colors.red),
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
                        ],
                      ),
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(width: 10),
                      FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.blue),
                        ),
                        onPressed: () => _createRole(
                          nameController.text,
                          selectedGlobalPermissions,
                          selectedStationPermissions,
                        ),
                        child: Text(
                          'Create',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditRoleDialog(RoleModel role) {
    TextEditingController nameController =
        TextEditingController(text: role.name ?? '');
    final _formKey = GlobalKey<FormState>();
    Set<String> selectedGlobalPermissions =
        Set.from(role.permissions?.global ?? []);
    Map<int, Set<String>> selectedStationPermissions = {};

    // Initialize station permissions
    if (role.permissions?.station != null) {
      for (var stationPerm in role.permissions!.station!) {
        selectedStationPermissions[stationPerm.id!] =
            Set.from(stationPerm.permissions ?? []);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Edit Role: ${role.name}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role Name
                          TextFormField(
                            controller: nameController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Role Name',
                              labelStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a role name';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 20),

                          // Permissions
                          FutureBuilder<PermissionsModel>(
                            future: permissions,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return _buildPermissionsSection(
                                  snapshot.data!,
                                  selectedGlobalPermissions,
                                  selectedStationPermissions,
                                  setDialogState,
                                );
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error loading permissions: ${snapshot.error}',
                                  style: TextStyle(color: Colors.red),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(width: 10),
                      FilledButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.orange),
                        ),
                        onPressed: () => _updateRole(
                          role.id!,
                          nameController.text,
                          selectedGlobalPermissions,
                          selectedStationPermissions,
                        ),
                        child: Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsSection(
    PermissionsModel permissionsModel,
    Set<String> selectedGlobalPermissions,
    Map<int, Set<String>> selectedStationPermissions,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Global Permissions
        Text(
          'Global Permissions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        if (permissionsModel.global != null)
          ...permissionsModel.global!.map((permission) {
            return CheckboxListTile(
              title: Text(
                permission.name ?? '',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              subtitle: Text(
                permission.id ?? '',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              value: selectedGlobalPermissions.contains(permission.id),
              onChanged: (bool? value) {
                setDialogState(() {
                  if (value == true) {
                    selectedGlobalPermissions.add(permission.id ?? '');
                  } else {
                    selectedGlobalPermissions.remove(permission.id);
                  }
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            );
          }).toList(),

        SizedBox(height: 20),

        // Station Permissions
        Text(
          'Station Permissions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        FutureBuilder<List<Station>>(
          future: stations,
          builder: (context, stationSnapshot) {
            if (stationSnapshot.hasData) {
              return Column(
                children: stationSnapshot.data!.map((station) {
                  int stationId = station.id ?? 0;
                  String stationName = station.name != null
                      ? utf8.decode(station.name!.codeUnits)
                      : 'Unknown Station';

                  selectedStationPermissions.putIfAbsent(stationId, () => {});

                  return ExpansionTile(
                    title: Text(
                      stationName,
                      style: TextStyle(color: Colors.white),
                    ),
                    children: permissionsModel.station?.map((permission) {
                          return CheckboxListTile(
                            title: Text(
                              permission.name ?? '',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            subtitle: Text(
                              permission.id ?? '',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            value: selectedStationPermissions[stationId]!
                                .contains(permission.id),
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedStationPermissions[stationId]!
                                      .add(permission.id ?? '');
                                } else {
                                  selectedStationPermissions[stationId]!
                                      .remove(permission.id);
                                }
                              });
                            },
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
                          );
                        }).toList() ??
                        [],
                  );
                }).toList(),
              );
            } else {
              return Text(
                'Loading stations...',
                style: TextStyle(color: Colors.grey),
              );
            }
          },
        ),
      ],
    );
  }

  void _createRole(
    String name,
    Set<String> globalPermissions,
    Map<int, Set<String>> stationPermissions,
  ) async {
    if (name.isEmpty) {
      _showErrorMessage('Please enter a role name');
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Build station permissions list
      List<StationPermission> stationPermissionsList = [];
      stationPermissions.forEach((stationId, permissions) {
        if (permissions.isNotEmpty) {
          stationPermissionsList.add(StationPermission(
            id: stationId,
            permissions: permissions.toList(),
          ));
        }
      });

      RolePermissions rolePermissions = RolePermissions(
        global: globalPermissions.toList(),
        station: stationPermissionsList,
      );

      ApiResponse response = await createRole(
        url: widget.url,
        apiKey: widget.apiKey,
        name: name,
        permissions: rolePermissions,
      );

      if (response.success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.green.withValues(alpha: 0.2),
          ),
        );
        _loadData();
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      _showErrorMessage('Error creating role: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _updateRole(
    int roleId,
    String name,
    Set<String> globalPermissions,
    Map<int, Set<String>> stationPermissions,
  ) async {
    if (name.isEmpty) {
      _showErrorMessage('Please enter a role name');
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Build station permissions list
      List<StationPermission> stationPermissionsList = [];
      stationPermissions.forEach((stationId, permissions) {
        if (permissions.isNotEmpty) {
          stationPermissionsList.add(StationPermission(
            id: stationId,
            permissions: permissions.toList(),
          ));
        }
      });

      RolePermissions rolePermissions = RolePermissions(
        global: globalPermissions.toList(),
        station: stationPermissionsList,
      );

      ApiResponse response = await updateRole(
        url: widget.url,
        apiKey: widget.apiKey,
        roleId: roleId,
        name: name,
        permissions: rolePermissions,
      );

      if (response.success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.green.withValues(alpha: 0.2),
          ),
        );
        _loadData();
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      _showErrorMessage('Error updating role: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showDeleteRoleDialog(RoleModel role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          'Delete Role',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete the role "${role.name}"?\n\nThis action cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteRole(role.id!);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteRole(int roleId) async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      ApiResponse response = await deleteRole(
        url: widget.url,
        apiKey: widget.apiKey,
        roleId: roleId,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.green.withValues(alpha: 0.2),
          ),
        );
        _loadData();
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      _showErrorMessage('Error deleting role: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.red),
        ),
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
            'Role Management',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () => _showCreateRoleDialog(),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              tooltip: 'Create Role',
            ),
            IconButton(
              onPressed: _isRefreshing ? null : _loadData,
              icon: _isRefreshing
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
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: FutureBuilder<List<RoleModel>>(
                    future: roles,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return _buildRolesList(snapshot.data!);
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
                                'Error Loading Roles',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              FilledButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Colors.blue),
                                ),
                                onPressed: _loadData,
                                child: Text('Retry'),
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
                                'Loading roles...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRolesList(List<RoleModel> rolesList) {
    if (rolesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.grey,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No roles found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first role to get started',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: rolesList.length,
      itemBuilder: (context, index) {
        RoleModel role = rolesList[index];
        return _buildRoleCard(role);
      },
    );
  }

  Widget _buildRoleCard(RoleModel role) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: role.isSuperAdmin == true
                        ? Colors.red.withValues(alpha: 0.2)
                        : Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          role.isSuperAdmin == true ? Colors.red : Colors.blue,
                    ),
                  ),
                  child: Text(
                    role.name ?? 'Unknown Role',
                    style: TextStyle(
                      color: role.isSuperAdmin == true
                          ? Colors.red.shade300
                          : Colors.blue.shade300,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                if (role.isSuperAdmin != true) ...[
                  IconButton(
                    onPressed: () => _showEditRoleDialog(role),
                    icon: Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit Role',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteRoleDialog(role),
                    icon: Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Role',
                  ),
                ],
              ],
            ),

            SizedBox(height: 12),

            // Permissions
            if (role.permissions != null) ...[
              // Global Permissions
              if (role.permissions!.global != null &&
                  role.permissions!.global!.isNotEmpty) ...[
                Text(
                  'Global Permissions',
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
                  children: role.permissions!.global!
                      .map((permission) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              permission,
                              style: TextStyle(
                                color: Colors.green.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 12),
              ],

              // Station Permissions
              if (role.permissions!.station != null &&
                  role.permissions!.station!.isNotEmpty) ...[
                Text(
                  'Station Permissions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...role.permissions!.station!.map((stationPerm) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Station ID: ${stationPerm.id}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6),
                        if (stationPerm.permissions != null)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: stationPerm.permissions!
                                .map((permission) => Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                            Border.all(color: Colors.orange),
                                      ),
                                      child: Text(
                                        permission,
                                        style: TextStyle(
                                          color: Colors.orange.shade300,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],

            // Super Admin Badge
            if (role.isSuperAdmin == true) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Super Administrator - Full Access',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
