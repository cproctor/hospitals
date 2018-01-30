
// ## Constants
// Define constants at the top of files so that you can easily find them and change them. 
// This also makes your code more readable.

// We want a higher score to be better, so the score is computed as `BASE_SCORE` minus 
// the sum of each town's distance to the nearest hospital.
int BASE_SCORE = 160;

// # MapModel

// MapModel is responsible for maintaining state for the whole map. 
class MapModel {

  // ### Instance variables

  // `cell_models` will be a 2d array of [MapCellModels](MapCellModel.html). Remember how [MapView](MapView.html)
  // kept a 2d array of [MapCellViews](MapCellView.html) which did all the real work? We
  // reuse the same pattern here.
  MapCellModel[][] cell_models;

  // A few integers keeping track of how many rows and columns there are in the map, and
  // the number of hospitals allowed.
  int rows, cols, hospitals_allowed;
  
  // ### Constructor

  // To create an instance of a MapModel, you must provide a 2d array of integers we'll call `terrain`
  // (remember seeing that in [hosptals.pde](hospitals.html#section-5)?), a 2d array of integers
  // giving the coordinates of the towns, and the number of hospitals that should be allowed.
  MapModel(int[][] terrain, int[][] towns, int _hospitals_allowed) {

    // Save the integers for later.
    rows = terrain.length;
    cols = terrain[0].length;
    hospitals_allowed = _hospitals_allowed;

    // Create a new instance of a 2d array to hold one [MapCellModel](MapCellModel.html) for each cell in the map. 
    // We could certainly have put them all into a 1d array, but we always look them 
    // up by (x, y) coordinates, so it makes more sense to store them this way.
    cell_models = new MapCellModel[rows][cols];

    // For each row...
    for (int j = 0; j < rows; j++) {

      // for each column...
      for (int i = 0; i < cols; i++) {

        // Create a new instance of a [MapCellModel](MapCellModel.html) using data from `terrain`.
        cell_models[j][i] = new MapCellModel(i, j, terrain[j][i]);
      }
    }

    // For each `townIndex` (a pair of (x, y) coordinates) in `towns`,
    for (int[] townIndex : towns) {

       // find the right [MapCellModel](MapCellModel.html) and add a town.
       int i = townIndex[0];
       int j = townIndex[1];
       cell_models[j][i].add_town();
    }
  }
  
  // ### num_hospitals

  // Counts the hospitals on the map.
  int num_hospitals() {

    // Create a variable called `count` and set it to `0`.
    int count = 0;

    // For each row of [MapCellModels](MapCellModel.html)...
    for (MapCellModel[] cell_model_row : cell_models) {

        // for each [MapCellModel](MapCellModel.html)...
       for (MapCellModel cell_model : cell_model_row) {

         // if it has a hospital, add 1 to `count`.
         if (cell_model.has_hospital) {
           count += 1;
         }
       }
    }
    // Then return `count`.
    return count;
  }
  
  // ### hospitals_left

  // Returns the number of hospitals which may still be placed. This might seem so simple
  // that it's not worth having a separate function, but anything you can do to reduce complexity
  // outside the model is usually worth it.
  int hospitals_left() {
    return hospitals_allowed - num_hospitals();
  }
  
  // ### town_distance_sum
  // Sums the distance for each cell containing a town. 
  // The goal of the game is to minimize this number.
  int town_distance_sum() {

    // Following the same pattern as `num_hospitals`, create a variable and set it to `0`.
    float sum = 0;

    // For each row of [MapCellModels](MapCellModel.html)...
    for (MapCellModel[] cell_model_row : cell_models) {

       // for each [MapCellModel](MapCellModel.html)...
       for (MapCellModel cell_model : cell_model_row) {

         // if this cell has a town, add its distance (distance to the nearest hospital) to the sum.
         if (cell_model.has_town) {
           sum += cell_model.distance;
         }
       }
    }

    // Then return `sum`.
    return round(sum);
  }

  // ### score

  // Returns the score for the map's current configuration.
  int score() {
    return BASE_SCORE - town_distance_sum();
  }
  
  // ### update_cell_distances

