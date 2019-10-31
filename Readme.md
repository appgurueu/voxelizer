![Logo](https://raw.githubusercontent.com/appgurueu/voxelizer/master/logo.png)

# Voxelizer (`voxelizer`)

Turns 3D models into astonishing voxel builds. Sort of the opposite of [`wesh`](https://github.com/entuland/wesh) and [`meshport`](https://github.com/random-geek/meshport).
Another mighty world manipulation tool like [`worldedit`](https://github.com/Uberi/Minetest-WorldEdit). Blazing fast.

## About

**Note : Voxelizer needs to be added to the "trusted mods" if "mod security" is enabled.**
Depends on [`modlib`](https://github.com/appgurueu/modlib) and [`cmdlib`](https://github.com/appgurueu/cmdlib). IntelliJ IDEA with EmmyLua plugin project.
Code licensed under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html) for now.

Written by Lars Mueller alias LMD or appguru(eu).

Media licenses (files in the `media` folder) :
* `character.obj` - [CC BY-SA 3.0](https://github.com/minetest/minetest_game/tree/master/mods/player_api/README.txt), by MirceaKitsune & stujones11
* `character.png` - [CC BY-SA 3.0](https://github.com/minetest/minetest_game/tree/master/mods/player_api/README.txt), by Jordach
* `colors.txt` - [BSD 2-Clause "Simplified" License](https://github.com/minetest/minetestmapper/blob/master/COPYING), by sfan5
* `wool.txt` - derived from `colors.txt`, same license

Logo license (`logo.png`) : derived from `character.png` by Jordach (see above), same license (CC BY-SA 3.0), rendering & modifications by me (LMD)

## Links

* [GitHub](https://github.com/appgurueu/voxelizer) - sources, issue tracking, contributing
* [Discord](https://discord.gg/ysP74by) - discussion, chatting
* [Minetest Forum](https://forum.minetest.net/viewtopic.php?f=9&t=23070) - (more organized) discussion
* [ContentDB](https://content.minetest.net/packages/LMD/voxelizer/) - releases (downloading from GitHub is recommended)


## Screenshots

![Screenshot 1](https://raw.githubusercontent.com/appgurueu/voxelizer/master/screenshot.png)
Some Sams, using reduced palettes.

![Screenshot 2](https://raw.githubusercontent.com/appgurueu/voxelizer/master/screenshot_2.png)
Another Sam, using the full `colors.txt` palette from Minetestmapper.

![Screenshot 3](https://raw.githubusercontent.com/appgurueu/voxelizer/master/screenshot_3.png)
Same Sam, rear view.

![Screenshot 4](https://raw.githubusercontent.com/appgurueu/voxelizer/master/screenshot_4.png)
2 mages & Ironmen (thanks to [Jordach](http://minetest.fensta.bplaced.net/#author=Jordach) and [Ginsu23](http://minetest.fensta.bplaced.net/#author=Ginsu23) for the skins)

The used texture pack was [MTUOTP](https://content.minetest.net/packages/GamingAssociation39/mtuotp/) by Aurailus and GamingAssociation39. 
Other textures seen are from [Minimal Development Test](https://github.com/minetest/minetest/tree/master/games/minimal) or the [Wool mod](https://github.com/minetest/minetest_game/tree/master/mods/wool) (wool textures by Cisoun).

## Usage

All commands are executed with `/vox <command> {params}`. If in need for help, just do `/help vox`.
You need the `voxelizer` priv to use any of the Voxelizer commands. Some commands require extra privs.
Media - models, textures and nodemaps (color lookups) - is stored in `<worldpath>/media`.
If you are unsure about which settings to use, either do some research or *try it and see*.
Editing the placed models is recommended; Voxelizer might place a few blocks undesirably, which needs to be fixed by hand.
Voxelizer needs to be added as to the trusted mods in the settings in order to be able to read textures or download files.
Disabling mod security would also work but is **not** recommended.

### Configuration

Per-player configuration commands. Configuration remains after shutdown (is persistent).

* `texture [path]` - set/get the current texture (see [Supported File Formats](#supported-file-formats))
* `nodemap [path]` - set/get the current nodemap (see [Supported File Formats](#supported-file-formats))
* `dithering [id]` - set/get the current error diffusion dithering algorithms (specify algorithm ID)
* `color_choosing [id]` - set/get current color choosing mode (best/average)
* `filtering [id]` - set/get current filtering mode (nearest/bilinear)
* `placement [id]` - set/get merge modes (specify mode ID)
* `model [path]` - set/get the current 3D model (see [Supported File Formats](#supported-file-formats))
* `alpha_weighing [enable/disable]` - get/enable/disable weighing colors (see `color_choosing`) by their alpha
* `protection_bypass [enable/disable]` - get/enable/disable protection bypass (you need the priv `protection_bypass` to enable it)
* `precision [number]` - set/get the current rasterization accuracy (integer). Note that this increases computation time quadratically. Values higher than `10` are not recommended.

#### Supported file formats

##### Textures

All file formats supported by `ImageIO` on your Java setup. You can find them out using the following commands : 
```bash
cd ~/.minetest/mods/voxelizer/production/voxelizer
java SupportedTextureFormats
```
On my system (Java 11), the output was : 
```
The supported image file formats are : JPG, jpg, tiff, bmp, BMP, gif, GIF, WBMP, png, PNG, JPEG, tif, TIF, TIFF, wbmp, jpeg
```

Internally, the `SIF` (`.sif`, "Simple Image File") file format (just gave it some name) is used : 
* 4 byte header : 2 times a 2 byte unsigned short, first is width, second is height
* Followed by uncompressed image data : array of 4 byte tuples, consisting of ARGB unsigned bytes, positions in array are calculated as `x + y * width`

##### Node Map

Any valid `minetestmapper-colors.txt` will be accepted by this mod. The format is : 

Multiple lines like `[(<content_id:hex>|<nodename>) <red> <green> <blue>][#<comment>]`

##### 3D Models

Only the `.obj` file format is (with certain restrictions) supported. It is recommended to export your models from Blender.

Restrictions : 

* No free form geometry (`vp`s)
* No complex texture coordinates (`vt`s with more than 2 coordinates given), use simple ones
* No polygonal faces (`f`s with more than 3 indexes), use triangles
* No line (`l`) elements
* No material (`.mtl`) file usage, only a single texture
* No smooth shading (`s`)
* No normals (`vn`)

All of the above will be ignored whenever possible.

Export your .obj files with Blender properly by ticking the right options, as seen here : 

![Ticked checkboxes in Blender's "Export OBJ" dialog](http://www.opengl-tutorial.org/assets/images/tuto-7-model-loading/Blender.png)

So summarized, the following boxes should be ticked : 

- [x] Apply modifiers
- [x] Write normals (not required)
- [x] Write UVs
- [x] Triangulate faces
- [x] Objects as OBJ objects

Everything else should not be ticked.

### Actions

* `1`/`2` - set first and second edge position, model will be placed thereafter and positions will be deleted
* `place [scale]` - place model with given scale (defaults to `1`)
* `download <url> [filename]` - download a file from the internet using a GET request, requires `voxelizer:download` priv additionally.
  File will be downloaded to `<worldpath>/media/filename`. The URL filename will be taken if `filename` is not specified.
  **Likely not safe due to the usage of HTTP Requests.**
