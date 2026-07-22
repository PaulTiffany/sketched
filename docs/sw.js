const CACHE='z0-shell-v4';
const SHELL=['./','./index.html','./manifest.webmanifest','./z0-icon.svg','./pdf.html','./pdf-support.js','./arxiv-bridge.js'];
const decorate=async response=>{
  const type=response.headers.get('content-type')||'';
  if(!type.includes('text/html'))return response;
  let html=await response.text();
  if(!html.includes('pdf-support.js'))html=html.replace('</body>','<script src="pdf-support.js"></script></body>');
  if(!html.includes('arxiv-bridge.js'))html=html.replace('</body>','<script src="arxiv-bridge.js"></script></body>');
  const headers=new Headers(response.headers);
  headers.delete('content-length');
  return new Response(html,{status:response.status,statusText:response.statusText,headers});
};
self.addEventListener('install',event=>{event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(SHELL)).then(()=>self.skipWaiting()))});
self.addEventListener('activate',event=>{event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(key=>key!==CACHE).map(key=>caches.delete(key)))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',event=>{
  const request=event.request;
  if(request.method!=='GET')return;
  const url=new URL(request.url);
  if(url.origin!==location.origin)return;
  if(request.mode==='navigate'){
    event.respondWith(fetch(request).then(decorate).then(async response=>{const copy=response.clone();const cache=await caches.open(CACHE);await cache.put(request,copy);return response}).catch(async()=>{const cached=await caches.match(request)||await caches.match('./');return cached?decorate(cached):Response.error()}));
    return;
  }
  event.respondWith(caches.match(request).then(cached=>cached||fetch(request).then(response=>{if(response.ok){const copy=response.clone();caches.open(CACHE).then(cache=>cache.put(request,copy))}return response})));
});
