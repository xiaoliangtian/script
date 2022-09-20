#!/usr/bin/env python
__author__ = 'Nieh Hsiaoting'
__version__ = '1.0.1'
__date__='2016/11/19'
__doc__="""The program used for creat color pathway html"""

import sys, urllib, time, os, re
from HTMLParser import HTMLParser
from collections import defaultdict
# http://www.kegg.jp/kegg-bin/show_pathway?<mapid>/default%3d<dcolor>/<keggid.n>%09<bgcolor>,<fgcolor>/

class parselinks(HTMLParser):
    def __init__(self):
        self.coords = {}
        self.img = ''
        HTMLParser.__init__(self)
    def handle_starttag(self,tag,attrs):
        if tag == 'area':
            areadict = {}
            if len(attrs) == 0:
                pass
            else:
                for name, value in attrs:
                    areadict[name] = value
                values = [areadict[name] for name in ('coords','shape','href','title')]
                self.coords[values[0]] = values[1:]
        if tag == 'img':
            if len(attrs) == 0:
                pass
            else:
                for name,value in attrs:
                    if name == 'src' and value.startswith('/tmp/'):
                        self.img = value

def DownloadImg(url):
    try:
        socket = urllib.urlopen(url)
    except:
        print 'can not open the url %s' %url
    filename = url.split('/')[-1]
    fimg = open(filename, 'wb')
    fimg.write(socket.read())
    fimg.close()

if len(sys.argv) != 3:
    print '%s: DEG_KEGGEnrich.gene sta.html' % sys.argv[0]
    sys.exit(2)

paths = os.path.dirname(os.path.abspath(__file__))

des = {}
homo = {}
for line in open('%s/pathway-coords' %paths, 'rU') :
    lineSplit = line.rstrip().split('\t')
    mapid = lineSplit[0]
    des[mapid] = lineSplit[1]
    if lineSplit[-1][0] == 'K':
        kohomo = re.findall('(K\d{5})', lineSplit[-1])
        for koid in kohomo:
            if koid not in homo:
                homo[koid] = {}
            if mapid not in homo[koid] :
                homo[koid][mapid] = {}
            homo[koid][mapid][kohomo[0]] = 1

# ko = defaultdict(list)
pathway = defaultdict(list)
kocolor = defaultdict(dict)
bgcolor = defaultdict(dict)
genecolor = defaultdict(dict)
# AT4G19810.1     K01183  E3.2.1.14; chitinase [EC:3.2.1.14]      Metabolism      Carbohydrate metabolism 00520 Amino sugar and nucleotide sugar metabolism       down
fin = open(sys.argv[1],'rU')
for line in fin.readlines()[1:]:
    lineSplit = line.rstrip().split('\t')
    if lineSplit[1] not in homo : continue
    fgcolor = 'red' if lineSplit[6] == 'up' else 'blue'
    # ko[lineSplit[1]].append('%s(%s)' %(lineSplit[0], lineSplit[6]))
    genecolor[lineSplit[1]][lineSplit[0]]=fgcolor

    for mapid in homo[lineSplit[1]] :
        pathway[mapid].append('%s(%s)' %(lineSplit[0], lineSplit[6]))

        if lineSplit[1] not in kocolor[mapid]:
            kocolor[mapid][lineSplit[1]] = fgcolor
        else:
            if kocolor[mapid][lineSplit[1]] != 'magenta' and kocolor[mapid][lineSplit[1]] != fgcolor:
                kocolor[mapid][lineSplit[1]] = 'magenta'

        for ecid in homo[lineSplit[1]][mapid]:
            if ecid not in bgcolor[mapid] :
                bgcolor[mapid][ecid] = fgcolor
            else:
                if bgcolor[mapid][ecid] != 'magenta' and bgcolor[mapid][ecid] != fgcolor:
                    bgcolor[mapid][ecid] = 'magenta'
fin.close()

