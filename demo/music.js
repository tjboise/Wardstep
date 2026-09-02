'use strict';
// Wardstep — Music Module
// Track 0: 古堡守望 (Am, BPM 90)  — atmospheric castle watch
// Track 1: 征途     (Dm, BPM 112) — heroic march
// Track 2: 夜袭     (Cm, BPM 76)  — dark tension
// Track 3: 霜晨     (Em, BPM 68)  — ethereal calm

let _AC=null,_MG=null,_muted=false,_trackIdx=0,_schedIv=null,_drones=[];
let _hatBuf=null,_snareBuf=null;
const _NAMES=['古堡守望','征途','夜袭','霜晨'];

function audioInit(){
  if(_AC)return;
  try{
    _AC=new(window.AudioContext||window.webkitAudioContext)();
    if(_AC.state==='suspended')_AC.resume();
    _MG=_AC.createGain();_MG.gain.value=.55;_MG.connect(_AC.destination);
    _hatBuf=_AC.createBuffer(1,Math.floor(_AC.sampleRate*.065),_AC.sampleRate);
    {const d=_hatBuf.getChannelData(0);for(let i=0;i<d.length;i++)d[i]=Math.random()*2-1;}
    _snareBuf=_AC.createBuffer(1,Math.floor(_AC.sampleRate*.12),_AC.sampleRate);
    {const d=_snareBuf.getChannelData(0);for(let i=0;i<d.length;i++)d[i]=Math.random()*2-1;}
    _playTrack(0);
  }catch(e){}
}

function toggleMute(){
  if(!_AC)return;
  _muted=!_muted;
  _MG.gain.linearRampToValueAtTime(_muted?0:.55,_AC.currentTime+.5);
  document.getElementById('btn-mute').textContent=_muted?'🔇':'🔈';
}

function nextTrack(){
  if(!_AC)return;
  _killDrones();
  clearInterval(_schedIv);_schedIv=null;
  _trackIdx=(_trackIdx+1)%_NAMES.length;
  _playTrack(_trackIdx);
  const btn=document.getElementById('btn-track');
  if(btn){btn.textContent=_NAMES[_trackIdx];setTimeout(()=>{btn.textContent='♪';},2400);}
}

function _killDrones(){
  _drones.forEach(o=>{try{o.stop();}catch(_){}});
  _drones=[];
}

function _playTrack(idx){
  [_track0,_track1,_track2,_track3][idx]();
}

// ── Shared instrument helpers ──────────────────────────────────────────────

function _drone(f,dt,tp,vol,fc){
  const o=_AC.createOscillator(),g=_AC.createGain(),fl=_AC.createBiquadFilter();
  o.type=tp;o.frequency.value=f;o.detune.value=dt;
  fl.type='lowpass';fl.frequency.value=fc;fl.Q.value=1.4;
  g.gain.value=vol;o.connect(fl);fl.connect(g);g.connect(_MG);o.start();
  const lfo=_AC.createOscillator(),lg=_AC.createGain();
  lfo.frequency.value=.09+Math.random()*.05;lg.gain.value=fc*.28;
  lfo.connect(lg);lg.connect(fl.frequency);lfo.start();
  _drones.push(o,lfo);
}

function _note(f,when,dur,tp,vol){
  const o=_AC.createOscillator(),g=_AC.createGain(),fl=_AC.createBiquadFilter();
  o.type=tp;o.frequency.value=f;fl.type='lowpass';fl.frequency.value=f*5;fl.Q.value=1;
  g.gain.setValueAtTime(0,when);g.gain.linearRampToValueAtTime(vol,when+.014);
  g.gain.exponentialRampToValueAtTime(.001,when+dur);
  o.connect(fl);fl.connect(g);g.connect(_MG);o.start(when);o.stop(when+dur+.04);
}

function _kick(when){
  const o=_AC.createOscillator(),g=_AC.createGain();
  o.type='sine';o.frequency.setValueAtTime(100,when);
  o.frequency.exponentialRampToValueAtTime(28,when+.13);
  g.gain.setValueAtTime(.22,when);g.gain.exponentialRampToValueAtTime(.001,when+.2);
  o.connect(g);g.connect(_MG);o.start(when);o.stop(when+.26);
}

function _hat(when,vol){
  if(!_hatBuf)return;
  const s=_AC.createBufferSource(),fl=_AC.createBiquadFilter(),g=_AC.createGain();
  s.buffer=_hatBuf;fl.type='highpass';fl.frequency.value=6500;
  g.gain.setValueAtTime(vol,when);g.gain.exponentialRampToValueAtTime(.001,when+.055);
  s.connect(fl);fl.connect(g);g.connect(_MG);s.start(when);
}

