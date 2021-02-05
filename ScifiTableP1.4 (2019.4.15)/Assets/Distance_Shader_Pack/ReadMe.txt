Distance based Low Poly and Smooth PBR Multi Color and Triplanar Terrain Shaders for Unity
(c) 2017 Dan Barabas
Created by Dan Barabas


DETAILS:

	I created these shaders as a fast way to apply multiple textures to procedural terrain (Spherical or Planar) 
	for various projects of mine.

	I hope you enjoy this asset. Feel free to include it in your own assets, games and source code.
	Please just add a credit in your Readme or Asset Description that links back to this asset. Thank you!

TL;DR Version:

	Add TerrainVectorsToShader.cs to your Game Object

	Make a Material (shaders are under DistanceGradient tab), and add it to Mesh Renderer
		If using Unity Terrain, also add your Material to the Custom Material tab under settings

	Setup your fields and get going! (Planar > Y-axis up, set Distance Scalars to (0,1,0); Spherical, set Distance Scalars to (1, 1, 1))
		*** May need to enter Play Mode once to get first Script and Material Updates to take place,
			after that, should update even in Edit Mode ***

		*** If Split Distances are not aligned properly, you can get some weird blends and negative colors:
			Make sure your Split Distances in the proper order ***

INCLUDED IN PACKAGE:

	Low Poly and Smooth, Texture and Color Shaders, with support for up to 11 Textures or Colors in each type.
		The paths for the various Shader types are:

					DistanceGradient/																				
			Terrain/				Color/
		Smooth/	LowPoly/		Smooth/	LowPoly/

	Terrain Shaders Properties:
		Properties for a specific Terrain

			Tint	
			Textures
			X Tiling
			Y Tiling
			Z Tiling
			Blend Sharpness
			Metallic
			Smoothness

		Properties for a specific Color

			Tint
			Metallic
			Smoothness
		
		Properties shared by adjacent Terrains/Colors

			Split Distance 	-This controls at what distance Colors/Terrains start blending

				*** If a higher level distance is below a lower level distance, you can get some odd blends and negative colors,
					so if things look odd, double check your split distances ***

			Blend Factor	-This controls the sharpness of the blending between two adjacent Colors/Terrains
			(0 is a hard edge, 1 is gradual blend)

		Overarching Property

			Noise Multiplier - Applies small variations to distance values so terrain splits are not completely even
	
	TerrainVectorsToShader.cs
		C# Script responsible for setting the axis or axes used for distance comparisons and the Distance Offset

	Some Meshes, Textures, and Materials I created for the Examples

	Example Scenes including:

		ExampleScene1
			Contains various examples of Shader/Material types

		ExampleScene2
			Contains a very basic example, to test how manipulating the variables effect the shader output

		ExampleUnityTerrainScene1
			Contains an example using Unity Terrain


INSTRUCTIONS:

	General and Procedural Meshes

		1) Add TerrainVectorsToShader.cs to the Game Object you will be texturing/coloring
			(This requires a Mesh Renderer and will add one, if one is not already present).

		2) Create a Material to apply to this Object and pick the Shader you want to use. Variants are in DistanceGradient.

		3) Attach the Material to the Game Object. This can be done either by dragging the Material onto the Object in the Hierarchy,
			or assigning it in the Mesh Renderer > Material field if the terrain is procedural.

		4) Set your TerrainVectorsToShader values in the Inspector. Distance Scalars determine which axes will be used as a distance evaluation.
			A value of zero means shifts in these axes will not effect the distance output. 
		
			A Value > 0 means there will be a distance evaluation along that axis, based on (0,0,0) or, if selected, an Offset. 

			Most Planar Terrains use Y-up, so Distance Scalar values of (0, 1, 0) would be used.
				For Spherical Terrains, values of (1, 1, 1) would be used. 

			Of course, you can use non zero/one values to introduce some non-uniformity in terrain/color patters.
				However, small changes in scalar values can have sweeping effects, and there is a Noise Value that can produce variations as well.

				*** You will want to input your Distance Scalars before any rotations are applied,
					since the shaders use local positions to calculate outputs ***

					For example: If you are importing a mesh made in Blender that hasn't had it's orientation fixed prior to importation (Z-up),
					you would want to use Distance Scalar values of (0, 0, 1)

		5) Begin setting up your Material. Changes should appear as they are made.

			*** If changes don't appear, you may need to hit Play Mode once to get them to Update the first time ***

			I find it's easiest to set up a gradient of Colors, then adjust the Split Distances, then add Textures and make finer changes.			

			For Procedural Meshes, changes made to the Material in Play Mode will stay, so you can adjust values there.

	Unity Terrain

		1) Create a 3D Object > Terrain in your scene.

		2) Add TerrainVectorsToShader.cs to your Terrain Game Object

		3) Go to the Settings Tab in your Terrain Component on your Terrain Game Object,
			and select Custom in the Material field under Base Terrain.

		4) Create a Material to apply to this Object and pick the Shader you want to use. Variants are in DistanceGradient.

		5) Add this Material to both the Mesh Renderer > Material field,
			as well as the Custom Material field under the Material field under Base Terrain.

		6) Set your TerrainVectorsToShader values in the Inspector.
			Distance Scalars determine which axes will be used as a distance evaluation.
			A value of zero means shifts in these axes will not effect the distance output.

			A Value > 0 means there will be a distance evaluation along that axis, based on (0,0,0) or, if selected, an Offset. 

			Unity Terrain is Y-up, so Distance Scalar values of (0, 1, 0) would be used.

			Of course, you can use non-zero/one values to introduce some non-uniformity in terrain/color patterns.
				However, small changes in scalar values can affect a wide area and the default Center Point is not in the center of the Unity Terrain.
				If using an Offset, I believe Unity Terrain's default size is 500x500, so an Offset of (250, 0, 250)
				should put the Offset at the center of the Terrain.
				There is also a Noise Value that can produce smaller scale variations as well.

		7) Begin setting up your Material. Changes should appear as they are made.

				*** If changes don't appear, you may need to hit Play Mode once to get them to Update the first time ***

			I find it's easiest to set up a gradient of Colors, then adjust the Split Distances, then add Textures and make finer changes.

THANK YOU!

	Hope you enjoy this and are able to use it. If you have any questions, feel free to message me and I'll get back to you
	as soon as I can. Thank you!
	
-Dan