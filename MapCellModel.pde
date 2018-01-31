// Constants
float[] TERRAIN_WEIGHTS = {1, 0.3, 3};
int MAX_VALUE = 10;

// MapCellModel manages state for one map cell. 
class MapCellModel {
  
  int id, i, j, terrain;
  float distance;
  boolean has_town, has_hospital;  
  
  // Constructor
  MapCellModel(int _i, int _j, int _terrain) {
    i = _i; 
    j = _j; 
    terrain = _terrain;
    has_town = false;
    has_hospital = false;
  }
  
  // Adds a town
  void add_town() {
    has_town = true;
  }
  
  // Adds a hospital
  void add_hospital() {
    has_hospital = true;
  }
  
  void remove_hospital() {
     has_hospital = false; 
  }
  
  float terrain_difficulty() {
    return TERRAIN_WEIGHTS[terrain];
  }
  
  // Scales this cell's distance to a range between 0 and 1
  float normalized_distance() {
   return max(0, min(MAX_VALUE, map(distance, 0, MAX_VALUE, 0, 1)));
  }
  
  // Defines how MapCellModels should be compared with each other
  // for equality. Here, two MapCellModels are equal if they 
  // share i and j. 
  boolean equals(MapCellModel other) {
   return i == other.i && j == other.j; 
  }
  
  // Returns true when there is no town or hospital here.
  boolean is_free() {
    return !(has_town || has_hospital);
  }
}