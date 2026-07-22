(()=>{'use strict';
const $=s=>document.querySelector(s),messages=$('#messages');
let tab=null,context=null,busy=false;
function add(kind,text){const d=document.createElement('div');d.className='msg '+kind;d.textContent=String(text||'');messages.append(d);messages.scrollTop=messages.scrollHeight}
function setState(text){$('#state').textContent=text}
async function active(){[tab]=await chrome.tabs.query({active:true,currentWindow:true});if(!tab)throw Error('No active tab.');$('#title').textContent=tab.title||'Untitled';$('#url').textContent=tab.url||'';return tab}
async function ensureBridge(){await active();if(!tab.id)throw Error('No tab id.');try{return await chrome.tabs.sendMessage(tab.id,{type:'z0:context'})}catch{await chrome.scripting.executeScript({target:{tabId:tab.id},files:['content.js']});return chrome.tabs.sendMessage(tab.id,{type:'z0:context'})}}
function arxivId(url){try{const u=new URL(url),m=u.hostname.endsWith('arxiv.org')&&u.pathname.match(/^\/(?:abs|pdf|html)\/(.+)$/i);return m?decodeURIComponent(m[1]).replace(/\.pdf$/i,'').replace(/\/$/,''):''}catch{return''}}
async function readableFallback(){
  const url=tab?.url||'';if(!/^https?:/i.test(url))throw Error('This browser page cannot be read directly.');
  const id=arxivId(url),target=id?`https://arxiv.org/pdf/${id}.pdf`:url;
  const r=await fetch('https://r.jina.ai/'+target);if(!r.ok)throw Error(`Readable route failed (${r.status}).`);const text=(await r.text()).slice(0,60000);
  return{title:tab.title||url,url,selection:'',text,language:''};
}
async function readTab(){setState('reading real tab…');try{context=await ensureBridge();setState(context.selection?'selection captured':'live page captured')}catch(e){try{context=await readableFallback();setState('reader channel captured')}catch(f){context=null;setState('unreadable surface');add('system',`${e.message}\n${f.message}`);return}}add('system',`Read ${context.title||'surface'} · ${context.text.length.toLocaleString()} characters${context.selection?' · selection included':''}`)}
async function sendTab(message){await active();try{return await chrome.tabs.sendMessage(tab.id,message)}catch{await chrome.scripting.executeScript({target:{tabId:tab.id},files:['content.js']});return chrome.tabs.sendMessage(tab.id,message)}}
async function infer(question){
  if(busy)return;const {key='',model='openrouter/free'}=await chrome.storage.local.get(['key','model']);if(!key){$('#settings').showModal();add('system','Add an OpenRouter key first.');return}
  if(!context)await readTab();if(!context)return;
  busy=true;setState('Omega reading…');
  const prompt=`You are OmegaClaw, a rigorous reading companion beside the real browser tab. Answer the question using only supplied page evidence. Return exactly one JSON object: {"reply":"concise answer","evidence":"an exact short phrase copied from the supplied text, or empty","location":"brief section/page clue","confidence":"high|medium|low"}. Do not invent quotations.\n\nTITLE: ${context.title}\nURL: ${context.url}\nSELECTED TEXT:\n${context.selection||'none'}\n\nPAGE OR PAPER TEXT:\n${context.text.slice(0,50000)}\n\nQUESTION: ${question}`;
  try{
    const r=await fetch('https://openrouter.ai/api/v1/chat/completions',{method:'POST',headers:{Authorization:`Bearer ${key}`,'Content-Type':'application/json','HTTP-Referer':'https://paultiffany.github.io/sketched/','X-OpenRouter-Title':'Z0 OmegaClaw'},body:JSON.stringify({model,temperature:.15,max_tokens:900,response_format:{type:'json_object'},provider:{allow_fallbacks:true,sort:'latency',max_price:{prompt:0,completion:0,image:0,request:0}},messages:[{role:'user',content:prompt}]})});
    const data=await r.json();if(!r.ok)throw Error(data.error?.message||`OpenRouter ${r.status}`);const raw=data.choices?.[0]?.message?.content||'{}',packet=JSON.parse(raw.replace(/^```(?:json)?|```$/g,'').trim());
    let answer=packet.reply||'No answer returned.';if(packet.location)answer+=`\n\nLocation: ${packet.location}`;answer+=`\nConfidence: ${packet.confidence||'unknown'}`;add('omega',answer);
    if(packet.evidence){const marked=await sendTab({type:'z0:highlight',text:packet.evidence}).catch(()=>({ok:false}));if(marked?.ok)add('system','Omega highlighted the cited evidence in the real page.');else add('system',`Evidence: “${packet.evidence}”`)}
    setState('ready');
  }catch(e){add('system','Inference failed: '+e.message);setState('route failed')}finally{busy=false}
}
$('#read').onclick=readTab;
$('#mark').onclick=async()=>{try{const r=await sendTab({type:'z0:mark-selection'});add('system',r?.ok?'Selection marked cyan.':'Select text in the page first.')}catch(e){add('system','This surface cannot be directly marked: '+e.message)}};
$('#clear').onclick=()=>sendTab({type:'z0:clear'}).then(()=>add('system','Page marks cleared.')).catch(()=>add('system','No injectable page marks to clear.'));
$('#composer').onsubmit=e=>{e.preventDefault();const q=$('#prompt').value.trim();if(!q)return;$('#prompt').value='';add('human',q);infer(q)};
$('#setup').onclick=async()=>{const s=await chrome.storage.local.get(['key','model']);$('#key').value=s.key||'';$('#model').value=s.model||'openrouter/free';$('#settings').showModal()};
$('#save').onclick=async()=>{await chrome.storage.local.set({key:$('#key').value.trim(),model:$('#model').value.trim()||'openrouter/free'});$('#settings').close();add('system','Omega route saved locally.')};
$('#forget').onclick=async()=>{await chrome.storage.local.remove('key');$('#key').value='';add('system','OpenRouter key removed.')};
chrome.tabs.onActivated.addListener(()=>{context=null;active().catch(()=>{})});chrome.tabs.onUpdated.addListener((id,info)=>{if(id===tab?.id&&info.status==='complete'){context=null;active().catch(()=>{})}});
active().then(()=>add('system','The browser remains the browser. Read the tab when ready.')).catch(e=>add('system',e.message));
})();
