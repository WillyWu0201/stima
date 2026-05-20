// The single App component. Takes a theme + dark/scale flags, manages
// internal nav between onboarding → main app, and is rendered three times
// at the top level (once per direction).

const { useState: apUS } = React;

function QuoteApp({ theme, dark, scale, startOnHome = false, initialScreen, seedDraft, initialPickerTab, useSheet, initialSheetOpen, seedCustomLibrary, initialMapOpen, initialShareOpen, initialPDFOpen, initialAddClientOpen }) {
  const t = resolveTheme(theme, { dark, scale });

  // nav state
  const [screen, setScreen] = apUS(initialScreen || (startOnHome ? 'home' : 'splash'));
  const [name, setName] = apUS(initialScreen && initialScreen !== 'new-review' ? '陳師傅' : '');
  const [quotes, setQuotes] = apUS(SAMPLE_QUOTES);
  const [categories, setCategories] = apUS(['常用', '拆除', '水電', '泥作', '木作']);
  const [customLibrary, setCustomLibrary] = apUS(seedCustomLibrary || []);
  const [clients, setClients] = apUS(SAMPLE_CLIENTS);
  const [taxRate, setTaxRate] = apUS(5);
  const [pdfTemplate, setPdfTemplate] = apUS(DEFAULT_TEMPLATE);
  const [isPro, setIsPro] = apUS(false);
  const [currency, setCurrency] = apUS('TWD');
  const [language, setLanguage] = apUS('zh-Hant');
  const [shareOpen, setShareOpen] = apUS(!!initialShareOpen);
  const [pdfPreviewOpen, setPdfPreviewOpen] = apUS(!!initialPDFOpen);
  const [draft, setDraft] = apUS(seedDraft || {
    client: '王先生', location: '台北市信義區',
    date: '2026-05-20', items: [], folder: null, status: 'draft',
  });
  const [coaching, setCoaching] = apUS(false);
  const [activeCoach, setActiveCoach] = apUS(true);
  const [viewingQuoteId, setViewingQuoteId] = apUS((initialScreen === 'detail' || initialScreen === 'invoice') ? SAMPLE_QUOTES[0].id : null);
  const [viewingClient, setViewingClient] = apUS(null);
  const [clientDetailReturn, setClientDetailReturn] = apUS('stats');
  const [viewingItem, setViewingItem] = apUS(null);
  const [isFirstTime, setIsFirstTime] = apUS(initialScreen === 'exported');

  const startTutorial = () => {
    setCoaching(true);
    setActiveCoach(true);
    setIsFirstTime(true);
    // seed draft with a sample client to make the tutorial less scary
    setDraft({
      client: '', location: '',
      date: '2026-05-20', items: [], folder: null, status: 'draft',
    });
    setScreen('new-info');
  };
  const onCoachAdvance = () => setActiveCoach(true);

  const finishQuote = () => {
    const subtotal = draft.items.reduce((s, it) => s + it.qty * it.price, 0);
    const total = subtotal + Math.round(subtotal * 0.05);
    const newQ = {
      id: Date.now(),
      client: draft.client || '未命名客戶',
      location: draft.location || '—',
      date: draft.date, total,
      itemList: draft.items.map(it => ({ name: it.name, unit: it.unit, qty: it.qty, price: it.price })),
      folder: null, status: 'ongoing',
    };
    setQuotes([newQ, ...quotes]);
    setScreen('exported');
  };

  // ─── Onboarding ───
  if (screen === 'splash' || screen === 'intro' || screen === 'tutorial0') {
    return (
      <DeviceShell t={t}>
        <OnboardingFlow
          t={t}
          step={screen}
          setStep={setScreen}
          name={name}
          setName={setName}
          onStart={startTutorial}
        />
      </DeviceShell>
    );
  }

  // ─── Main app screens ───
  let content;
  if (screen === 'home') {
    content = <HomeScreen t={t} quotes={quotes} name={name}
      onOpenQuote={(id) => { setViewingQuoteId(id); setScreen('detail'); }}
      onNewQuote={() => {
        setCoaching(false);
        setDraft({ client: '', location: '', date: '2026-05-20', items: [], folder: null, status: 'draft' });
        setScreen('new-info');
      }}
      onOpenStats={() => setScreen('stats')}
      onOpenSettings={() => setScreen('settings')}
      onOpenClient={(cl) => { setViewingClient(cl); setClientDetailReturn('stats'); setScreen('client-detail'); }} />;
  } else if (screen === 'new-info') {
    content = <NewQuoteInfoScreen t={t} draft={draft} setDraft={setDraft}
      onBack={() => setScreen(coaching ? 'tutorial0' : 'home')}
      onNext={() => { setActiveCoach(true); setScreen('new-items'); }}
      coaching={coaching && activeCoach}
      dismissCoach={() => setActiveCoach(false)}
      initialMapOpen={initialMapOpen} />;
  } else if (screen === 'new-items') {
    // pre-seed an item in tutorial mode so user sees something interactive
    if (coaching && draft.items.length === 0) {
      setDraft({ ...draft, items: [
        { id: 1, name: '拆除磁磚', unit: '坪', qty: 10, price: 1800 },
        { id: 2, name: '油漆批土', unit: '坪', qty: 25, price: 850 },
      ] });
    }
    const ItemsScreen = useSheet ? NewQuoteItemsScreenSheet : NewQuoteItemsScreen;
    content = <ItemsScreen t={t} draft={draft} setDraft={setDraft}
      onBack={() => setScreen('new-info')}
      onNext={() => { setActiveCoach(true); setScreen('new-review'); }}
      coaching={coaching && activeCoach}
      dismissCoach={() => setActiveCoach(false)}
      initialPickerTab={initialPickerTab}
      initialSheetOpen={initialSheetOpen}
      categories={categories} />;
  } else if (screen === 'new-review') {
    content = <NewQuoteReviewScreen t={t} draft={draft}
      onBack={() => setScreen('new-items')}
      onFinish={finishQuote}
      coaching={coaching && activeCoach}
      dismissCoach={() => setActiveCoach(false)}
      name={name} setName={setName} />;
  } else if (screen === 'exported') {
    content = <ExportedScreen t={t} isFirstTime={isFirstTime}
      onHome={() => { setCoaching(false); setIsFirstTime(false); setScreen('home'); }} />;
  } else if (screen === 'detail') {
    const quote = quotes.find(q => q.id === viewingQuoteId);
    content = <DetailScreen t={t} quote={quote} onBack={() => setScreen('home')}
      shareOpen={shareOpen} setShareOpen={setShareOpen}
      pdfPreviewOpen={pdfPreviewOpen} setPdfPreviewOpen={setPdfPreviewOpen}
      template={pdfTemplate} isPro={isPro}
      clients={clients}
      onOpenClient={(cl) => { setViewingClient(cl); setClientDetailReturn('detail'); setScreen('client-detail'); }}
      onCopy={() => {
        // duplicate the current quote into the draft and jump into items
        setDraft({
          client: quote.client, location: quote.location,
          date: new Date().toISOString().slice(0, 10),
          items: quote.itemList.map((it, i) => ({ id: Date.now() + i, ...it })),
          folder: quote.folder, status: 'draft',
        });
        setScreen('new-review');
      }}
      onInvoice={() => setScreen('invoice')} />;
  } else if (screen === 'stats') {
    content = <StatsScreen t={t} quotes={quotes} name={name} onHome={() => setScreen('home')}
      onOpenClient={(cl) => { setViewingClient(cl); setScreen('client-detail'); }}
      onOpenItem={(it) => { setViewingItem(it); setScreen('item-detail'); }}
      onSettings={() => setScreen('settings')} />;
  } else if (screen === 'client-detail') {
    content = <ClientDetailScreen t={t} quotes={quotes} clients={clients} clientName={viewingClient}
      onBack={() => setScreen(clientDetailReturn)}
      onOpenQuote={(id) => { setViewingQuoteId(id); setScreen('detail'); }} />;
  } else if (screen === 'item-detail') {
    content = <ItemDetailScreen t={t} quotes={quotes} itemName={viewingItem}
      onBack={() => setScreen('stats')} />;
  } else if (screen === 'settings') {
    content = <SettingsScreen t={t}
      name={name} setName={setName}
      categories={categories} setCategories={setCategories}
      customLibrary={customLibrary} setCustomLibrary={setCustomLibrary}
      taxRate={taxRate} setTaxRate={setTaxRate}
      isPro={isPro}
      currency={currency} setCurrency={setCurrency}
      language={language} setLanguage={setLanguage}
      onHome={() => setScreen('home')}
      onStats={() => setScreen('stats')}
      onOpenContacts={() => setScreen('contacts')}
      onOpenPDFTemplate={() => setScreen('pdf-template')}
      onOpenPaywall={() => setScreen('paywall')} />;
  } else if (screen === 'contacts') {
    content = <ContactsScreen t={t} clients={clients} quotes={quotes}
      initialAddOpen={initialAddClientOpen}
      onAddClient={(data) => setClients([...clients, data])}
      onBack={() => setScreen('settings')}
      onOpenClient={(cl) => { setViewingClient(cl); setClientDetailReturn('contacts'); setScreen('client-detail'); }} />;
  } else if (screen === 'pdf-template') {
    content = <PDFTemplateScreen t={t}
      template={pdfTemplate} setTemplate={setPdfTemplate}
      onBack={() => setScreen('settings')}
      onPreview={() => setPdfPreviewOpen(true)} />;
  } else if (screen === 'paywall') {
    content = <PaywallScreen t={t}
      onBack={() => setScreen('settings')}
      onSubscribe={() => { setIsPro(true); setScreen('settings'); }} />;
  } else if (screen === 'invoice') {
    const quote = quotes.find(q => q.id === viewingQuoteId);
    content = <InvoiceScreen t={t} quote={quote} onBack={() => setScreen('detail')} />;
  }

  return <DeviceShell t={t}>{content}</DeviceShell>;
}

