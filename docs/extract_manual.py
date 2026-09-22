import pathlib
from pypdf import PdfReader

f = "C:/Users/hongfu/Desktop/KaihongOS Meta 5.0.1 开鸿行业应用市场操作手册.pdf"
r = PdfReader(f)
txt = "\n".join((p.extract_text() or "") for p in r.pages)
dest = pathlib.Path("D:/uniterm/docs/research_pdf/03-market-manual.txt")
dest.write_text(txt, encoding="utf-8")
print(len(r.pages), "pages ->", dest.name, len(txt), "chars")
