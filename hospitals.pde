// # Hospitals
// 
// Hospitals is a simple game designed to show off the capabilities of TLTL's 
// tangible user interface tables (TUI's) and to demonstrate some best practices
// for writing programs. The goal of the game is to place hospitals so that they 
// do as good a job as possible serving all the rural towns. The score reflects 
// how long it takes to get from each town to the nearest hospital; travel is 
// faster along roads and much slower through forests. 

// It probably makes sense to play the game before reading the code. To play Hospitals, 
// download [Processing](https://processing.org/) and then download 
// [the code for Hospitals](https://github.com/cproctor/hospitals/releases/tag/v1). 

// <img src="hospitals.png" width="100%">

// ## Initialization

// We declare two global variables, `model` and `view`, each of which will 
// refer to an object defined in other files. It is wise to structure
// programs in this way. Models are responsible for managing state, all the data
// you would need to save a game
// and load it later. (For this game, state includes the positions of 
// all the hospitals and the score. If towns and terrain could change, we would
// also consider them part of state. Mouse events can impact the game, but the mouse 
// position isn't part of the core game data so we don't consider it part of state.)
// Views are
// responsible for interaction with the outside world--rendering the model 
// data and responding to user interactions. 
MapModel model;
MapView view;

// We use a two-dimensional array to define the world's terrain; `0` for fields, 
// `1` for roads, `2` for forests.
int[][] terrain = {
  { 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 }, 
  { 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 }, 
  { 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 }, 
  { 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 }, 
  { 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0 }, 
  { 0, 0, 0, 0, 1, 0, 0, 0, 2, 2, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 },
  { 0, 0, 0, 0, 1, 0, 0, 0, 2, 2, 2, 2, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 },
  { 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 },
  { 0, 0, 0, 0, 1, 0, 0, 2, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 },
  { 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 },
  { 0, 0, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0 },
  { 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 },
  { 0, 0, 2, 2, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 },
  { 0, 0, 2, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
  { 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 2, 0, 2, 0, 0, 0 },
  { 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 2, 2, 2, 2, 0, 2 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 2, 2, 2, 2, 2, 2 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 2, 2 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
};

// Then we describe
// the position of towns using another 2d array of (x,y) coordinates. It would be
// more graceful to store this data in another file (so that we could support
// multiple levels), but this works for now.
int[][] towns = {
  {0, 0}, {3,3}, {20, 21}, {18, 20}, {17, 3}, {15,16}, {17, 16}, 
  {17, 14}, {14, 17}, {10, 7}, {6, 12}
};

// ### Setup

// Every Processing program requires two functions: `setup` and `draw`. `setup` 
// runs once at the beginning of the program, setting the window size and 
// creating instances of the model and view. 
void setup() {
   size(576, 576);
   model = new MapModel(terrain, towns, 3);
   view = new MapView(24, 24, 0, 0, 576, 576);
}

// ### Draw

// `draw` is called over and over, many times per second. 
// The view's main job is to render the state data contained in the model. 
// As the program runs, the state changes, and it is reflected on-screen by
// re-rendering the view. 
void draw() {
  view.render(model);
}

// ## Event bindings
// The view's other job is to manage user interaction. These three functions
// are defined by Processing ([reference](https://processing.org/reference/))
// and are invoked at the appropriate time. (Thus, these functions are said to be
// *bound to the event*.) In each case, the main program 
// delegates action to the view. 

// ### mousePressed

// When the mouse is pressed, if the mouse is over the map, the view's 
// `handle_press` method is called. Note that we pass in the model, because
// the view will likely need to make changes to the state (for example, 
// adding a new hospital in a certain cell).
void mousePressed() {
  if (view.mouse_over_map()) {
    view.handle_press(model); 
  }
}

// ### mouseDragged

// `mouseDragged` is called every time the mouse moves while the button is pressed 
// (often tens of times per second). 
void mouseDragged() {
  if (view.mouse_over_map()) {
    view.handle_drag(model); 
  }
}

// ### mouseReleased

// `mouseReleased` is called every time the mouse button is released.
void mouseReleased() {
  view.handle_release();
}

// ### Next up...

// Before we go on, it's worth noting how little code there was in this file
// and how manageable it (hopefully) felt. One major goal of software design 
// is **modularity**, the encapsulation of complexity. In this file, we
// ask a bunch of objects to do complicated tasks, but we don't want to worry
// about the details of how those tasks get done (yet). Your tour of the code
// will dig deeper one layer at a time.
// 
// Next you should read about [MapView](MapView.html), the class which renders 
// the map and handles user interactions.
//
//
