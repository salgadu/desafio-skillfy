import 'package:desafio_skillfy/app/core/ui/theme/theme_controller.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart'; // Importe o modelo Task
import 'package:desafio_skillfy/app/module/task_management/ui/screens/dashboard_screen.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/screens/task_form_screen.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/screens/task_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:desafio_skillfy/app/core/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        themeController.initializeTheme();
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gestão de Tarefas',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          // Remova initialRoute e routes
          // initialRoute: '/',
          // routes: {
          //   '/': (context) => const DashboardScreen(),
          //   '/task_list': (context) => const TaskListScreen(),
          //   '/task_form': (context) => const TaskFormScreen(),
          // },

          // Use onGenerateRoute para lidar com as rotas dinamicamente
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (_) => const DashboardScreen(),
                );
              case '/task_list':
                return MaterialPageRoute(
                  builder: (_) => const TaskListScreen(),
                );
              case '/task_form':
                // Extrai o argumento (que deve ser um objeto Task ou null)
                final task = settings.arguments as Task?;
                return MaterialPageRoute(
                  builder: (context) => TaskFormScreen(
                    taskToEdit:
                        task, // Passa a tarefa para o construtor da tela de formulário
                  ),
                );
              default:
                // Rota padrão para páginas não encontradas
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('Erro: Página não encontrada!')),
                  ),
                );
            }
          },
        );
      },
    );
  }
}
