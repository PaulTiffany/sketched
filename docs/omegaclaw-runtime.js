(()=>{'use strict';
const STORE='z0.presenter-field.v1',CFG='z0.omegaclaw.runtime.v1',SENTINEL='__REAL_OMEGACLAW__';
let cfg={mode:'direct',endpoint:'',token:'',directKey:null,directModel:''};
try{cfg={...cfg,...JSON.parse(localStorage.getItem(CFG)||'{}')}}catch{}
const saveCfg=()=>localStorage.setItem(CFG,JSON.stringify(cfg));
const getState=()=>{try{return JSON.parse(localStorage.getItem(STORE)||'{}')}catch{return{}}};
const setState=state=>localStorage.setItem(STORE,JSON.stringify(state));
if(cfg.mode==='omegaclaw'){
  const state=getState();
  if(state.key!==SENTINEL){cfg.directKey=state.key||null;cfg.directModel=state.model||'';saveCfg()}
  state.key=SENTINEL;state.model='runtime/omegaclaw';setState(state);
}
const nativeFetch=window.fetch.bind(window);
function headers(){const h={'Content-Type':'application/json'};if(cfg.token)h.Authorization=`Bearer ${cfg.token}`;return h}
function endpoint(path){return String(cfg.endpoint||'').replace(/\/+$/,'')+path}
function textOf(content){if(typeof content==='string')return content;if(Array.isArray(content))return content.map(x=>x?.text||'').join('\n');return''}
function extractJson(raw){let s=String(raw||'').trim().replace(/^```(?:json)?/i,'').replace(/```$/,'').trim(),a=s.indexOf('{'),b=s.lastIndexOf('}');if(a<0||b<=a)throw Error('OmegaClaw did not return the Z0 JSON contract');return JSON.parse(s.slice(a,b+1))}
async function invokeRuntime(instruction,surface={}){
  if(!cfg.endpoint)throw Error('Set the OmegaClaw Space endpoint in Ω SETUP');
  const health=await nativeFetch(endpoint('/health'),{headers:headers()});
  const hd=await health.json().catch(()=>({}));
  if(!health.ok)throw Error(hd.detail||`OmegaClaw health ${health.status}`);
  if(!hd.agent_connected)throw Error('OmegaClaw is waking; retry in a moment');
  const submitted=await nativeFetch(endpoint('/api/turn'),{method:'POST',headers:headers(),body:JSON.stringify({instruction,surface,session_id:localStorage.getItem('z0.omegaclaw.session')||''})});
  const sd=await submitted.json().catch(()=>({}));
  if(!submitted.ok)throw Error(sd.detail||`OmegaClaw submit ${submitted.status}`);
  for(let i=0;i<120;i++){
    await new Promise(r=>setTimeout(r,i?1500:400));
    const response=await nativeFetch(endpoint(`/api/turn/${encodeURIComponent(sd.request_id)}`),{headers:headers()});
    const data=await response.json().catch(()=>({}));
    if(!response.ok)throw Error(data.detail||`OmegaClaw poll ${response.status}`);
    if(data.status==='complete')return data;
    if(data.status==='error')throw Error(data.error||'OmegaClaw turn failed');
  }
  throw Error('OmegaClaw turn timed out');
}
window.fetch=async(input,init)=>{
  const url=typeof input==='string'||input instanceof URL?String(input):input?.url||'';
  if(cfg.mode==='omegaclaw'&&url.startsWith('https://openrouter.ai/api/v1/models')){
    return new Response(JSON.stringify({data:[{id:'runtime/omegaclaw',name:'REAL OMEGACLAW',pricing:{prompt:'0',completion:'0',request:'0'},architecture:{input_modalities:['text']},supported_parameters:['response_format'],context_length:32000}]}),{status:200,headers:{'Content-Type':'application/json'}});
  }
  if(cfg.mode==='omegaclaw'&&url.startsWith('https://openrouter.ai/api/v1/chat/completions')){
    try{
      const body=JSON.parse(init?.body||'{}');
      if(body.model==='runtime/omegaclaw'){
        const messages=Array.isArray(body.messages)?body.messages:[];
        const user=[...messages].reverse().find(message=>message?.role==='user');
        const instruction=textOf(user?.content).trim()||'Reply exactly: Z0 OmegaClaw runtime works.';
        const result=await invokeRuntime(instruction,{url:location.href,title:document.title,page:'runtime test',selection:'',text:''});
        return new Response(JSON.stringify({model:'asi-alliance/OmegaClaw-Core',choices:[{message:{role:'assistant',content:result.text}}],usage:null}),{status:200,headers:{'Content-Type':'application/json'}});
      }
    }catch(error){
      return new Response(JSON.stringify({error:{message:String(error?.message||error)}}),{status:503,headers:{'Content-Type':'application/json'}});
    }
  }
  return nativeFetch(input,init);
};
const NativeWorker=window.Worker;
let latestWorker=null;
window.Worker=function(...args){const w=new NativeWorker(...args);latestWorker=w;return w};
window.Worker.prototype=NativeWorker.prototype;
Object.setPrototypeOf(window.Worker,NativeWorker);
const nativePost=NativeWorker.prototype.postMessage;
NativeWorker.prototype.postMessage=function(message,...rest){
  if(cfg.mode!=='omegaclaw'||message?.type!=='infer')return nativePost.call(this,message,...rest);
  runTurn(this,message);return undefined;
};
function surfaceFrom(message){const state=getState(),messages=Array.isArray(message.messages)?message.messages:[],joined=messages.map(x=>textOf(x.content)).join('\n');const page=(joined.match(/PAGE:\s*([^\n]+)/i)||[])[1]||'';const pdfText=(joined.match(/PAGE TEXT:\n([\s\S]*)/i)||[])[1]||'';return{url:state.url||'',title:state.pageTitle||'',page,selection:state.sharedText||'',text:(pdfText||state.pageText||joined).slice(0,24000)}}
function instructionFrom(message){const messages=Array.isArray(message.messages)?message.messages:[];for(let i=messages.length-1;i>=0;i--){const text=textOf(messages[i].content).trim();if(text&&!/^(PRESENTED PAGE|CURRENT PDF)/.test(text))return text.slice(0,4000)}return'Observe the current surface, answer the presenter, and create a sparse useful Z0 performance.'}
async function runTurn(worker,message){const started=Date.now();worker.onmessage?.({data:{type:'status',value:'thinking'}});try{const result=await invokeRuntime(instructionFrom(message),surfaceFrom(message));const packet=extractJson(result.text);worker.onmessage?.({data:{type:'result',packet,served:'asi-alliance/OmegaClaw-Core',elapsed:Date.now()-started}})}catch(error){worker.onmessage?.({data:{type:'error',message:String(error?.message||error)}})}finally{worker.onmessage?.({data:{type:'done'}})}}
async function health(){if(!cfg.endpoint)return{ok:false,label:'endpoint not set'};try{const r=await nativeFetch(endpoint('/health'),{headers:headers()});const d=await r.json();return{ok:r.ok&&d.runtime==='asi-alliance/OmegaClaw-Core'&&d.agent_connected,label:d.agent_connected?'official runtime connected':'runtime waking',data:d}}catch(error){return{ok:false,label:error.message}}}
function restoreDirect(){const state=getState();state.key=cfg.directKey||null;state.model=cfg.directModel||'';setState(state)}
function addRuntimeCard(){const settings=document.querySelector('.settings');if(!settings||document.querySelector('#realRuntimeCard'))return;const card=document.createElement('div');card.className='card';card.id='realRuntimeCard';card.innerHTML=`<div class="eyebrow">cognitive runtime</div><select id="runtimeMode"><option value="direct">DIRECT MODEL · browser inference</option><option value="omegaclaw">REAL OMEGACLAW · official runtime</option></select><label class="muted">OmegaClaw Space endpoint<input id="runtimeEndpoint" type="url" placeholder="https://username-z0-omegaclaw.hf.space" style="width:100%;margin-top:.3rem;padding:.55rem;border-radius:.5rem;background:#fff;color:#111"></label><label class="muted">Optional access token<input id="runtimeToken" type="password" autocomplete="off" style="width:100%;margin-top:.3rem;padding:.55rem;border-radius:.5rem;background:#fff;color:#111"></label><div class="actions"><button class="action good" id="runtimeTest">TEST RUNTIME</button><button class="action primary" id="runtimeApply">APPLY & RELOAD</button></div><div class="mono" id="runtimeResult">Not tested.</div>`;settings.prepend(card);
  const mode=card.querySelector('#runtimeMode'),ep=card.querySelector('#runtimeEndpoint'),token=card.querySelector('#runtimeToken'),result=card.querySelector('#runtimeResult');mode.value=cfg.mode;ep.value=cfg.endpoint||'';token.value=cfg.token||'';
  card.querySelector('#runtimeTest').onclick=async()=>{cfg.endpoint=ep.value.trim();cfg.token=token.value.trim();saveCfg();result.textContent='Testing…';const h=await health();result.textContent=h.ok?`VERIFIED\n${h.data.runtime}\n${h.data.transport}`:`NOT CONNECTED\n${h.label}`};
  card.querySelector('#runtimeApply').onclick=()=>{const next=mode.value;cfg.endpoint=ep.value.trim();cfg.token=token.value.trim();if(next==='direct'&&cfg.mode==='omegaclaw')restoreDirect();cfg.mode=next;saveCfg();location.reload()};
  const setText=(element,text)=>{if(element&&element.textContent!==text)element.textContent=text};
  const rewrite=()=>{if(cfg.mode!=='omegaclaw')return;const s=document.querySelector('#omegaState'),b=document.querySelector('#omegaStatus'),setup=document.querySelector('#setupButton');if(s&&/awake|asleep|working/.test(s.textContent||''))setText(s,s.textContent==='working'?'OmegaClaw working':'OmegaClaw · '+(latestWorker?'awake':'asleep'));if(b)setText(b,b.textContent.includes('working')?'Real OmegaClaw is working':latestWorker?'Real OmegaClaw is awake':'Real OmegaClaw is asleep');setText(setup,'CLAW SETUP')};
  new MutationObserver(rewrite).observe(document.body,{subtree:true,childList:true,characterData:true});rewrite();
}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',addRuntimeCard,{once:true});else addRuntimeCard();
})();