function _snare(when){
  if(!_snareBuf)return;
  const s=_AC.createBufferSource(),fl=_AC.createBiquadFilter(),g=_AC.createGain();
  s.buffer=_snareBuf;fl.type='bandpass';fl.frequency.value=1800;fl.Q.value=.8;
  g.gain.setValueAtTime(.14,when);g.gain.exponentialRampToValueAtTime(.001,when+.11);
  s.connect(fl);fl.connect(g);g.connect(_MG);s.start(when);
  const o=_AC.createOscillator(),g2=_AC.createGain();
  o.type='triangle';o.frequency.setValueAtTime(220,when);
  o.frequency.exponentialRampToValueAtTime(110,when+.1);
  g2.gain.setValueAtTime(.08,when);g2.gain.exponentialRampToValueAtTime(.001,when+.1);
  o.connect(g2);g2.connect(_MG);o.start(when);o.stop(when+.15);
}

function _pad(chords,bar,when,dur){
  chords[bar%chords.length].forEach(f=>{
    const o=_AC.createOscillator(),g=_AC.createGain(),fl=_AC.createBiquadFilter();
    o.type='sine';o.frequency.value=f;fl.type='lowpass';fl.frequency.value=f*5;
    g.gain.setValueAtTime(0,when);g.gain.linearRampToValueAtTime(.028,when+.55);
    g.gain.setValueAtTime(.028,when+dur-.45);g.gain.linearRampToValueAtTime(0,when+dur);
    o.connect(fl);fl.connect(g);g.connect(_MG);o.start(when);o.stop(when+dur+.05);
  });
}

// ── Track 0: 古堡守望 (Am, BPM 90) ──────────────────────────────────────
function _track0(){
  const BPM=90,BEAT=60/BPM,S=BEAT/2;
  [[55,0,'sawtooth',.07,230],[55,-9,'sawtooth',.05,185],[82.4,0,'sine',.038,310]]
    .forEach(a=>_drone(...a));
  const CHORDS=[[110,164.8,220],[146.8,220,293.7],[164.8,246.9,329.6],[110,164.8,220]];
  const ARP=[
    220,261.6,329.6,440,392,329.6,261.6,220,
    293.7,349.2,440,587.3,523.3,440,349.2,293.7,
    329.6,392,493.9,659.3,587.3,493.9,392,329.6,
    440,523.3,659.3,784,659.3,523.3,440,392,
  ];
  const MEL=[440,null,659.3,523.3, 587.3,null,440,349.2, 493.9,440,392,349.2, 329.6,null,null,null];
  const PERC=[1,3,2,3,1,3,2,3, 1,3,2,3,1,3,2,3, 1,3,2,3,1,3,2,3, 1,3,2,3,1,3,2,3];
  let step=0,nxt=_AC.currentTime+.05;
  function sched(){
    while(nxt<_AC.currentTime+.3){
      const si=step%32,bar=Math.floor(si/8);
      _note(ARP[si],nxt,S*.8,'triangle',.04);
      if(si%2===0){const m=MEL[si>>1];if(m)_note(m,nxt,BEAT*.88,'sine',.022);}
      if(si%8===0)_pad(CHORDS,bar,nxt,BEAT*4);
      const p=PERC[si];
      if(p===1)_kick(nxt);else if(p===2)_hat(nxt,.08);else if(p===3)_hat(nxt,.026);
      nxt+=S;step++;
    }
  }
  sched();_schedIv=setInterval(sched,50);
}

// ── Track 1: 征途 (Dm, BPM 112) — heroic march ──────────────────────────
function _track1(){
  const BPM=112,BEAT=60/BPM,S=BEAT/2;
  [[73.4,0,'triangle',.06,200],[73.4,-8,'sawtooth',.038,165],[110,0,'sine',.028,240]]
    .forEach(a=>_drone(...a));
  // Dm → Bb → F → C
  const CHORDS=[[146.8,220,293.7],[116.5,174.6,233.1],[174.6,261.6,349.2],[130.8,196,261.6]];
  const ARP=[
    220,293.7,220,293.7, 440,293.7,220,146.8,
    174.6,233.1,174.6,233.1, 349.2,233.1,174.6,116.5,
    261.6,349.2,261.6,349.2, 523.3,349.2,261.6,174.6,
    196,261.6,196,261.6, 392,261.6,196,130.8,
  ];
  const MEL=[293.7,null,349.2,329.6, 293.7,null,233.1,220, 261.6,null,293.7,349.2, 440,null,null,null];
  // 1=kick, 3=hat, 4=snare
  const PERC=[1,3,4,3,1,3,4,3, 1,3,4,3,1,3,4,3, 1,3,4,3,1,3,4,3, 1,3,4,3,1,3,4,3];
  let step=0,nxt=_AC.currentTime+.05;
  function sched(){
    while(nxt<_AC.currentTime+.3){
      const si=step%32,bar=Math.floor(si/8);
      _note(ARP[si],nxt,S*.75,'triangle',.05);
      if(si%2===0){const m=MEL[si>>1];if(m)_note(m,nxt,BEAT*.85,'sawtooth',.018);}
      if(si%8===0)_pad(CHORDS,bar,nxt,BEAT*4);
      const p=PERC[si];
      if(p===1)_kick(nxt);else if(p===4)_snare(nxt);else if(p===3)_hat(nxt,.032);
      nxt+=S;step++;
    }
  }
  sched();_schedIv=setInterval(sched,50);
}

