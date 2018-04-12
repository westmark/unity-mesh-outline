# unity-mesh-outline
Unity Package for rendering outlines around meshes/objects

## Usage

Either clone this repo, or download the latest \*.unitypackage from releases.

Add the `OutlinePostEffect` to your main camera. Drag and drop the two shaders `DrawSimple` and `PostOutline` to their respective receptors on the newly added `OutlinePostEffect` component.

## Caveats

* Currently the outline renders on top of everything else
* There is no way(that I know of) to configure the outline width

If you know how to fix any of the above(and make it configurable) I would love a PR.

## Credits

All credit for this work goes to the participants in the following thread on the Unity3D forums:

https://forum.unity.com/threads/can-we-use-new-unity-5-5-editor-outline-in-game.445885/

All I did was to bundle the code and make a few minor changes such as making the outline color configurable.
