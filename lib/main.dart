import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star Wars Wiki',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
          primary: const Color(0xFFFFE81F),
          onPrimary: Colors.black,
          primaryContainer: Colors.black,
          onPrimaryContainer: const Color(0xFFFFE81F),
        ),
      ),
      home: const MyHomePage(title: 'Star Wars Wiki'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class PlanetPage extends StatefulWidget {
  const PlanetPage({super.key});

  @override
  State<PlanetPage> createState() => _PlanetPageState();
}

class Planet {
  final String name;
  final String climate;
  final String terrain;

  Planet({required this.name, required this.climate, required this.terrain});

  factory Planet.fromJson(Map<String, dynamic> json) {
    return Planet(
      name: json['name'],
      climate: json['climate'],
      terrain: json['terrain'],
    );
  }
}

class _PlanetPageState extends State<PlanetPage> {
  List<Planet> planets = [];
  bool isLoading = false;

  Future<void> fetchPlanets() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://swapi.dev/api/planets/'));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
        final planetList = decodedData['results'] as List;
        planets = planetList
            .map((planetData) => Planet.fromJson(planetData))
            .toList();
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching planet data: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlanets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planets'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : (planets.isEmpty)
                ? const Text('No planet data available')
                : ListView.builder(
                    itemCount: planets.length,
                    itemBuilder: (context, index) {
                      final planet = planets[index];
                      return ListTile(
                        title: Text(planet.name),
                        subtitle: Text(
                            'Climate: ${planet.climate}, Terrain: ${planet.terrain}'),
                      );
                    },
                  ),
      ),
    );
  }
}

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  String peopleData = '';
  bool isLoading = false;

  Future<void> fetchPeopleData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://swapi.dev/api/people/'));
      if (response.statusCode == 200) {
        setState(() {
          peopleData = response.body;
          isLoading = false;
        });
      } else {
        if (kDebugMode) {
          print('Failed to fetch people data: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching people data: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPeopleData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : (peopleData.isEmpty)
                ? const Text('No people data available')
                : ListView.builder(
                    itemCount: parsePeopleCount(peopleData),
                    itemBuilder: (context, index) {
                      final personData = parsePersonData(peopleData, index);
                      return ListTile(
                        title: Text(personData['name']),
                        subtitle: Text(
                          'Height: ${personData['height']}, Birth Year: ${personData['birth_year']}',
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

int parsePeopleCount(String jsonData) {
  final decodedData = jsonDecode(jsonData) as Map<String, dynamic>;
  return decodedData['results'].length;
}

Map<String, dynamic> parsePersonData(String jsonData, int index) {
  final decodedData = jsonDecode(jsonData) as Map<String, dynamic>;
  return decodedData['results'][index] as Map<String, dynamic>;
}

class FilmsPage extends StatefulWidget {
  const FilmsPage({super.key});

  @override
  State<FilmsPage> createState() => _FilmsPageState();
}

class Film {
  final String title;
  final int episodeId;
  final String director;
  final String openingCrawl;
  final String producer;
  final String releaseDate;
  final List<String> characters;
  final List<String> planets;
  final List<String> starships;
  final List<String> vehicles;
  final List<String> species;
  final String created;
  final String edited;
  final String url;

  Film({
    required this.title,
    required this.episodeId,
    required this.director,
    required this.openingCrawl,
    required this.producer,
    required this.releaseDate,
    required this.characters,
    required this.planets,
    required this.starships,
    required this.vehicles,
    required this.species,
    required this.created,
    required this.edited,
    required this.url,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      title: json['title'],
      episodeId: json['episode_id'],
      director: json['director'],
      openingCrawl: json['opening_crawl'],
      producer: json['producer'],
      releaseDate: json['release_date'],
      characters: List<String>.from(json['characters']),
      planets: List<String>.from(json['planets']),
      starships: List<String>.from(json['starships']),
      vehicles: List<String>.from(json['vehicles']),
      species: List<String>.from(json['species']),
      created: json['created'],
      edited: json['edited'],
      url: json['url'],
    );
  }
}

class _FilmsPageState extends State<FilmsPage> {
  List<Film> films = [];
  bool isLoading = false;

  Future<void> fetchFilmsData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://swapi.dev/api/films/'));
      if (response.statusCode == 200) {
        final decodeData = jsonDecode(response.body) as Map<String, dynamic>;
        final filmList = decodeData['results'] as List;
        films = filmList
          .map((filmData) => Film.fromJson(filmData))
          .toList();
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching films data: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFilmsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Films'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : (films.isEmpty)
                ? const Text('No film available')
                : ListView.builder(
                    itemCount: films.length,
                    itemBuilder: (context, index) {
                      final film = films[index];
                      return ListTile(
                        title: Text(film.title),
                        subtitle: Text(
                            'Director: ${film.director}, Producer: ${film.producer}'),
                      );
                    }),
      ),
    );
  }
}

class Vehicle {
  final String name;
  final String model;
  final String manufacturer;
  final String costInCredits;
  final String length;
  final String maxAtmospheringSpeed;
  final String crew;
  final String passengers;
  final String cargoCapacity;
  final String consumables;
  final String vehicleClass;
  final List<String> pilots;
  final List<String> films;
  final String created;
  final String edited;
  final String url;

  Vehicle({
    required this.name,
    required this.model,
    required this.manufacturer,
    required this.costInCredits,
    required this.length,
    required this.maxAtmospheringSpeed,
    required this.crew,
    required this.passengers,
    required this.cargoCapacity,
    required this.consumables,
    required this.vehicleClass,
    required this.pilots,
    required this.films,
    required this.created,
    required this.edited,
    required this.url,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      name: json['name'],
      model: json['model'],
      manufacturer: json['manufacturer'],
      costInCredits: json['cost_in_credits'],
      length: json['length'],
      maxAtmospheringSpeed: json['max_atmosphering_speed'],
      crew: json['crew'],
      passengers: json['passengers'],
      cargoCapacity: json['cargo_capacity'],
      consumables: json['consumables'],
      vehicleClass: json['vehicle_class'],
      pilots: List<String>.from(json['pilots']),
      films: List<String>.from(json['films']),
      created: json['created'],
      edited: json['edited'],
      url: json['url'],
    );
  }
}

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  List<Vehicle> vehicles = [];
  bool isLoading = false;

  Future<void> fetchVehiclesData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://swapi.dev/api/vehicles/'));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
        final vehicleList = decodedData['results'] as List;
        vehicles = vehicleList
            .map((vehicleData) => Vehicle.fromJson(vehicleData))
            .toList();
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching vehicles data: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVehiclesData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : (vehicles.isEmpty)
                ? const Text('No vehicle data available')
                : ListView.builder(
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return ListTile(
                        title: Text(vehicle.name),
                        subtitle: Text(
                            'Model: ${vehicle.model}, Manufacturer: ${vehicle.manufacturer}'),
                      );
                    },
                  ),
      ),
    );
  }
}

