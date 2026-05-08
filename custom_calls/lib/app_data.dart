import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'constants.dart';
import 'drawable.dart';

const streamingModel = 'granite4:3b';
const functionCallingModel = 'granite4:3b';
const jsonFixModel = 'granite4:3b';

class AppData extends ChangeNotifier {
  String _responseText = "";
  bool _isLoading = false;
  bool _isInitial = true;
  http.Client? _client;
  IOClient? _ioClient;
  HttpClient? _httpClient;
  StreamSubscription<String>? _streamSubscription;

  final List<Drawable> drawables = [];
  ///lista donde guardo las figuras para que recuerd la ia
  List<Map<String, dynamic>> _chatHistory = [];
  String get responseText =>
      _isInitial ? "..." : (_isLoading ? "Esperant ..." : _responseText);

  bool get isLoading => _isLoading;

  AppData() {
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void addDrawable(Drawable drawable) {
    drawables.add(drawable);
    notifyListeners();
  }
  //helper para convertir string hrx a objectos color de fluter
  Color _parseColor(dynamic value) {
    if (value == null || value is! String || value.isEmpty) return Colors.black;
    try {
      String hex = value.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex'; // Añadir opacidad si no está
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.black;
    }
  }

  Future<void> callStream({required String question}) async {
    _isInitial = false;
    setLoading(true);

    try {
      var request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/generate'),
      );

      request.headers.addAll({'Content-Type': 'application/json'});
      request.body = jsonEncode(
          {'model': streamingModel, 'prompt': question, 'stream': true});

      var streamedResponse = await _client!.send(request);
      _streamSubscription =
          streamedResponse.stream.transform(utf8.decoder).listen((value) {
        var jsonResponse = jsonDecode(value);
        var jsonResponseStr = jsonResponse['response'];
        _responseText = "$_responseText\n$jsonResponseStr";
        notifyListeners();
      }, onError: (error) {
        if (error is http.ClientException &&
            error.message == 'Connection closed while receiving data') {
          _responseText += "\nRequest cancelled.";
        } else {
          _responseText += "\nError during streaming: $error";
        }
        setLoading(false);
        notifyListeners();
      }, onDone: () {
        setLoading(false);
      });
    } catch (e) {
      _responseText = "\nError during streaming.";
      setLoading(false);
      notifyListeners();
    }
  }

  Future<dynamic> fixJsonInStrings(dynamic data) async {
    if (data is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      for (final entry in data.entries) {
        result[entry.key] = await fixJsonInStrings(entry.value);
      }
      return result;
    } else if (data is List) {
      return Future.wait(data.map((value) => fixJsonInStrings(value)));
    } else if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        return data;
      }

