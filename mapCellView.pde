// the mapCellView takes care of rendering a mapCellModel

int TOWN = 3;
int HOSPITAL = 4;

class MapCellView {
  
  int x, y, cell_width, cell_height;
  PImage[] tiles;
  
  MapCellView(int _x, int _y, int _cell_width, int _cell_height, PImage[] _tiles) {
    x = _x; 
    y = _y;
    cell_width = _cell_width;
    cell_height = _cell_height;
    tiles = _tiles;
  }
  
  void render(MapCellModel model) {
    tint(get_tint(model.normalized_value()));
    image(tiles[model.terrain], x, y, cell_width, cell_height);
    if (model.has_town) {
       image(tiles[TOWN], x, y, cell_width, cell_height);
    }
    if (model.has_hospital) {
       image(tiles[HOSPITAL], x, y, cell_width, cell_height);
    }
  }
  
  color get_tint(float value) {
    return lerpColor(color(100, 255, 100), color(255, 100, 100), value);
  }
}