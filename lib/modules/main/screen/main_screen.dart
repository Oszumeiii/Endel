import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../soundscape/presentation/screens/soundscape_screen.dart';

/// Màn hình chính của Endel Soundscape:
/// - Hiển thị trực tiếp giao diện phát âm thanh không gian & đồng hồ toàn màn hình
/// - Đã loại bỏ hoàn toàn appbar và các tab home/profile ở dưới góc màn hình theo yêu cầu
@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SoundscapeScreen();
  }
}