// ────────────────────────────────────────────────────────────────────
// DeviceShell — iPhone frame with our custom status bar + home indicator
// We use the project's IOSDevice as the bezel only and inject our own
// app content (with our own theme-aware status bar) inside.
// ────────────────────────────────────────────────────────────────────
function DeviceShell({ t, children }) {
  // Decide whether to draw the status bar dark or light based on theme bg
  // luminance.
  const isLightBg = isLightHex(t.bg);
  return (
    <div style={{
      width: 402, height: 874, borderRadius: 48, overflow: 'hidden',
      position: 'relative',
      background: t.bg,
      boxShadow: '0 40px 80px rgba(0,0,0,0.22), 0 0 0 1px rgba(0,0,0,0.12)',
      fontFamily: t.fontSans,
      WebkitFontSmoothing: 'antialiased',
    }}>
      {/* dynamic island */}
      <div style={{
        position: 'absolute', top: 11, left: '50%', transform: 'translateX(-50%)',
        width: 126, height: 37, borderRadius: 24, background: '#000', zIndex: 200,
      }} />
      {/* status bar */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 150 }}>
        <IOSStatusBar dark={!isLightBg} />
      </div>
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', position: 'relative' }}>
        {children}
      </div>
      {/* home indicator */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 250,
        height: 34, display: 'flex', justifyContent: 'center', alignItems: 'flex-end',
        paddingBottom: 8, pointerEvents: 'none',
      }}>
        <div style={{
          width: 139, height: 5, borderRadius: 100,
          background: isLightBg ? 'rgba(0,0,0,0.35)' : 'rgba(255,255,255,0.7)',
        }} />
      </div>
    </div>
  );
}

function isLightHex(hex) {
  // simple luminance check
  const h = hex.replace('#', '');
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  return (0.299 * r + 0.587 * g + 0.114 * b) > 130;
}

Object.assign(window, { QuoteApp, DeviceShell });
