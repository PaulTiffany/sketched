(()=>{
  if(window.__z0OmegaClaw)return;
  window.__z0OmegaClaw=true;
  const MARK='data-z0-mark';
  const esc=s=>String(s||'').replace(/\s+/g,' ').trim();
  function selection(){return esc(getSelection()?.toString()).slice(0,12000)}
  function pageText(){
    const root=document.querySelector('article,main,[role=main]')||document.body;
    return esc(root?.innerText||'').slice(0,60000);
  }
  function context(){return{title:document.title,url:location.href,selection:selection(),text:pageText(),language:document.documentElement.lang||''}}
  function clear(){document.querySelectorAll(`[${MARK}]`).forEach(el=>{el.style.removeProperty('background');el.style.removeProperty('outline');el.style.removeProperty('box-shadow');el.removeAttribute(MARK)})}
  function markSelection(){const sel=getSelection();if(!sel||sel.rangeCount===0||sel.isCollapsed)return false;const range=sel.getRangeAt(0);const span=document.createElement('mark');span.setAttribute(MARK,'human');span.style.background='#78e7f3';span.style.color='#071215';span.style.borderRadius='.18em';try{range.surroundContents(span);span.scrollIntoView({behavior:'smooth',block:'center'});sel.removeAllRanges();return true}catch{return false}}
  function highlightText(needle){
    needle=esc(needle);if(!needle)return false;clear();
    const walker=document.createTreeWalker(document.body,NodeFilter.SHOW_TEXT,{acceptNode:n=>{const p=n.parentElement;if(!p||['SCRIPT','STYLE','NOSCRIPT','TEXTAREA','INPUT'].includes(p.tagName))return NodeFilter.FILTER_REJECT;return esc(n.nodeValue).toLowerCase().includes(needle.toLowerCase())?NodeFilter.FILTER_ACCEPT:NodeFilter.FILTER_REJECT}});
    const node=walker.nextNode();if(!node)return false;const raw=node.nodeValue,at=raw.toLowerCase().indexOf(needle.toLowerCase());if(at<0)return false;const range=document.createRange();range.setStart(node,at);range.setEnd(node,Math.min(raw.length,at+needle.length));const span=document.createElement('mark');span.setAttribute(MARK,'omega');span.style.background='#ffd166';span.style.color='#1b1300';span.style.borderRadius='.18em';try{range.surroundContents(span);span.scrollIntoView({behavior:'smooth',block:'center'});return true}catch{return false}}
  chrome.runtime.onMessage.addListener((m,_s,reply)=>{
    if(m?.type==='z0:context'){reply(context());return}
    if(m?.type==='z0:mark-selection'){reply({ok:markSelection()});return}
    if(m?.type==='z0:highlight'){reply({ok:highlightText(m.text)});return}
    if(m?.type==='z0:clear'){clear();reply({ok:true});return}
  });
})();
