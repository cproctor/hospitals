// TUIOMapView supports interaction with a tangible user interface table. 
// If you haven't read the documentation for the standard [MapView](MapView.html), 
// start there first. This documentation will focus on what has changed.

// We will use a map (sometimes called a hashmap, dictionary, or associative array) in this class, 
// so we need to import the relevant library (the [documentation for HashMap](https://processing.org/reference/HashMap.html) tells us this).
import java.util.Map;

// ## Constants

// These constants define properties of the text that will be displayed 
// in the top right hand corner of the screen, so we can easily make changes.
int ROWS_OF_TEXT = 4;
int TEXT_LINE_HEIGHT = 14;
int TEXT_OFFSET_TOP = 20;
int TEXT_OFFSET_RIGHT = 140;

// # TUIOMapView

// Like [MapView](MapView.html), TUIOMapView handles interaction with the outside world, in this case
// a tangible user interface table. 
class TUIOMapView {

  // ### Instance variables

  // We still need to know how many rows and columns there should be in the map.
  // And we still need a bunch of [MapCellViews](MapCellView.html). 
  int cols, rows;
  MapCellView[][] cell_views;
  PImage[] tiles;

  // We are using a new helper class called a [Frame](Frame.html), which translates between
  // different coordinate spaces. More on this later.
  Frame camera_frame, map_frame, text_frame;

  // We are going to use a HashMap to keep track of the fiducials (See the [the BB&A page](https://web.stanford.edu/class/educ211/tangible-interface-tables.html)). Each fiducial on the screen is identified by an integer ID, and will 
  // point to one MapCellModel. As the fiducials move around, we want to update MapCellModels with the locations 
  // of hospitals.
  HashMap<Integer,MapCellModel> fiducials;
  
  // ### Constructor

  // The constructor now requires more parameters: we need to know the location (x, y) and size (width, height) of
  // the area of interest in the camera's field of view as well as the location and size of the display area
  // where the map should be rendered.
  TUIOMapView(
      int _cols, int _rows, 
      int x_in, int y_in, int width_in, int height_in, 
      int x_out, int y_out, int width_out, int height_out
  ) {

    // We now have a lot of numbers to keep track of. This is where [Frames](Frame.html) come in. 
    // Once we initialize them, we can rely on them to translate back and forth between camera space, display 
    // space, and map space. (We're even using an extra frame to define the space of the text box where
    // instructions and score get rendered.)
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

    // Create an instance of the HashMap, ready for use.
    fiducials = new HashMap<Integer,MapCellModel>();
        
    // As before, load the images once instead of having separate images loaded for each cell.
    tiles = new PImage[] {
      loadImage("tiles/field.png"), 
      loadImage("tiles/road.png"), 
      loadImage("tiles/forest.png"),
      loadImage("tiles/town.png"),
      loadImage("tiles/hospital.png")
    };

    // As before, instantiate each [MapCellView](MapCellView.html). 
    // The only change is that we got rid of some math because the [Frame](Frame.html) can do it
    // for us.
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
  
  // ### render 

  // Except for one minor change, `render` is unchanged.
  void render(MapModel model) {
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        cell_views[j][i].render(model.cell_models[j][i]);
      }
    }    
    fill(0);

    // As before, print some text to the top right corner.
    // Compared to [MapView](MapView.html), the [Frame](Frame.html) abstraction
    // lets us do this much more elegantly. As a result, we can get a bit more
    // creative: When there are no hospitals on the board, don't show the score. 
    // When all the hospitals are placed, don't show how many hospitals are left.
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

  // ## Event bindings

  // ### handle_add_fiducial
  
  // Called when the camera detects a new fiducial.
  void handle_add_fiducial(int id, float x, float y, MapModel model) {

    // Figure out which map cell the fiducial's camera-space position corresponds to and 
    // get that cell.
    int col = camera_frame.get_col(x);
    int row = camera_frame.get_row(y);
    MapCellModel cell_model = model.cell_models[row][col];

    // Store a link between the fiducial's id and the cell.
    fiducials.put(id, cell_model);

    // And add a hospital to the cell. 
    cell_model.add_hospital();

    // Every time a hospital is added or removed, we need to re-compute cell distances.
    model.update_cell_distances();
  }

  // ### handle_remove_fiducial
  
  // Called when the camera no longer sees a fiducial.
  void handle_remove_fiducial(int id, float x, float y, MapModel model) {

    // Look up the fiducial's cell, remove its hospital, and remove the 
    // link between the fiducial's id and the cell.
    MapCellModel cell_model = fiducials.get(id);
    cell_model.remove_hospital();
    fiducials.remove(id);

    // Then update distances.
    model.update_cell_distances();
  }
  
  // ### handle_move_fiducial

  // Called when a fiducial's position changes..
  void handle_move_fiducial(int id, float x, float y, MapModel model) {

    // Figure out which map cell the fiducial's camera-space position corresponds to and 
    // get that cell. Then get this fiducial's new cell using its camera-space position 
    // and the fiducial's old cell by looking it up in `fiducials`.
    int col = camera_frame.get_col(x);
    int row = camera_frame.get_row(y);
    MapCellModel new_cell_model = model.cell_models[row][col];
    MapCellModel old_cell_model = fiducials.get(id);

    // Check whether the new cell and the old cell are actually different (otherwise 
    // it was just a small change in position, mapping to the same cell, and there is no effect 
    // on the model).
    if (new_cell_model != old_cell_model) {

       // If they are different, then update this fiducial's cell in `fiducials`, remove the hospital
       // from the old cell, add it to the new cell, and update cell distances.
       fiducials.put(id, new_cell_model);
       old_cell_model.remove_hospital();
       new_cell_model.add_hospital();
       model.update_cell_distances();
    }
  }
}

// ## Next up...

// That's about it! We don't need to make any changes to the other files. We did, however, use one new
// class: [Frame](Frame.html). Now that we have another set of coordinates (points in the camera space 
// coming from ReactiVision), I noticed that I frequently needed to convert from one coordinate space 
// to another. So I designed a class which takes care of this work for me. This is yet another example
// of using modularity to encapsulate complexity. 

// Let's read how [Frame](Frame.html) works.
