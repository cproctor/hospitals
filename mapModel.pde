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
  
  // Updates each cell's weight, or distance to the nearest hospital.
  // Here's the hardest work of the program: We need to figure out how far each 
  // space is from a hospital. The algorithm is actually pretty simple:
  // Conceptually, we can start at the hospitals and work our way outward. If we know
  // how far it is from a hospital to a particular cell, then it's pretty easy to figure
  // out how far it is to that cell's neighbors. We will use three categories of cells:
  // "old cells" are the ones we've already processed; "new cells" are those we haven't 
  // seen yet, and "edge cells" are the ones we're currently working on. 
  // Start by defining all the hospitals to be the "edges," and give them values of 
  // 0. Everything else is "new." Then repeatedly choose the "edge" with the lowest value, 
  // add all its "new" neighbors to "edges," give them values of the edge value + 1, 
  // and move the edge to "old". Keep going until we assign values to all the cells.
  void update_cell_weights() {
    ArrayList<MapCellModel> new_nodes = new ArrayList<MapCellModel>();
    ArrayList<MapCellModel> edge_nodes = new ArrayList<MapCellModel>();
    ArrayList<MapCellModel> old_nodes = new ArrayList<MapCellModel>();
     for (MapCellModel[] cell_modelRow : cell_models) {
       for (MapCellModel cell_model : cell_modelRow) {
        if (cell_model.has_hospital) {
          cell_model.value = cell_model.terrain_difficulty();
          edge_nodes.add(cell_model);
        }
        else {
          new_nodes.add(cell_model);
        }
      }
    }
    while (!edge_nodes.isEmpty()) {
      int min_index = get_min_index(edge_nodes);
      MapCellModel node = edge_nodes.remove(min_index);
      ArrayList<MapCellModel> neighbors = get_neighbors(node);
      for (MapCellModel neighbor : neighbors) {
        if (new_nodes.remove(neighbor)) {
          neighbor.value = node.value + neighbor.terrain_difficulty();
          edge_nodes.add(neighbor);
        }
      }
      old_nodes.add(node);
    }
  }
  
  // Goes through a list of cell models and returns the index of the one with the lowest value.
  int get_min_index(ArrayList<MapCellModel> cell_models) {
    int min_index = 0;
    for (int i = 0; i < cell_models.size(); i++) {
      if (cell_models.get(i).value < cell_models.get(min_index).value) {
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
  
  // Sums the value for each cell containing a town. 
  // The goal of the game is to minimize this number.
  int town_value_sum() {
    float sum = 0;
    for (MapCellModel[] cell_model_row : cell_models) {
       for (MapCellModel cell_model : cell_model_row) {
         if (cell_model.has_town) {
           sum += cell_model.value;
         }
       }
    }
    return round(sum);
  }
}