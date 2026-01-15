# Libraries

Shared, reusable OpenSCAD modules used across QuackWorks projects.

## Contents

### connectors
- `snap-connector.scad` - Snap connector module
- `pushfit-connector.scad` - Push-fit connector (MultiBoard compatible)
- `lego-compatible-base.scad` - LEGO compatible base plate

### multiconnect
- `multiconnect-generator.scad` - Multiconnect slot generator
- `multiconnect-slot-design.scad` - Slot design module
- `multiconnect-slot-design-bosl.scad` - BOSL2 version of slot design
- `multiconnect-generator.json` - Generator configuration

## Usage

Include these libraries in your OpenSCAD files:
```openscad
include <libraries/connectors/snap-connector.scad>
include <libraries/multiconnect/multiconnect-generator.scad>
```
