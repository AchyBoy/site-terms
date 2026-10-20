#!/bin/bash
# Deploy with cache busting: stamps one BUILD into index.html (BUILD var + every
# img/ and music ?v=) and version.json, then commits and pushes. Pages rebuilds in ~60s.
set -e
cd "$(dirname "$0")"
B=$(date +%Y%m%d-%H%M%S)
python3 - "$B" <<'PY'
import re,sys
b=sys.argv[1]; p='index.html'; s=open(p).read()
s2,n=re.subn(r"var BUILD='[^']*';", "var BUILD='%s';"%b, s)
assert n==1, 'BUILD var missing'
s2=re.sub(r'((?:img/[\w.-]+|music\.m4a))(\?v=[\w-]+)?(?=["\')])', lambda m: m.group(1)+'?v='+b, s2)
open(p,'w').write(s2)
open('version.json','w').write('{"build":"%s"}\n'%b)
PY
git add -A
git commit -qm "${1:-Update} (build $B)"
git push -q
echo "pushed build $B"
