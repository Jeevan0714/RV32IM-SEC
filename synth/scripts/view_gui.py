import pya
import os

work_dir = os.path.abspath(".")
tech_lef = os.path.join(work_dir, "synth/lib/NangateOpenCellLibrary.tech.lef")
macro_lef = os.path.join(work_dir, "synth/lib/NangateOpenCellLibrary.macro.lef")
def_file = os.path.join(work_dir, "synth/reports/riscv_core_bus_routed.def")

print("Opening Placed & Routed DEF layout in KLayout GUI...")

opt = pya.LoadLayoutOptions()
opt.lefdef_config.macro_resolution_mode = 1
opt.lefdef_config.read_all_def_layers = True
opt.lefdef_config.lef_files = [tech_lef, macro_lef]

mw = pya.MainWindow.instance()
if mw is not None:
    mw.load_layout(def_file, opt, 1)
    view = mw.current_view()
    if view is not None:
        view.max_hier()
        view.zoom_fit()
    print("SUCCESS: Layout loaded into KLayout GUI!")
