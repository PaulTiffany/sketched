chrome.runtime.onInstalled.addListener(async()=>{
  await chrome.sidePanel.setPanelBehavior({openPanelOnActionClick:true});
});

chrome.runtime.onMessage.addListener((message,sender,sendResponse)=>{
  if(message?.type==='z0:get-active-tab'){
    chrome.tabs.query({active:true,currentWindow:true}).then(([tab])=>sendResponse({tab}));
    return true;
  }
  if(message?.type==='z0:open-side-panel'){
    const tabId=message.tabId||sender.tab?.id;
    if(tabId)chrome.sidePanel.open({tabId}).then(()=>sendResponse({ok:true})).catch(error=>sendResponse({ok:false,error:error.message}));
    return true;
  }
});
