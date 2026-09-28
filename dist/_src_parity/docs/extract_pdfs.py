import pathlib
from pypdf import PdfReader

files = [
    "C:/Users/hongfu/Desktop/KaihongOS Meta 5.0.1 开鸿行业应用市场白皮书.pdf",
    "C:/Users/hongfu/Desktop/KaihongOS桌面版 北向应用开发指导书.pdf",
    "C:/Users/hongfu/Desktop/VSCode插件使用指南（ArkTS Project Manager）.pdf",
    "C:/Users/hongfu/Desktop/KaihongOS 5.0.1 Stan. 北向应用开发指导书.pdf",
]
out = pathlib.Path("D:/uniterm/docs/research_pdf")
out.mkdir(exist_ok=True)

for f in files:
    r = PdfReader(f)
    name = f.split("/")[-1].replace(".pdf", "").replace(" ", "_").replace("（", "(").replace("）", ")")
    txt = "\n".join((p.extract_text() or "") for p in r.pages)
    dest = out / (name + ".txt")
    dest.write_text(txt, encoding="utf-8")
    print(len(r.pages), "pages ->", dest.name, len(txt), "chars")
