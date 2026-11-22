import os,re,sys
HEX=re.compile(r'(?<!url\()(?<![\w&])#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})(?![0-9a-zA-Z_-])')
RGB=re.compile(r'rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)')
def g(r,gg,b):
    y=min(255,round((0.2126*r+0.7152*gg+0.0722*b)*1.05)); return y
def hx(m):
    h=m.group(1)
    if len(h)==3: h=''.join(c*2 for c in h)
    y=g(int(h[0:2],16),int(h[2:4],16),int(h[4:6],16)); return '#%02x%02x%02x'%(y,y,y)
def rg(m):
    y=g(*map(int,m.groups())); return 'rgb(%d,%d,%d)'%(y,y,y)
n=0
for root in sys.argv[1:]:
  for dp,dn,fn in os.walk(root):
    for f in fn:
      p=os.path.join(dp,f)
      if os.path.islink(p) or not f.endswith('.svg'): continue
      s=open(p,encoding='utf-8',errors='surrogateescape').read()
      t=RGB.sub(rg,HEX.sub(hx,s))
      if t!=s: open(p,'w',encoding='utf-8',errors='surrogateescape').write(t); n+=1
print('svgs en gris:',n)