  // ** Warning: Advanced! ** 
  // Update each cell's distance, which is the distance to the nearest hospital.
  // Conceptually, the algorithm is pretty simple: we can start at the hospitals and work our way outward. If we know
  // how far it is from a hospital to a particular cell, then it's pretty easy to figure
  // out how far it is to that cell's neighbors. 
  void update_cell_distances() {

    // We will use three categories of cells:
    // *new cells* are the ones we haven't seen yet, 
    // *edge cells* are the ones we're currently working on, 
    // and *old cells* are the ones we've already processed.
    // Create an [ArrayList](https://processing.org/reference/ArrayList.html) (basically a resizable array) for each.
    ArrayList<MapCellModel> new_cells = new ArrayList<MapCellModel>();
    ArrayList<MapCellModel> edge_cells = new ArrayList<MapCellModel>();
    ArrayList<MapCellModel> old_cells = new ArrayList<MapCellModel>();

    // Start by putting all the cells with hospitals into `edge_cells` and assign them distances according to their 
    // terrain difficulty (so a hospital in the forest is harder to reach than a hospital on a field).
     for (MapCellModel[] cell_model_row : cell_models) {
       for (MapCellModel cell_model : cell_model_row) {
        if (cell_model.has_hospital) {
          cell_model.distance = cell_model.terrain_difficulty();
          edge_cells.add(cell_model);
        }

        // Put all cells without hospitals in `new_cells`.
        else {
          new_cells.add(cell_model);
        }
      }
    }

    // Then, as long as there are any *edge cells*, repeatedly: 
    while (!edge_cells.isEmpty()) {
      // select the edge cell with the lowest distance, remove it from `edge_cells` and add it to 
      // `old_cells` instead.
      int min_index = get_min_index(edge_cells);
      MapCellModel closest_edge_cell = edge_cells.remove(min_index);
      old_cells.add(closest_edge_cell);

      // Then get all its neighbors. 
      ArrayList<MapCellModel> neighbors = get_neighbors(closest_edge_cell);

      // For each neighbor, 
      for (MapCellModel neighbor : neighbors) {

        // if it's in `new_cells`, remove it from `new_cells`, 
        if (new_cells.remove(neighbor)) {
        
          // add it to `edge_cells`,
          edge_cells.add(neighbor);

          // and assign it a distance. The shortest possible path from a hospital to this neighbor
          // is via `closest_edge_cell`, so its distance must be the `closest_edge_cell.distance` plus the neighbor's 
          // terrain difficulty. *Note: This is not an obvious fact--it uses
          // a famous result called [Dijkstra's Algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm).*
          neighbor.distance = closest_edge_cell.distance + neighbor.terrain_difficulty();
        }
      }
    }
  }
  
  // ## Helpers
  // Each of the helpers below is only used once. But they're stil worth breaking out into separate functions 
  // because `update_cell_distances` is already complex enough!

  // ### get_min_index

  // Go through a list of cell models and returns the index of the one with the lowest distance.
  int get_min_index(ArrayList<MapCellModel> cell_models) {

    // Create a variable called `min_index` and set it to `0`. Until we see otherwise, the first
    // element is the smallest.
    int min_index = 0;

    // For each [MapCellModel](MapCellModel.html) in the [ArrayList](https://processing.org/reference/ArrayList.html), 
    for (int i = 0; i < cell_models.size(); i++) {

      // if its distance is less than the [MapCellModel](MapCellModel.html) at position `min_index`, 
      if (cell_models.get(i).distance < cell_models.get(min_index).distance) {

        // update `min_index`
         min_index = i;         
      }
    }

    // Return the index of the [MapCellModel](MapCellModel.html) with the smallest distance.
    return min_index;
  }  
  
  // ### get_neighbors

  // Given a [MapCellModel](MapCellModel.html), return a list of adjacent [MapCellModels](MapCellModel.html).
  ArrayList<MapCellModel> get_neighbors(MapCellModel model) {

    // Using the coordinates of this [MapCellModel](MapCellModel.html), 
    // construct an array containing the coordinates of all possible neighbors.
    int i = model.i;
    int j = model.j;
    int[][] neighborIndices = new int[][] {{i+1, j}, {i, j+1}, {i-1, j}, {i, j-1}};
    
    // Create an [ArrayList](https://processing.org/reference/ArrayList.html) called `neighbors`.
    ArrayList<MapCellModel> neighbors = new ArrayList<MapCellModel>();

    // For each `neighborIndex`, 
    for (int[] neighborIndex : neighborIndices) {

      // if its coordinates are valid (within the map),  
      int nI = neighborIndex[0];
      int nJ = neighborIndex[1];
      if ((nI >= 0) && (nI < rows) && nJ >= 0 && nJ < cols) {

        // add it to `neighbors`.
        neighbors.add(cell_models[nJ][nI]);
      }
    }
    // Finally, return `neighbors`.
    return neighbors;
  }
}

// ## Next up...

// Whew! MapModel was definitely trickier, but we're past the worst of it. 
// We have just two more classes to go over: [MapCellView](MapCellView.html)
// and [MapCellModel](MapCellModel.html), which implement the view and model
// for each map cell. It's not uncommon to have nested models and views, each 
// taking care of one part of a larger application. 

// Following our outside-in pattern, let's move on to [MapCellView](MapCellView.html).
