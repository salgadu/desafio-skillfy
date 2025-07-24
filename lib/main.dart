import 'package:desafio_skillfy/app/core/core_provider.dart';
import 'package:desafio_skillfy/app/module/task_management/task_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desafio_skillfy/app/app_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ...CoreProvider.providers,
        ...TaskManagementProvider.providers,
      ],
      child: const AppWidget(),
    ),
  );
}
