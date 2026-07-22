(()=>{'use strict';
const PDF_RE=/\.pdf(?:$|[?#])/i,form=document.querySelector('#urlForm'),input=document.querySelector('#urlInput'),frame=document.querySelector('#browserFrame'),reader=document.querySelector('#reader'),readerToggle=document.querySelector('#readerToggle'),stageState=document.querySelector('#stageState'),modelMeta=document.querySelector('#modelMeta');
if(!form||!input||!frame)return;
let activePdf='',pageContext=null;
const normalize=raw=>{raw=String(raw||'').trim();if(!raw)return'';if(!/^https?:\/\//i.test(raw))raw='https://'+raw;try{return new URL(raw).href}catch{return''}};
const isPdf=url=>PDF_RE.test(url||'');
function viewerUrl(url){return `pdf.html?src=${encodeURIComponent(url)}`}
function setLive(){reader.classList.add('hidden');frame.classList.remove('hidden');readerToggle.classList.remove('active');readerToggle.setAttribute('aria-pressed','false');readerToggle.textContent='READ'}
function openPdf(url){activePdf=url;pageContext=null;setLive();frame.src=viewerUrl(url);stageState.textContent='loading PDF…'}
const originalSubmit=form.onsubmit;
form.onsubmit=e=>{const url=normalize(input.value);if(!isPdf(url)){activePdf='';pageContext=null;return originalSubmit?.call(form,e)};originalSubmit?.call(form,e);setTimeout(()=>openPdf(url),0)};
reader.addEventListener('click',e=>{const a=e.target.closest('a[href]');if(!a||!isPdf(a.href))return;e.preventDefault();e.stopImmediatePropagation();input.value=a.href;form.requestSubmit()},true);
addEventListener('message',e=>{if(e.origin!==location.origin||!e.data)return;const m=e.data;if(m.type==='z0-pdf-page'){activePdf=m.src||activePdf;pageContext={page:m.page,pages:m.pages,text:String(m.text||'').slice(0,12000),image:String(m.image||'')};stageState.textContent=`PDF · page ${m.page} of ${m.pages}`;reader.innerHTML=`<h1>PDF page ${m.page} of ${m.pages}</h1><p>${String(m.text||'').replace(/[&<>]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]))}</p>`}else if(m.type==='z0-pdf-error'){stageState.textContent='PDF unavailable';reader.innerHTML=`<h1>PDF unavailable</h1><p>${String(m.message||'Unknown PDF error')}</p><p>Use OPEN to view it in the normal browser.</p>`}},false);
const originalPost=Worker.prototype.postMessage;
Worker.prototype.postMessage=function(message,...rest){try{if(message?.type==='infer'&&activePdf&&pageContext){const vision=/VISION/i.test(modelMeta?.textContent||'');message.system=String(message.system||'')+`\nThe presenter surface is PDF page ${pageContext.page} of ${pageContext.pages}. Current-page text and, when supported, a rendered page image are attached. Ground all highlights broadly in that page.`;const text=`CURRENT PDF\nURL: ${activePdf}\nPAGE: ${pageContext.page} of ${pageContext.pages}\nPAGE TEXT:\n${pageContext.text||'No extractable text.'}`;message.messages=Array.isArray(message.messages)?message.messages:[];if(vision&&pageContext.image)message.messages.push({role:'user',content:[{type:'text',text},{type:'image_url',image_url:{url:pageContext.image}}]});else message.messages.push({role:'user',content:text})}}catch{}return originalPost.call(this,message,...rest)};
const initial=normalize(input.value);if(isPdf(initial))setTimeout(()=>openPdf(initial),250);
})();
