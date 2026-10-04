import os
from PySide6.QtCore import QTimer
try:
    from binaryninjaui import UIContext
except Exception:
    UIContext = None

def target():
    try:
        return int(open("/tmp/bn_nav_addr").read().strip(), 16)
    except Exception:
        return 0x477c20

done = {"v": False}
def tick():
    if done["v"] or UIContext is None:
        return
    try:
        ctx = UIContext.activeContext()
        if not ctx: return
        vf = ctx.getCurrentViewFrame()
        if not vf: return
        bv = vf.getCurrentBinaryView()
        if not bv: return
        t = target()
        f = bv.get_function_at(t)
        if f:
            vf.navigate(bv, t)
            done["v"] = True
            open("/tmp/bn_nav_done","w").write(hex(t))
    except Exception as e:
        open("/tmp/bn_nav_err","w").write(str(e))

_t = QTimer(); _t.timeout.connect(tick); _t.start(4000)
