import pya
import os

work_dir = os.path.abspath(".")
tech_lef = os.path.join(work_dir, "synth/lib/NangateOpenCellLibrary.tech.lef")
macro_lef = os.path.join(work_dir, "synth/lib/NangateOpenCellLibrary.macro.lef")

def render_def(module_name):
    def_file = os.path.join(work_dir, f"synth/reports/{module_name}_routed.def")
    output_png = os.path.join(work_dir, f"synth/reports/{module_name}_layout.png")
    
    if not os.path.exists(def_file):
        print(f"Skipping {module_name}: {def_file} not found")
        return
        
    print(f"Reading {module_name} DEF into KLayout...")
    opt = pya.LoadLayoutOptions()
    opt.lefdef_config.macro_resolution_mode = 1
    opt.lefdef_config.lef_files = [tech_lef, macro_lef]
    
    layout = pya.Layout()
    layout.read(def_file, opt)
    
    view = pya.LayoutView()
    view.show_layout(layout, True)
    view.max_hier()
    view.zoom_fit()
    view.save_image(output_png, 1200, 1200)
    print(f"Saved: {output_png}")

render_def("riscv_core_bus")
render_def("lfsr_nfsr_top")
