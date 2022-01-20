Unity Package for uDTU version 1.3 alpha 4
====================


This the Unity Package for Unofficial DTU Bridge, an unofficial update project for the opensource Daz To Unity Bridge released by Daz3D.  It contains a number of bugfixes and feature additions not yet incorporated in the official Daz To Unity project.

**PLEASE NOTE**: This is only HALF of the full uDTU Bridge.  You must also install the [Daz Plugin](https://github.com/danielbui78/UDTU) part of the uDTU Bridge in order to have full functionallity of all features and bugfixes.  Additionally, this project is still in _alpha development_ stage.  As you will see, the Daz Plugin is not even at version 1.3 yet.  Once the Daz Plugin is updated to v1.3, there will be better integration and **better instuctional documentation** between this Unity Package and the Daz Plugin.  Thanks for your understanding.

New in this version:
====================
- Fixed assembly definition for Scripts/Editor folder.  Projects should now properly build.
- Fixed error when importing with dForce Support enabled.


Known Issues:
=============
- Subdivision procedure is currently only single-threaded CPU-based and may take several minutes to bake Subdivision level 3 and 4.
- dForce strand-based hair is not yet supported.
- dForce clothing with high poly counts will cause heavy performance slowdowns in Unity.
- Geograft morphs are not yet supported.
- Genesis 8/8.1 prop rigging is not yet 100% accurately converted.
- Identical / duplicate materials are not yet detected for merger in Unity.
- Cloth physics colliders are not yet resized to Daz figures.
- Daz dForce weight maps are not yet converted properly to Unity Cloth physics weight maps.


Installation Instructions:
==========================
This Unity Package should be installed from the Unity Package Manager:
1. You will need to delete any existing DTU plugin from "Assets/Daz3D" folder.  You can save your previous exported assets.
2. In Unity, select the main menu option Window -> Package Manager.
3. Click the "+" button and select "Add package from git URL".
4. Paste `https://github.com/danielbui78/udtu-unity-package.git` into the text field and click the "Add" button.
5. Wait for the "Unofficial DTU Bridge" package to be installed.
6. Select "In Project" from dropdown button next to the "+" button.
7. "Unofficial DTU Bridge" should now show up in the "Other" section above "Unity Technologies".
8. Once the Unity Package is installed, select the main menu option Daz3D -> "Open DazToUnity Bridge window". (You may need to close and re-open your project for the Daz3D main menu option to show up.)
9. Select the "Options" tab. If the text line at the bottom reads: "RenderPipeline Not Detected", click "Redetect RenderPipeline".
10. Select the option to Update the Symbol Definitions.  Then wait for the scripts to recompile.  This may take several minutes.
11. Once the RenderPipeline is configured, be sure to follow directions below to add the IrayUberSkinDiffusionProfile if you are using HDRP.


HDRP-ONLY: Adding HDRP Diffusion Profile (aka subsurface-scattering):
==========================
In order to use the HDRP Daz skin shaders, you must manually add the IrayUberSkinDiffusionProfile to the Diffusion Profile List.  Until this is done, materials using the HDRP Daz skin shader will have a Green Tint.
Unity 2019: This list is found in the Material section of each HD RenderPipeline Asset, which can be found in the Quality->HDRP panel of the Project Settings dialog.
Unity 2020 and above: This list is found at the bottom of the HDRP Default Settings panel in the Project Settings dialog.



To Test Subdivision support:
=========================
1. Load Daz Figure.
2. Select "File->Send To->Unofficial DTU".  The "Unofficial DTU Bridge" main dialog window should appear.
3. If the "Enable Subdivision" checkbox is unchecked, click to place a checkmark.
4. Click "Choose Subdivisions". The "Choose Subdivision Levels" dialog window should appear.
5. Set the desired Subdivision Level for each Object/Figure by clicking the corresponding "Subdivision Level" drop-down menu and selecting a subdivision level from 0 to 4.
6. Click Accept for the "Choose Subdivision Levels" dialog.
7. Click Accept for the "Unofficial DTU Bridge" dialog.


To Test dForce Clothing to Unity Cloth Physics support:
=======================================================
*Make sure you save your DazStudio project before taking these steps, some will Not revert with Undo command.*
*Preparation:*
1. In the Unity Editor, open the Unofficial DTU Bridge window.  Go to the Options tab.  Make sure the "Enable dForce Support" option is checked on.  Close the Unofficial DTU Bridge window.  Switch to Daz Studio.
2. Load dForce compliant clothing onto your figure.
3. Clear any dForce simulation calculations in the scene by selecting the Simulations Settings Pane and clicking "Clear".  Warning: you will NOT be able to undo this procedure.
4. Select the Surfaces Pane and select the clothing surface materials.  For each material, double-check the Simulation Properties Tab to make sure that Dynamics Strength is set correctly: a value of 1.00 will often cause clothing to fall off or explode in Unity.  Try setting this to 0.5 if this happens.
5. Recommend setting one Material's Dynamics Strength to 0.2 or less, to act as an anchor for the rest of the clothing -- example: waist-line of pants and skirts, neck-line of shirts and jackets.
6. With dForce Clothing still selected, add a Push Modifier via the "Edit->Object->Geometry->Add Push Modifier..." menu command.  This will add a new property in the Parameters Pane called "PushModifier" in the "Mesh Offset" Property Group.  Try 0.1 as an initial value.  It can be increased if you are having cloth collision issues such as clothes exploding.
7. Select "File->Send To->Unofficial Daz to Unity Bridge".
8. Open Unity Editor window and wait for DTU import to complete and Prefab to be created in the Scene.

*Cloth Colliders:*
1. In the Scene Pane, open the imported prefab and select the "Cloth Collision Rig".  In the Inspector Pane, you will see the "Cloth Collision Assigner" Script Component.
2. There are three sections that can be expanded: "Upperbody Colliders" contains a list of *paired* sphere colliders for the upper body.  "Lowerbody Colliders" contains a similar list of *paired* sphere colliders for the lower body.  *"Paired" sphere colliders* are a two sphere colliders that joined together by the Cloth Physics component into a collision cylinder with differing sized round ends.  This way, you can make custom shapes for limbs, torso and other body parts.
3. You may click on each sphere collider to access the specific sphere collider component within the animation skeleton.  You can then adjust the position or size of the collider.
4. The third section is "Cloth Configuration List".  Expand this section and you will see a list of all imported dForce items that have been converted to use Unity Cloth Physics components.  Select each item and uncheck "Upper Body" or "Lower Body" to disable any cloth collision skeleton parts that are unneeded by that clothing.
5. Double click on a Cloth component here will take you to the clothing object that it controls.  Do this for each one: Find the Cloth component and check the Sphere Colliders section.  You will notice that this is empty.  It is filled at runtime (when the project is Played) by the "Cloth Collision Assigner" Script.  If you want the list to be populated at Edit-Time, then during runtime, click on the three dots of the component and select "Copy Component".  Then stop the project and click the three dots again, now select "Paste Component Values".

*Cloth Physics Weight Maps:*
1. Select dforce clothing in the Scene Pane and you should see the Cloth Physics Component in the Inspector Pane.
2. Below the Cloth Physics Component is a new "Cloth Tools" component that contains convenience features for working with cloth physics weight maps.
3. The first section lists all the material groups within the current dforce item.  Each one contains a slider and number textfield and a "Set" and "Clear" button.
4. Use the slider or textfield to enter a decimal number then click "Set" to assign that number as the "Max Distance" to all vertices within that material group.  Note: "Max Distance" is the maximum distance a vertex can travel from its original position due to cloth physics and is measured in Unity worldspace units.  That means a value of "1.0" will let a vertex move up to 1 meter in the world.  The slider will move up to 0.2 units (20 centimeters) but the textfield can be used to enter a value of any size.
5. Click "Clear" to remove all constraints, represented by a black sphere.  This will let the vertex travel an infinite distance from its original position due to cloth physics.
6. "Load Weightmap data" can be used to load Unity Weight Maps or Dforce Weight Maps.  You can use the drop down menu in the load file dialog to choose which file types to filter or to see all files.  The Unity Weight Maps are raw binary dumps of the floating point information for MaxDistance values of the selected item.  The Dforce Weight Maps are raw binary dumps of the unsigned shorts (16bit) information from the Daz Studio "Dforce Weight Node Modifier / Influence Maps".  Dforce Weight map files are automatically created if Daz item contains a Dforce weightmap.
*Note*: In Daz Studio, this value is multiplied by the Dynamics Strength for the corresponding material group.  However, the imported Unity value is not currently multiplied by the corresponding material group because the vertex ordering of the raw Dforce weight map has not yet been decoded.
7. "Save Weightmap data" will popup the save file dialog to let you save the current weightmap in a Unity-compatible Weight Map format.
8. "Load Gradient Pattern" will create a gradient pattern from 0.0 to 1.0 from index 0 of the weightmap to the last index of the weightmap.
9. "Zero All Weights" will set the entire weightmap to 0.0.
10. "Clear All Weights" will remove all constraints from the entire weightmap and allow infinite distance to be travelled by cloth physics.

Tips: if clothing falls off or explodes, try decreasing the Dynamics Strength inside Daz Studio and/or increasing the Push Modifier Offset.


Copyright Notice:
==========
This product is based on software by DAZ 3D, Inc. Copyright 2002-2021 DAZ 3D, Inc., used under modified Apache 2.0 License.  All rights reserved.