// ── Track 2: 夜袭 (Cm, BPM 76) — dark tension ───────────────────────────
function _track2(){
  const BPM=76,BEAT=60/BPM,S=BEAT/2;
  [[65.4,0,'sawtooth',.065,160],[65.4,-11,'sawtooth',.042,135],[98,0,'sine',.028,190]]
    .forEach(a=>_drone(...a));
  // Cm → Ab → Fm → G
  const CHORDS=[[130.8,155.6,196],[103.8,155.6,207.7],[174.6,207.7,261.6],[196,246.9,293.7]];
  const ARP=[
    130.8,155.6,196,207.7, 196,155.6,130.8,155.6,
    103.8,155.6,207.7,311.1, 207.7,155.6,103.8,103.8,
    174.6,207.7,261.6,349.2, 261.6,207.7,174.6,155.6,
    196,246.9,293.7,392, 293.7,246.9,196,155.6,
  ];
  const MEL=[196,null,207.7,196, 155.6,null,130.8,null, 174.6,155.6,130.8,null, 196,null,null,null];
  // Sparse — heavier kick, ghost hats
  const PERC=[1,0,3,0,1,0,3,0, 1,0,3,0,1,3,3,0, 1,0,3,0,1,0,2,0, 1,0,3,0,1,0,0,0];
  let step=0,nxt=_AC.currentTime+.05;
  function sched(){
    while(nxt<_AC.currentTime+.3){
      const si=step%32,bar=Math.floor(si/8);
      _note(ARP[si],nxt,S*.9,'triangle',.035);
      if(si%2===0){const m=MEL[si>>1];if(m)_note(m,nxt,BEAT*.92,'sine',.016);}
      if(si%8===0)_pad(CHORDS,bar,nxt,BEAT*4);
      const p=PERC[si];
      if(p===1)_kick(nxt);else if(p===2)_hat(nxt,.065);else if(p===3)_hat(nxt,.018);
      nxt+=S;step++;
    }
  }
  sched();_schedIv=setInterval(sched,50);
}

// ── Track 3: 霜晨 (Em, BPM 68) — ethereal calm ──────────────────────────
function _track3(){
  const BPM=68,BEAT=60/BPM,S=BEAT/2;
  [[82.4,0,'sine',.045,160],[123.5,3,'sine',.028,140],[164.8,0,'triangle',.022,200]]
    .forEach(a=>_drone(...a));
  // Em → Am → C → D
  const CHORDS=[[164.8,246.9,329.6],[220,261.6,329.6],[130.8,196,261.6],[146.8,220,293.7]];
  const ARP=[
    164.8,246.9,329.6,329.6, 493.9,329.6,246.9,164.8,
    220,261.6,329.6,440, 329.6,261.6,220,261.6,
    130.8,196,261.6,392, 261.6,196,130.8,196,
    146.8,220,293.7,440, 293.7,220,146.8,220,
  ];
  const MEL=[329.6,null,493.9,440, 329.6,null,246.9,null, 261.6,246.9,220,null, 329.6,null,null,null];
  // Very sparse, gentle
  const PERC=[1,0,0,3,0,0,3,0, 1,0,0,3,0,3,0,0, 1,0,0,3,0,0,3,0, 1,0,0,0,3,0,0,0];
  let step=0,nxt=_AC.currentTime+.05;
  function sched(){
    while(nxt<_AC.currentTime+.3){
      const si=step%32,bar=Math.floor(si/8);
      _note(ARP[si],nxt,S*.85,'sine',.028);
      if(si%2===0){const m=MEL[si>>1];if(m)_note(m,nxt,BEAT*.95,'sine',.014);}
      if(si%8===0)_pad(CHORDS,bar,nxt,BEAT*4);
      const p=PERC[si];
      if(p===1)_kick(nxt);else if(p===2)_hat(nxt,.055);else if(p===3)_hat(nxt,.014);
      nxt+=S;step++;
    }
  }
  sched();_schedIv=setInterval(sched,50);
}
