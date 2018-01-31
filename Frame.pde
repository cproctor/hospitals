// # Frame

// A Frame epresents a 2-dimensional space of rows and columns
// embedded within a larger coordinate space. Each of Frame's methods
// is relatively straightforward, but encapsulating it here makes
// the rest of our code much easier to think about.
class Frame {

   // ### Instance variables

   // These should be familiar by now.
   int cols, rows, x, y, frame_width, frame_height, cell_width, cell_height;
   
   // ### Constructor

   // Does almost nothing other than storing the variables passed in.
   Frame(int _cols, int _rows, int _x, int _y, int _frame_width, int _frame_height) {
    cols = _cols;
    rows = _rows;
    frame_width = _frame_width;
    frame_height = _frame_height;
    x = _x;
    y = _y;
    cell_width = frame_width / cols;
    cell_height = frame_height / rows;
   }
   
   // ### get_col

   // Translate a point's x-value in the external space into its corresponding column. 
   int get_col(float i) {

      // The built-in functions [floor](https://processing.org/reference/floor_.html) and 
      // [map](https://processing.org/reference/map_.html) save us some work.
      return floor(map(i, x, x+frame_width, 0, cols));
   }
   
   // ### get_row

   // Translate a point's y-value in the external space into its corresponding row. 
   int get_row(float j) {
     return floor(map(j, y, y+frame_height, 0, rows));
   }
   
   // ### get_x

   // Translate a column into the corresponding x-value in the external space.
   int get_x(int col) {
     return floor(map(col, 0, cols, x, x+frame_width));
   }
   
   // ### get_y

   // Translate a row into the corresponding y-value in the external space.
   int get_y(int row) {
     return floor(map(row, 0, rows, y, y+frame_height));
   }

   // ### is_in_frame

   // Determine whether a point in the external coordinate space is within the frame
   boolean is_in_frame(float i, float j) {
     int col = get_col(i);
     int row = get_row(j);
     return 0 <= col && col < cols && 0 <= row && row < rows;
   }
}

// ### That's it!
// I hope some of the design principles discussed in this documentation are useful to you 
// in your own programming. [Back to the menu](index.html).
