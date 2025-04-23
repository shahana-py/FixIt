// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
//
// class SearchPage extends StatefulWidget {
//   const SearchPage({Key? key}) : super(key: key);
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//   List<String> recentSearches = [];
//   List<String> filteredResults = [];
//   List<String> allServices = ['AC Repair', 'Plumbing', 'Painting', 'Cleaning', 'Laundry'];
//   bool isSearching = false;
//
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _loadRecentSearches();
//
//     _searchController.addListener(() {
//       final query = _searchController.text.trim();
//       setState(() {
//         isSearching = query.isNotEmpty;
//
//         // Filter services based on search query
//         filteredResults = allServices
//             .where((service) => service.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       });
//     });
//   }
//
//   Future<void> _loadRecentSearches() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       recentSearches = prefs.getStringList('recentSearches') ?? [];
//     });
//   }
//
//   Future<void> _addToRecentSearches(String search) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     search = search.trim();
//
//     // Remove if already exists to avoid duplicates
//     recentSearches.remove(search);
//
//     // Add to beginning of list
//     recentSearches.insert(0, search);
//
//     // Keep only the last 10 searches
//     if (recentSearches.length > 10) {
//       recentSearches = recentSearches.sublist(0, 10);
//     }
//
//     await prefs.setStringList('recentSearches', recentSearches);
//
//     // Clear the search field after selection
//     _searchController.clear();
//     setState(() {
//       isSearching = false;
//     });
//   }
//
//   void _startListening() async {
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(onResult: (result) {
//         setState(() {
//           _searchController.text = result.recognizedWords;
//         });
//       });
//     }
//   }
//
//   void _stopListening() {
//     _speech.stop();
//     setState(() => _isListening = false);
//   }
//
//   void _clearRecentSearches() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       recentSearches.clear();
//     });
//     await prefs.remove('recentSearches');
//   }
//
//   void _reuseSearch(String search) {
//     _searchController.text = search;
//     // Trigger search immediately
//     setState(() {
//       isSearching = true;
//       filteredResults = allServices
//           .where((service) => service.toLowerCase().contains(search.toLowerCase()))
//           .toList();
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _speech.stop();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xff0F3966),
//         title: Container(
//           height: 45,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.search, color: Colors.grey),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: const InputDecoration(
//                     hintText: "Search for services...",
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.mic,
//                   color: _isListening ? Colors.blue : Colors.grey, // Changed from red to blue
//                 ),
//                 onPressed: _isListening ? _stopListening : _startListening,
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Show recent searches only when not actively searching
//             if (!isSearching && recentSearches.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "Your Recent Searches",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: _clearRecentSearches,
//                         child: const Text(
//                           "Clear all",
//                           style: TextStyle(color: Colors.blue),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   ...recentSearches.map((search) => ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     dense: true,
//                     leading: const Icon(Icons.history, color: Colors.grey),
//                     title: Text(
//                       search,
//                       style: const TextStyle(fontSize: 15),
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.search, size: 20),
//                       onPressed: () => _reuseSearch(search),
//                     ),
//                     onTap: () => _reuseSearch(search),
//                   )),
//                 ],
//               ),
//
//             // Show search results when typing
//             if (isSearching)
//               Expanded(
//                 child: filteredResults.isEmpty
//                     ? const Center(child: Text("No services found"))
//                     : ListView.builder(
//                   itemCount: filteredResults.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       leading: const Icon(Icons.miscellaneous_services),
//                       title: Text(filteredResults[index]),
//                       onTap: () {
//                         _addToRecentSearches(filteredResults[index]);
//                       },
//                     );
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  bool isLoading = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;

  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadRecentSearches();

    _searchController.addListener(() {
      final query = _searchController.text.trim();
      setState(() {
        isSearching = query.isNotEmpty;
      });

      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          searchResults = [];
        });
      }
    });
  }

  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _addToRecentSearches(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    search = search.trim();

    // Remove if already exists to avoid duplicates
    recentSearches.remove(search);

    // Add to beginning of list
    recentSearches.insert(0, search);

    // Keep only the last 10 searches
    if (recentSearches.length > 10) {
      recentSearches = recentSearches.sublist(0, 10);
    }

    await prefs.setStringList('recentSearches', recentSearches);

    // Clear the search field after selection
    _searchController.clear();
    setState(() {
      isSearching = false;
      searchResults = [];
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _clearRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches.clear();
    });
    await prefs.remove('recentSearches');
  }

  void _reuseSearch(String search) {
    _searchController.text = search;
    // Trigger search immediately
    setState(() {
      isSearching = true;
    });
    _performSearch(search);
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      print("Searching for: $query");
      // Prepare to store results
      List<Map<String, dynamic>> results = [];

      // Convert query to lowercase for case-insensitive search
      final lowercaseQuery = query.toLowerCase();

      print("Fetching services...");
      // Get all services
      final servicesSnapshot = await _firestore.collection('services').get();
      print("Services fetched: ${servicesSnapshot.docs.length}");

      for (var doc in servicesSnapshot.docs) {
        final data = doc.data();
        final serviceName = data['name']?.toString().toLowerCase() ?? '';

        // Check if service name contains the query string (case insensitive)
        if (serviceName.contains(lowercaseQuery)) {
          print("Match found - service: ${data['name']}");
          results.add({
            'id': doc.id,
            'name': data['name'] ?? 'Unknown Service',
            'type': 'service',
            'provider_id': data['provider_id'],
            'description': data['description'] ?? '',
            'rating': data['rating'] ?? 0,
            'experience': data['experience'] ?? 0,
            'hourly_rate': data['hourly_rate'] ?? 0,
            'work_sample': data['work_sample'] ?? '',
            'work_samples': data['work_samples'] ?? [],
          });
        }
      }

      // We've removed the service provider search code since you only want service results

      print("Search complete. Found ${results.length} service results.");
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print('Error searching: $e');
      setState(() {
        searchResults = [];
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff0F3966),
        title: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search for services...", // Updated hint text
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.mic,
                  color: _isListening ? Colors.blue : Colors.grey,
                ),
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show recent searches only when not actively searching
            if (!isSearching && recentSearches.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Your Recent Searches",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearRecentSearches,
                        child: const Text(
                          "Clear all",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...recentSearches.map((search) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(
                      search,
                      style: const TextStyle(fontSize: 15),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.search, size: 20),
                      onPressed: () => _reuseSearch(search),
                    ),
                    onTap: () => _reuseSearch(search),
                  )),
                ],
              ),

            // Show search results when typing
            if (isSearching)
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchResults.isEmpty
                    ? const Center(child: Text("No services found"))
                    : GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final result = searchResults[index];
                    // Since we're only showing services, we can simplify this
                    String? networkImage;
                    if (result['work_sample'] != null) {
                      networkImage = result['work_sample'];
                    }

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        onTap: () {
                          _addToRecentSearches(result['name']);
                          // Here you would navigate to details page
                          // Navigator.push(...);
                        },
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: networkImage != null && networkImage.isNotEmpty
                                      ? Image.network(
                                    networkImage,
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      "assets/images/Jhon_plumber5.jpeg",
                                      height: 110,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : Image.asset(
                                    "assets/images/Jhon_plumber5.jpeg",
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Service",
                                      style: TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff0F3966),
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              result['description'] ?? '',
                                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ],
                                        ),
                                      ),
                                      if (result['rating'] != null)
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          width: 47,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: Colors.green[700],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.white, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${result['rating']}",
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (result['hourly_rate'] != null)
                                        Text(
                                          "₹${result['hourly_rate']}/hr",
                                          style: const TextStyle(
                                            color: Color(0xff0F3966),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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