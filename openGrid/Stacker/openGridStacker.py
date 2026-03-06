# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "rich-click",
#     "rich",
# ]
# ///

import os
import sys
import subprocess
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
import rich_click as click
from rich.console import Console
from rich.panel import Panel

console = Console()

TEMPLATE_PATH = Path(__file__).parent / "TEMPLATE.md"

MATERIAL_INSTRUCTIONS = {
    "pctg": """* **Interface Shells (CRITICAL):** Under the **'Multimaterial'** tab, you MUST enable **'Interface shells'**. This forces OrcaSlicer to generate solid top and bottom layers at the zero-gap boundary.
* **High Purge Volumes:** Click the 'Flushing volumes' button above the filament list. Set the transition from PLA to PCTG to **800**, and PCTG to PLA to **800** to guarantee no cross-contamination.
* **No Flush into Infill:** Disable 'Flush into object's infill' and 'Flush into support' (under 'Multimaterial' -> 'Flush options').
* **Dry your Filament:** Ensure PCTG is dried at 65°C for 6 hours.""",
    "pla_support": """* **Interface Shells (CRITICAL):** Under the **'Multimaterial'** tab, you MUST enable **'Interface shells'**. This forces OrcaSlicer to generate solid top and bottom layers at the zero-gap boundary.
* **High Purge Volumes:** Click the 'Flushing volumes' button above the filament list. Set the transition from PLA to PLA Support to **800**, and PLA Support to PLA to **800** to guarantee no cross-contamination.
* **No Flush into Infill:** Disable 'Flush into object's infill' and 'Flush into support' (under 'Multimaterial' -> 'Flush options').""",
    "pla": """* **Interface Shells (CRITICAL):** Under the **'Multimaterial'** tab, you MUST enable **'Interface shells'**. This forces OrcaSlicer to generate solid top and bottom layers.
* **Standard Purge:** Standard flushing volumes are usually fine.
* **Separation:** Be careful when removing; a putty knife may be required.""",
    "nothing": """* **Standard Supports:** You must enable standard supports in the slicer to bridge the gaps between layers."""
}

