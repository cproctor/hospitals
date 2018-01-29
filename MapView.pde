// # MapView

// The MapView class is responsible for rendering the whole map and managing interaction
// with the map. Classes describe kinds of things; instances represent things themselves. 
// We only create one instance of MapView (in [hospitals.pde](hospitals.html#section-4)), 
// but we will create many instances of other classes. 
class MapView {

  // ### Instance variables

  // Each instance of MapView will have its own copy of these variables. 
  // First, we have a bunch of integers (`int`) which record the number of rows and columns in the map, the x and y 
  // coordinates of the map on the screen, the width and height of the map on the 
  // screen, and the width and height of each cell in the map.
  int cols, rows, x, y, map_width, map_height, cell_width, cell_height;

  // `cell_views` will be a two-dimensional array of MapCellViews, each of which will be 
  // responsible for rendering one cell in the map. 
  MapCellView[][] cell_views;

  // `tiles` will hold an array of images. These will be used by MapCellViews during rendering, 
  // bit it would be pretty inefficient to ask each MapCellView to re-load the same images. 
  // So instead the MapView will load them once, and make them available to each MapCellView.
  PImage[] tiles;

  // `active_cell_model` will be a reference to a particular cell model. This will be used when 
  // the player drags a hospital around the screen. When the mouse moves over a new cell, we will
  // need to remember where the hospital used to be so that we can move it from there to the new
  // cell.
  MapCellModel active_cell_model;
  
  // ### Constructor

  // A class constructor describes how to make a new instance. For MapView, you need to provide
  // integers for the number of columns and rows, the x and y screen coordinates, and the width
  // and height of the map on the screen. 
  MapView(int _cols, int _rows, int _x, int _y, int _map_width, int _map_height) {

    // Save the arguments in instance variables so we can access them later.
    // This is a common pattern you'll see in other classes.
    cols = _cols;
    rows = _rows;
    x = _x;
    y = _y;
    map_width = _map_width;
    map_height = _map_height;

    // Calculate the cell width and height using the other parameters. 
    cell_width = map_width / cols;
    cell_height = map_height / rows;

    // Create a 2d array to hold a bunch of [MapCellViews](MapCellView.html).
    cell_views = new MapCellView[rows][cols];
    
    // Load the images we will need for rendering tiles. (These live in the `data` folder.)
    // <br />
    // <img src="tiles/field.png" width="32px">
    // <img src="tiles/road.png" width="32px">
    // <img src="tiles/forest.png" width="32px">
    // <img src="tiles/town.png" width="32px">
    // <img src="tiles/hospital.png" width="32px">
    tiles = new PImage[] {
      loadImage("tiles/field.png"), 
      loadImage("tiles/road.png"), 
      loadImage("tiles/forest.png"),
      loadImage("tiles/town.png"),
      loadImage("tiles/hospital.png")
    };


    // Go through every row...
    for (int j = 0; j < rows; j++) {
    
      // and every column... 
      for (int i = 0; i < cols; i++) {

        // and create an instance of a [MapCellView](MapCellView.html),
        // providing x, y, width, and height coordinates (as well as the tile images). 
        // This [MapCellView](MapCellView.html) will own that little patch of screen. 
        cell_views[j][i] = new MapCellView(
          x + i * cell_width, 
          y + j * cell_height, 
          cell_width, 
          cell_height, 
          tiles
        );
      }
    }
  }
  
  // ### Render

  // `render` is the most important method of every view--`render` kicks off the 
  // whole process of rendering the view. 
  void render(MapModel model) {

    // Most of the work is delegated to the individual MapCellViews, so we go through 
    // every row...
    for (int j = 0; j < rows; j++) {

      // and every column...
      for (int i = 0; i < cols; i++) {

        // look up the right [MapCellView](MapCellView.html), and tell it to 
        // [render](MapCellView.html#section-11). To do this, we also need to provide
        // the right [MapCellModel](MapCellModel.html), but that's getting ahead of ourselves.
        cell_views[j][i].render(model.cell_models[j][i]);
      }
    }    

    // Set the text color to black.
    fill(0);

    // Write some basic instructions at the top right corner of the screen,
    text("Place the hospitals", x+map_width - 140, y+20);
    text("so they serve the towns", x+map_width - 140, y+32);

    // and write the score and number of hospitals remaining. Remember, `render` gets called
    // over and over many times per second, so as long as the model always knows the score, 
    // it will be shown correctly. 
    text("Score: " + model.score(), x+map_width - 140, y+44);
    if (model.hospitals_left() > 0) {
      text("Hospitals left: " + model.hospitals_left(), x+map_width - 140, y+56);
    }
  }
  
  // ## Event handlers

