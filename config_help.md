# Voxelizer - Configuration

JSON Configuration : `<worldpath>/config/voxelizer.json`

Text Logs : `<worldpath>/logs/voxelizer/<date>.txt`

Explaining document(this, Markdown) : `<modpath/gamepath>/voxelizer/config_help.md`

Readme : `<modpath/gamepath>/voxelizer/Readme.md`

Default Configuration : `<modpath/gamepath>/voxelizer/default_config.json`
```json
{
  "max_precision" : 15,
  "download" : true,
  "defaults" : {
    "precision" : 4,
    "min_density" : 0.1,
    "dithering" : 10,
    "placement" : 1,
    "color_choosing" : 1,
    "filtering" : 1
   }
}
```

#### `max_precision`
Integer, maximum settable precision.
#### `download`
Boolean, whether to enable the `/vox download` chatcommand.
#### `defaults`
Dictionairy / table, default names assigned to corresponding values. Possible names below.
##### `min_density`
Float between 0 and 1. Minimum density default.
##### `precision`
Integer > 1 and < 100. Precision default.
##### `dithering`
Default dithering algorithm ID (see `/vox dithering`).
##### `placement`
Default placement mode ID (see `/vox placement`).
##### `color_choosing`
Default color choosing algorithm ID (see `/vox color_choosing`).
##### `filtering`
Default filtering algorithm ID (see `/vox filtering`).
##### `model` / `texture` / `nodemap`
Optional default filenames. Files will be searched in world's media folder.
If not given, Voxelizer falls back to default files from mod's media folder.