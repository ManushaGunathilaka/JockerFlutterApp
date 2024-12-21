import 'package:flutter/material.dart';
import 'joke_service.dart'; // Import the JokeService file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Joke App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'Joke App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final JokeService _jokeService = JokeService(); // Initialize JokeService
  List<dynamic> _jokes = [];
  bool _isLoading = false;

  Future<void> fetchJokes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to fetch jokes from the API
      final jokes = await _jokeService.fetchJokesFromApi();
      await _jokeService.saveJokesToCache(jokes); // Cache the jokes
      setState(() {
        _jokes = jokes;
      });
    } catch (error) {
      // If API call fails, fetch jokes from cache
      final cachedJokes = await _jokeService.fetchJokesFromCache();
      if (cachedJokes.isNotEmpty) {
        setState(() {
          _jokes = cachedJokes;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loaded jokes from cache')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch jokes: $error')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to the Joke App!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : fetchJokes,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Fetch Jokes'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _jokes.length,
                itemBuilder: (context, index) {
                  final joke = _jokes[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        joke['setup'] != null
                            ? '${joke['setup']} - ${joke['delivery']}'
                            : joke['joke'] ?? 'No joke',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
