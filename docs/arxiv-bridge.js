(()=>{'use strict';
if(/\/pdf\.html$/i.test(location.pathname))return;
const nativeFetch=window.fetch.bind(window),JINA='https://r.jina.ai/';
function arxiv(raw){
  try{
    let value=String(raw||'').trim();
    if(value.startsWith(JINA))value=value.slice(JINA.length);
    const u=new URL(value,location.href);
    if(!/(^|\.)arxiv\.org$/i.test(u.hostname))return null;
    const m=u.pathname.match(/^\/(abs|pdf|html)\/([^?#]+)$/i);
    if(!m)return null;
    const id=decodeURIComponent(m[2]).replace(/\.pdf$/i,'').replace(/\/$/,'');
    if(!id)return null;
    return{
      id,
      kind:m[1].toLowerCase(),
      abs:`https://arxiv.org/abs/${id}`,
      pdf:`https://arxiv.org/pdf/${id}.pdf`,
      pdfBare:`https://arxiv.org/pdf/${id}`,
      exportPdf:`https://export.arxiv.org/pdf/${id}.pdf`,
      html:`https://arxiv.org/html/${id}`,
      readers:[
        `${JINA}https://arxiv.org/pdf/${id}.pdf`,
        `${JINA}https://arxiv.org/pdf/${id}`,
        `${JINA}https://arxiv.org/html/${id}`,
        `${JINA}https://arxiv.org/abs/${id}`
      ]
    };
  }catch{return null}
}
window.Z0Arxiv={parse:arxiv};
window.fetch=async(input,init)=>{
  const raw=typeof input==='string'||input instanceof URL?String(input):input?.url||'';
  const paper=arxiv(raw);
  if(!paper)return nativeFetch(input,init);
  const direct=/^https?:\/\/([^/]+\.)?arxiv\.org\/(abs|pdf|html)\//i.test(raw);
  const jina=raw.startsWith(JINA);
  if(!direct&&!jina)return nativeFetch(input,init);
  let lastError;
  for(const url of paper.readers){
    try{
      const response=await nativeFetch(url,{...init,headers:{...(init?.headers||{}),Accept:'text/plain'}});
      if(response.ok)return response;
      lastError=new Error(`Reader ${response.status}`);
    }catch(error){lastError=error}
  }
  if(jina&&lastError)throw lastError;
  return nativeFetch(input,init);
};
function install(){
  const form=document.getElementById('urlForm'),input=document.getElementById('urlInput');
  form?.addEventListener('submit',()=>{
    const paper=arxiv(input?.value);
    if(!paper)return;
    document.getElementById('stageState')?.setAttribute('data-arxiv',paper.id);
    window.dispatchEvent(new CustomEvent('z0:arxiv-paper',{detail:paper}));
  },true);
}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',install,{once:true});else install();
})();
