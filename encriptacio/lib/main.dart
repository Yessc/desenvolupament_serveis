import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/asymmetric/api.dart' as rsa;

void main() => runApp(const EncriptadorApp());

class EncriptadorApp extends StatelessWidget {
  const EncriptadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Container(
          width: 1000,
          height: 600,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildTab("Encriptar", isActive: true),
                  _buildTab("Desencriptar", isActive: false),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Expanded(
                child: Row(
                  children: [
                    Expanded(child: SeccioOperacio(esXifrat: true)),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFEEEEEE),
                    ),
                    Expanded(child: SeccioOperacio(esXifrat: false)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, {required bool isActive}) {
    return Container(
      width: 200,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFFF8F9FA),
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(
            color: isActive ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.black87 : Colors.grey,
        ),
      ),
    );
  }
}

class SeccioOperacio extends StatefulWidget {
  final bool esXifrat;
  const SeccioOperacio({super.key, required this.esXifrat});

  @override
  State<SeccioOperacio> createState() => _SeccioOperacioState();
}

class _SeccioOperacioState extends State<SeccioOperacio> {
  String clauPath = '';
  String arxiuInPath = '';
  String arxiuOutPath = '';

  @override
  void initState() {
    super.initState();
    if (!widget.esXifrat) {
      String home = Platform.environment['HOME'] ?? '';
      clauPath = '$home/.ssh/clau_privada.pem';
    }
  }

  void _notificar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _executar() {
    if (clauPath.isEmpty || arxiuInPath.isEmpty) {
      _notificar('Falten camps per omplir', Colors.orange);
      return;
    }

    try {
      final clauString = File(clauPath).readAsStringSync();
      final parser = enc.RSAKeyParser();
      final bytesEntrada = File(arxiuInPath).readAsBytesSync();

      if (widget.esXifrat) {
        //--encriptar proceso archivo en trozos de 200bytes y convierto cada trozo en un bloque ilegible y lo guardo como .enc
        final clauPub = parser.parse(clauString) as rsa.RSAPublicKey;
        final encriptador = enc.Encrypter(enc.RSA(publicKey: clauPub));
        List<int> result = [];
        for (var i = 0; i < bytesEntrada.length; i += 200) {
          int end = (i + 200 < bytesEntrada.length)
              ? i + 200
              : bytesEntrada.length;
          result.addAll(
            encriptador.encryptBytes(bytesEntrada.sublist(i, end)).bytes,
          );
        }
        File('$arxiuInPath.enc').writeAsBytesSync(result);
        _notificar('Arxiu encriptat!', Colors.green);
      } else {
        // ---desincreptar el programa lee los bloques del archivo cifrado  y los traduce de vuelta y cre un .desc
        final clauPriv = parser.parse(clauString) as rsa.RSAPrivateKey;
        final encriptador = enc.Encrypter(enc.RSA(privateKey: clauPriv));
        List<int> result = [];
        for (var i = 0; i < bytesEntrada.length; i += 256) {
          final chunk = bytesEntrada.sublist(i, i + 256);
          result.addAll(
            encriptador.decryptBytes(enc.Encrypted(Uint8List.fromList(chunk))),
          );
        }
        final desti = arxiuOutPath.isEmpty ? '$arxiuInPath.dec' : arxiuOutPath;
        File(desti).writeAsBytesSync(result);
        _notificar('Arxiu desxifrat!', Colors.green);
      }
    } catch (e) {
      _notificar('Error: Verifica que la clau sigui la correcta', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.esXifrat ? 'Encriptar Arxiu' : 'Desencriptar Arxiu',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 30),
          _label(
            widget.esXifrat ? "Clau pública (RSA):" : "Clau privada (RSA):",
          ),
          _selector(
            clauPath,
            (p) => setState(() => clauPath = p),
            editable: true,
          ),
          const SizedBox(height: 20),
          _label(widget.esXifrat ? "Arxiu a encriptar:" : "Arxiu xifrat:"),
          _selector(arxiuInPath, (p) => setState(() => arxiuInPath = p)),
          if (!widget.esXifrat) ...[
            const SizedBox(height: 20),
            _label("Ruta de destí:"),
            _selector(
              arxiuOutPath,
              (p) => setState(() => arxiuOutPath = p),
              editable: true,
            ),
          ],
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: _executar,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.esXifrat
                    ? const Color(0xFF0073E6)
                    : const Color(0xFF388E3C),
                foregroundColor: Colors.white,
                minimumSize: const Size(280, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                widget.esXifrat ? 'Encripta Arxiu' : 'Desencripta Arxiu',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );

  Widget _selector(
    String val,
    Function(String) onSelect, {
    bool editable = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 35,
            child: TextField(
              controller: TextEditingController(text: val)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: val.length),
                ),
              onChanged: onSelect,
              readOnly: !editable,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () async {
            FilePickerResult? r = await FilePicker.platform.pickFiles();
            if (r != null) onSelect(r.files.single.path!);
          },
          child: const Text("Navega...", style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
