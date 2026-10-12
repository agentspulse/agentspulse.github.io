# coding: utf-8
"""Check the rendered article and public asset allowlist; standard-library only."""
from pathlib import Path
from html.parser import HTMLParser
import json,re,sys,xml.etree.ElementTree as ET
from urllib.parse import urlparse,unquote
class Page(HTMLParser):
    def __init__(self):
        super().__init__();self.tags=[];self.scripts=[];self.text=[];self._script=None;self.title='';self._title=False
    def handle_starttag(self,tag,attrs):
        attrs=dict(attrs);self.tags.append((tag,attrs))
        if tag=='script' and attrs.get('type')=='application/ld+json':self._script=[]
        if tag=='title':self._title=True
    def handle_endtag(self,tag):
        if tag=='script' and self._script is not None:self.scripts.append(json.loads(''.join(self._script)));self._script=None
        if tag=='title':self._title=False
    def handle_data(self,data):
        self.text.append(data)
        if self._script is not None:self._script.append(data)
        if self._title:self.title+=data
site=Path(sys.argv[1]);repo=Path.cwd();folder=Path(__file__).resolve().parent.name
path=site/'tutorials/microsoft-decision-1/index.html';assert path.is_file(),path
p=Page();p.feed(path.read_text());tags=p.tags;text=' '.join(p.text);checks={}
def check(name,condition):
    if not condition:raise AssertionError(name)
    checks[name]=True
url='https://agentspulse.github.io/tutorials/microsoft-decision-1/'
metas=[a for t,a in tags if t=='meta'];m=lambda k:next((a.get('content') for a in metas if a.get('name')==k or a.get('property')==k),None)
check('title_product_and_brand',p.title=='Microsoft-Decision-1: Pricing, API & Limits | AgentsPulse')
check('single_description',len([a for a in metas if a.get('name')=='description'])==1 and bool(m('description')))
check('language',next(a.get('lang') for t,a in tags if t=='html')=='en')
check('single_h1',sum(t=='h1' for t,a in tags)==1)
check('no_heading_skip',not any(t in ['h4','h5','h6'] for t,a in tags))
check('canonical', [a.get('href') for t,a in tags if t=='link' and a.get('rel')=='canonical']==[url])
check('indexable',not any('noindex' in a.get('content','') for a in metas if a.get('name')=='robots'))
check('social_url_and_description',m('og:url')==url and m('og:description')==m('description') and m('twitter:description')==m('description'))
check('social_type',m('og:type')=='article' and m('twitter:card')=='summary_large_image')
for key in ['og:image','twitter:image']:
    value=m(key);check(key+'_absolute',value is not None and value.startswith('https://agentspulse.github.io/'))
    check(key+'_asset',(site/unquote(urlparse(value).path).lstrip('/')).is_file())
images=[a for t,a in tags if t=='img' and (folder in a.get('src','') or 'image-gen_20261012_103040/' in a.get('src',''))]
check('three_article_images',len(images)==3)
for i,a in enumerate(images):
    check(f'image_{i}_alt_size',bool(a.get('alt')) and int(a.get('width','0'))>0 and int(a.get('height','0'))>0)
    check(f'image_{i}_asset',(site/unquote(urlparse(a['src']).path).lstrip('/')).is_file())
    check(f'image_{i}_zoom','data-zoomable' in a)
check('two_lazy_body_images',sum(a.get('loading')=='lazy' for a in images)==2)
check('responsive_picture_sources',sum(t=='source' and a.get('media')=='(max-width: 640px)' for t,a in tags)==2)
anchors=[a.get('href','') for t,a in tags if t=='a'];ids={a['id'] for t,a in tags if a.get('id')}
check('toc_targets',all(x[1:] in ids for x in anchors if x.startswith('#')))
internal=[x for x in anchors if x.startswith('/tutorials/') and x!='/tutorials/microsoft-decision-1/']
check('contextual_and_related_internal_links',len(set(internal))>=3)
check('internal_targets',all((site/x.lstrip('/')/'index.html').is_file() for x in internal))
check('no_private_host_in_body','222.131.67.9' not in text and 'localhost:3001' not in text)
check('teaching_limits','illustrative probabilities' in text and 'hypothetical' in text)
# Visible prose must be English. Ignore JSON-LD data that can contain asset-path characters.
visible=Page();visible.feed(re.sub(r'<script\b[^>]*>.*?</script>', '', path.read_text(), flags=re.S|re.I))
visible_text=' '.join(visible.text)
check('visible_english_only',not re.search(r'[\u4e00-\u9fff]',visible_text))
check('no_production_note_footer',not re.search(r'Eureka|materials read|SEO edits|site version|this session|production note|we did not run',visible_text,re.I))
by_type={s.get('@type'):s for s in p.scripts}
check('article_and_breadcrumb_and_faq',all(t in by_type for t in ['Article','BreadcrumbList','FAQPage']))
article=by_type['Article'];check('article_dates',article['datePublished'].startswith('2026-10-12T00:00:00') and article['dateModified'].startswith('2026-10-12T00:00:00'))
check('article_urls',article['url']==url and article['mainEntityOfPage']['@id']==url)
check('structured_language',article['inLanguage']=='en' and by_type['FAQPage']['inLanguage']=='en')
normalized=re.sub(r'\s+','',text)
faq=by_type['FAQPage']['mainEntity'];check('faq_three',len(faq)==3)
check('faq_matches_visible_copy',all(re.sub(r'\s+','',f['name']) in normalized and re.sub(r'\s+','',f['acceptedAnswer']['text']) in normalized for f in faq))
sm=ET.parse(site/'sitemap.xml').getroot();ns={'s':'http://www.sitemaps.org/schemas/sitemap/0.9'};entries=[node for node in sm.findall('s:url',ns) if node.findtext('s:loc',namespaces=ns)==url]
check('sitemap_article_once',len(entries)==1)
check('sitemap_modified_date',entries[0].findtext('s:lastmod',namespaces=ns).startswith('2026-10-12'))
home=Page();home.feed((site/'index.html').read_text());check('homepage_discovery',any(t=='a' and a.get('href')=='/tutorials/microsoft-decision-1/' for t,a in home.tags))
for a in [a for t,a in home.tags if t=='a' and a.get('href')=='/tutorials/microsoft-decision-1/']:
    check('homepage_recency',int(a.get('data-latest','0'))>0)
# Only exactly whitelisted image assets can exist in the artifact folder in public output.
expected={Path('资源')/p.name for p in (repo/folder/'资源').glob('封面-*.webp')}
public=site/folder;actual={f.relative_to(public) for f in public.rglob('*') if f.is_file()}
check('public_asset_allowlist',actual==expected)
new_folder='image-gen_20261012_103040'
expected_new={Path(name)/'article.webp' for name in ['decision-types','decision-types-mobile','calibration','calibration-mobile']}
actual_new={f.relative_to(site/new_folder) for f in (site/new_folder).rglob('*') if f.is_file()}
check('english_asset_allowlist',actual_new==expected_new)
check('no_scratch_urls',all(folder not in loc.text for loc in sm.findall('s:url/s:loc',ns)))
print(json.dumps({'checks':checks,'description_length':len(m('description')),'title_length':len(p.title),'canonical':url,'whitelisted_public_images':len(expected)+len(expected_new)},ensure_ascii=False,indent=2))
