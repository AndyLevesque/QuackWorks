# OpenGrid Stacking Tutorial (OrcaSlicer)

This guide explains how to use the provided Python CLI tool to generate and print stacked OpenGrids efficiently. Printing stacks allows you to produce many grids in a single print session without manually removing parts from the build plate. Using a chemically incompatible material (like PCTG or PLA Support) for the interface layer yields perfectly smooth undersides.

## Generating the Stack

We have provided a convenient Python CLI tool using `uv` and `rich-click`.

### Prerequisites
- Install [uv](https://github.com/astral-sh/uv) (e.g., `curl -LsSf https://astral.sh/uv/install.sh | sh`).
- *(Optional)* Install OpenSCAD and ensure it is in your system `PATH` to enable direct `.3mf` export.

### Usage
Navigate to the `openGrid/Stacker` directory and run the script with `uv run`:

```bash
cd openGrid/Stacker
uv run openGridStacker.py --width 8 --height 7 --stack-count 7 --interface-material pctg --type Lite
```

#### Command Line Options
- `--width`: The width of the grid in tiles (default: 8).
- `--height`: The height of the grid in tiles (default: 7).
- `--stack-count`: The number of grids to stack (default: 7).
- `--type`: Grid version to generate: Full, Lite, or Heavy (default: Lite).
- `--interface-material`: The material strategy to use for the interface layers between grids.
- `--no-screws`: Disable screw holes. By default, M4 screw holes are generated in the corners.
- `--output`: Output filename base (without extension). If not provided, it's auto-generated.
- `--no-3mf`: Disable automatic export to 3MF.
- `--no-instructions`: Disable generation of print instructions markdown.

### Interface Material Options
1. **`pctg` or `pla_support`**: Generates a solid 0.4mm interface layer with **0.0mm gap**. Since PLA and PCTG (or PLA Support) do not bond, they peel apart perfectly, leaving flawless surfaces.
2. **`pla`**: Generates an interface layer with a **0.15mm gap** (0.3mm total gap per layer). Use this if you only have one material. It breaks away but the surface will be slightly rougher.
3. **`nothing`**: Omits the interface layer entirely and leaves a **0.2mm gap** between stacked models. You must configure your slicer's standard supports between layers.

---

## Slicing in OrcaSlicer (Multi-Material: PLA + PCTG)

If you chose `pctg` or `pla_support` as your interface material, follow these best practices for optimal strength and clean separation.

### 1. Import the Model as a Multi-Part Object
- The script automatically merges the grids and interfaces into a single `.3mf` file (e.g., `opengrid_lite_8x7_s7_pctg.3mf`).
- Drag and drop this `.3mf` file into your OrcaSlicer window. It will automatically import as a single object containing multiple parts.
- In the "Process" tab (Object view), assign your PLA filament to the main grid parts (usually named `Grids`) and your PCTG / PLA Support filament to the interface layer parts (usually named `Interfaces`).

### 2. Multi-Material Best Practices (Crucial for PCTG/PLA)
Because PLA and PCTG are chemically incompatible, any cross-contamination will cause severe layer adhesion failure in your main prints.

*   **Interface Shells (CRITICAL):** Under the **Multimaterial** tab, you MUST check **"Interface shells"**. Without this, OrcaSlicer will see the 0.0mm gap and treat the parts as one block, skipping the essential solid Top/Bottom layers between the PLA and PCTG.
*   **High Purge Volumes:** Click the "Flushing volumes" button located right above your filament list. Set the transition from PLA to PCTG to **800**, and from PCTG back to PLA to **800**. This higher value (rather than 600) is the safest way to guarantee absolutely zero brittle cross-contamination.
*   **Disable Flush into Infill / Support:** Under the **Multimaterial** tab -> **Flush options**, ensure **"Flush into object's infill"** and **"Flush into support"** are **DISABLED**. You do not want incompatible materials mixed inside your print, as it will cause it to snap under minimal stress.
*   **Temperature Management:** Ensure the slicer purges at the **higher** of the two temperatures (the PCTG temp) to melt out all the PLA completely before printing the PCTG layer.

### 3. Official openGrid Print Settings
For the best strength and dimensional accuracy, openGrid models should be printed with the following general settings:

*   **Wall Loops (Perimeters):** 3
*   **Infill:** 15% (Grid or Gyroid)
*   **Layer Height:** 0.2mm
*   **Bottom Shell Layers:** 3
*   **Top Shell Layers:** 4

### 4. PCTG Specific Warnings
*   **Dry the PCTG:** PCTG is highly hygroscopic. Dry it at 65°C for 6 hours before printing. Wet PCTG will pop during printing, which ruins the smooth interface surface and causes pockmarks on your PLA.
*   **Bed Adhesion:** If your first layer happens to be PCTG, use a glue stick. PCTG bonds incredibly well to PEI plates and can damage them if removed while hot.
*   **Cooling:** While PCTG usually needs less cooling than PLA, you can crank the fan to 100% for the **interface layers** to ensure the material solidifies instantly and doesn't "bleed" into the PLA model below it.

Happy printing!