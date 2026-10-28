// Injected only on Windows, after the shared UI.
(() => {
 document.documentElement.classList.add('windows');
 const head=document.getElementById('head');
 const brand=document.createElement('img');
 brand.className='brand-icon';brand.src=window.__WINDOWS_ICON__;brand.alt='';brand.draggable=false;
 head.insertBefore(brand,head.firstChild);
 const toolbar=document.createElement('div');
 toolbar.className='toolbar'; toolbar.setAttribute('role','toolbar'); toolbar.setAttribute('aria-label','Littodoo tools');
 ['bColor','bPin','bMap','bAdd','bClose'].forEach(id=>{
  const button=document.getElementById(id);
  if(!button)return;
  button.setAttribute('aria-label',button.title||id);
  toolbar.appendChild(button);
 });
 head.appendChild(toolbar);
 const bPin=document.getElementById('bPin');
 const oldSetPin=setPin;
 setPin=on=>{oldSetPin(on);bPin.setAttribute('aria-pressed',String(S.pin));bPin.title=S.pin?'Unpin (Alt+F)':'Pin on top (Alt+F)';};
 bPin.setAttribute('aria-pressed',String(!!S.pin));
 document.getElementById('bAdd').title='Add (Alt+N)';
 document.getElementById('bColor').title='Color';
 document.getElementById('bClose').title='Close';
 // Native drag via DLL; no webpage mousemove loop.
 head.addEventListener('pointerdown',e=>{
  if(e.button!==0 || e.target.closest('button,.mp-pal,.sw'))return;
  e.preventDefault();
  document.activeElement?.blur();
  post({type:'drag'});
 });
 const oldColor=color;
 color=id=>{oldColor(id);post({type:'appearance',color:getComputedStyle(document.documentElement).getPropertyValue('--bg').trim(),value:S.opacity});};
 window.__native.applyOpacity=()=>{
  document.getElementById('note').style.opacity=1;
  post({type:'appearance',color:getComputedStyle(document.documentElement).getPropertyValue('--bg').trim(),value:S.opacity});
 };
 window.addEventListener('pywebviewready',()=>{window.__native.applyOpacity();post({type:'pin',on:!!S.pin});});
 window.__windowsShortcut=action=>{
  if(action==='opacity-up')window.__native.opacityDelta(0.08);
  else if(action==='opacity-down')window.__native.opacityDelta(-0.08);
  else if(action==='pin')setPin(!S.pin);
  else if(action==='add'){
   if(S.mode==='map'&&typeof mapOnAdd==='function')mapOnAdd();
   else addAtCaret();
  }
 };
 window.addEventListener('keydown',e=>{
  if(!e.altKey||e.ctrlKey||e.metaKey||e.isComposing)return;
  let action=null;
  if(['Equal','NumpadAdd'].includes(e.code)||['=','+','Add'].includes(e.key))action='opacity-up';
  else if(['Minus','NumpadSubtract'].includes(e.code)||['-','Subtract'].includes(e.key))action='opacity-down';
  else if(e.code==='KeyF'||e.key.toLowerCase()==='f')action='pin';
  else if(e.code==='KeyN'||e.key.toLowerCase()==='n')action='add';
  if(!action)return;
  e.preventDefault();e.stopImmediatePropagation();
  if(e.repeat&&(action==='pin'||action==='add'))return;
  window.__windowsShortcut(action);
 },true);
 const oldRender=render;
 render=(...args)=>{
  oldRender(...args);
  const hint=document.querySelector('#list .empty');
  if(hint)hint.textContent='Click empty space to start';
 };
 document.getElementById('list').addEventListener('click',e=>{
  if(S.items.length||pending||e.target.closest('.it'))return;
  addAtCaret();
  document.querySelector('#list .tx')?.focus();
 });
 if(typeof render==='function')render();
 document.getElementById('bClose').onclick=async()=>{
  document.activeElement?.blur();
  await window.pywebview.api.msg(JSON.stringify({type:'save',json:JSON.stringify(S)}));
  await window.pywebview.api.msg(JSON.stringify({type:'close'}));
 };
})();