class Species {
  final String? name;
  final String? classification;
  final String? designation;
  final String? averageHeight;
  final String? skinColors;
  final String? hairColors;
  final String? eyeColors;
  final String? averageLifespan;
  final String? homeworld;
  final String? language;
  final List<String>? people;
  final List<String>? films;
  final String? created;
  final String? edited;
  final String? url;

  Species({
    required this.name,
    required this.classification,
    required this.designation,
    required this.averageHeight,
    required this.skinColors,
    required this.hairColors,
    required this.eyeColors,
    required this.averageLifespan,
    required this.homeworld,
    required this.language,
    required this.people,
    required this.films,
    required this.created,
    required this.edited,
    required this.url,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      name: json['name'],
      classification: json['classification'],
      designation: json['designation'],
      averageHeight: json['average_height'],
      skinColors: json['skin_colors'],
      hairColors: json['hair_colors'],
      eyeColors: json['eye_colors'],
      averageLifespan: json['average_lifespan'],
      homeworld: json['homeworld'],
      language: json['language'],
      people: List<String>.from(json['people']),
      films: List<String>.from(json['films']),
      created: json['created'],
      edited: json['edited'],
      url: json['url'],
    );
  }
}

class SpeciesPage extends StatefulWidget {
  const SpeciesPage({super.key});

  @override
  State<SpeciesPage> createState() => _SpeciesPageState();
}

class _SpeciesPageState extends State<SpeciesPage> {
  List<Species> species = [];
  bool isLoading = false;

  Future<void> fetchSpeciesData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://swapi.dev/api/species/'));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
        final speciesList = decodedData['results'] as List;
        species = speciesList
            .map((speciesData) => Species.fromJson(speciesData))
            .toList();
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching species data: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSpeciesData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Species'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : (species.isEmpty)
                ? const Text('No species data available')
                : ListView.builder(
                    itemCount: species.length,
                    itemBuilder: (context, index) {
                      final specie = species[index];
                      return ListTile(
                        title: Text(specie.name!),
                        subtitle: Text(
                            'Classification: ${specie.classification}, Designation: ${specie.designation}'),
                      );
                    },
                  ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  final List<Widget> _pages = [
    const PlanetPage(),
    const PeoplePage(),
    const FilmsPage(),
    const VehiclesPage(),
    const SpeciesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          widget.title,
          style: const TextStyle(color: Color(0xFFFFE81F)),
        ),
      ),
      body: _pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.onPrimary,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.public),
            label: 'Planets',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'People',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie),
            label: 'Films',
          ),
          NavigationDestination(
            icon: Icon(Icons.airplanemode_active),
            label: 'Vehicles',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets),
            label: 'Species',
          ),
        ],
      ),
    );
  }
}
