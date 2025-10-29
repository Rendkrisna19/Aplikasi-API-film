import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const omdbKey = 'cc31bf62'; // ganti kalau perlu

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OmdbDemo(),
      );
}

class OmdbDemo extends StatefulWidget {
  const OmdbDemo({super.key});
  @override
  State<OmdbDemo> createState() => _OmdbDemoState();
}

class _OmdbDemoState extends State<OmdbDemo> {
  Map<String, dynamic>? data;
  String? error;

  Future<void> fetchMovie(String title) async {
    setState(() { error = null; data = null; });
    final uri = Uri.https('www.omdbapi.com', '/', {
      't': title,           // atau pakai 'i': 'tt3896198'
      'apikey': omdbKey,    // harus 'apikey' (lowercase)
      'plot': 'full',
    });

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['Response'] == 'False') {
        // OMDb mengirim error di field 'Error'
        throw Exception(json['Error'] ?? 'Unknown error');
      }
      setState(() => data = json);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMovie('Inception'); // contoh awal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OMDb Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Cari judul film',
                hintText: 'mis. Inception',
                border: OutlineInputBorder(),
              ),
              onSubmitted: fetchMovie,
            ),
            const SizedBox(height: 16),
            if (error != null) ...[
              Text('Error: $error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ] else if (data == null) ...[
              const CircularProgressIndicator(),
            ] else ...[
              if (data!['Poster'] != null && data!['Poster'] != 'N/A')
                Image.network(data!['Poster'], height: 220, fit: BoxFit.contain),
              const SizedBox(height: 8),
              Text('${data!['Title']} (${data!['Year']})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(data!['Genre'] ?? '-'),
              const SizedBox(height: 8),
              Text(data!['Plot'] ?? '-'),
              const SizedBox(height: 8),
              Text('IMDb: ${data!['imdbRating'] ?? '-'}'),
            ],
          ],
        ),
      ),
    );
  }
}
