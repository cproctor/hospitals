float[] terrainWeights = {1, 0.3, 3};
int MAX_VALUE = 10;

class MapCellModel {
  
  int id, i, j, terrain;
  float value;
  boolean has_town, has_hospital;  
  
  MapCellModel(int _i, int _j, int _terrain) {
    i = _i; 
    j = _j; 
    terrain = _terrain;
    has_town = false;
    has_hospital = false;
  }
  
  void add_town() {
    has_town = true;
  }
  
  void add_hospital() {
    has_hospital = true;
  }
  
  float terrain_difficulty() {
    return terrainWeights[terrain];
  }
  
  float normalized_value() {
   return max(0, min(MAX_VALUE, map(value, 0, MAX_VALUE, 0, 1)));
  }
  
  boolean equals(MapCellModel other) {
   return i == other.i && j == other.j; 
  }
  
  boolean is_free() {
    return !(has_town || has_hospital);
  }
}