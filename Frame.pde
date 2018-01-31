// Represents a 2-dimensional coordinate space
class Frame {
   int cols, rows, x, y, frame_width, frame_height, cell_width, cell_height;
   
   // Constructor
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
   
   int get_col(float i) {
      return floor(map(i, x, x+frame_width, 0, cols));
   }
   
   int get_row(float j) {
     return floor(map(j, y, y+frame_height, 0, rows));
   }
   
   int get_x(int col) {
     return floor(map(col, 0, cols, x, x+frame_width));
   }
   
   int get_y(int row) {
     return floor(map(row, 0, rows, y, y+frame_height));
   }

   // Determine whether a point in the external coordinate space is within the frame
   boolean is_in_frame(float i, float j) {
     int col = get_col(i);
     int row = get_row(j);
     return 0 <= col && col < cols && 0 <= row && row < rows;
   }
}