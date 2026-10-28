import Cocoa
import WebKit

class StickyWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

let html = #"""
<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8">
<style>
:root{--bg:#FAFAFA;--ink:#222;--sub:rgba(0,0,0,.38);--line:rgba(0,0,0,.1);--time:#A8A8A8;--box:rgba(0,0,0,.35)}
*{box-sizing:border-box}
html,body{margin:0;height:100%;background:transparent;overflow:hidden;
 font-family:-apple-system,"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif;color:var(--ink);cursor:default;-webkit-user-select:none;user-select:none}
.note{position:absolute;inset:0;background:var(--bg);border-radius:12px;display:flex;flex-direction:column;overflow:hidden}
.head{display:flex;align-items:center;gap:2px;padding:10px 10px 6px 14px;flex:none}
.title{flex:1;font-size:13px;font-weight:650;letter-spacing:.03em;opacity:.8;height:22px;line-height:22px}
.btn{width:22px;height:22px;border:none;background:transparent;color:var(--ink);border-radius:6px;
 display:flex;align-items:center;justify-content:center;cursor:pointer;opacity:.55;padding:0}
.btn:hover{opacity:1;background:rgba(0,0,0,.08)}
.btn.on{opacity:1}
.btn svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
.dot{width:12px;height:12px;border-radius:50%;background:var(--bg);border:1.5px solid var(--ink)}
.sw{display:none;gap:8px;padding:2px 14px 8px;flex:none;flex-wrap:wrap}
.sw.show{display:flex}
.sw i{width:16px;height:16px;border-radius:50%;border:1.5px solid rgba(0,0,0,.2);cursor:pointer;display:block}
.sw i.act{outline:2px solid var(--ink);outline-offset:1px}
.list{flex:1;overflow-y:auto;padding:0 0 26px;margin:0;list-style:none}
.list::-webkit-scrollbar{width:0}
.it{position:relative;overflow:hidden;border-bottom:1px dashed var(--line);touch-action:pan-y}
.it:last-child{border-bottom:none}
.inner{display:flex;align-items:flex-start;gap:9px;padding:7px 14px;position:relative;z-index:1;
 background:var(--bg);transition:transform .22s ease;will-change:transform}
.it.dragging .inner{transition:none}
.it.reveal .inner{transform:translateX(-92px)}
.reveal{opacity:.0;transition:opacity .12s}
.list.swiping .reveal{opacity:1}
.it.reveal .reveal{opacity:1}
.reveal{position:absolute;right:0;top:0;bottom:0;width:92px;display:flex;align-items:center;justify-content:center;
 font-size:11px;color:var(--time);letter-spacing:.01em;z-index:0;pointer-events:none;padding:0 6px;text-align:center;line-height:1.25}
.ck{flex:none;width:15px;height:15px;margin-top:2px;border-radius:50%;border:1.6px solid var(--ink);opacity:.7;cursor:pointer;
 display:flex;align-items:center;justify-content:center}
.ck svg{width:9px;height:9px;stroke:var(--bg);stroke-width:3;fill:none;stroke-linecap:round;stroke-linejoin:round;display:none}
.it.done .ck,.mk.done .ck{background:var(--ink);opacity:.5}
.it.done .ck svg,.mk.done .ck svg{display:block}
.tx{flex:1;font-size:14px;line-height:1.4;min-height:1.4em;outline:none;word-break:break-word;white-space:pre-wrap;
 -webkit-user-select:text;user-select:text;cursor:text}
.tx::after{content:"\200b"}
.it.done .tx,.mk.done .tx{text-decoration:line-through;color:var(--sub)}
.x{flex:none;border:none;background:none;color:var(--sub);font-size:14px;cursor:pointer;opacity:0;padding:0 2px;line-height:1.4}
.it:hover .x,.mk:hover .x,.mp:hover .mp-x{opacity:1}
.x:hover,.mp-x:hover{color:var(--ink)}
.empty{font-size:12px;color:var(--sub);padding:10px 14px}
.grip{position:absolute;right:0;bottom:0;width:22px;height:22px;cursor:nwse-resize;z-index:3}
.grip:after{content:"";position:absolute;right:5px;bottom:5px;width:9px;height:9px;
 border-right:1.6px solid var(--sub);border-bottom:1.6px solid var(--sub);border-radius:0 0 3px 0}
.fx{position:absolute;inset:0;pointer-events:none;overflow:hidden;z-index:5}
.star{position:absolute;font-size:12px;animation:burst .7s ease-out forwards;opacity:0}
@keyframes burst{
 0%{transform:translate(0,0) scale(.4) rotate(0);opacity:1}
 100%{transform:translate(var(--dx),var(--dy)) scale(1.1) rotate(var(--rot));opacity:0}
}
/* —— Map mode —— */
.map{display:none;flex:1;position:relative;overflow:auto;background:var(--bg);padding:0 0 26px;min-height:0}
.map.show{display:block}
.map::-webkit-scrollbar{width:0;height:0}
.map-lines{position:absolute;left:0;top:0;overflow:visible;pointer-events:none;z-index:0}
.map-stage{position:relative;min-width:100%;min-height:100%;z-index:1}
.map-empty{position:absolute;left:14px;top:10px;font-size:12px;color:var(--sub);pointer-events:none;z-index:2}
.mp{position:absolute;display:flex;align-items:flex-start;gap:0;z-index:1}
.mp.dragging{z-index:4;opacity:.92}
.mp-head{position:relative;flex:none}
.mp-title{display:block;min-width:72px;max-width:140px;padding:6px 10px;border:1.5px solid var(--tbd,var(--box));
 border-radius:8px;font-size:13px;font-weight:600;line-height:1.35;outline:none;word-break:break-word;white-space:pre-wrap;
 -webkit-user-select:text;user-select:text;cursor:grab;background:var(--tb,var(--bg));color:var(--tink,var(--ink));position:relative}
.mp-title.press,.mp-title.press:focus{cursor:grab}
.mp-title:focus{cursor:text;border-color:var(--tink,var(--ink))}
.mp-title::after{content:"\200b"}
.mp-pal{position:absolute;left:0;top:100%;padding-top:5px;z-index:6;opacity:0;pointer-events:none;transition:opacity .12s}
.mp-pal i{display:inline-flex;gap:5px;padding:5px 7px;background:var(--bg);border-radius:12px;box-shadow:0 0 0 1px var(--line),0 3px 10px rgba(0,0,0,.12);font-style:normal}
.mp-pal b{display:block;width:14px;height:14px;border-radius:50%;cursor:pointer;border:1.5px solid rgba(0,0,0,.25);box-sizing:border-box}
.mp-pal b.sel{box-shadow:0 0 0 2px var(--ink)}
.mp-head:hover .mp-pal,.mp-head:focus-within .mp-pal{opacity:1;pointer-events:auto}
.mp.dragging .mp-pal{opacity:0!important;pointer-events:none!important}
#bMap{width:26px;min-width:26px;padding:0;gap:0;justify-content:center;display:inline-flex;align-items:center;opacity:1;background:rgba(0,0,0,.07);font-size:11px;font-weight:600;color:var(--ink)}
#bMap:hover{background:rgba(0,0,0,.14)}
#bMap svg{width:15px;height:15px}
.mp-x,.mp-col{position:absolute;width:15px;height:15px;border:none;border-radius:50%;padding:0;cursor:pointer;opacity:0;
 display:flex;align-items:center;justify-content:center;z-index:2;transition:opacity .12s}
.mp-x{top:-8px;right:-8px;background:var(--bg);color:var(--sub);font-size:12px;line-height:1;box-shadow:0 0 0 1px var(--line)}
.mp-col{display:none!important;top:-8px;left:-8px;background:var(--cb,transparent);border:1.5px solid var(--cbd,var(--box))}
.mp:hover .mp-x,.mp:hover .mp-col{opacity:1}
.mp.dragging .mp-x,.mp.dragging .mp-col{opacity:0}
.mp-kids{flex:none;display:flex;flex-direction:column;gap:3px;margin-left:30px;padding:2px 0}
.mn{display:flex;align-items:flex-start}
.mn-kids{flex:none;display:flex;flex-direction:column;gap:3px;margin-left:40px;padding:0}
.mk{display:flex;align-items:flex-start;gap:7px;padding:1px 0;position:relative}
.mk .ck{margin-top:3px;width:13px;height:13px;border-width:1.4px}
.mk .ck svg{width:8px;height:8px}
.mk .tx{font-size:13px;font-weight:400;min-height:1.35em;line-height:1.35;flex:none;min-width:48px;max-width:210px}
.mn[data-depth="2"] .mk .tx,.mn[data-depth="3"] .mk .tx,.mn[data-depth="4"] .mk .tx,.mn[data-depth="5"] .mk .tx{font-size:12.5px}
.acts{position:absolute;left:100%;top:1px;margin-left:3px;display:flex;align-items:center;gap:1px;opacity:0;transition:opacity .12s;
 background:var(--bg);border-radius:6px;z-index:2}
.mk:hover .acts,.mp-head:hover .acts{opacity:1}
.mp.dragging .acts{opacity:0}
.acts button{width:16px;height:16px;border:none;background:none;color:var(--sub);cursor:pointer;padding:0;
 display:flex;align-items:center;justify-content:center;font-size:13px;line-height:1;border-radius:4px}
.acts button:hover{color:var(--ink);background:rgba(0,0,0,.07)}
.acts svg{width:10px;height:10px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
.mp-head .acts{top:50%;margin-top:-8px}
body.dragging-card,body.dragging-card *{cursor:grabbing!important;-webkit-user-select:none!important;user-select:none!important}
.list.hide{display:none}
</style></head><body>
<div class="note" id="note">
 <div class="head" id="head">
  <div class="title" id="title">To Do</div>
  <button class="btn" id="bColor" title="Color" style="width:auto;padding:0 5px;font-size:11px;font-weight:700;letter-spacing:.2px;opacity:.75">Col</button>
  <button class="btn" id="bPin" title="Pin"><svg viewBox="0 0 16 16"><path d="M9.5 1.8l4.7 4.7-2 .6-2.3 2.8.2 2.6-1 1-3-3-4 4M7 5.2l3-3"/></svg></button>
  <button class="btn" id="bMap" title="Switch To Do / Map"></button>
  <button class="btn" id="bAdd" title="Add"><svg viewBox="0 0 16 16"><path d="M8 2.5v11M2.5 8h11"/></svg></button>
  <button class="btn" id="bClose" title="Close"><svg viewBox="0 0 16 16"><path d="M3.5 3.5l9 9M12.5 3.5l-9 9"/></svg></button>
 </div>
 <div class="sw" id="sw"></div>
 <ul class="list" id="list"></ul>
 <div class="map" id="map">
  <svg class="map-lines" id="mapLines"></svg>
  <div class="map-stage" id="mapStage"></div>
 </div>
 <div class="grip" id="grip"></div>
 <div class="fx" id="fx"></div>
</div>
<script>
const COLORS=[
 {id:"white",bg:"#FAFAFA",ink:"#222222"},{id:"yellow",bg:"#FFF6C8",ink:"#2a2a2a"},
 {id:"mint",bg:"#D8F3DC",ink:"#1b4332"},{id:"sky",bg:"#D6EAF8",ink:"#1b3a4b"},
 {id:"peach",bg:"#FFE0C8",ink:"#4a2c14"},{id:"lilac",bg:"#E8DFF5",ink:"#3b2a4a"},
 {id:"rose",bg:"#F8D7DA",ink:"#4a1c24"},{id:"night",bg:"#2B2B2E",ink:"#EDEDED"}];
const isWin=/Win/i.test(navigator.userAgent||"")||(window.__PLATFORM__==="win");
let S=window.__INIT__||{color:"white",pin:false,opacity:1,items:[],mode:"list",map:{projects:[]}};
S.color=S.color||"white";S.items=S.items||[];
if(typeof S.opacity!=="number")S.opacity=1;
if(S.mode!=="map")S.mode="list";
if(!S.map||typeof S.map!=="object")S.map={projects:[]};
if(!Array.isArray(S.map.projects))S.map.projects=[];
const post=m=>{try{window.webkit.messageHandlers.app.postMessage(m);}catch(e){try{window.pywebview.api.msg(JSON.stringify(m));}catch(e2){}}};
const save=()=>post({type:"save",json:JSON.stringify(S)});
const uid=()=>Date.now().toString(36)+Math.random().toString(36).slice(2,6);
let pending=null,openReveal=null,mapFocus=null,mapCascade=0;

function tsFromId(id){
 if(!id)return null;
 const m=String(id).match(/^[0-9a-z]+/i);
 if(!m)return null;
 const n=parseInt(m[0],36);
 return Number.isFinite(n)&&n>1e12&&n<4e12?n:null;
}
function ensureCreated(it){
 if(!it.createdAt){it.createdAt=tsFromId(it.id)||Date.now();}
 return it.createdAt;
}
function fmtTime(ts){
 if(!ts)return "—";
 const d=new Date(ts);
 if(isNaN(d.getTime()))return "—";
 const p=n=>String(n).padStart(2,"0");
 return `${p(d.getMonth()+1)}-${p(d.getDate())}\n${p(d.getHours())}:${p(d.getMinutes())}`;
}
function color(id){
 const c=COLORS.find(x=>x.id===id)||COLORS[0];S.color=c.id;
 const r=document.documentElement.style;
 r.setProperty("--bg",c.bg);r.setProperty("--ink",c.ink);
 const dark=c.id==="night";
 r.setProperty("--sub",dark?"rgba(255,255,255,.4)":"rgba(0,0,0,.38)");
 r.setProperty("--line",dark?"rgba(255,255,255,.14)":"rgba(0,0,0,.1)");
 r.setProperty("--time",dark?"rgba(255,255,255,.35)":"#A8A8A8");
 r.setProperty("--box",dark?"rgba(255,255,255,.35)":"rgba(0,0,0,.35)");
 document.querySelectorAll(".sw i").forEach(e=>e.classList.toggle("act",e.dataset.id===c.id));
 if(S.mode==="map")requestAnimationFrame(drawMapLines);
}
function ordered(){return S.items.filter(x=>!x.done).concat(S.items.filter(x=>x.done));}
function fireworks(el){
 const fx=document.getElementById("fx"),r=el.getBoundingClientRect(),nr=document.getElementById("note").getBoundingClientRect();
 const cx=r.left-nr.left+20,cy=r.top-nr.top+10,chars=["✦","✧","★","·","*"];
 for(let i=0;i<10;i++){
  const s=document.createElement("span");s.className="star";s.textContent=chars[i%chars.length];
  const ang=Math.random()*Math.PI*2,dist=18+Math.random()*36;
  s.style.left=cx+"px";s.style.top=cy+"px";
  s.style.setProperty("--dx",(Math.cos(ang)*dist)+"px");
  s.style.setProperty("--dy",(Math.sin(ang)*dist-10)+"px");
  s.style.setProperty("--rot",(Math.random()*180-90)+"deg");
  s.style.color=["#F5C542","#FF8FAB","#7BDFF2","#B5E48C","#C77DFF"][i%5];
  fx.appendChild(s);setTimeout(()=>s.remove(),720);
 }
}
function closeReveals(except){
 document.querySelectorAll(".it.reveal").forEach(el=>{if(el!==except)el.classList.remove("reveal");});
 if(except)openReveal=except; else openReveal=null;
}

/* ========== LIST MODE (unchanged behavior) ========== */
function render(focusId){
 const ul=document.getElementById("list");
 const oldTop={};ul.querySelectorAll(".it").forEach(e=>{oldTop[e.dataset.id]=e.getBoundingClientRect().top;});
 const keepScroll=ul.scrollTop;
 ul.innerHTML="";
 const items=ordered();let inserted=false;
 items.forEach(it=>{
  ul.appendChild(row(it,false));
  if(pending&&pending._after===it.id){ul.appendChild(row(pending,true));inserted=true;}
 });
 if(pending&&!inserted)ul.appendChild(row(pending,true));
 if(pending){requestAnimationFrame(()=>{const li=[...ul.querySelectorAll(".it")].find(e=>e.dataset.id===pending.id);
  const t=li&&li.querySelector(".tx");t&&t.focus();if(li)li.scrollIntoView({block:"nearest"});});}
 else if(!S.items.length){const d=document.createElement("div");d.className="empty";d.textContent="Tap + to add";ul.appendChild(d);}
 ul.scrollTop=keepScroll;
 const moved=[];
 ul.querySelectorAll(".it").forEach(e=>{
  const o=oldTop[e.dataset.id];if(o===undefined)return;
  const dy=o-e.getBoundingClientRect().top;
  if(Math.abs(dy)>1){e.style.transition="none";e.style.transform=`translateY(${dy}px)`;e.style.position="relative";e.style.zIndex=e.classList.contains("done")?"2":"1";moved.push(e);}
 });
 if(moved.length){
  void ul.offsetHeight;
  requestAnimationFrame(()=>moved.forEach(e=>{
   e.style.transition="transform .55s cubic-bezier(.22,.8,.2,1)";e.style.transform="";
   setTimeout(()=>{e.style.transition="";e.style.zIndex="";},600);
  }));
 }
 if(focusId){requestAnimationFrame(()=>{const el=[...ul.querySelectorAll(".it")].find(e=>e.dataset.id===focusId);
  const t=el&&el.querySelector(".tx");t&&t.focus();});}
}
function isCaretAtStart(el){
 const s=window.getSelection();if(!s||!s.rangeCount)return false;
 const r=s.getRangeAt(0);if(!r.collapsed)return false;
 const pre=document.createRange();pre.selectNodeContents(el);pre.setEnd(r.startContainer,r.startOffset);
 return pre.toString().length===0;
}
function insertAtCaret(text){
 const sel=window.getSelection();if(!sel||!sel.rangeCount)return;
 const r=sel.getRangeAt(0);r.deleteContents();
 const n=document.createTextNode(text);r.insertNode(n);
 r.setStartAfter(n);r.collapse(true);sel.removeAllRanges();sel.addRange(r);
 const li=n.parentNode&&n.parentNode.closest&&n.parentNode.closest(".it");if(li)li.scrollIntoView({block:"nearest"});
}
function caretInfo(tx){
 const sel=window.getSelection();if(!sel||!sel.rangeCount||!tx.contains(sel.anchorNode))return null;
 const r=sel.getRangeAt(0);const pre=document.createRange();pre.selectNodeContents(tx);pre.setEnd(r.startContainer,r.startOffset);
 const before=pre.toString();return {pos:before.length,line:(before.match(/\n/g)||[]).length};
}
function addAtCaret(){
 const tx=document.activeElement&&document.activeElement.classList&&document.activeElement.classList.contains("tx")?document.activeElement:null;
 if(!tx){if(!pending)pending={id:uid(),text:"",done:false,createdAt:Date.now()};render();return;}
 const li=tx.closest(".it"),id=li.dataset.id,info=caretInfo(tx);
 const full=tx.textContent.replace(/\u00a0/g," ");
 const isPending=pending&&pending.id===id;
 tx.blur();
 if(isPending){pending={id:uid(),text:"",done:false,createdAt:Date.now()};render();return;}
 const it=S.items.find(x=>x.id===id);if(!it){render();return;}
 const lines=full.split("\n");const idx=info?info.line:0;
 if(idx>0){
  const keep=lines.slice(0,idx).join("\n").replace(/\s+$/,"");
  const rest=lines.slice(idx).join("\n");
  it.text=keep||it.text;
  if(rest.trim()){
   const ni={id:uid(),text:rest.replace(/\s+$/,""),done:false,createdAt:Date.now()};
   S.items.splice(S.items.indexOf(it)+1,0,ni);save();render(ni.id);
   requestAnimationFrame(()=>requestAnimationFrame(()=>{const el=[...document.querySelectorAll(".it")].find(e=>e.dataset.id===ni.id);
    const t=el&&el.querySelector(".tx");if(!t)return;const rg=document.createRange();rg.setStart(t.firstChild||t,0);rg.collapse(true);
    const sl=window.getSelection();sl.removeAllRanges();sl.addRange(rg);}));
   return;
  }
  save();
 }
 pending={id:uid(),text:"",done:false,createdAt:Date.now(),_after:id};render();
}
function row(it,isNew){
 const li=document.createElement("li");li.className="it"+(it.done?" done":"");li.dataset.id=it.id;
 const reveal=document.createElement("div");reveal.className="reveal";ensureCreated(it);reveal.textContent=fmtTime(it.createdAt);
 const inner=document.createElement("div");inner.className="inner";
 const ck=document.createElement("div");ck.className="ck";
 ck.innerHTML='<svg viewBox="0 0 10 10"><path d="M2 5.3l2.2 2.2L8 3"/></svg>';
 ck.onclick=()=>{if(isNew)return;const was=!it.done;it.done=was;li.classList.toggle("done",was);if(was)fireworks(li);save();setTimeout(()=>render(),was?420:80);};
 const tx=document.createElement("div");tx.className="tx";tx.contentEditable="true";tx.spellcheck=false;tx.textContent=it.text||"";
 let finished=false;
 const commit=(again)=>{
  if(finished)return;finished=true;
  const v=tx.textContent.replace(/\u00a0/g," ").replace(/\s+$/,"");
  if(isNew){
   pending=null;
   if(v.trim()){it.text=v;it.createdAt=it.createdAt||Date.now();delete it._after;S.items.push(it);save();}
   if(again&&v.trim())pending={id:uid(),text:"",done:false,createdAt:Date.now()};
   render();
  }else{
   if(!v.trim()){S.items=S.items.filter(x=>x.id!==it.id);save();render();}
   else if(v!==it.text){it.text=v;save();}
  }
 };
 tx.onkeydown=e=>{
  if(e.key==="Enter"&&!e.isComposing){
   e.preventDefault();
   if(!tx.textContent.trim())return;
   insertAtCaret("\n");return;
  }
  if(e.key==="Escape"){e.preventDefault();if(isNew){finished=true;pending=null;render();}else tx.blur();return;}
  if((e.key==="Backspace"||e.key==="Delete")&&!e.isComposing&&isCaretAtStart(tx)){
   if(isNew){
    e.preventDefault();finished=true;pending=null;
    const open=S.items.filter(x=>!x.done);const prev=open[open.length-1];
    if(prev){
     const add=tx.textContent||"";
     prev.text=(prev.text||"")+(prev.text?"\n":"")+add;save();render(prev.id);
     requestAnimationFrame(()=>{const el=[...document.querySelectorAll(".it")].find(e=>e.dataset.id===prev.id);
      const t=el&&el.querySelector(".tx");if(!t)return;const r=document.createRange();r.selectNodeContents(t);r.collapse(false);
      const s=window.getSelection();s.removeAllRanges();s.addRange(r);});
    }else render();
    return;
   }
   if(!tx.textContent){
    e.preventDefault();
    const seq=ordered();const openIdx=seq.findIndex(x=>x.id===it.id);
    if(openIdx>0&&!it.done&&!seq[openIdx-1].done){
     const prev=seq[openIdx-1];
     S.items=S.items.filter(x=>x.id!==it.id);save();render(prev.id);
     requestAnimationFrame(()=>{const el=[...document.querySelectorAll(".it")].find(e=>e.dataset.id===prev.id);
      const t=el&&el.querySelector(".tx");if(!t)return;const r=document.createRange();r.selectNodeContents(t);r.collapse(false);
      const s=window.getSelection();s.removeAllRanges();s.addRange(r);});
    }
   }
  }
 };
 tx.addEventListener("paste",e=>{e.preventDefault();const t=(e.clipboardData||window.clipboardData).getData("text/plain");if(t)insertAtCaret(t.replace(/\r\n?/g,"\n"));});
 tx.onblur=()=>commit(false);
 tx.addEventListener("pointerdown",e=>e.stopPropagation());

 let sx=0,sy=0,tracking=false,axis=null,base=0;
 const onDown=e=>{
  if(e.target.closest(".ck")||e.target.closest(".x")||e.target.closest(".tx"))return;
  tracking=true;axis=null;sx=e.clientX;sy=e.clientY;
  base=li.classList.contains("reveal")?-92:0;
  li.classList.add("dragging");
  try{li.setPointerCapture(e.pointerId);}catch(_){}
 };
 const onMove=e=>{
  if(!tracking)return;
  const dx=e.clientX-sx,dy=e.clientY-sy;
  if(!axis){if(Math.abs(dx)<6&&Math.abs(dy)<6)return;axis=Math.abs(dx)>Math.abs(dy)?"x":"y";}
  if(axis!=="x")return;
  e.preventDefault();
  let x=base+dx;if(x>0)x=0;if(x<-92)x=-92;
  inner.style.transform=`translateX(${x}px)`;
 };
 const onUp=()=>{
  if(!tracking)return;tracking=false;li.classList.remove("dragging");
  const m=inner.style.transform.match(/translateX\((-?\d+(?:\.\d+)?)px\)/);
  const x=m?parseFloat(m[1]):0;
  inner.style.transform="";
  if(x<-46){closeReveals(li);li.classList.add("reveal");}
  else{li.classList.remove("reveal");if(openReveal===li)openReveal=null;}
 };
 li.addEventListener("pointerdown",onDown);
 li.addEventListener("pointermove",onMove);
 li.addEventListener("pointerup",onUp);
 li.addEventListener("pointercancel",onUp);

 const x=document.createElement("button");x.className="x";x.textContent="×";
 x.onmousedown=e=>e.preventDefault();
 x.onclick=()=>{S.items=S.items.filter(i=>i.id!==it.id);if(isNew)pending=null;save();render();};
 inner.append(ck,tx,x);li.append(reveal,inner);return li;
}
document.getElementById("list").addEventListener("pointerdown",e=>{
 if(!e.target.closest(".it"))closeReveals(null);
});

/* ========== MAP MODE ========== */
const PCOLORS=[
 {id:"def"},
 {id:"white",bg:"#FFFFFF",bd:"rgba(0,0,0,.28)",ink:"#222222"},
 {id:"cream",bg:"#FFF3C4",bd:"#E6CF85",ink:"#3a3320"},
 {id:"pink",bg:"#FBDDE2",bd:"#E8A9B4",ink:"#4a1c24"},
 {id:"mint",bg:"#D8F3DC",bd:"#98CFA4",ink:"#1b4332"},
 {id:"blue",bg:"#D6EAF8",bd:"#92BEDC",ink:"#1b3a4b"},
 {id:"lavender",bg:"#E8DFF5",bd:"#BBA6DC",ink:"#3b2a4a"},
 {id:"night",bg:"#2B2B2E",bd:"#5a5a60",ink:"#EDEDED"}];
const MAXDEPTH=5;
let rendering=false;
const textOf=el=>(el.textContent||"").replace(/\u00a0/g," ").replace(/\u200b/g,"").replace(/\s+$/,"");
function pcolor(p){return PCOLORS.find(c=>c.id===p.color)||PCOLORS[0];}
function applyPColor(p,title,chip){
 const c=pcolor(p),st=title.style;
 if(c.bg){st.setProperty("--tb",c.bg);st.setProperty("--tbd",c.bd);st.setProperty("--tink",c.ink);}
 else{st.removeProperty("--tb");st.removeProperty("--tbd");st.removeProperty("--tink");}
 if(chip){
  if(c.bg){chip.style.setProperty("--cb",c.bg);chip.style.setProperty("--cbd",c.bd);}
  else{chip.style.removeProperty("--cb");chip.style.removeProperty("--cbd");}
 }
}
function ensureNode(n){
 ensureCreated(n);
 if(n.children!==undefined&&!Array.isArray(n.children))n.children=[];
 (n.children||[]).forEach(ensureNode);
}
function ensureMap(){
 if(!S.map)S.map={projects:[]};
 if(!Array.isArray(S.map.projects))S.map.projects=[];
 S.map.projects.forEach(p=>{
  if(typeof p.x!=="number")p.x=24;
  if(typeof p.y!=="number")p.y=24;
  if(!Array.isArray(p.children))p.children=[];
  ensureCreated(p);
  p.children.forEach(ensureNode);
 });
}
function findProject(id){return S.map.projects.find(p=>p.id===id);}
function searchNodes(arr,p,parent,depth,id){
 for(let i=0;i<arr.length;i++){
  const n=arr[i];
  if(n.id===id)return {p,arr,parent,idx:i,node:n,depth};
  if(n.children&&n.children.length){const r=searchNodes(n.children,p,n,depth+1,id);if(r)return r;}
 }
 return null;
}
function locate(id){
 for(const p of S.map.projects){const r=searchNodes(p.children,p,null,1,id);if(r)return r;}
 return null;
}
function newNode(){return {id:uid(),text:"",done:false,createdAt:Date.now()};}
function setMode(mode){
 S.mode=mode==="map"?"map":"list";
 const list=document.getElementById("list");
 const map=document.getElementById("map");
 const bMap=document.getElementById("bMap");
 const title=document.getElementById("title");
 const isMap=S.mode==="map";
 list.classList.toggle("hide",isMap);
 map.classList.toggle("show",isMap);
 bMap.classList.toggle("on",isMap);
 bMap.innerHTML=isMap?'<svg viewBox="0 0 16 16"><circle cx="2.8" cy="4" r="1.1"/><circle cx="2.8" cy="8" r="1.1"/><circle cx="2.8" cy="12" r="1.1"/><path d="M6.5 4H14M6.5 8H14M6.5 12H14"/></svg>':'<svg viewBox="0 0 16 16"><rect x="1.5" y="5.6" width="5" height="4.8" rx="1.4"/><rect x="10.5" y="1.6" width="4" height="3.4" rx="1.1"/><rect x="10.5" y="11" width="4" height="3.4" rx="1.1"/><path d="M6.5 8H8.5M8.5 3.3V12.7M8.5 3.3H10.5M8.5 12.7H10.5"/></svg>';
 bMap.title=isMap?'Switch to list':'Switch to mind map';
 title.textContent=isMap?"Map":"To Do";
 if(isMap){ensureMap();renderMap();}
 else render();
 save();
}
/* new root project box, cascaded below existing ones (or at x,y when given) */
function mapAddProject(px,py){
 ensureMap();
 const map=document.getElementById("map");
 let x,y;
 if(typeof px==="number"){x=Math.max(0,px);y=Math.max(0,py);}
 else{
  let bottom=0;const mps=document.querySelectorAll("#mapStage .mp");
  mps.forEach(m=>{bottom=Math.max(bottom,m.offsetTop+m.offsetHeight);});
  x=24+(map.scrollLeft||0)+(S.map.projects.length%3)*16;
  y=mps.length?bottom+14:20+(map.scrollTop||0);
 }
 const p={id:uid(),title:"",x,y,createdAt:Date.now(),children:[]};
 S.map.projects.push(p);save();renderMap(p.id,null);
}
function mapAddProjectChild(pid){
 const p=findProject(pid);if(!p)return;
 const k=newNode();p.children.push(k);save();renderMap(null,k.id);
}
function mapAddSibling(id){
 const loc=locate(id);if(!loc)return;
 const k=newNode();loc.arr.splice(loc.idx+1,0,k);save();renderMap(null,k.id);
}
function mapAddSub(id){
 const loc=locate(id);if(!loc||loc.depth>=MAXDEPTH)return;
 const k=newNode();
 if(!Array.isArray(loc.node.children))loc.node.children=[];
 loc.node.children.push(k);save();renderMap(null,k.id);
}
function mapOutdent(id){
 const loc=locate(id);if(!loc||!loc.parent)return;
 const pl=locate(loc.parent.id);if(!pl)return;
 loc.arr.splice(loc.idx,1);
 pl.arr.splice(pl.idx+1,0,loc.node);
 save();renderMap(null,loc.node.id);
}
function mapOnAdd(){
 const ae=document.activeElement;
 if(ae&&ae.classList){
  if(ae.classList.contains("tx")&&ae.closest(".mk")){
   if(!textOf(ae))return;
   if(ae._commit)ae._commit();
   mapAddSibling(ae.closest(".mk").dataset.id);return;
  }
  if(ae.classList.contains("mp-title")){
   const p=findProject(ae.closest(".mp").dataset.id);
   if(p&&!textOf(ae)&&!p.children.length)return;
   ae.blur();mapAddProject();return;
  }
 }
 mapAddProject();
}
function drawMapLines(){
 const svg=document.getElementById("mapLines");
 const stage=document.getElementById("mapStage");
 if(!svg||!stage)return;
 let maxW=stage.parentElement.clientWidth||400,maxH=stage.parentElement.clientHeight||300;
 const sr=stage.getBoundingClientRect();
 const out=[];
 const link=(x1,y1,mn,depth)=>{
  const mk=mn.children[0];if(!mk)return;
  const kr=mk.getBoundingClientRect();
  const x2=kr.left-sr.left,y2=kr.top-sr.top+10;
  const mid=(x1+x2)/2;
  out.push({d:`M${x1},${y1} C${mid},${y1} ${mid},${y2} ${x2},${y2}`,depth});
  const sub=mn.children[1];
  if(sub)[...sub.children].forEach(c=>link(kr.right-sr.left+2,y2,c,depth+1));
 };
 stage.querySelectorAll(".mp").forEach(mp=>{
  const title=mp.querySelector(".mp-title"),kids=mp.querySelector(".mp-kids");
  if(!title)return;
  const tr=title.getBoundingClientRect();
  if(kids)[...kids.children].forEach(mn=>link(tr.right-sr.left+1,tr.top-sr.top+tr.height/2,mn,1));
  maxW=Math.max(maxW,mp.offsetLeft+mp.offsetWidth+70);
  maxH=Math.max(maxH,mp.offsetTop+mp.offsetHeight+40);
 });
 svg.setAttribute("width",Math.ceil(maxW));svg.setAttribute("height",Math.ceil(maxH));
 svg.style.width=Math.ceil(maxW)+"px";svg.style.height=Math.ceil(maxH)+"px";
 stage.style.minWidth=Math.ceil(maxW)+"px";stage.style.minHeight=Math.ceil(maxH)+"px";
 const ink=getComputedStyle(document.documentElement).getPropertyValue("--ink").trim()||"#222";
 const stroke=ink.startsWith("#")?ink:"#222";
 svg.innerHTML=out.map(o=>{
  const op=o.depth<=1?.3:o.depth===2?.2:.14,w=o.depth<=1?1.2:1;
  return `<path d="${o.d}" fill="none" stroke="${stroke}" stroke-opacity="${op}" stroke-width="${w}"/>`;
 }).join("");
}
function focusEditable(el){
 if(!el)return;
 requestAnimationFrame(()=>{
  el.focus();
  try{
   const r=document.createRange();r.selectNodeContents(el);r.collapse(false);
   const s=window.getSelection();s.removeAllRanges();s.addRange(r);
  }catch(_){}
 });
}
const ARROW='<svg viewBox="0 0 12 12"><path d="M2.5 6h7M6.5 3l3 3-3 3"/></svg>';
function buildNode(n,depth,p){
 const mn=document.createElement("div");mn.className="mn";mn.dataset.depth=depth;mn.dataset.nid=n.id;
 const mk=document.createElement("div");mk.className="mk"+(n.done?" done":"");mk.dataset.id=n.id;
 const ck=document.createElement("div");ck.className="ck";
 ck.innerHTML='<svg viewBox="0 0 10 10"><path d="M2 5.3l2.2 2.2L8 3"/></svg>';
 ck.onclick=()=>{n.done=!n.done;mk.classList.toggle("done",n.done);if(n.done)fireworks(mk);save();};
 const tx=document.createElement("div");tx.className="tx";tx.contentEditable="true";tx.spellcheck=false;
 tx.textContent=n.text||"";
 tx._commit=()=>{const v=textOf(tx);if(v&&v!==n.text){n.text=v;save();}};
 tx.onblur=()=>{
  if(rendering)return;
  const v=textOf(tx);
  if(v){if(v!==(n.text||"")){n.text=v;save();}return;}
  setTimeout(()=>{
   const loc=locate(n.id);if(!loc)return;
   const live=document.querySelector('.mk[data-id="'+n.id+'"] .tx');
   if(live&&document.activeElement===live)return;
   const cur=textOf(live||tx);
   if(cur){loc.node.text=cur;save();return;}
   if(loc.node.children&&loc.node.children.length)return;
   loc.arr.splice(loc.idx,1);save();
   const el=document.querySelector('.mn[data-nid="'+n.id+'"]');if(el)el.remove();
   drawMapLines();
  },120);
 };
 tx.onkeydown=e=>{
  if(e.isComposing)return;
  if(e.key==="Enter"){
   e.preventDefault();
   if(!textOf(tx))return;
   tx._commit();mapAddSibling(n.id);return;
  }
  if(e.key==="Tab"){
   e.preventDefault();
   if(e.shiftKey){tx._commit();mapOutdent(n.id);return;}
   if(!textOf(tx))return;
   tx._commit();mapAddSub(n.id);return;
  }
  if(e.key==="Escape"){e.preventDefault();tx.blur();return;}
  if((e.key==="Backspace"||e.key==="Delete")&&!textOf(tx)){
   const loc=locate(n.id);if(!loc)return;
   if(loc.node.children&&loc.node.children.length)return;
   e.preventDefault();
   loc.arr.splice(loc.idx,1);save();
   if(loc.idx>0)renderMap(null,loc.arr[loc.idx-1].id);
   else if(loc.parent)renderMap(null,loc.parent.id);
   else renderMap(loc.p.id,null);
  }
 };
 tx.addEventListener("paste",e=>{
  e.preventDefault();
  const t=(e.clipboardData||window.clipboardData).getData("text/plain");
  if(t)document.execCommand("insertText",false,t.replace(/\r\n?/g,"\n"));
 });
 tx.addEventListener("pointerdown",e=>e.stopPropagation());
 const acts=document.createElement("div");acts.className="acts";
 if(depth<MAXDEPTH){
  const ad=document.createElement("button");ad.title="Add sub-item";ad.innerHTML=ARROW;
  ad.onmousedown=e=>e.preventDefault();
  ad.onclick=e=>{e.stopPropagation();if(textOf(tx))tx._commit();mapAddSub(n.id);};
  acts.appendChild(ad);
 }
 const x=document.createElement("button");x.title="Delete";x.textContent="×";
 x.onmousedown=e=>e.preventDefault();
 x.onclick=e=>{e.stopPropagation();const loc=locate(n.id);if(!loc)return;loc.arr.splice(loc.idx,1);save();renderMap();};
 acts.appendChild(x);
 mk.append(ck,tx,acts);mn.appendChild(mk);
 if(n.children&&n.children.length){
  const kc=document.createElement("div");kc.className="mn-kids";
  n.children.forEach(c=>kc.appendChild(buildNode(c,depth+1,p)));
  mn.appendChild(kc);
 }
 return mn;
}
function renderMap(focusProjectId,focusNodeId){
 ensureMap();
 const stage=document.getElementById("mapStage");
 const map=document.getElementById("map");
 const ae=document.activeElement;
 if(ae&&ae._commit)ae._commit();
 rendering=true;
 stage.innerHTML="";
 let emptyEl=map.querySelector(".map-empty");
 if(!S.map.projects.length){
  if(!emptyEl){emptyEl=document.createElement("div");emptyEl.className="map-empty";map.appendChild(emptyEl);}
  emptyEl.textContent="Tap + to add a project";
 }else if(emptyEl)emptyEl.remove();

 S.map.projects.forEach(p=>{
  const mp=document.createElement("div");
  mp.className="mp";mp.dataset.id=p.id;
  mp.style.left=(p.x||0)+"px";mp.style.top=(p.y||0)+"px";

  const title=document.createElement("div");
  title.className="mp-title";title.contentEditable="true";title.spellcheck=false;
  title.textContent=p.title||"";
  title._commit=()=>{const v=textOf(title);if(v&&v!==(p.title||"")){p.title=v;save();}};

  const chip=document.createElement("button");chip.className="mp-col";
  const pal=document.createElement("div");pal.className="mp-pal";
  const palIn=document.createElement("i");pal.appendChild(palIn);
  const paintPal=()=>{[...palIn.children].forEach((d,i)=>d.classList.toggle("sel",PCOLORS[i].id===(p.color||"def")));};
  PCOLORS.forEach(c=>{
   const d=document.createElement("b");d.title="Project color";
   d.style.background=c.bg||"var(--bg)";d.style.borderColor=c.bd||"rgba(0,0,0,.25)";
   if(!c.bg)d.style.backgroundImage="linear-gradient(135deg,transparent 45%,#e55 45%,#e55 55%,transparent 55%)";
   d.onmousedown=e=>{e.preventDefault();e.stopPropagation();};
   d.onpointerdown=e=>e.stopPropagation();
   d.onclick=e=>{e.stopPropagation();if(c.id==="def")delete p.color;else p.color=c.id;applyPColor(p,title,chip);paintPal();save();};
   palIn.appendChild(d);
  });
  paintPal();
  applyPColor(p,title,chip);

  const delP=document.createElement("button");delP.className="mp-x";delP.textContent="×";
  delP.onmousedown=e=>e.preventDefault();
  delP.onclick=e=>{e.stopPropagation();S.map.projects=S.map.projects.filter(x=>x.id!==p.id);save();renderMap();};

  const pacts=document.createElement("div");pacts.className="acts";
  const pad=document.createElement("button");pad.title="Add sub-item";pad.innerHTML=ARROW;
  pad.onmousedown=e=>e.preventDefault();
  pad.onclick=e=>{e.stopPropagation();title._commit();mapAddProjectChild(p.id);};
  pacts.appendChild(pad);

  title.onblur=()=>{
   if(rendering)return;
   const v=textOf(title);
   if(!v&&!p.children.length){
    S.map.projects=S.map.projects.filter(x=>x.id!==p.id);save();renderMap();return;
   }
   if(v!==(p.title||"")){p.title=v;save();}
  };
  title.onkeydown=e=>{
   if(e.isComposing)return;
   if(e.key==="Enter"||e.key==="Tab"){
    e.preventDefault();
    if(!textOf(title)&&!p.children.length)return;
    title._commit();mapAddProjectChild(p.id);return;
   }
   if(e.key==="Escape"){e.preventDefault();title.blur();return;}
   if((e.key==="Backspace"||e.key==="Delete")&&!textOf(title)&&!p.children.length){
    e.preventDefault();
    S.map.projects=S.map.projects.filter(x=>x.id!==p.id);save();renderMap();
   }
  };
  title.addEventListener("paste",e=>{
   e.preventDefault();
   const t=(e.clipboardData||window.clipboardData).getData("text/plain");
   if(t)document.execCommand("insertText",false,t.replace(/\s*\r?\n\s*/g," "));
  });

  /* drag: grab on press, grabbing from the first move until release */
  title.addEventListener("pointerdown",e=>{
   if(e.button!=null&&e.button!==0)return;
   const sx=e.clientX,sy=e.clientY,ox=p.x,oy=p.y,pid=e.pointerId;
   let moved=false;
   title.classList.add("press");
   const onMove=ev=>{
    const dx=ev.clientX-sx,dy=ev.clientY-sy;
    if(!moved&&Math.hypot(dx,dy)<5)return;
    if(!moved){
     moved=true;mp.classList.add("dragging");document.body.classList.add("dragging-card");
     try{title.blur();}catch(_){}
     try{window.getSelection().removeAllRanges();}catch(_){}
     try{title.setPointerCapture(pid);}catch(_){}
    }
    ev.preventDefault();
    p.x=Math.max(0,ox+dx);p.y=Math.max(0,oy+dy);
    mp.style.left=p.x+"px";mp.style.top=p.y+"px";
    drawMapLines();
   };
   const onUp=()=>{
    title.removeEventListener("pointermove",onMove);
    title.removeEventListener("pointerup",onUp);
    title.removeEventListener("pointercancel",onUp);
    title.classList.remove("press");
    document.body.classList.remove("dragging-card");
    try{title.releasePointerCapture(pid);}catch(_){}
    if(moved){mp.classList.remove("dragging");save();drawMapLines();}
   };
   title.addEventListener("pointermove",onMove);
   title.addEventListener("pointerup",onUp);
   title.addEventListener("pointercancel",onUp);
  });

  const head=document.createElement("div");head.className="mp-head";
  head.append(title,chip,delP,pacts,pal);
  mp.appendChild(head);
  if(p.children.length){
   const kids=document.createElement("div");kids.className="mp-kids";
   p.children.forEach(k=>kids.appendChild(buildNode(k,1,p)));
   mp.appendChild(kids);
  }
  stage.appendChild(mp);
 });
 rendering=false;

 requestAnimationFrame(()=>{
  drawMapLines();
  if(focusNodeId)focusEditable(stage.querySelector('.mk[data-id="'+focusNodeId+'"] .tx'));
  else if(focusProjectId)focusEditable(stage.querySelector('.mp[data-id="'+focusProjectId+'"] .mp-title'));
 });
}

// pan empty canvas; double-click empty canvas = new root project box there
(function(){
 const map=document.getElementById("map");
 let pan=null;
 map.addEventListener("pointerdown",e=>{
  if(e.target.closest(".mp"))return;
  if(e.button!=null&&e.button!==0)return;
  const a=document.activeElement;if(a&&a.isContentEditable)a.blur();
  pan={x:e.clientX,y:e.clientY,sl:map.scrollLeft,st:map.scrollTop};
  try{map.setPointerCapture(e.pointerId);}catch(_){}
 });
 map.addEventListener("pointermove",e=>{
  if(!pan)return;
  map.scrollLeft=pan.sl-(e.clientX-pan.x);
  map.scrollTop=pan.st-(e.clientY-pan.y);
 });
 map.addEventListener("pointerup",()=>{pan=null;});
 map.addEventListener("pointercancel",()=>{pan=null;});
 map.addEventListener("dblclick",e=>{
  if(e.target.closest(".mp"))return;
  const r=document.getElementById("mapStage").getBoundingClientRect();
  mapAddProject(e.clientX-r.left,e.clientY-r.top);
 });
})();

/* ========== chrome ========== */
const sw=document.getElementById("sw");
COLORS.forEach(c=>{const i=document.createElement("i");i.dataset.id=c.id;i.style.background=c.bg;
 i.onclick=()=>{color(c.id);save();};sw.appendChild(i);});
document.getElementById("bColor").onclick=()=>sw.classList.toggle("show");
document.getElementById("bAdd").onmousedown=e=>e.preventDefault();
document.getElementById("bAdd").onclick=()=>{
 if(S.mode==="map")mapOnAdd();
 else addAtCaret();
};
document.getElementById("bMap").onclick=()=>setMode(S.mode==="map"?"list":"map");
document.getElementById("bClose").onclick=()=>post({type:"close"});
const bPin=document.getElementById("bPin");
function setPin(on){S.pin=!!on;bPin.classList.toggle("on",S.pin);post({type:"pin",on:S.pin});save();}
bPin.onclick=()=>setPin(!S.pin);
bPin.classList.toggle("on",!!S.pin);
document.getElementById("head").addEventListener("mousedown",e=>{
 if(e.target.closest(".btn"))return;post({type:"drag"});});
const g=document.getElementById("grip");let rsx=0,rsy=0;
g.addEventListener("pointerdown",e=>{g.setPointerCapture(e.pointerId);rsx=e.screenX;rsy=e.screenY;post({type:"rs"});});
g.addEventListener("pointermove",e=>{if(!g.hasPointerCapture(e.pointerId))return;post({type:"r",dx:e.screenX-rsx,dy:e.screenY-rsy});});
g.addEventListener("pointerup",e=>{g.releasePointerCapture(e.pointerId);});

window.__native={
 togglePin:()=>setPin(!S.pin),
 applyOpacity:()=>{document.getElementById("note").style.opacity=S.opacity;post({type:"opacity",value:S.opacity});},
 opacityDelta:(d)=>{S.opacity=Math.min(1,Math.max(0.25,+(S.opacity+d).toFixed(2)));window.__native.applyOpacity();save();},
 setOpacity:(v)=>{S.opacity=Math.min(1,Math.max(0.25,+v));window.__native.applyOpacity();save();},
 add:()=>{if(S.mode==="map")mapOnAdd();else addAtCaret();}
};
window.addEventListener("keydown",e=>{
 const mod=isWin?e.altKey:e.metaKey;
 if(!mod)return;
 if(e.key==="f"||e.key==="F"){e.preventDefault();setPin(!S.pin);}
 if(e.key==="="||e.key==="+"){e.preventDefault();window.__native.opacityDelta(0.08);}
 if(e.key==="-"){e.preventDefault();window.__native.opacityDelta(-0.08);}
 if(e.key==="n"||e.key==="N"){e.preventDefault();window.__native.add();}
});
let swipeX=0,swipeTimer=null;
const MAXS=92;
function applySwipe(x,animate){
 if(S.mode==="map")return;
 swipeX=x;
 const list=document.getElementById("list");
 list.classList.toggle("swiping",!animate&&x>0);
 document.querySelectorAll(".it .inner").forEach(el=>{
  el.style.transition=animate?"transform .28s cubic-bezier(.2,.8,.2,1)":"none";
  el.style.transform=x>0?`translateX(${-x}px)`:"";
 });
}
window.addEventListener("wheel",e=>{
 const mod=isWin?e.altKey:e.metaKey;
 if(mod){e.preventDefault();window.__native.opacityDelta(e.deltaY>0?-0.04:0.04);return;}
 if(S.mode==="map")return;
 const ax=Math.abs(e.deltaX),ay=Math.abs(e.deltaY);
 if(ax>ay&&ax>0){
  e.preventDefault();
  let nx=swipeX-e.deltaX;
  if(nx<0)nx=0;
  if(nx>MAXS)nx=MAXS+(nx-MAXS)*0.15;
  if(nx>MAXS*1.25)nx=MAXS*1.25;
  applySwipe(nx,false);
  clearTimeout(swipeTimer);
  swipeTimer=setTimeout(()=>applySwipe(0,true),140);
 }
},{passive:false});

window.addEventListener("resize",()=>{if(S.mode==="map")drawMapLines();});

(S.items||[]).forEach(ensureCreated);
ensureMap();
save();
color(S.color);
if(S.mode==="map")setMode("map");
else{setMode("list");}
window.__native.applyOpacity();
post({type:"pin",on:!!S.pin});
</script></body></html>
"""#

class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler {
    var window: StickyWindow!
    var web: WKWebView!
    var startFrame = NSRect.zero
    let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("ToDoTie")
    var stateURL: URL { dir.appendingPathComponent("state.json") }

    func applicationDidFinishLaunching(_ n: Notification) {
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        var saved = (try? String(contentsOf: stateURL, encoding: .utf8)) ?? "null"
        if saved == "null" {
            saved = "{\"color\":\"white\",\"pin\":false,\"opacity\":1,\"items\":[]}"
        }
        var pin = false
        var opacity: Double = 1
        if let d = saved.data(using: .utf8), let o = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
            pin = (o["pin"] as? Bool) ?? false
            opacity = (o["opacity"] as? Double) ?? 1
        }

        let cfg = WKWebViewConfiguration()
        let uc = WKUserContentController()
        uc.add(self, name: "app")
        uc.addUserScript(WKUserScript(source: "window.__PLATFORM__='mac'; window.__INIT__ = \(saved);", injectionTime: .atDocumentStart, forMainFrameOnly: true))
        cfg.userContentController = uc

        window = StickyWindow(contentRect: NSRect(x: 0, y: 0, width: 340, height: 400),
                              styleMask: [.borderless, .resizable], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.minSize = NSSize(width: 200, height: 180)
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.level = pin ? .floating : .normal
        window.alphaValue = CGFloat(max(0.25, min(1, opacity)))
        window.isReleasedWhenClosed = false

        web = WKWebView(frame: window.contentView!.bounds, configuration: cfg)
        web.autoresizingMask = [.width, .height]
        web.setValue(false, forKey: "drawsBackground")
        window.contentView!.addSubview(web)
        web.loadHTMLString(html, baseURL: nil)

        if !window.setFrameUsingName("ToDoTieWindow") {
            if let s = NSScreen.main { window.setFrameTopLeftPoint(NSPoint(x: s.visibleFrame.maxX - 360, y: s.visibleFrame.maxY - 40)) }
        }
        window.setFrameAutosaveName("ToDoTieWindow")
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        setupMenu()
        NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] ev in
            guard let self = self, ev.modifierFlags.contains(.command) else { return ev }
            self.adjustOpacity(by: Double(ev.scrollingDeltaY) * 0.01)
            return nil
        }
    }

    @objc func togglePin(_ sender: Any?) {
        web.evaluateJavaScript("window.__native && window.__native.togglePin()", completionHandler: nil)
    }
    @objc func opacityUp(_ sender: Any?) { adjustOpacity(by: 0.08) }
    @objc func opacityDown(_ sender: Any?) { adjustOpacity(by: -0.08) }
    @objc func addItem(_ sender: Any?) {
        web.evaluateJavaScript("window.__native && window.__native.add()", completionHandler: nil)
    }

    func adjustOpacity(by d: Double) {
        let next = max(0.25, min(1.0, Double(window.alphaValue) + d))
        window.alphaValue = CGFloat(next)
        web.evaluateJavaScript("S.opacity=\(String(format: "%.2f", next));save();", completionHandler: nil)
    }

    func userContentController(_ c: WKUserContentController, didReceive m: WKScriptMessage) {
        guard let b = m.body as? [String: Any], let t = b["type"] as? String else { return }
        switch t {
        case "save":
            if let j = b["json"] as? String { try? j.write(to: stateURL, atomically: true, encoding: .utf8) }
        case "drag":
            if let e = NSApp.currentEvent { window.performDrag(with: e) }
        case "rs":
            startFrame = window.frame
        case "r":
            let dx = CGFloat((b["dx"] as? Double) ?? 0), dy = CGFloat((b["dy"] as? Double) ?? 0)
            var f = startFrame
            f.size.width = max(window.minSize.width, startFrame.width + dx)
            f.size.height = max(window.minSize.height, startFrame.height + dy)
            f.origin.y = startFrame.maxY - f.size.height
            window.setFrame(f, display: true)
        case "pin":
            window.level = ((b["on"] as? Bool) ?? false) ? .floating : .normal
        case "opacity":
            if let v = b["value"] as? Double { window.alphaValue = CGFloat(max(0.25, min(1, v))) }
        case "close":
            NSApp.terminate(nil)
        default: break
        }
    }

    func setupMenu() {
        let main = NSMenu()
        let appItem = NSMenuItem(); main.addItem(appItem)
        let appMenu = NSMenu(); appItem.submenu = appMenu
        appMenu.addItem(withTitle: "Quit Littodoo", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        let editItem = NSMenuItem(); main.addItem(editItem)
        let edit = NSMenu(title: "Edit"); editItem.submenu = edit
        edit.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        edit.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        edit.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        let viewItem = NSMenuItem(); main.addItem(viewItem)
        let view = NSMenu(title: "View"); viewItem.submenu = view
        let pin = NSMenuItem(title: "Pin on Top", action: #selector(togglePin(_:)), keyEquivalent: "f")
        pin.keyEquivalentModifierMask = [.command]
        view.addItem(pin)
        let up = NSMenuItem(title: "More Opaque", action: #selector(opacityUp(_:)), keyEquivalent: "=")
        up.keyEquivalentModifierMask = [.command]
        view.addItem(up)
        let up2 = NSMenuItem(title: "More Opaque+", action: #selector(opacityUp(_:)), keyEquivalent: "+")
        up2.keyEquivalentModifierMask = [.command]
        view.addItem(up2)
        let down = NSMenuItem(title: "More Transparent", action: #selector(opacityDown(_:)), keyEquivalent: "-")
        down.keyEquivalentModifierMask = [.command]
        view.addItem(down)
        let add = NSMenuItem(title: "Add", action: #selector(addItem(_:)), keyEquivalent: "n")
        add.keyEquivalentModifierMask = [.command]
        view.addItem(add)
        NSApp.mainMenu = main
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let del = AppDelegate()
app.delegate = del
app.run()