DG = sys.argv[1].split('.DEG')[0]
dirs = DG + '_map'
header = '''<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <meta name="author" content="Nieh Hsiaoting" />
  <style type="text/css">
    * {
        font-family: "Calibri",Helvetica;
    }
    caption{
        font-weight:700;
    }
    .xls {
        table-layout: fixed;
        border-collapse:collapse;
        margin: 0 50px 50px 50px;
    }
    .xls td, th {
    /*    text-overflow: ellipsis;
        white-space: nowrap;
        overflow: hidden;*/
        word-break: break-all;
        word-wrap: break-word;
        border: 1px solid #98bf21;
        padding: 3px 7px 2px 7px;
    }
    .xls th {
        padding-top: 5px;
        padding-bottom: 4px;
        background-color: #A7C942;
        color: #ffffff;
    }
  </style>
  <title>KEGG pathway statistic</title>
</head>

<body>
  <table class="xls" align="center">
    <caption>Pathway annotation of %s</caption>
    <tr><th>#Pathway</th><th>Genes involved in the pathway</th></tr>
''' % DG

fout = open(sys.argv[2], 'w')
fout.write(header)
for mapid in pathway :
    fout.write('    <tr><td><a href="%s/%s.html">%s</td><td>%s</td></tr>\n' %(dirs, mapid, des[mapid], ';'.join(pathway[mapid])))
fout.write('  </table>\n</body>\n</html>\n')
fout.close()

htmlheader = '''<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <style type="text/css">
    area {cursor: pointer;}
  </style>
  <script type="text/javascript">
    function showInfo(info) {
      obj = document.getElementById("popup");
      obj.innerHTML = "<div style='cursor: pointer;position: absolute; right: 5px; color: black;' onclick='javascript: document.getElementById(\\"popup\\").style.display = \\"none\\";' title='close'>x</div>" + info;
      obj.style.top = document.body.scrollTop;
      // obj.style.left = document.body.scrollLeft;
      obj.style.display = "";
    }
  </script>
'''

if not os.path.isdir(dirs) :
    os.makedirs(dirs)
os.chdir(dirs)

keggurl = 'http://www.kegg.jp'
for mapid in bgcolor :
    mapurl = '%s/kegg-bin/show_pathway?%s' %(keggurl, mapid)
    for ecid in bgcolor[mapid] :
        mapurl += '/%s%%09%s,' %(ecid, bgcolor[mapid][ecid])
    html = parselinks()
    html.feed(urllib.urlopen(mapurl).read())
    DownloadImg(keggurl + html.img)
    time.sleep(3)

    fmap = open(mapid + '.html','w')
    fmap.write(htmlheader)
    fmap.write('  <title>%s</title>\n</head>\n<body>\n' %mapid)
    fmap.write('  <div id="popup" style="position: absolute; border: 1px solid black; opacity: 0.95; font-size: 12px; padding-right: 10px; background-color: white;"></div>\n')
    fmap.write('  <img src="%s.png" name="pathwayimage" usemap="#mapdata" border="0">\n\n  <map name="mapdata">\n' %mapid)
    for coords in html.coords:
        shape, href, title = html.coords[coords]
        area = 'shape="%s" coords="%s" href="%s%s" title="%s"' % (shape, coords, keggurl, href, title)
        onmouseover = ''
        if title[0]=='K':
            kohomo = re.findall('(K\d{5})',title)
            for koid in kohomo :
                # if koid in ko :
                #     onmouseover += '<li>%s: %s</li>' %(koid, '; '.join(ko[koid]))
                if koid in kocolor[mapid]:
                    if kocolor[mapid][koid]=='magenta':
                        a=';'.join(['<span style=\\"color: %s\\">%s</span>' %(genecolor[koid][gene], gene) for gene in genecolor[koid]])
                    else:
                        a=';'.join(genecolor[koid].keys())
                    onmouseover+='<li style=\\"color: %s\\">%s: %s</li>' %(kocolor[mapid][koid], koid, a)

        if onmouseover :
            area += ' onmouseover=\'javascript: showInfo("<ul><li>Gene<ul>%s</ul></li></ul>");\'' %onmouseover
        fmap.write('    <area %s>\n' %area)
    fmap.write('  </map>\n</body>\n</html>\n')
    fmap.close()
