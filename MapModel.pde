// Constants
int BASE_SCORE = 160;

// MapModel is responsible for maintaining state for the whole map. 
class MapModel {
  MapCellModel[][] cell_models;
  int rows, cols, hospitals_allowed;
  
  // Constructor
  MapModel(int[][] terrain, int[][] towns, int _hospitals_allowed) {
    rows = terrain.length;
    cols = terrain[0].length;
    hospitals_allowed = _hospitals_allowed;
    cell_models = new MapCellModel[rows][cols];
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        cell_models[j][i] = new MapCellModel(i, j, terrain[j][i]);
      }
    }
    for (int[] townData : towns) {
       cell_models[townData[1]][townData[0]].add_town();
    }
  }
  
  // Update each cell's distance to the nearest hospital, 
  // using Dijkstra's algorithm
  void update_cell_distances() {
    if (num_hospitals() == 0) {
      clear_cell_distances();
      return;
    } 
    ArrayList<MapCellModel> new_cells = new ArrayList<MapCellModel>();
    ArrayList<MapCellModel> edge_cells = new ArrayList<MapCellModel>();
    ArrayList<MapCellModel> old_cells = new ArrayList<MapCellModel>();
     for (MapCellModel[] cell_modelRow : cell_models) {
       for (MapCellModel cell_model : cell_modelRow) {
        if (cell_model.has_hospital) {
          cell_model.distance = cell_model.terrain_difficulty();
          edge_cells.add(cell_model);
        }
        else {
          new_cells.add(cell_model);
        }
      }
    }
    while (!edge_cells.isEmpty()) {
      int min_index = get_min_index(edge_cells);
      MapCellModel node = edge_cells.remove(min_index);
      ArrayList<MapCellModel> neighbors = get_neighbors(node);
      for (MapCellModel neighbor : neighbors) {
        if (new_cells.remove(neighbor)) {
          neighbor.distance = node.distance + neighbor.terrain_difficulty();
          edge_cells.add(neighbor);
        }
      }
      old_cells.add(node);
    }
  }
  
  void clear_cell_distances() {
    for (MapCellModel[] cell_modelRow : cell_models) {
       for (MapCellModel cell_model : cell_modelRow) {
         cell_model.distance = 0;
       }
    }
  }
  
  // Goes through a list of cell models and returns the index of the one with the lowest distance.
  int get_min_index(ArrayList<MapCellModel> cell_models) {
    int min_index = 0;
    for (int i = 0; i < cell_models.size(); i++) {
      if (cell_models.get(i).distance < cell_models.get(min_index).distance) {
         min_index = i;         
      }
    }
    return min_index;
  }  
  
  // Given a MapCellModel, returns a list of adjacent MapCellModels.
  // Most of the work here involves checking to make sure the neighbors 
  // actually exist (ex: if we're in a corner, there are only two neighbors.)
  ArrayList<MapCellModel> get_neighbors(MapCellModel model) {
    int i = model.i;
    int j = model.j;
    int[][] neighborIndices = new int[][] {{i+1, j}, {i, j+1}, {i-1, j}, {i, j-1}};
    
    ArrayList<MapCellModel> neighbors = new ArrayList<MapCellModel>();
    for (int[] neighborIndex : neighborIndices) {
      int nI = neighborIndex[0];
      int nJ = neighborIndex[1];
      if ((nI >= 0) && (nI < rows) && nJ >= 0 && nJ < cols) {
        neighbors.add(cell_models[nJ][nI]);
      }
    }
    return neighbors;
  }
  
  // Counts the hospitals on the board 
  int num_hospitals() {
    int count = 0;
    for (MapCellModel[] cell_model_row : cell_models) {
       for (MapCellModel cell_model : cell_model_row) {
         if (cell_model.has_hospital) {
           count += 1;
         }
       }
    }
    return count;
  }
  
  // Returns the number of hospitals which may still be placed
  int hospitals_left() {
    return hospitals_allowed - num_hospitals();
  }
  
  // Sums the distance for each cell containing a town. 
  // The goal of the game is to minimize this number.
  int town_distance_sum() {
    float sum = 0;
    for (MapCellModel[] cell_model_row : cell_models) {
       for (MapCellModel cell_model : cell_model_row) {
         if (cell_model.has_town) {
           sum += cell_model.distance;
         }
       }
    }
    return round(sum);
  }

  int score() {
    return BASE_SCORE - town_distance_sum();
  }
}