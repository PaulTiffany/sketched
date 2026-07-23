(()=>{'use strict';
const CONFIG_KEY='z0.inference.connector.v1';
const LEGACY_KEY='z0.openrouter.key';
const LEGACY_MODEL='z0.openrouter.model';
const SECRET_KEY='z0.inference.secret.openrouter';
const $=selector=>document.querySelector(selector);
const $$=selector=>[...document.querySelectorAll(selector)];
const nativeFetch=window.fetch.bind(window);
let models=[];
let loading=false;
let selected='';
let config={};
try{config=JSON.parse(localStorage.getItem(CONFIG_KEY)||'{}')}catch{}
if(config.provider==='openrouter')selected=config.model||'';
const key=()=>sessionStorage.getItem(SECRET_KEY)||sessionStorage.getItem(LEGACY_KEY)||'';
const esc=value=>String(value).replace(/[&<>"']/g,char=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[char]));
const providerName=id=>String(id||'').split('/')[0]||'other';
const perMillion=value=>Number(value||0)*1_000_000;
const price=value=>{const n=Number(value||0);if(n===0)return'free';if(n<.01)return'<$0.01';return'$'+n.toFixed(n<1?2:1)};
const context=value=>{const n=Number(value||0);if(!n)return'';return n>=1e6?(n/1e6).toFixed(n%1e6?1:0)+'M':Math.round(n/1000)+'K'};
function record(row){const input=row.architecture?.input_modalities||[],output=row.architecture?.output_modalities||[],params=row.supported_parameters||[];const prompt=perMillion(row.pricing?.prompt),completion=perMillion(row.pricing?.completion);return{id:row.id,name:row.name||row.id,description:row.description||'',provider:providerName(row.id),text:input.includes('text')&&output.includes('text'),vision:input.includes('image'),structured:params.includes('structured_outputs')||params.includes('response_format'),context:Number(row.context_length||0),prompt,completion,free:prompt===0&&completion===0,variable:row.id==='openrouter/free'}}
function saveSelection(){if(!selected)return;config={...config,provider:'openrouter',base:'https://openrouter.ai/api/v1',model:selected};localStorage.setItem(CONFIG_KEY,JSON.stringify(config));localStorage.setItem(LEGACY_MODEL,selected);$('#setup').classList.remove('open');location.reload()}
function filters(){return{query:String($('#modelSearch')?.value||'').trim().toLowerCase(),provider:$('#modelProviderFilter')?.value||'all',free:Boolean($('#freeOnly')?.checked),reliable:$('#reliableJson')?.checked!==false}}
function visible(){const f=filters();return models.filter(model=>(f.provider==='all'||model.provider===f.provider)&&(!f.free||model.free)&&(!f.reliable||model.structured)&&(!f.query||`${model.name} ${model.id} ${model.description}`.toLowerCase().includes(f.query)))}
function renderProviderFilter(){const select=$('#modelProviderFilter');if(!select)return;const current=select.value||'all',counts=new Map();models.forEach(model=>counts.set(model.provider,(counts.get(model.provider)||0)+1));select.innerHTML='<option value="all">All providers</option>'+[...counts].sort((a,b)=>a[0].localeCompare(b[0])).map(([name,count])=>`<option value="${esc(name)}">${esc(name)} (${count})</option>`).join('');if([...select.options].some(option=>option.value===current))select.value=current}
function renderSelected(){const box=$('#selectedModel'),button=$('#useConnector'),model=models.find(item=>item.id===selected);if(!box||!button)return;if(!model){box.innerHTML='<strong>No model selected</strong><span>Choose one model from the catalog.</span>';button.disabled=true;return}box.innerHTML=`<strong>${esc(model.name)}</strong><span>${esc(model.id)}${model.variable?' · variable free route':''}</span>`;button.disabled=false}
function render(){const output=$('#modelResults'),status=$('#catalogStatus');if(!output||!status)return;if(loading){output.innerHTML='<div class="model-empty">Loading model catalog…</div>';status.textContent='Loading OpenRouter models…';return}const rows=visible();status.textContent=`${rows.length} shown · ${models.length} text models available.`;output.innerHTML=rows.slice(0,120).map(model=>{const badges=[model.free?'FREE':`${price(model.prompt)} / ${price(model.completion)} per M`,model.structured?'RELIABLE JSON':'GUARDED JSON',model.vision?'VISION':'TEXT',model.context?context(model.context)+' CONTEXT':''].filter(Boolean);return `<button class="model-card ${model.id===selected?'selected':''}" data-or-model="${esc(model.id)}"><span class="model-card-main"><strong>${esc(model.name)}</strong><small>${esc(model.id)}</small></span><span class="model-badges">${badges.map(badge=>`<span>${esc(badge)}</span>`).join('')}</span>${model.variable?'<em>Free route varies by request.</em>':''}</button>`}).join('')||'<div class="model-empty">No matches. Turn off “Reliable lesson JSON” to include guarded models.</div>';$$('[data-or-model]').forEach(button=>button.addEventListener('click',event=>{event.preventDefault();event.stopPropagation();selected=button.dataset.orModel;render();renderSelected()}));renderSelected()}
async function load(force=false){if(loading||(!force&&models.length)||!key())return;loading=true;render();try{const response=await nativeFetch('https://openrouter.ai/api/v1/models?input_modalities=text&output_modalities=text&sort=most-popular',{headers:{Authorization:'Bearer '+key()}});const data=await response.json();if(!response.ok)throw Error(data.error?.message||`HTTP ${response.status}`);models=(data.data||[]).map(record).filter(model=>model.text);if(!models.some(model=>model.id==='openrouter/free'))models.unshift({id:'openrouter/free',name:'OpenRouter Free',description:'Variable free text route.',provider:'openrouter',text:true,vision:false,structured:false,context:0,prompt:0,completion:0,free:true,variable:true});renderProviderFilter()}catch(error){models=[];$('#catalogStatus').textContent='Could not load models: '+error.message;$('#modelResults').innerHTML='<div class="model-empty">Reconnect OpenRouter or refresh the catalog.</div>'}finally{loading=false;render()}}
function accountState(){const connected=Boolean(key());$('#openrouterBrowser').hidden=!connected;$('#openrouterDisconnect').hidden=!connected;$('#openrouterAccountState').innerHTML=connected?'<strong>Connected</strong><span>Choose a provider and model below.</span>':'<strong>Not connected</strong><span>Sign in to OpenRouter to load the model catalog.</span>';if(connected)load()}
function open(){setTimeout(()=>{accountState();renderAdvanced();render()},0)}
function renderAdvanced(){$('#providerGrid')?.querySelectorAll('[data-provider]').forEach(button=>{if(button.dataset.provider==='openrouter')button.remove()})}
$('#setupButton')?.addEventListener('click',open);
$('#modelSearch')?.addEventListener('input',render);
$('#modelProviderFilter')?.addEventListener('change',render);
$('#freeOnly')?.addEventListener('change',render);
$('#reliableJson')?.addEventListener('change',render);
$('#refreshOpenRouterModels')?.addEventListener('click',event=>{event.preventDefault();load(true)});
$('#useConnector')?.addEventListener('click',event=>{if(!$('#openrouterPanel')?.hidden&&selected){event.preventDefault();event.stopImmediatePropagation();saveSelection()}},true);
$('#manualOpenRouterKey')?.addEventListener('input',event=>{const value=event.target.value.trim();if(value){sessionStorage.setItem(SECRET_KEY,value);sessionStorage.setItem(LEGACY_KEY,value)}else{sessionStorage.removeItem(SECRET_KEY);sessionStorage.removeItem(LEGACY_KEY)}accountState()});
const observer=new MutationObserver(()=>renderAdvanced());observer.observe($('#providerGrid')||document.body,{childList:true,subtree:true});
accountState();
})();
