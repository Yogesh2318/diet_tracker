import 'package:my_project/model/place.dart';

import 'package:my_project/providers/user_places.dart';
import 'package:my_project/widgets/image_input.dart';
import 'package:my_project/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titlecontroller = TextEditingController();
  File? _selectedImage;
  PlaceLocation ? _selectedLocation;

  void _savePlace() {
    final enteredTitle = _titlecontroller.text;

    if (enteredTitle.isEmpty || _selectedImage == null || _selectedLocation == null) {
      return;
    }

    ref.read(userPlacesProvider.notifier).addPlace(enteredTitle, _selectedImage!, _selectedLocation!);

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titlecontroller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(
            decoration: InputDecoration(labelText: 'Title'),
            controller: _titlecontroller,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 10),
          ImageInput(
            onPickImage: (image) {
              _selectedImage = image;
            },
          ),
          const SizedBox(height: 10),
          LocationInput(onSelectLocation: (location) {
            _selectedLocation = location as PlaceLocation? ;
          },),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _savePlace,
            icon: Icon(Icons.add),
            label: const Text('Add Meal'),
          ),
        ]),
      ),
    );
  }
}
