import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

DocumentReference? selectGuide(List<QueryDocumentSnapshot<Object?>> filteredGuides, int seats) {
  if (filteredGuides.length > 1) {
    // Use only the top 5 guides if the list has more than 5
    List<QueryDocumentSnapshot> topGuides = filteredGuides.length > 5 ? filteredGuides.sublist(0, 5) : filteredGuides;

    if(seats == 4) {
      //if possible select only guides that have tuks with 4 seats
      if(topGuides.where((guide) => guide.get("tuktukSeats") == 4).isNotEmpty) {
        topGuides = topGuides.where((guide) => guide.get("tuktukSeats") == 4).toList();
      }
    }

    // Generate weights dynamically based on the length of the selected top guides
    List<int> weights = List.generate(topGuides.length, (index) => topGuides.length - index);

    // Select a guide based on weights
    QueryDocumentSnapshot selectedGuide = weightedRandomSelection(topGuides, weights);

    print("Selected Guide: ${selectedGuide.id}");
    return selectedGuide.reference;
  } else {
    return filteredGuides.isNotEmpty ? filteredGuides[0].reference : null;
  }
}

QueryDocumentSnapshot weightedRandomSelection(List<QueryDocumentSnapshot> items, List<int> weights) {
  if (items.length != weights.length || items.isEmpty) {
    throw ArgumentError("Items and weights must have the same non-zero length.");
  }

  // Calculate the total weight
  int totalWeight = weights.reduce((a, b) => a + b);

  // Generate a random number between 0 and totalWeight
  int randomNumber = Random().nextInt(totalWeight);

  // Determine which item is selected
  int cumulativeWeight = 0;
  for (int i = 0; i < items.length; i++) {
    cumulativeWeight += weights[i];
    if (randomNumber < cumulativeWeight) {
      return items[i];
    }
  }

  // Fallback (shouldn't happen if logic is correct)
  throw StateError("No item selected. Check the weights and logic.");
}
