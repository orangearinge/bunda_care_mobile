import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform, exit;
import 'package:flutter/services.dart';
import '../utils/styles.dart';
import '../utils/dialogs.dart';

class MainNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigation({super.key, required this.navigationShell});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  bool _isDialogShowing = false;
  final List<Object> _backInvocationHistory = [];

  Future<void> _confirmExit() async {
    if (_isDialogShowing || !mounted) return;

    _isDialogShowing = true;
    final shouldExit = await Dialogs.showExitConfirmation(context);
    _isDialogShowing = false;

    if (shouldExit && mounted) {
      if (Platform.isAndroid || Platform.isIOS) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    }
  }

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        final invocation = Object();
        _backInvocationHistory.add(invocation);

        if (_backInvocationHistory.length > 1) {
          _backInvocationHistory.clear();
          return;
        }

        Future.delayed(const Duration(milliseconds: 200), () {
          _backInvocationHistory.clear();
        });

        if (!_isDialogShowing && mounted) {
          await _confirmExit();
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, Icons.home, 0),
                  _buildNavItem(
                    Icons.chat_bubble_outline,
                    Icons.chat_bubble,
                    1,
                  ),
                  _buildNavItem(
                    Icons.photo_camera_outlined,
                    Icons.photo_camera,
                    2,
                  ),
                  _buildNavItem(Icons.menu_book_outlined, Icons.menu_book, 3),
                  _buildNavItem(Icons.person_outline, Icons.person, 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData iconOutlined, IconData iconFilled, int index) {
    bool isSelected = widget.navigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppStyles.pinkGradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isSelected ? iconFilled : iconOutlined,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 28,
        ),
      ),
    );
  }
}