      try {
        // Si és JSON dins d'una cadena, el deserialitzem
        final parsed = jsonDecode(data);
        return fixJsonInStrings(parsed);
      } catch (_) {
        if (_looksLikeJsonCandidate(trimmed)) {
          final repairedJson = await _repairJsonWithAi(trimmed);
          if (repairedJson != null) {
            return fixJsonInStrings(repairedJson);
          }
        }

        // Si no és JSON o no es pot reparar, retornem la cadena tal qual
        return data;
      }
    }
    // Retorna qualsevol altre tipus sense canvis (números, booleans, etc.)
    return data;
  }

  bool _looksLikeJsonCandidate(String value) {
    return value.startsWith('{') ||
        value.startsWith('[') ||
        ((value.contains('{') || value.contains('[')) && value.contains(':'));
  }

  Future<dynamic> _repairJsonWithAi(String rawJson) async {
    const apiUrl = 'http://localhost:11434/api/chat';
    final body = {
      "model": jsonFixModel,
      "stream": false,
      "format": "json",
      "messages": [
        {
          "role": "system",
          "content":
              "You repair malformed JSON. Return only valid JSON that preserves the original intent and values as closely as possible."
        },
        {
          "role": "user",
          "content":
              "Repair this malformed JSON and return only the fixed JSON:\n$rawJson"
        }
      ]
    };

    try {
      final response = await _client!.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final jsonResponse = jsonDecode(response.body);
      final content = jsonResponse['message']?['content'];
      if (content is! String || content.trim().isEmpty) {
        return null;
      }

      return jsonDecode(content);
    } catch (_) {
      return null;
    }
  }

  dynamic cleanKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.trim()] = cleanKeys(v);
      });
      return result;
    }
    if (value is List) {
      return value.map(cleanKeys).toList();
    }
    return value;
  }

  Future<void> callWithCustomTools({required String userPrompt}) async {
  const apiUrl = 'http://localhost:11434/api/chat';
  _isInitial = false;
  setLoading(true);
  _responseText = "";

  // 1. Añadimos el mensaje del usuario al historial
  _chatHistory.add({"role": "user", "content": userPrompt});

  final body = {
    "model": functionCallingModel,
    "stream": false,
    "messages": [
      {
        "role": "system",
        "content": "Eres un asistente de dibujo vectorial. El lienzo es de 500x500. "
            "REGLAS DE ORO:\n"
            "1. Cada vez que dibujes algo, asígnale un ID numérico simple (1, 2, 3...).\n"
            "2. Memoriza ese ID. Si el usuario te pide moverlo, o que le cambies de posicion usa 'update_drawable' con ese ID, Si el usuario te pide eliminar, borrar  o olvidar usa 'delete_drawable'.\n"
            "3. Responde siempre con la herramienta adecuada."
      },
      
      ..._chatHistory, //acumulamos historial 
    ],
    "tools": tools
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final message = jsonResponse['message'];
      //guardamos respuesta de la ia para que no olvide el id que genero
      _chatHistory.add(message);

      if (message['tool_calls'] != null) {
        final toolCalls = (message['tool_calls'] as List)
            .map((e) => cleanKeys(e))
            .toList();
        for (final tc in toolCalls) {
          if (tc['function'] != null) {
            await _processFunctionCall(tc['function']);
          }
        }
      }
    }
    setLoading(false);
  } catch (e) {
    print("Error during API call: $e");
    setLoading(false);
  }
}

  void cancelRequests() {
    _streamSubscription?.cancel();
    _httpClient?.close(force: true);
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
    _responseText += "\nRequest cancelled.";
    setLoading(false);
    notifyListeners();
  }
  //agregamos funcion para limpiar 
  void clearCanvas() {
    drawables.clear();
    _chatHistory.clear();
    _responseText = "Lienzo reiniciado.";
    notifyListeners();
  }

  double parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  double _randomBetween(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }

  
    
