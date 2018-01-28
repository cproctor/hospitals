// Create an array of MapCellViews. 
class MapView {
  
  int cols, rows, x, y, map_width, map_height, cell_width, cell_height;
  MapCellView[][] cellViews;
  PImage[] tiles;
  MapCellModel activeCellModel;
  
  MapView(int _cols, int _rows, int _x, int _y, int _map_width, int _map_height) {
    cols = _cols;
    rows = _rows;
    map_width = _map_width;
    map_height = _map_height;
    x = _x;
    y = _y;
    cell_width = map_width / cols;
    cell_height = map_height / rows;
    cellViews = new MapCellView[rows][cols];
    
    // We can look up the filename for the tile image of a piece of terrain. Note that
    // this lives in the view, not the model, because it's more related to the 
    // presentation than to the data itself. 
    tiles = new PImage[] {
      loadImage("tiles/field.png"), 
      loadImage("tiles/road.png"), 
      loadImage("tiles/forest.png"),
      loadImage("tiles/town.png"),
      loadImage("tiles/hospital.png")
    };

    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        cellViews[j][i] = new MapCellView(x + i * cell_width, y + j * cell_height, cell_width, cell_height, tiles);
      }
    }
  }
  
  void render(MapModel model) {
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        cellViews[j][i].render(model.cellModels[j][i]);
      }
    }    
    text("Score: " + model.town_value_sum(), x+map_width - 80, y+30);
  }
  
  void handle_press(MapModel model) {
    int[] ix = get_mouse_cell_index();
    println("PRESS", ix[0], ix[1]);
    MapCellModel cellModel = model.cellModels[ix[1]][ix[0]];
    
    // If the space is free and we can add hospitals, do so. 
    if (cellModel.is_free() & model.num_hospitals() < model.hospitals_allowed) {
        cellModel.has_hospital = true;
        activeCellModel = cellModel;
        model.update_cell_weights();
    }
    // Else, if there's a hospital there, start dragging it.
    else if (cellModel.has_hospital) {
      activeCellModel = cellModel;
    }
    
    else {
      activeCellModel = null; 
    }
  }
  
  void handle_drag(MapModel model) {
    if (mouse_over_map()) {
      int[] ix = get_mouse_cell_index();
      println("DRAG", ix[0], ix[1]);
      MapCellModel cellModel = model.cellModels[ix[1]][ix[0]];
      // If we can drag the hospital 
      if (activeCellModel != null & cellModel != activeCellModel & cellModel.is_free()) {
       activeCellModel.has_hospital = false;
       cellModel.has_hospital = true;
       activeCellModel = cellModel;
       model.update_cell_weights();
      }
    }
  }
  
  void handle_release() {
    println("RELEASE");
    activeCellModel = null; 
  }
  
  // Converts absolute mouse coordinates into the [i, j] coordinates of 
  // the cell it's currently over.
  int[] get_mouse_cell_index() {
    int i = (mouseX - x) / cell_width;
    int j = (mouseY - y) / cell_height;
    int[] cell = new int[] {max(0, min(cols-1, i)), max(0, min(rows-1, j))};
    return cell;
  }
  
  // Tells whether the mouse is over the map.
  boolean mouse_over_map() {
    return (x <= mouseX && mouseX < x+map_width && y <= mouseY && mouseY < y+map_height);
  }
}