def export_3mf(scad_file: Path, mf_file: Path):
    """Run OpenSCAD CLI to export a 3MF."""
    console.print(f"[yellow]Generating {mf_file.name} via OpenSCAD...[/yellow]")
    try:
        subprocess.run(
            ["openscad", "-o", str(mf_file), str(scad_file)],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        return True
    except FileNotFoundError:
        console.print("[red]Error: OpenSCAD CLI not found. Skipping 3MF export.[/red]")
        return False
    except subprocess.CalledProcessError as e:
        console.print(f"[red]Error during OpenSCAD export for {mf_file.name}:[/red]")
        if e.stderr: console.print(e.stderr.decode())
        return False

def merge_3mfs(grid_3mf: Path, interface_3mf: Path, output_3mf: Path):
    """Merge two 3MF files into a single, multi-part 3MF for OrcaSlicer."""
    console.print("[yellow]Merging into single multi-part 3MF assembly...[/yellow]")
    
    try:
        NS = {'': 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02'}
        ET.register_namespace('', NS[''])
        
        with zipfile.ZipFile(grid_3mf, 'r') as zg:
            grid_model_str = zg.read('3D/3dmodel.model')
            
        with zipfile.ZipFile(interface_3mf, 'r') as zi:
            if_model_str = zi.read('3D/3dmodel.model')

        root_g = ET.fromstring(grid_model_str)
        root_i = ET.fromstring(if_model_str)
        
        resources_g = root_g.find('{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}resources')
        obj_g = resources_g.find('{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}object')
        obj_g.set('id', '1')
        obj_g.set('name', 'Grids')

        resources_i = root_i.find('{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}resources')
        obj_i = resources_i.find('{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}object')
        obj_i.set('id', '2')
        obj_i.set('name', 'Interfaces')
        
        # We construct a new root
        new_root = ET.Element('model', unit="millimeter", **{'{http://www.w3.org/XML/1998/namespace}lang': 'en-US'})
        new_res = ET.SubElement(new_root, 'resources')
        new_res.append(obj_g)
        new_res.append(obj_i)
        
        # Create assembly object
        assembly = ET.SubElement(new_res, 'object', id='3', type='model', name='OpenGrid Stack Assembly')
        components = ET.SubElement(assembly, 'components')
        # Add standard 3mf component
        ET.SubElement(components, 'component', objectid='1')
        ET.SubElement(components, 'component', objectid='2')
        
        build = ET.SubElement(new_root, 'build')
        ET.SubElement(build, 'item', objectid='3')
        
        # OrcaSlicer/BambuStudio specific metadata to force part names
        config_xml = """<?xml version="1.0" encoding="UTF-8"?>
<config>
  <object id="3">
    <metadata key="name" value="OpenGrid Stack Assembly"/>
    <part id="1" subtype="normal_part">
      <metadata key="name" value="Grids"/>
    </part>
    <part id="2" subtype="normal_part">
      <metadata key="name" value="Interfaces"/>
    </part>
  </object>
</config>
"""
        
        with zipfile.ZipFile(output_3mf, 'w', zipfile.ZIP_DEFLATED) as zout:
            with zipfile.ZipFile(grid_3mf, 'r') as zg:
                for item in zg.infolist():
                    if item.filename != '3D/3dmodel.model':
                        zout.writestr(item, zg.read(item.filename))
            
            xml_str = ET.tostring(new_root, encoding='utf-8', xml_declaration=True)
            zout.writestr('3D/3dmodel.model', xml_str)
            zout.writestr('Metadata/model_settings.config', config_xml)
            
        return True
    except Exception as e:
        console.print(f"[red]Error merging 3MF files: {e}[/red]")
        return False

@click.command()
@click.option("--width", default=8, help="Grid width (number of tiles).", show_default=True)
@click.option("--height", default=7, help="Grid height (number of tiles).", show_default=True)
@click.option("--stack-count", default=7, help="Number of grids in the stack.", show_default=True)
@click.option(
    "--interface-material", 
    type=click.Choice(["nothing", "pla", "pla_support", "pctg"], case_sensitive=False),
    default="pctg",
    help="Material used for the interface layer between stacked grids.",
    show_default=True
)
@click.option("--output", help="Output filename base (without extension). If not provided, it's auto-generated.")
@click.option("--no-3mf", is_flag=True, help="Disable automatic export to 3MF.")
@click.option("--no-instructions", is_flag=True, help="Disable generation of print instructions markdown.")
@click.option("--type", "grid_type", type=click.Choice(["Full", "Lite", "Heavy"], case_sensitive=False), default="Lite", help="Grid version.", show_default=True)
@click.option("--no-screws", is_flag=True, help="Disable screw holes. By default, screw holes are generated in the corners.")
def generate(width, height, stack_count, interface_material, output, no_3mf, no_instructions, grid_type, no_screws):
    """
    Generate stacked versions of the OpenGrid using an OpenSCAD script.
    
    Files are saved in the 'output/' directory.
    When a multimaterial interface is used, this script will automatically merge 
    the grids and interface layers into a single multi-part 3MF for OrcaSlicer.
    """
    
    output_dir = Path("output")
    output_dir.mkdir(exist_ok=True)
    
    if not output:
        screws_suffix = "_noscrews" if no_screws else ""
        output = f"opengrid_{grid_type.lower()}_{width}x{height}_s{stack_count}_{interface_material.lower()}{screws_suffix}"
    
    z_gap = "0"
    strategy = "Zero-gap multi-material interface"
    has_interfaces = True
    
    if interface_material == "nothing":
        has_interfaces = False
        interface_thickness = 0
        interface_separation = 0.1
        z_gap = "0.2"
        strategy = "Air gap (requires slicer supports)"
    elif interface_material == "pla":
        interface_thickness = 0.4
        interface_separation = 0.15
        z_gap = "0.15"
        strategy = "PLA on PLA with separation gap"
    elif interface_material in ["pla_support", "pctg"]:
        interface_thickness = 0.4
        interface_separation = 0.0
        z_gap = "0"
        strategy = "Zero-gap chemically incompatible interface"
        
    results = []
    
    screw_mounting = "None" if no_screws else "Corners"
    
    common_scad_params = f"""
Full_or_Lite = "{grid_type.capitalize()}";
Board_Width = {width};
Board_Height = {height};
Stack_Count = {stack_count};

Tile_Size = 28;
Tile_Thickness = 6.8;
Lite_Tile_Thickness = 4;
Heavy_Tile_Thickness = 13.8;
Screw_Mounting = "{screw_mounting}";
Chamfers = "Corners";
Connector_Holes = true;
"""

    grid_scad_file = output_dir / f"{output}_grids.scad"
    grid_mf_file = output_dir / f"{output}_grids.3mf"
    
    grid_scad_content = f"""// Generated by OpenGrid Stacker
include <../../openGrid.scad>
{common_scad_params}

// Render the grids explicitly
if (Full_or_Lite == "Lite") {{
    zcopies(spacing=Lite_Tile_Thickness + {interface_thickness} + 2 * {interface_separation}, n=Stack_Count, sp=[0, 0, Lite_Tile_Thickness])
        openGridLite(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, Connector_Holes=Connector_Holes, anchor=$idx % 2 == 0 ? TOP : BOT, orient=$idx % 2 == 0 ? UP : DOWN);
}} else if (Full_or_Lite == "Full") {{
    zcopies(spacing=Tile_Thickness + {interface_thickness} + 2 * {interface_separation}, n=Stack_Count, sp=[0, 0, Tile_Thickness])
        zflip()
            openGrid(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Tile_Thickness=Tile_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, anchor=BOT, Connector_Holes=Connector_Holes);
}} else if (Full_or_Lite == "Heavy") {{
    zcopies(spacing=Heavy_Tile_Thickness + {interface_thickness} + 2 * {interface_separation}, n=Stack_Count, sp=[0, 0, Heavy_Tile_Thickness])
        openGridHeavy(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, Connector_Holes=Connector_Holes, anchor=$idx % 2 == 0 ? TOP : BOT, orient=$idx % 2 == 0 ? UP : DOWN);
}}

// Prevent openGrid from auto-generating its default view
Fill_Space_Mode = "Library";
"""
    grid_scad_file.write_text(grid_scad_content)
    
    # In 'nothing' mode, this is the final file. In others, it's a temporary building block.
    final_3mf_file = output_dir / f"{output}.3mf"
    
    if not has_interfaces:
        results.append(f"- SCAD: {grid_scad_file}")
        if not no_3mf:
            if export_3mf(grid_scad_file, final_3mf_file):
                results.append(f"- Final 3MF: {final_3mf_file}")
    else:
        if not no_3mf:
            export_3mf(grid_scad_file, grid_mf_file)

    # Interface generation
    if has_interfaces and stack_count > 1:
        interface_scad_file = output_dir / f"{output}_interfaces.scad"
        interface_mf_file = output_dir / f"{output}_interfaces.3mf"
        
        interface_scad_content = f"""// Generated by OpenGrid Stacker
include <../../openGrid.scad>
{common_scad_params}
Interface_Thickness = {interface_thickness};

// Render the interfaces explicitly
if (Full_or_Lite == "Lite") {{
    zcopies(spacing=Lite_Tile_Thickness + {interface_thickness} + 2 * {interface_separation}, n=Stack_Count - 1, sp=[0, 0, Lite_Tile_Thickness + {interface_separation}])
        color("red") interfaceLayer2D(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType="Lite", topSide=$idx % 2 == 0 ? false : true);
}} else if (Full_or_Lite == "Full") {{
    zcopies(spacing=Tile_Thickness + {interface_thickness} + 2 * {interface_separation}, n=Stack_Count - 1, sp=[0, 0, Tile_Thickness + {interface_separation}])
        color("red") interfaceLayer(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Tile_Thickness=Tile_Thickness, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType="Full", anchor=BOT);
}} else if (Full_or_Lite == "Heavy") {{
    zcopies(spacing=Heavy_Tile_Thickness + {interface_thickness} + 2 * {interface_separation}, n=Stack_Count - 1, sp=[0, 0, Heavy_Tile_Thickness + {interface_separation}])
        color("red") interfaceLayer2D(Board_Width=Board_Width, Board_Height=Board_Height, tileSize=Tile_Size, Screw_Mounting=Screw_Mounting, Chamfers=Chamfers, boardType="Lite", topSide=$idx % 2 == 0 ? false : true);
}}

// Prevent openGrid from auto-generating its default view
Fill_Space_Mode = "Library";
"""
        interface_scad_file.write_text(interface_scad_content)
        
        if not no_3mf:
            export_3mf(interface_scad_file, interface_mf_file)
            
            # Merge the two 3MFs into a final 3MF assembly
            if grid_mf_file.exists() and interface_mf_file.exists():
                if merge_3mfs(grid_mf_file, interface_mf_file, final_3mf_file):
                    results.append(f"- Final 3MF Assembly: {final_3mf_file}")
                    
                    # Cleanup temporary files
                    grid_mf_file.unlink(missing_ok=True)
                    interface_mf_file.unlink(missing_ok=True)
                    grid_scad_file.unlink(missing_ok=True)
                    interface_scad_file.unlink(missing_ok=True)

    # Instruction Generation
    if not no_instructions and TEMPLATE_PATH.exists():
        md_file = output_dir / f"{output}.md"
        template = TEMPLATE_PATH.read_text()
        
        instructions = template.replace("{{TYPE}}", grid_type.capitalize()) \
                               .replace("{{WIDTH}}", str(width)) \
                               .replace("{{HEIGHT}}", str(height)) \
                               .replace("{{STACK_COUNT}}", str(stack_count)) \
                               .replace("{{SCREWS}}", "No" if no_screws else "Yes (Corners)") \
                               .replace("{{MATERIAL}}", interface_material.upper()) \
                               .replace("{{STRATEGY}}", strategy) \
                               .replace("{{FILENAME_3MF}}", f"`{final_3mf_file.name}`") \
                               .replace("{{Z_GAP}}", z_gap) \
                               .replace("{{MATERIAL_SPECIFIC_INSTRUCTIONS}}", MATERIAL_INSTRUCTIONS.get(interface_material.lower(), ""))
        md_file.write_text(instructions)
        results.append(f"- Instructions: {md_file}")

    message = (
        f"[green]Stack Generation Complete![/green]\n\n"
        f"[bold]Files created in {output_dir.absolute()}:[/bold]\n" + "\n".join(results)
    )
    console.print(Panel.fit(message, title="OpenGrid Stacker"))

if __name__ == "__main__":
    generate()