  // Remember how [hospitals.pde](hospitals.html#section-10) delegated events to the view?
  // Now we have to describe what should happen when user interaction events occur. In the three
  // functions below, we make it possible for the user to place new hospitals by clicking on empty map cells,
  // and to move hospitals around by clicking, dragging, and releasing cells containing hospitals. 

  // ### handle_press

  // When the mouse is pressed over a cell, 
  void handle_press(MapModel model) {

    // Get the map coordinates of the cell under the mouse.
    int[] index = get_mouse_cell_index();

    // Print a debugging statement to the console. 
    println("PRESS", index[0], index[1]);

    // Make a variable called `cell_model` referring to a particular [MapCellModel](MapCellModel.html). 
    // (Use the map coordinates to look up the right cell model.)
    MapCellModel cell_model = model.cell_models[index[1]][index[0]];
   
    // If the cell is free (it has no towns or hospitals), and there are still more 
    // hospitals available to be placed,
    if (cell_model.is_free() && model.num_hospitals() < model.hospitals_allowed) {
        
        // then add a hospital here, remember this cell as the active cell model, 
        // and update the cell distances. ([model.update_cell_distances](MapModel.html#section-34) computes each cell's distance
        // to the nearest hospital.)
        cell_model.add_hospital();
        active_cell_model = cell_model;
        model.update_cell_distances();
    }

    // Otherwise, if there's a hospital here, 
    else if (cell_model.has_hospital) {

      // remember this  as the active cell model.
      active_cell_model = cell_model;
    }

    // Finally, in case neither of the previous conditions was true, clear `active_cell_model` to indicate
    // that there is no active cell.
    else {
      active_cell_model = null; 
    }
  }
  
  // ### handle_drag

  // When when the mouse moves while pressed, 
  void handle_drag(MapModel model) {
    
    // If the mouse is over the map, 
    if (mouse_over_map()) {

      // Get the map coordinates of the cell under the mouse, print a debugging statement to the console,
      // and create a reference to the relevant cell model (same as the previous function). 
      int[] index = get_mouse_cell_index();
      println("DRAG", index[0], index[1]);
      MapCellModel cell_model = model.cell_models[index[1]][index[0]];

      // If there is an active cell, and it's not the same as the cell presently under the mouse, and 
      // if the cell presently under the mouse is free,
      if (active_cell_model != null && cell_model != active_cell_model && cell_model.is_free()) {

       // then move the hospital from the active cell to this cell, make this the active cell, and 
       // update the cell distances. (A hospital's position has changed, so we need to re-compute every 
       // cell's distance to the closest hospital.)
       active_cell_model.remove_hospital();
       cell_model.add_hospital();
       active_cell_model = cell_model;
       model.update_cell_distances();
      }
    }
  }
  
  // ### handle_release

  // When the user releases the mouse button, clear `active_cell_model` to indicate that there is no
  // active cell (in particular, no hospitals should be getting moved around). 
  void handle_release() {
    println("RELEASE");
    active_cell_model = null; 
  }
  
  // ## Helpers
  // In the methods above, there were some tasks that had to be done several times. We were able to simplify
  // the code by pulling this work out into helpers. 

  // ### get_mouse_cell_index
  
  // Some simple math allows us to convert screen coordinates into map coordinates. The model doesn't know
  // anything about where on screen the map is getting rendered (or whether it's getting rendered at all), 
  // so we want to work with map coordinates instead. Processing always provides `mouseX` and `mouseY`.
  int[] get_mouse_cell_index() {
    int i = (mouseX - x) / cell_width;
    int j = (mouseY - y) / cell_height;

    // We also want to ensure that we never return invalid coordinates, so constrain the return values
    // to be between 0 and `rows - 1` or `cols - 1`. Then we return an array with two integers. 
    int[] cell = new int[] {max(0, min(cols-1, i)), max(0, min(rows-1, j))};
    return cell;
  }
  
  // ### mouse_over_map

  // Returns a boolean (`true` or `false`) indicating whether the mouse is over the map. 
  boolean mouse_over_map() {

    // For x and y, check that the mouse position is big enough but not too big.
    return (x <= mouseX && mouseX < x+map_width && y <= mouseY && mouseY < y+map_height);
  }
}

// ## Next up...

// Before we go on, I would like to point out that our work here was made much easier because
// we had model methods like [model.score()](MapModel.html#section-32) and 
// [model.update_cell_distances()](MapModel.html#section-34) to do the
// hard work for us. This is another layer of modularity. In earlier versions, this file
// was a lot messier--whenever possible, it's a good idea to **refactor** your code and move complexity
// into the model. 

// Now let's dive one layer deeper into [MapModel](MapModel.html). 
