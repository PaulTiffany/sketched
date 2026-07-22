(()=>{'use strict';
const nativeFetch=window.fetch.bind(window);
function arxiv(raw){
  try{
    const u=new URL(String(raw||''),location.href);
    if(!/(^|\.)arxiv\.org$/i.test(u.hostname))return null;
    const m=u.pathname.match(/^\/(abs|pdf|html)\/(.+)$/i);
    if(!m)return null;
    const id=decodeURIComponent(m[2]).replace(/\.pdf$/i,'').replace(/\/$/,'');
    if(!id)return null;
    return{
      id,
      kind:m[1].toLowerCase(),
      abs:`https://arxiv.org/abs/${id}`,
      pdf:`https://arxiv.org/pdf/${id}`,
      html:`https://arxiv.org/html/${id}`,
      reader:`https://r.jina.ai/https://arxiv.org/pdf/${id}`
    };
  }catch{return null}
}
function jinaTarget(raw){
  const s=String(raw||'');
  const prefix='https://r.jina.ai/';
  if(!s.startsWith(prefix))return null;
  return arxiv(s.slice(prefix.length));
}
window.fetch=async(input,init)=>{
  const raw=typeof input==='string'||input instanceof URL?String(input):input?.url||'';
  const paper=arxiv(raw)||jinaTarget(raw);
  if(!paper)return nativeFetch(input,init);
  const isPaperPage=/^https?:\/\/([^/]+\.)?arxiv\.org\/(abs|html)\//i.test(raw);
  const isJinaArxiv=raw.startsWith('https://r.jina.ai/')&&!!jinaTarget(raw);
  if(!isPaperPage&&!isJinaArxiv)return nativeFetch(input,init);
  try{
    const response=await nativeFetch(paper.reader,{...init,headers:{...(init?.headers||{}),Accept:'text/plain'}});
    if(response.ok)return response;
  }catch{}
  if(isJinaArxiv)return nativeFetch(`https://r.jina.ai/${paper.abs}`,init);
  return nativeFetch(input,init);
};
function syncFrame(){
  const frame=document.getElementById('browserFrame');
  if(!frame)return;
  const paper=arxiv(frame.getAttribute('src')||frame.src);
  if(!paper)return;
  frame.dataset.z0Arxiv=paper.id;
  frame.title=`arXiv ${paper.id} PDF`;
  if(paper.kind!=='pdf'&&frame.getAttribute('src')!==paper.pdf)frame.setAttribute('src',paper.pdf);
  window.dispatchEvent(new CustomEvent('z0:arxiv-paper',{detail:paper}));
}
function install(){
  const frame=document.getElementById('browserFrame');
  if(frame)new MutationObserver(syncFrame).observe(frame,{attributes:true,attributeFilter:['src']});
  syncFrame();
  const form=document.getElementById('urlForm');
  const input=document.getElementById('urlInput');
  form?.addEventListener('submit',()=>{
    const paper=arxiv(input?.value);
    if(!paper)return;
    document.getElementById('stageState')?.setAttribute('data-arxiv',paper.id);
  },true);
}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',install,{once:true});else install();
})();
