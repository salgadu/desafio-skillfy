import 'package:desafio_skillfy/app/core/service/client/http_client_impl.dart';
import 'package:desafio_skillfy/app/core/service/client/i_http_client.dart';
import 'package:desafio_skillfy/app/core/constants/env.dart';
import 'package:desafio_skillfy/app/core/service/storage/i_storage.dart';
import 'package:desafio_skillfy/app/core/service/storage/shared_preferences_impl.dart';
import 'package:desafio_skillfy/app/core/ui/theme/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class CoreProvider {
  static List<SingleChildWidget> providers = [
    Provider<IHttpClient>(
      create: (_) => DioHttpClient(DioFactory.dio(), baseUrl: baseUrl),
    ),

    Provider<IStorage>(create: (_) => SharedPreferencesImpl()),

    ChangeNotifierProvider<ThemeController>(
      create: (context) => ThemeController(context.read<IStorage>()),
    ),
  ];
}
