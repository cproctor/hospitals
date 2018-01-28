// A map model 

// Need to initialize with a 2d array of terrains
// Also need to initialize with a list of [object, position]

class MapModel {
  MapCellModel[][] cellModels;
  int rows, cols, hospitals_allowed;
  
  MapModel(int[][] terrain, int[][] towns, int _hospitals_allowed) {
    rows = terrain.length;
    cols = terrain[0].length;
    hospitals_allowed = _hospitals_allowed;
    cellModels = new MapCellModel[rows][cols];
    
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        cellModels[j][i] = new MapCellModel(i, j, terrain[j][i]);
      }
    }
    for (int[] townData : towns) {
       cellModels[townData[1]][townData[0]].add_town();
    }
  }
  
  // Here's the hardest work of the program: We need to figure out how far each 
  // space is from a hospital. The algorithm is actually pretty simple though:
  // Start by defining all the hospitals to be the "edges," and give them values of 
  // 0. Everything else is "new." Then repeatedly choose the edge with the lowest value, 
  // add all its "new" neighbors to "edges," give them values of the edge value + 1, 
  // and move the edge to "old".
  void update_cell_weights() {
    ArrayList<MapCellModel> new_nodes = new ArrayList<MapCellModel>();
    ArrayList<MapCellModel> edge_nodes = new ArrayList<MapCellModel>();
    ArrayList<MapCellModel> old_nodes = new ArrayList<MapCellModel>();
     for (MapCellModel[] cellModelRow : cellModels) {
       for (MapCellModel cellModel : cellModelRow) {
        if (cellModel.has_hospital) {
          cellModel.value = cellModel.terrain_difficulty();
          edge_nodes.add(cellModel);
        }
        else {
          new_nodes.add(cellModel);
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
  
  // Goes through a list of models and returns the index of the one with the lowest value.
  int get_min_index(ArrayList<MapCellModel> models) {
    int min_index = 0;
    for (int i = 0; i < models.size(); i++) {
      if (models.get(i).value < models.get(min_index).value) {
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
        neighbors.add(cellModels[nJ][nI]);
      }
    }
    return neighbors;
  }
  
  int num_hospitals() {
    int count = 0;
    for (MapCellModel[] cellModelRow : cellModels) {
       for (MapCellModel cellModel : cellModelRow) {
         if (cellModel.has_hospital) {
           count += 1;
         }
       }
    }
    return count;
  }
  
  int hospitals_left() {
    return hospitals_allowed - num_hospitals();
  }
  
  int town_value_sum() {
    float sum = 0;
    for (MapCellModel[] cellModelRow : cellModels) {
       for (MapCellModel cellModel : cellModelRow) {
         if (cellModel.has_town) {
           sum += cellModel.value;
         }
       }
    }
    return round(sum);
  }
}