Future<void> _processFunctionCall(Map<String, dynamic> functionCall) async {
  final fixedJson = await fixJsonInStrings(functionCall);
  final parameters = fixedJson['arguments'] ?? <String, dynamic>{};
  final String name = fixedJson['name'] ?? "";

  // Prioridad al ID que asigne la IA (Reglas de Oro)
  String id = parameters['id']?.toString() ?? 
              (DateTime.now().millisecondsSinceEpoch.toString());

  switch (name) {
    case 'draw_circle':
      addDrawable(Circle(
        id: id,
        center: Offset(parseDouble(parameters['x']), parseDouble(parameters['y'])),
        radius: max(1.0, parseDouble(parameters['radius'])),
        strokeColor: _parseColor(parameters['strokeColor']),
        fillColor: parameters['fillColor'] != null ? _parseColor(parameters['fillColor']) : null,
        strokeWidth: parseDouble(parameters['strokeWidth'] ?? 2.0),
      ));
      break;

    case 'draw_line':
      addDrawable(Line(
        id: id,
        start: Offset(parseDouble(parameters['startX']), parseDouble(parameters['startY'])),
        end: Offset(parseDouble(parameters['endX']), parseDouble(parameters['endY'])),
        color: _parseColor(parameters['color'] ?? parameters['strokeColor']),
        strokeWidth: parseDouble(parameters['strokeWidth'] ?? 2.0),
      ));
      break;

    case 'draw_rectangle':
      addDrawable(Rectangle(
        id: id,
        topLeft: Offset(parseDouble(parameters['topLeftX']), parseDouble(parameters['topLeftY'])),
        bottomRight: Offset(parseDouble(parameters['bottomRightX']), parseDouble(parameters['bottomRightY'])),
        strokeColor: _parseColor(parameters['strokeColor']),
        fillColor: parameters['fillColor'] != null ? _parseColor(parameters['fillColor']) : null,
        strokeWidth: parseDouble(parameters['strokeWidth'] ?? 2.0),
      ));
      break;

    case 'update_drawable':
        int index = drawables.indexWhere((d) => d.id == id);
        
        if (index != -1) {
          final old = drawables[index];
          
          //colores nuevos
          final nuevoColor = parameters['newColor'] ?? parameters['fillColor'] ?? parameters['color'];
          final nuevoBorde = parameters['strokeColor'] ?? parameters['newStrokeColor'];
          
          // coordenadas nuevas
          final double? nx = parameters['newX'] != null ? parseDouble(parameters['newX']) : 
                            (parameters['x'] != null ? parseDouble(parameters['x']) : null);
          final double? ny = parameters['newY'] != null ? parseDouble(parameters['newY']) : 
                            (parameters['y'] != null ? parseDouble(parameters['y']) : null);

          if (old is Circle) {
            drawables[index] = Circle(
              id: id,
              center: (nx != null || ny != null) 
                  ? Offset(nx ?? old.center.dx, ny ?? old.center.dy) 
                  : old.center,
              radius: parameters['newRadius'] != null ? parseDouble(parameters['newRadius']) : old.radius,
              strokeColor: nuevoBorde != null ? _parseColor(nuevoBorde) : 
                          (nuevoColor != null ? _parseColor(nuevoColor) : old.strokeColor),
              fillColor: nuevoColor != null ? _parseColor(nuevoColor) : old.fillColor,
              strokeWidth: parameters['strokeWidth'] != null ? parseDouble(parameters['strokeWidth']) : old.strokeWidth,
            );
          } else if (old is Rectangle) {
            double dx = (nx != null) ? nx - old.topLeft.dx : 0;
            double dy = (ny != null) ? ny - old.topLeft.dy : 0;
            
            drawables[index] = Rectangle(
              id: id,
              topLeft: Offset(old.topLeft.dx + dx, old.topLeft.dy + dy),
              bottomRight: Offset(old.bottomRight.dx + dx, old.bottomRight.dy + dy),
              strokeColor: nuevoBorde != null ? _parseColor(nuevoBorde) : 
                          (nuevoColor != null ? _parseColor(nuevoColor) : old.strokeColor),
              fillColor: nuevoColor != null ? _parseColor(nuevoColor) : old.fillColor,
              strokeWidth: parameters['strokeWidth'] != null ? parseDouble(parameters['strokeWidth']) : old.strokeWidth,
            );
          } else if (old is Line) {
            double dx = (nx != null) ? nx - old.start.dx : 0;
            double dy = (ny != null) ? ny - old.start.dy : 0;

            drawables[index] = Line(
              id: id,
              start: Offset(old.start.dx + dx, old.start.dy + dy),
              end: Offset(old.end.dx + dx, old.end.dy + dy),
              color: nuevoBorde != null ? _parseColor(nuevoBorde) : 
                    (nuevoColor != null ? _parseColor(nuevoColor) : old.color),
              strokeWidth: parameters['strokeWidth'] != null ? parseDouble(parameters['strokeWidth']) : old.strokeWidth,
            );
          }
          
          _responseText = "Figura $id actualizada correctamente.";
          notifyListeners(); 
        } else {
          print("ERROR: ID $id no encontrado. Disponibles: ${drawables.map((d) => d.id)}");
          _responseText = "No se pudo encontrar la figura $id.";
          notifyListeners();
        }
        break;
    
    case 'delete_drawable':
        drawables.removeWhere((d) => d.id == id);
        _responseText = "Figura $id eliminada.";
        notifyListeners();
        break;
    }
  }
}

