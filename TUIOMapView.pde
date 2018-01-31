import java.util.Map;

int ROWS_OF_TEXT = 4;
int TEXT_LINE_HEIGHT = 14;
int TEXT_OFFSET_TOP = 20;
int TEXT_OFFSET_RIGHT = 140;

class TUIOMapView {
  int cols, rows;
  Frame camera_frame, map_frame, text_frame;
  MapCellView[][] cell_views;
  PImage[] tiles;
  HashMap<Integer,MapCellModel> fiducials;
  
  TUIOMapView(
      int _cols, int _rows, 
      int x_in, int y_in, int width_in, int height_in, 
      int x_out, int y_out, int width_out, int height_out
  ) {
    cols = _cols;
    rows = _rows;
    camera_frame = new Frame(cols, rows, x_in, x_out, width_in, height_in);
    map_frame = new Frame(cols, rows, x_out, y_out, width_out, height_out);
    text_frame = new Frame(
      1, 
      ROWS_OF_TEXT, 
      x_out + width_out - TEXT_OFFSET_RIGHT, 
      y_out + TEXT_OFFSET_TOP, 
      1, 
      ROWS_OF_TEXT * TEXT_LINE_HEIGHT
    );
    fiducials = new HashMap<Integer,MapCellModel>();
        
    tiles = new PImage[] {
      loadImage("tiles/field.png"), 
      loadImage("tiles/road.png"), 
      loadImage("tiles/forest.png"),
      loadImage("tiles/town.png"),
      loadImage("tiles/hospital.png")
    };

    cell_views = new MapCellView[rows][cols];
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        cell_views[j][i] = new MapCellView(
          map_frame.get_x(i), 
          map_frame.get_y(j),
          map_frame.cell_width, 
          map_frame.cell_height, 
          tiles
        );
      }
    }
  }
  
  void render(MapModel model) {
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        cell_views[j][i].render(model.cell_models[j][i]);
      }
    }    
    fill(0);
    int row = 0;
    text("Place the hospitals", text_frame.x, text_frame.get_y(row++));
    text("so they serve the towns", text_frame.x, text_frame.get_y(row++));
    if (model.hospitals_left() < model.hospitals_allowed) {
      text("Score: " + model.score(), text_frame.x, text_frame.get_y(row++));
    }
    if (model.hospitals_left() > 0) {
      text("Hospitals left: " + model.hospitals_left(), text_frame.x, text_frame.get_y(row++));
    }
  }
  
  void handle_add_fiducial(int id, float x, float y, MapModel model) {
    int col = camera_frame.get_col(x);
    int row = camera_frame.get_row(y);
    MapCellModel cell_model = model.cell_models[row][col];
    fiducials.put(id, cell_model);
    cell_model.add_hospital();
    model.update_cell_distances();
  }
  
  void handle_remove_fiducial(int id, float x, float y, MapModel model) {
    int col = camera_frame.get_col(x);
    int row = camera_frame.get_row(y);
    MapCellModel cell_model = model.cell_models[row][col];
    fiducials.remove(id);
    cell_model.remove_hospital();
    model.update_cell_distances();
  }
  
  void handle_move_fiducial(int id, float x, float y, MapModel model) {
    int col = camera_frame.get_col(x);
    int row = camera_frame.get_row(y);
    MapCellModel new_cell_model = model.cell_models[row][col];
    MapCellModel old_cell_model = fiducials.get(id);
    if (new_cell_model != old_cell_model) {
       fiducials.put(id, new_cell_model);
       old_cell_model.remove_hospital();
       new_cell_model.add_hospital();
       model.update_cell_distances();
    }
  }
}