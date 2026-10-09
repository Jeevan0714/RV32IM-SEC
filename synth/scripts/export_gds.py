import pya
import os

work_dir = os.path.abspath(".")
tech_lef = os.path.join(work_dir, "synth/lib/NangateOpenCellLibrary.tech.lef")
macro_lef = os.path.join(work_dir, "synth/lib/NangateOpenCellLibrary.macro.lef")

def def_to_gds(module_name):
    def_file = os.path.join(work_dir, f"synth/reports/{module_name}_routed.def")
    gds_file = os.path.join(work_dir, f"synth/reports/{module_name}.gds")
    
    if not os.path.exists(def_file):
        return
        
    print(f"Converting {module_name} DEF to standalone GDS-II...")
    opt = pya.LoadLayoutOptions()
    opt.lefdef_config.macro_resolution_mode = 1
    opt.lefdef_config.read_all_def_layers = True
    opt.lefdef_config.lef_files = [tech_lef, macro_lef]
    
    layout = pya.Layout()
    layout.read(def_file, opt)
    
    # Write GDS
    layout.write(gds_file)
    print(f"SUCCESS: Saved standalone GDS-II layout to {gds_file}")

def_to_gds("riscv_core_bus")
def_to_gds("lfsr_nfsr_top")
