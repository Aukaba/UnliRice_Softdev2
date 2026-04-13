import zipfile
import xml.etree.ElementTree as ET

z = zipfile.ZipFile('plan.docx')
content = z.read('word/document.xml').decode('utf-8')
root = ET.fromstring(content)
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
paragraphs = root.findall('.//w:p', ns)
texts = []
for p in paragraphs:
    runs = p.findall('.//w:t', ns)
    line = ''.join(r.text or '' for r in runs)
    texts.append(line)
with open('plan_text.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(texts))
print('Done')
