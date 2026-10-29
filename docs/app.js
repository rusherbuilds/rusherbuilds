(() => {
  'use strict';
  const c = window.PORTFOLIO;
  if (!c) return;
  const byId = id => document.getElementById(id);
  const text = (id, value) => { const node = byId(id); if (node) node.textContent = String(value); };
  const username = String(c.username || 'rusherbuilds').replace(/[^a-zA-Z0-9-]/g, '');
  const profileUrl = `https://github.com/${username}`;
  document.title = `${c.displayName || username} | Systems & Software`;
  text('footer-name', (c.displayName || username).toUpperCase());
  text('year', new Date().getFullYear());
  text('about-content', c.about);
  text('hero-subtext', c.headline);
  text('about-location', `BASED IN ${(c.location || 'THE WORLD').toUpperCase()}`);
  ['nav-github','hero-github','contact-github','footer-gh'].forEach(id => { if (byId(id)) byId(id).href = profileUrl; });
  if(byId('all-repos')) byId('all-repos').href = `${profileUrl}?tab=repositories`;
  const focusGrid = byId('focus-grid');
  (c.focus || []).forEach(item => {
    const el = document.createElement('article'); el.className = 'focus-card';
    const top = document.createElement('div'); top.className = 'focus-card-top';
    const number = document.createElement('span'); number.textContent = item.number || '';
    const icon = document.createElement('span'); icon.className = 'focus-card-icon'; icon.textContent = item.icon || '◇';
    const title = document.createElement('h3'); title.textContent = item.title;
    const desc = document.createElement('p'); desc.textContent = item.text;
    top.append(number,icon); el.append(top,title,desc); focusGrid.append(el);
  });
  (c.tools || []).forEach(tool => {
    const el = document.createElement('span'); el.className = 'tool-tag'; el.textContent = tool; byId('tool-tags').append(el);
  });

  // Hand-curated tools. The page does not invent projects or links.
  const customToolsGrid = byId('custom-tools-grid');
  if (customToolsGrid) {
    const entries = Array.isArray(c.myTools) ? c.myTools : [];
    if (entries.length) {
      customToolsGrid.replaceChildren();
      entries.forEach(tool => {
        const validLink = typeof tool.url === 'string' && /^https:\/\//i.test(tool.url);
        const card = document.createElement(validLink ? 'a' : 'article');
        card.className = 'repo-card';
        if (validLink) { card.href=tool.url; card.target='_blank'; card.rel='noopener noreferrer'; }
        const title = document.createElement('div'); title.className='repo-title'; title.textContent = String(tool.name || 'Unnamed tool');
        const description = document.createElement('p'); description.textContent = String(tool.description || '');
        const meta = document.createElement('div'); meta.className='repo-card-footer'; meta.textContent=String(tool.status || 'Personal project');
        card.append(title,description,meta); customToolsGrid.append(card);
      });
    }
  }

  // Typewriter animation, with a reduced-motion fallback.
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const words = Array.isArray(c.taglines) && c.taglines.length ? c.taglines : ['Building real software'];
  if (reducedMotion) text('typewriter', words[0]);
  else {
    let i=0, n=0, deleting=false;
    const type = () => {
      const str=words[i % words.length];
      n += deleting ? -1 : 1;
      text('typewriter', str.slice(0, Math.max(0,n)));
      let delay=deleting ? 48 : 78;
      if (!deleting && n >= str.length) { deleting=true; delay=1750; }
      else if(deleting && n <= 0){ deleting=false; i++; delay=350; }
      window.setTimeout(type,delay);
    };
    window.setTimeout(type,550);
  }

  // Scroll-in animation is progressive enhancement, not required for reading the content.
  const observable = document.querySelectorAll('.observe');
  if ('IntersectionObserver' in window && !reducedMotion) {
    const observer = new IntersectionObserver(entries => entries.forEach(entry => {
      if (entry.isIntersecting) { entry.target.classList.add('is-visible'); observer.unobserve(entry.target); }
    }),{threshold:.08});
    observable.forEach(el=>observer.observe(el));
  } else observable.forEach(el=>el.classList.add('is-visible'));
  let scrollPending=false;
  window.addEventListener('scroll', () => {
    if(scrollPending)return;
    scrollPending=true;
    requestAnimationFrame(()=>{
      const h=document.documentElement.scrollHeight-window.innerHeight;
      byId('progress').style.width = (h>0 ? Math.min(100,100*window.scrollY/h) : 0)+'%';
      scrollPending=false;
    });
  },{passive:true});
  const menu=byId('menu-toggle'), nav=byId('navigation');
  menu?.addEventListener('click',()=>{const open=nav.classList.toggle('open');menu.setAttribute('aria-expanded', String(open));});
  nav?.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>{nav.classList.remove('open');menu.setAttribute('aria-expanded','false');}));
  byId('copy-url')?.addEventListener('click',async()=>{
    const btn=byId('copy-url');
    try { await navigator.clipboard.writeText(location.href); btn.textContent='COPIED ✓'; }
    catch { btn.textContent='COPY FROM ADDRESS BAR'; }
    window.setTimeout(()=>btn.textContent='COPY PAGE LINK ↗',2200);
  });

  // Real public GitHub data only. No hardcoded repo counts or invented projects.
  const repoGrid=byId('repos-grid');
  const languageColor={JavaScript:'#f7df1e',TypeScript:'#3178c6',Python:'#3776ab','C++':'#f34b7d',C:'#555555',HTML:'#e34c26',CSS:'#663399',Java:'#b07219',Rust:'#dea584',Go:'#00add8'};
  function linkRepo(r) {
    const a=document.createElement('a'); a.className='repo-card'; a.href=r.html_url;
    a.target='_blank'; a.rel='noopener noreferrer';
    const top=document.createElement('div'); top.className='repo-card-top';
    const title=document.createElement('div'); title.className='repo-title'; title.textContent=r.name;
    const arrow=document.createElement('span'); arrow.className='repo-icon'; arrow.textContent='↗';
    top.append(title,arrow);
    const desc=document.createElement('p'); desc.textContent=r.description || 'Explore the repository for documentation and source code.';
    const footer=document.createElement('div'); footer.className='repo-card-footer';
    const lang=document.createElement('span'); const dot=document.createElement('span'); dot.className='repo-lang-dot'; dot.style.background=languageColor[r.language] || '#79f5e6'; lang.append(dot,document.createTextNode(r.language||'Repository'));
    const stars=document.createElement('span'); stars.textContent=`☆ ${r.stargazers_count || 0}`;
    footer.append(lang,stars); a.append(top,desc,footer); return a;
  }
  const controller = new AbortController();
  const timeout = window.setTimeout(()=>controller.abort(),8500);
  Promise.all([
    fetch(`https://api.github.com/users/${username}`,{signal:controller.signal,headers:{'Accept':'application/vnd.github+json'}}).then(r=>{if(!r.ok)throw new Error(`GitHub API ${r.status}`); return r.json();}),
    fetch(`https://api.github.com/users/${username}/repos?per_page=100&sort=updated`,{signal:controller.signal,headers:{'Accept':'application/vnd.github+json'}}).then(r=>{if(!r.ok)throw new Error(`GitHub API ${r.status}`);return r.json();})
  ]).then(([user,repos])=>{
    text('repo-stat',user.public_repos ?? '—');text('follower-stat',user.followers ?? '—');text('following-stat',user.following ?? '—');
    const list=repos.filter(r=>!r.archived && r.name.toLowerCase()!==username.toLowerCase() && (c.showForks||!r.fork));
    list.sort((a,b)=>(b.stargazers_count-a.stargazers_count) || (new Date(b.pushed_at)-new Date(a.pushed_at)));
    repoGrid.replaceChildren();
    if(!list.length){const el=document.createElement('div');el.className='repo-loading fallback';el.textContent='No public project repositories to display yet. Publish your first project and it will show up here automatically.';repoGrid.append(el);return;}
    list.slice(0,6).forEach(r=>repoGrid.append(linkRepo(r)));
  }).catch(()=>{
    repoGrid.replaceChildren();
    const el=document.createElement('div');el.className='repo-loading fallback';
    el.append('Unable to fetch repositories right now. GitHub public API can be rate-limited. ');
    const a=document.createElement('a');a.href=`${profileUrl}?tab=repositories`;a.target='_blank';a.rel='noopener noreferrer';a.textContent='Open repositories directly ↗';el.append(a);repoGrid.append(el);
  }).finally(()=>window.clearTimeout(timeout));

  // Decorative particles only, respects reduced motion and tab visibility.
  const canvas=byId('ambient');
  if(!canvas || reducedMotion) return;
  const ctx=canvas.getContext('2d');if(!ctx)return;
  let particles=[],height=0,width=0,raf=0;
  function resize(){const ratio=Math.min(2,window.devicePixelRatio||1);width=window.innerWidth;height=window.innerHeight;canvas.width=Math.round(width*ratio);canvas.height=Math.round(height*ratio);ctx.setTransform(ratio,0,0,ratio,0,0);const count=Math.max(18,Math.min(65,Math.floor(width*height/24000)));particles=Array.from({length:count},(_,i)=>({x:Math.random()*width,y:Math.random()*height,dx:(Math.random()-.5)*.28,dy:(Math.random()-.5)*.24,r:Math.random()*1.4+.3}));}
  function draw(){ctx.clearRect(0,0,width,height);for(const p of particles){p.x=(p.x+p.dx+width)%width;p.y=(p.y+p.dy+height)%height;ctx.fillStyle='rgba(135,222,231,.36)';ctx.beginPath();ctx.arc(p.x,p.y,p.r,0,Math.PI*2);ctx.fill();}for(let i=0;i<particles.length;i++){for(let j=i+1;j<particles.length;j++){const a=particles[i],b=particles[j],d=Math.hypot(a.x-b.x,a.y-b.y);if(d<110){ctx.strokeStyle=`rgba(85,207,205,${(1-d/110)*.09})`;ctx.beginPath();ctx.moveTo(a.x,a.y);ctx.lineTo(b.x,b.y);ctx.stroke();}}}raf=requestAnimationFrame(draw)}
  resize();draw();window.addEventListener('resize',()=>{cancelAnimationFrame(raf);resize();draw();},{passive:true});
  document.addEventListener('visibilitychange',()=>{if(document.hidden)cancelAnimationFrame(raf);else {cancelAnimationFrame(raf);draw();}});
})();
