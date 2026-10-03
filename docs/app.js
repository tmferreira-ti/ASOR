(() => {
  const $ = (id) => document.getElementById(id);
  const themeButton = $('theme-button');
  function setTheme(theme) {
    document.documentElement.dataset.theme = theme;
    themeButton.setAttribute('aria-label', theme === 'light' ? 'Ativar tema escuro' : 'Ativar tema claro');
  }
  try { setTheme(localStorage.getItem('asor-theme') || 'dark'); } catch { setTheme('dark'); }
  themeButton.addEventListener('click', () => {
    const theme = document.documentElement.dataset.theme === 'light' ? 'dark' : 'light';
    setTheme(theme);
    try { localStorage.setItem('asor-theme', theme); } catch { /* Storage is optional. */ }
  });

  const headings = [...$('guide').querySelectorAll('h1, h2')];
  const links = headings.map((heading) => {
    const link = document.createElement('a');
    link.href = '#' + heading.id;
    link.textContent = heading.textContent;
    if (heading.tagName === 'H1') link.className = 'toc-major';
    $('table-of-contents').append(link);
    return link;
  });
  function toggleMenu(open) {
    $('sidebar').classList.toggle('open', open);
    $('mobile-menu').setAttribute('aria-expanded', String(open));
  }
  $('mobile-menu').addEventListener('click', () => toggleMenu(!$('sidebar').classList.contains('open')));
  $('close-sidebar').addEventListener('click', () => { toggleMenu(false); $('mobile-menu').focus(); });
  links.forEach(link => link.addEventListener('click', () => toggleMenu(false)));
  let scheduled = false;
  function updateReading() {
    const total = document.documentElement.scrollHeight - innerHeight;
    $('reading-progress').style.width = (total > 0 ? scrollY / total * 100 : 0) + '%';
    let current = 0;
    headings.forEach((heading, i) => { if (heading.getBoundingClientRect().top <= 150) current = i; });
    links.forEach((link, i) => {
      link.classList.toggle('active', i === current);
      if (i === current) link.setAttribute('aria-current', 'location');
      else link.removeAttribute('aria-current');
    });
    scheduled = false;
  }
  addEventListener('scroll', () => { if (!scheduled) { scheduled = true; requestAnimationFrame(updateReading); } }, {passive: true});
  addEventListener('resize', updateReading);
  updateReading();

  const sections = headings.map(heading => {
    let node = heading.nextElementSibling;
    let text = '';
    while (node && !node.matches('h1, h2')) { text += node.textContent + ' '; node = node.nextElementSibling; }
    return {heading, text};
  });
  const normalize = text => text.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  const dialog = $('search-dialog');
  function renderResults() {
    const query = normalize($('search-input').value.trim());
    $('search-results').replaceChildren();
    const results = query ? sections.filter(section => normalize(section.heading.textContent + ' ' + section.text).includes(query)) : [];
    if (!results.length) {
      const message = document.createElement('p');
      message.textContent = query ? 'Nenhuma seção encontrada.' : 'Digite para pesquisar nas seções do guia.';
      $('search-results').append(message);
    }
    results.forEach(section => {
      const link = document.createElement('a');
      link.className = 'search-result';
      link.href = '#' + section.heading.id;
      const title = document.createElement('strong'); title.textContent = section.heading.textContent;
      const excerpt = document.createElement('span'); excerpt.textContent = section.text.slice(0, 160);
      link.append(title, excerpt);
      link.addEventListener('click', () => { dialog.close(); section.heading.setAttribute('tabindex', '-1'); section.heading.focus(); });
      $('search-results').append(link);
    });
  }
  function openSearch() { renderResults(); dialog.showModal(); $('search-input').focus(); }
  $('search-button').addEventListener('click', openSearch);
  $('close-search').addEventListener('click', () => dialog.close());
  $('search-input').addEventListener('input', renderResults);
  dialog.addEventListener('click', event => { if (event.target === dialog) { const r = dialog.getBoundingClientRect(); if (event.clientX < r.left || event.clientX > r.right || event.clientY < r.top || event.clientY > r.bottom) dialog.close(); } });
  addEventListener('keydown', event => {
    if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') { event.preventDefault(); if (!dialog.open) openSearch(); }
    if (event.key === 'Escape') toggleMenu(false);
  });

  let toastTimer;
  $('guide').querySelectorAll('pre').forEach(pre => {
    const code = pre.querySelector('code');
    const wrap = document.createElement('div'); wrap.className = 'code-wrap';
    const toolbar = document.createElement('div'); toolbar.className = 'code-toolbar';
    const label = document.createElement('span'); label.textContent = code?.classList.contains('language-bash') ? 'Bash' : 'Texto';
    const copy = document.createElement('button'); copy.type = 'button'; copy.className = 'copy-button'; copy.textContent = 'Copiar';
    copy.setAttribute('aria-label', 'Copiar bloco de código');
    copy.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText((code || pre).textContent);
        $('toast').textContent = 'Bloco copiado';
      } catch { $('toast').textContent = 'Não foi possível copiar. Selecione e copie o texto manualmente.'; }
      $('toast').classList.add('show'); clearTimeout(toastTimer);
      toastTimer = setTimeout(() => $('toast').classList.remove('show'), 3000);
    });
    toolbar.append(label, copy); pre.before(wrap); wrap.append(toolbar, pre);
  });
})();
