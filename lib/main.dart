
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

// ============================================================
// COLORES Y CONFIGURACIÓN
// ============================================================

const Color gold = Color(0xFFFFB83D);
const Color background = Color(0xFF101010);
const Color panel = Color(0xFF1D1D1D);
const Color white = Colors.white;

const String operatorPassword = '1234';

// ============================================================
// POSICIONES DEL LOGO
// ============================================================

enum LogoPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

// ============================================================
// CONFIGURACIÓN DEL EVENTO
// ============================================================

class EventConfig {
  String eventName;
  String logoPath;
  LogoPosition position;
  double logoSize;
  bool logoEnabled;

  EventConfig({
    this.eventName = 'PALOMITOPTY SNAP',
    this.logoPath = '',
    this.position = LogoPosition.bottomRight,
    this.logoSize = 0.20,
    this.logoEnabled = true,
  });

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('eventName', eventName);
    await prefs.setString('logoPath', logoPath);
    await prefs.setString('logoPosition', position.name);
    await prefs.setDouble('logoSize', logoSize);
    await prefs.setBool('logoEnabled', logoEnabled);
  }

  static Future<EventConfig> load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedPosition = prefs.getString('logoPosition');

    return EventConfig(
      eventName:
          prefs.getString('eventName') ?? 'PALOMITOPTY SNAP',
      logoPath: prefs.getString('logoPath') ?? '',
      position: LogoPosition.values.firstWhere(
        (element) => element.name == savedPosition,
        orElse: () => LogoPosition.bottomRight,
      ),
      logoSize: (prefs.getDouble('logoSize') ?? 0.20)
          .clamp(0.08, 0.40),
      logoEnabled: prefs.getBool('logoEnabled') ?? true,
    );
  }
}

// ============================================================
// FUNCIÓN PRINCIPAL
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  runApp(const PalomitoptySnap());
}

// ============================================================
// APLICACIÓN
// ============================================================

