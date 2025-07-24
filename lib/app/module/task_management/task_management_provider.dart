import 'package:desafio_skillfy/app/core/service/client/i_http_client.dart';
import 'package:desafio_skillfy/app/module/task_management/controller/task_controller.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_suggestions_time.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_task_management.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/suggestions_time_impl.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/task_management_impl.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class TaskManagementProvider {
  static List<SingleChildWidget> providers = [
    // Repository
    ProxyProvider<IHttpClient, ITaskManagement>(
      update: (context, httpClient, _) => TaskManagementImpl(httpClient),
    ),

    ProxyProvider<IHttpClient, ISuggestionsTime>(
      update: (context, httpClient, _) => SuggestionsTimeImpl(httpClient),
    ),

    // Controller
    ChangeNotifierProxyProvider2<
      ITaskManagement,
      ISuggestionsTime,
      TaskController
    >(
      create: (context) => TaskController(
        context.read<ITaskManagement>(),
        context.read<ISuggestionsTime>(),
      ),
      update: (context, repository, suggestionsRepository, controller) {
        if (controller == null) {
          return TaskController(repository, suggestionsRepository);
        }
        return controller;
      },
    ),
  ];
}
