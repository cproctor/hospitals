
// ## Constants

// Determines how much *distance* gets added when traversing each type of terrain:
// field, road, and forest.
float[] TERRAIN_WEIGHTS = {1, 0.3, 3};

// When distances are normalized (scaled to a [0, 1] range), we need to define 
// what should be considered the maximum distance. 
int MAX_DISTANCE = 20;

// # MapCellModel

// MapCellModel manages state for one map cell. 
class MapCellModel {
  
  // ## Instance variables

  // A few integers keeping track of this cell's map coordinates and terrain type.
  int i, j, terrain;

  // The cell's distance to the nearest hospital. This is updated frequently by 
  // [MapModel.update_cell_distances](MapModel.html#section-34)
  float distance;

  // Keep track of whether this cell has a town and whether this cell has a hospital.
  boolean has_town, has_hospital;  
  
  // ## Constructor

  // The constructor is straightforward; we just store the values passed in and set default
  // values for `has_town` and `has_hospital`.
  MapCellModel(int _i, int _j, int _terrain) {
    i = _i; 
    j = _j; 
    terrain = _terrain;
    has_town = false;
    has_hospital = false;
  }
  
  // ### add_town

  // Adds a town
  void add_town() {
    has_town = true;
  }
  
  // ### add_hospital

  // Adds a hospital
  void add_hospital() {
    has_hospital = true;
  }

  // ### remove_hospital

  // Removes a hospital
  void remove_hospital() {
    has_hospital = true;
  }
  
  // ### is_free

  // Return true when there is no town or hospital here.
  boolean is_free() {
    return !(has_town || has_hospital);
  }

  // ### terrain_difficulty

  // Looks up and returns the terrain difficulty.
  // This method and those preceding it might seem pointless
  // when their work is accomplished in one simple line of code. 
  // However, it's important that each part of your program minds
  // its own business, and these methods help achieve that. 
  // This becomes especially important when you want to change your program; 
  // The more different parts of your code reach into each others' internals, 
  // the more likely it is that a change will result in an error somewhere else. 
  float terrain_difficulty() {
    return TERRAIN_WEIGHTS[terrain];
  }
  
  // ### normalized_distance

  // Scale distance to a range between 0 and 1. This function relies on some 
  // convenient built-in Processing functions. 
  float normalized_distance() {
   return max(0, min(MAX_DISTANCE, map(distance, 0, MAX_DISTANCE, 0, 1)));
  }
  
  // ### equals 

  // Defines how MapCellModels should be compared with each other
  // for equality. Here, two MapCellModels are equal if they 
  // share i and j. This is used internally by [ArrayList](https://processing.org/reference/ArrayList.html)
  // when figuring out whether a particular MapCellModel is in an ArrayList. 
  boolean equals(MapCellModel other) {
   return i == other.i && j == other.j; 
  }
  
}