class PalomitoptySnap extends StatelessWidget {
  const PalomitoptySnap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PALOMITOPTY SNAP',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ============================================================
// PANTALLA DE BIENVENIDA
// ============================================================

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> openOperator(BuildContext context) async {
    final controller = TextEditingController();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: panel,
            title: const Text('Acceso de operador'),
            content: TextField(
              controller: controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    controller.text == operatorPassword,
                  );
                },
                child: const Text('Ingresar'),
              ),
            ],
          );
        },
      );

      if (result == true && context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const OperatorScreen(),
          ),
        );
      } else if (result == false && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña incorrecta o acceso cancelado'),
          ),
        );
      }
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF202020),
                  Color(0xFF080808),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white54,
                size: 28,
              ),
              onPressed: () => openOperator(context),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: gold,
                  size: 90,
                ),
                const SizedBox(height: 20),
                const Text(
                  'PALOMITOPTY',
                  style: TextStyle(
                    color: gold,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const Text(
                  'SNAP',
                  style: TextStyle(
                    color: white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'TODO LO QUE NECESITAS PARA TU FIESTA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 45),
                SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      'INICIAR FOTOGRAFÍAS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CameraScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODO OPERADOR
// ============================================================

class OperatorScreen extends StatefulWidget {
  const OperatorScreen({super.key});

  @override
  State<OperatorScreen> createState() => _OperatorScreenState();
}

class _OperatorScreenState extends State<OperatorScreen> {
  final TextEditingController eventController =
      TextEditingController();

  EventConfig config = EventConfig();

  bool loading = true;
  bool saving = false;
  bool selectingLogo = false;

  String loadError = '';

  @override
  void initState() {
    super.initState();

    debugPrint('OPERADOR: pantalla iniciada');

    loadConfig();
  }

  // ==========================================================
  // CARGAR CONFIGURACIÓN
  // ==========================================================

  Future<void> loadConfig() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      loadError = '';
    });

    try {
      debugPrint('OPERADOR: cargando preferencias');

      final loadedConfig = await EventConfig.load().timeout(
        const Duration(seconds: 15),
      );

      if (!mounted) return;

      config = loadedConfig;

      eventController.text = config.eventName;

      if (config.logoPath.isNotEmpty) {
        final logoFile = File(config.logoPath);

        if (!await logoFile.exists()) {
          config.logoPath = '';
        }
      }

      if (!mounted) return;

      setState(() {
        loading = false;
        loadError = '';
      });

      debugPrint('OPERADOR: configuración cargada correctamente');
    } catch (e, stackTrace) {
      debugPrint('OPERADOR ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      config = EventConfig();

      eventController.text = config.eventName;

      setState(() {
        loading = false;
        loadError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    debugPrint('OPERADOR: cerrando pantalla');

    eventController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SELECCIONAR LOGO
  // ==========================================================

  Future<void> selectLogo() async {
    if (selectingLogo || saving) return;

    setState(() {
      selectingLogo = true;
    });

    try {
      final picker = ImagePicker();

      final XFile? selected = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (selected == null) return;

      final directory = await getApplicationDocumentsDirectory();

      final extension = selected.path.contains('.')
          ? selected.path.split('.').last.toLowerCase()
          : 'png';

      final destination = File(
        '${directory.path}/event_logo.$extension',
      );

      await File(selected.path).copy(destination.path);

      if (!mounted) return;

      setState(() {
        config.logoPath = destination.path;
        config.logoEnabled = true;
      });

      showMessage('Logo seleccionado correctamente');
    } catch (e) {
      showMessage('No se pudo cargar el logo: $e');
    } finally {
      if (mounted) {
        setState(() {
          selectingLogo = false;
        });
      }
    }
  }

  // ==========================================================
  // ELIMINAR LOGO
  // ==========================================================

  Future<void> deleteLogo() async {
    if (saving || selectingLogo) return;

    try {
      if (config.logoPath.isNotEmpty) {
        final file = File(config.logoPath);

        if (await file.exists()) {
          await file.delete();
        }
      }

      if (!mounted) return;

      setState(() {
        config.logoPath = '';
      });

      showMessage('Logo eliminado');
    } catch (e) {
      showMessage('No se pudo eliminar el logo: $e');
    }
  }

  // ==========================================================
  // GUARDAR CONFIGURACIÓN
  // ==========================================================

  Future<void> saveConfig() async {
    if (saving || selectingLogo) return;

    setState(() {
      saving = true;
    });

    try {
      config.eventName = eventController.text.trim().isEmpty
          ? 'PALOMITOPTY SNAP'
          : eventController.text.trim();

      await config.save().timeout(
        const Duration(seconds: 15),
      );

      if (!mounted) return;

      showMessage('Configuración guardada correctamente');
    } catch (e) {
      showMessage('Error al guardar: $e');
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  // ==========================================================
  // MENSAJES
  // ==========================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================================
  // VISTA PREVIA DEL LOGO
  // ==========================================================

  Widget logoPreview() {
    if (config.logoPath.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: const Center(
          child: Text(
            'Selecciona un logo para el evento',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.white12,
            ),
          ),
          if (config.logoEnabled)
            Align(
              alignment: alignmentForPosition(config.position),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.file(
                  File(config.logoPath),
                  width: 180 * config.logoSize,
                  height: 130 * config.logoSize,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'No se pudo mostrar el logo',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // POSICIÓN DEL LOGO
  // ==========================================================

  Alignment alignmentForPosition(LogoPosition position) {
    switch (position) {
      case LogoPosition.topLeft:
        return Alignment.topLeft;
      case LogoPosition.topRight:
        return Alignment.topRight;
      case LogoPosition.bottomLeft:
        return Alignment.bottomLeft;
      case LogoPosition.bottomRight:
        return Alignment.bottomRight;
    }
  }

  Widget positionButton(
    String label,
    LogoPosition position,
    IconData icon,
  ) {
    final selected = config.position == position;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? gold : panel,
            foregroundColor: selected ? Colors.black : white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: saving
              ? null
              : () {
                  setState(() {
                    config.position = position;
                  });
                },
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PANTALLA DE CARGA
  // ==========================================================

  Widget loadingScreen() {
    return const Scaffold(
      backgroundColor: background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: gold),
            SizedBox(height: 20),
            Text(
              'CARGANDO CONFIGURACIÓN...',
              style: TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // INTERFAZ DEL OPERADOR
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return loadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONFIGURACIÓN DEL EVENTO'),
        backgroundColor: panel,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (loadError.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      border: Border.all(color: Colors.redAccent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AVISO DE CONFIGURACIÓN',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No se pudieron cargar las preferencias. '
                          'Se muestran valores predeterminados.\n$loadError',
                          style: const TextStyle(color: white),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: loadConfig,
                          icon: const Icon(Icons.refresh),
                          label: const Text('VOLVER A INTENTAR'),
                        ),
                      ],
                    ),
                  ),

                const Text(
                  'DATOS DEL EVENTO',
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: eventController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del evento',
                    hintText: 'Ejemplo: Navidad Jumbo Market',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'LOGO DE LA MARCA',
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 12),

                logoPreview(),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: selectingLogo || saving
                            ? null
                            : selectLogo,
                        icon: selectingLogo
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.image),
                        label: Text(
                          selectingLogo
                              ? 'CARGANDO LOGO...'
                              : 'SELECCIONAR LOGO',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: saving || selectingLogo
                          ? null
                          : deleteLogo,
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Eliminar logo',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SwitchListTile(
                  title: const Text(
                    'Mostrar logo en las fotografías',
                  ),
                  subtitle: const Text(
                    'Activa o desactiva la marca del evento',
                  ),
                  value: config.logoEnabled,
                  activeThumbColor: gold,
                  onChanged: saving
                      ? null
                      : (value) {
                          setState(() {
                            config.logoEnabled = value;
                          });
                        },
                ),

                const SizedBox(height: 15),

                const Text(
                  'POSICIÓN DEL LOGO',
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    positionButton(
                      'Arriba izq.',
                      LogoPosition.topLeft,
                      Icons.north_west,
                    ),
                    positionButton(
                      'Arriba der.',
                      LogoPosition.topRight,
                      Icons.north_east,
                    ),
                  ],
                ),

                Row(
                  children: [
                    positionButton(
                      'Abajo izq.',
                      LogoPosition.bottomLeft,
                      Icons.south_west,
                    ),
                    positionButton(
                      'Abajo der.',
                      LogoPosition.bottomRight,
                      Icons.south_east,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                const Text(
                  'TAMAÑO DEL LOGO',
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Slider(
                  value: config.logoSize,
                  min: 0.08,
                  max: 0.40,
                  divisions: 16,
                  activeColor: gold,
                  label: '${(config.logoSize * 100).round()}%',
                  onChanged: saving
                      ? null
                      : (value) {
                          setState(() {
                            config.logoSize = value;
                          });
                        },
                ),

                Text(
                  'Tamaño: ${(config.logoSize * 100).round()}%',
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : saveConfig,
                    icon: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      saving
                          ? 'GUARDANDO...'
                          : 'GUARDAR CONFIGURACIÓN DEL EVENTO',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'La configuración se conservará hasta que la cambies '
                  'para otro evento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PROCESAR FOTO Y APLICAR LOGO
// ============================================================

Future<Uint8List> createBrandedPhoto(
  String photoPath,
  EventConfig config,
) async {
  final photoFile = File(photoPath);
  final photoBytes = await photoFile.readAsBytes();

  final decodedPhoto = img.decodeImage(photoBytes);

  if (decodedPhoto == null) {
    throw Exception('No se pudo procesar la fotografía');
  }

  final photo = img.bakeOrientation(decodedPhoto);

  if (config.logoEnabled &&
      config.logoPath.isNotEmpty &&
      await File(config.logoPath).exists()) {
    final logoBytes = await File(config.logoPath).readAsBytes();
    final decodedLogo = img.decodeImage(logoBytes);

    if (decodedLogo != null) {
      final logo = img.bakeOrientation(decodedLogo);

      final maxLogoWidth = math.max(
        1,
        (photo.width * config.logoSize).round(),
      ).toInt();

      final maxLogoHeight = math.max(
        1,
        (photo.height * config.logoSize).round(),
      ).toInt();

      final scale = math.min(
        maxLogoWidth / logo.width,
        maxLogoHeight / logo.height,
      );

      final targetWidth = math.max(
        1,
        (logo.width * scale).round(),
      ).toInt();

      final targetHeight = math.max(
        1,
        (logo.height * scale).round(),
      ).toInt();

      final resizedLogo = img.copyResize(
        logo,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.average,
      );

      final margin = math.max(
        12,
        (math.min(photo.width, photo.height) * 0.025).round(),
      ).toInt();

      int x = 0;
      int y = 0;

      switch (config.position) {
        case LogoPosition.topLeft:
          x = margin;
          y = margin;
          break;

        case LogoPosition.topRight:
          x = photo.width - resizedLogo.width - margin;
          y = margin;
          break;

        case LogoPosition.bottomLeft:
          x = margin;
          y = photo.height - resizedLogo.height - margin;
          break;

        case LogoPosition.bottomRight:
          x = photo.width - resizedLogo.width - margin;
          y = photo.height - resizedLogo.height - margin;
          break;
      }

      x = x.clamp(
        0,
        math.max(0, photo.width - resizedLogo.width),
      ).toInt();

      y = y.clamp(
        0,
        math.max(0, photo.height - resizedLogo.height),
      ).toInt();

      img.compositeImage(
        photo,
        resizedLogo,
        dstX: x,
        dstY: y,
      );
    }
  }

  return Uint8List.fromList(
    img.encodeJpg(photo, quality: 95),
  );
}

// ============================================================
// CÁMARA
// ============================================================

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? cameraController;

  EventConfig config = EventConfig();

  bool loading = true;
  bool cameraReady = false;
  bool processing = false;
  bool photoSaved = false;
  bool initializingCamera = false;

  int countdown = 0;

  Uint8List? brandedBytes;

  Timer? countdownTimer;

  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    initializeScreen();
  }

  Future<void> initializeScreen() async {
    try {
      config = await EventConfig.load();
      await initializeCamera();
    } catch (e) {
      errorMessage = 'No se pudo iniciar la cámara: $e';
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  // ==========================================================
  // INICIALIZAR CÁMARA
  // ==========================================================

  Future<void> initializeCamera() async {
    if (initializingCamera) return;

    initializingCamera = true;

    CameraController? controller;

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No se encontraron cámaras');
      }

      CameraDescription selectedCamera = cameras.first;

      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      cameraController = controller;

      setState(() {
        cameraReady = true;
        errorMessage = '';
      });
    } catch (e) {
      if (controller != null) {
        await controller.dispose();
      }

      cameraController = null;

      if (mounted) {
        setState(() {
          cameraReady = false;
          errorMessage = 'Error al iniciar la cámara: $e';
        });
      }
    } finally {
      initializingCamera = false;
    }
  }

  // ==========================================================
  // CICLO DE VIDA
  // ==========================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final controller = cameraController;

      cameraController = null;

      if (controller != null) {
        controller.dispose();
      }

      if (mounted) {
        setState(() {
          cameraReady = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      if (mounted && !loading && cameraController == null) {
        initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    countdownTimer?.cancel();

    cameraController?.dispose();

    super.dispose();
  }

  // ==========================================================
  // CUENTA REGRESIVA Y CAPTURA
  // ==========================================================

  Future<void> startCapture() async {
    if (processing || countdown > 0 || !cameraReady) {
      return;
    }

    setState(() {
      brandedBytes = null;
      photoSaved = false;
      processing = true;
      countdown = 3;
    });

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (countdown > 1) {
          setState(() {
            countdown--;
          });
        } else {
          timer.cancel();

          setState(() {
            countdown = 0;
          });

          await takePhoto();
        }
      },
    );
  }

  Future<void> takePhoto() async {
    final controller = cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      if (mounted) {
        setState(() {
          processing = false;
        });
      }
      return;
    }

    try {
      final XFile photo = await controller.takePicture();

      final finalBytes = await createBrandedPhoto(
        photo.path,
        config,
      );

      if (!mounted) return;

      setState(() {
        brandedBytes = finalBytes;
        processing = false;
        photoSaved = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        processing = false;
        errorMessage = 'Error al tomar la fotografía: $e';
      });

      showMessage(errorMessage);
    }
  }

  // ==========================================================
  // GUARDAR EN FOTOS DEL IPAD
  // ==========================================================

  Future<void> saveAndPrintPhoto() async {
    if (brandedBytes == null || processing) return;

    setState(() {
      processing = true;
    });

    try {
      if (!photoSaved) {
        bool hasAccess = await Gal.hasAccess();

        if (!hasAccess) {
          hasAccess = await Gal.requestAccess();
        }

        if (!hasAccess) {
          throw Exception(
            'No se concedió permiso para guardar fotografías',
          );
        }

        final directory = await getTemporaryDirectory();

        final file = File(
          '${directory.path}/PALOMITOPTY_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        await file.writeAsBytes(
          brandedBytes!,
          flush: true,
        );

        await Gal.putImage(file.path);

        photoSaved = true;
      }

      if (!mounted) return;

      setState(() {
        processing = false;
      });

      showMessage('Fotografía guardada en Fotos del iPad');

      await printPhoto();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        processing = false;
      });

      showMessage('No se pudo guardar o imprimir: $e');
    }
  }

  // ==========================================================
  // IMPRESIÓN 4 X 6 PULGADAS
  // ==========================================================

  Future<void> printPhoto() async {
    if (brandedBytes == null) return;

    try {
      final imageBytes = brandedBytes!;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            4 * 72,
            6 * 72,
          ),
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Container(
              width: double.infinity,
              height: double.infinity,
              color: PdfColors.white,
              child: pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async {
          return pdf.save();
        },
        name: 'PALOMITOPTY_${DateTime.now().millisecondsSinceEpoch}',
        format: const PdfPageFormat(
          4 * 72,
          6 * 72,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      showMessage('Error al imprimir: $e');
    }
  }

  // ==========================================================
  // REPETIR FOTOGRAFÍA
  // ==========================================================

  void retakePhoto() {
    setState(() {
      brandedBytes = null;
      photoSaved = false;
      processing = false;
      countdown = 0;
    });
  }

  // ==========================================================
  // MENSAJES
  // ==========================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================================
  // VISTA DE CÁMARA
  // ==========================================================

  Widget buildCameraPreview() {
    final controller = cameraController;

    if (controller == null ||
        !cameraReady ||
        !controller.value.isInitialized ||
        controller.value.previewSize == null) {
      return const Center(
        child: CircularProgressIndicator(color: gold),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  // ==========================================================
  // INTERFAZ PRINCIPAL
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (brandedBytes != null)
            Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: Image.memory(
                brandedBytes!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                gaplessPlayback: true,
              ),
            )
          else if (loading)
            const Center(
              child: CircularProgressIndicator(color: gold),
            )
          else if (cameraReady)
            buildCameraPreview()
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: gold,
                      size: 60,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      errorMessage.isEmpty
                          ? 'No se pudo iniciar la cámara'
                          : errorMessage,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                          errorMessage = '';
                        });

                        await initializeCamera();

                        if (mounted) {
                          setState(() {
                            loading = false;
                          });
                        }
                      },
                      child: const Text('REINTENTAR'),
                    ),
                  ],
                ),
              ),
            ),

          // ENCABEZADO

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.80),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.camera_alt,
                    color: gold,
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'PALOMITOPTY SNAP',
                    style: TextStyle(
                      color: gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      config.eventName,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CUENTA REGRESIVA

          if (countdown > 0)
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gold,
                    width: 5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$countdown',
                    style: const TextStyle(
                      color: gold,
                      fontSize: 95,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),

          // PROCESANDO

          if (processing && brandedBytes == null)
            Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: const Center(
                child: CircularProgressIndicator(
                  color: gold,
                ),
              ),
            ),

          // BOTONES INFERIORES

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.90),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: brandedBytes == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              processing || !cameraReady
                                  ? null
                                  : startCapture,
                          icon: const Icon(Icons.camera),
                          label: const Text('TOMAR FOTO'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35,
                              vertical: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: processing ? null : retakePhoto,
                          icon: const Icon(Icons.refresh),
                          label: const Text('REPETIR'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: white,
                            side: const BorderSide(color: white),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          onPressed:
                              processing ? null : saveAndPrintPhoto,
                          icon: const Icon(Icons.print),
                          label: Text(
                            processing
                                ? 'PROCESANDO...'
                                : photoSaved
                                    ? 'IMPRIMIR OTRA VEZ'
                                    : 'GUARDAR E IMPRIMIR',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
