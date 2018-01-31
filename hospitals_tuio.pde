// # Hospitals TUIO

// This file is almost the same as the [original version](hospitals.html), except
// that we are using a new view class and bind to new events, so that we can support
// a tangible user interface table instead of a mouse as an input device. 

// Because we wisely designed a clean separation of model and view, 
// only minimal changes are needed to support this new interface.
// In this documentation, I will focus on the changes we had to make to the original file. 

// ### Initializing TUIO

// We need to import the TUIO library and create a TuioProcessing object. 
// You can read more about setting up TUIO [on the BB&A course website](https://web.stanford.edu/class/educ211/tangible-interface-tables.html).
import TUIO.*;
TuioProcessing tuioClient;


// We are now using a view of class [TUIOMapView](TUIOMapView.html) instead of 
// [MapView](MapView.html). We'll dig into that class shortly.
MapModel model;
TUIOMapView view;

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
int[][] towns = {
  {0, 0}, {3,3}, {20, 21}, {18, 20}, {17, 3}, {15,16}, {17, 16}, 
  {17, 14}, {14, 17}, {10, 7}, {6, 12}
};

void setup() {
   size(576, 576);

   // Create an instance of the TuioProcessing object, which listens for 
   // changes on the tangible interface table when ReactiVision is running. 
   // (Again, see details [here](https://web.stanford.edu/class/educ211/tangible-interface-tables.html).)
   tuioClient  = new TuioProcessing(this);
   model = new MapModel(terrain, towns, 3);
   view = new TUIOMapView(24, 24, 0, 0, 1, 1, 0, 0, 576, 576);
}

void draw() {
  view.render(model);
}

// ## New event bindings

// Previously, we bound to mouse presses, releases, and drags. Now, we have a new
// set of events, defined by the TUIO protocol. When we create functions with certain 
// names, they will be bound to the events we care about: fiducials being added, removed, and moved.
// As before, we delegate the action to our view.
void addTuioObject(TuioObject obj) {
  println("ADD", obj.getSymbolID());
  view.handle_add_fiducial(obj.getSymbolID(), obj.getX(), obj.getY(), model);
}

void removeTuioObject(TuioObject obj) {
  println("REMOVE", obj.getSymbolID());
  view.handle_remove_fiducial(obj.getSymbolID(), obj.getX(), obj.getY(), model);
}

void updateTuioObject(TuioObject obj) {
  println("MOVE", obj.getSymbolID(), obj.getX(), obj.getY());
  view.handle_move_fiducial(obj.getSymbolID(), obj.getX(), obj.getY(), model);
}

// ## Next up...

// Now let's see what's new in [TUIOMapView](TUIOMapView.html).
