# scad-parametric-timing-belt-generator
Generates STL or DWF files for a wide variety of timing belts

This is primarily based on https://www.youmagine.com/designs/parametric-timing-belt-generator but adds support for generating a 2d profile you export as a DXF or a 3d STL for directy printing or using in your model.


## Belt Profiles Supported:
- MXL
- T2.5
- T5 
- T10 
- GT2_2mm 
- GT2_3mm 
- GT2_5mm 
- AT5 
- HTD_3mm 
- HTD_5mm 
- HTD_8mm 
- 40DP 
- XL 

## Printing Styles Supported:
- straight (straight belt segment)
- loop (closed loop with teeth on inner side of loop)
- loop_inner (same as loop)
- loop_outer (closed loop with teeth on outer side of loop)
- loop_match (closed loop with teeth mirrored on both sides of loop)
- loop_offset (closed loop with teeth on both sides of loop, offset by half a tooth)
- spiral. (belt spiraling inward from maximum_diameter with teeth on the inner side)

## Other options:
- tooth count OR belth length
- belt width
- belt backing thickness


Examples for how to use it are in the source code. It is pretty simple and just requires changing a few values to meet your needs.

### As a 3d model:

<img width="499" alt="image" src="https://user-images.githubusercontent.com/4974259/136828593-0bdf20eb-5783-4f7e-a4be-2116e0565a7f.png">

### As a 2d profile: 

<img width="603" alt="image" src="https://user-images.githubusercontent.com/4974259/136828678-f2bfbe27-9e86-4e51-8c37-c2dd144be828.png">


## What is SCAD?

It' basically a little CAD app that runs scripts to generate files. It is useful for creating universal parametric designs to that can be easily imported into your primary CAD software.

You can download SCAD here (supports Mac and PC): https://openscad.org
