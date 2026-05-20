// Main application screens — home, new-quote flow, detail, stats.
// All screens take `t` (resolved theme) plus the data + nav functions
// they need. Onboarding-aware screens accept `coaching` + `coachStep`.

const { useState: scUS } = React;

// ────────────────────────────────────────────────────────────────────
// HomeScreen — quote list with filter tabs
// ────────────────────────────────────────────────────────────────────
function HomeScreen({ t, quotes, name, onOpenQuote, onNewQuote, onOpenStats, onOpenSettings, onOpenClient }) {
  const [tab, setTab] = scUS('all');
  const [search, setSearch] = scUS('');

  const tabs = [
    { key: 'all',           label: '全部',     color: t.inkSoft },
    { key: 'status:ongoing', label: '進行中',   color: t.accent },
    { key: 'status:done',    label: '已完工',   color: t.positive },
    { key: 'status:paid',    label: '已收款',   color: t.cool },
    { key: 'folder:2026',    label: '2026',    color: t.warn, isFolder: true },
    { key: 'folder:老客戶',  label: '老客戶',  color: t.warn, isFolder: true },
  ];

  const filtered = quotes.filter(q => {
    if (tab === 'all') return true;
    if (tab.startsWith('status:')) return q.status === tab.slice(7);
    if (tab.startsWith('folder:')) return q.folder === tab.slice(7);
    return true;
  }).filter(q => !search || q.client.includes(search) || q.location.includes(search));

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: t.bg, overflow: 'hidden',
    }}>
      <AppBackground t={t} />
      <div style={{
        position: 'relative', zIndex: 1, height: '100%',
        display: 'flex', flexDirection: 'column',
      }}>
        <AppHeader t={t}
          subtitle={`歡迎，${name || '陳師傅'}`}
          title="我的報價單"
          accent={t.id === 'refined'}
          right={
            <button onClick={onNewQuote} aria-label="新增報價單" style={{
              background: 'transparent', border: 'none', cursor: 'pointer',
              color: t.id === 'refined' ? t.accent2 : t.accent,
              padding: 8, marginRight: -8, display: 'flex',
              alignItems: 'center', justifyContent: 'center',
            }}>
              <IconPlus size={26} stroke="currentColor" sw={2.2} />
            </button>
          }
        />

        <div style={{ padding: '14px 20px 0', flexShrink: 0 }}>
          <TextInput t={t} value={search} onChange={e => setSearch(e.target.value)}
            placeholder="搜尋客戶、地點、項目（例：冷氣）"
            leadingIcon={<IconSearch size={16} stroke={t.inkSoft} />} />
        </div>

        {/* Tabs row */}
        <div style={{
          display: 'flex', gap: 8, overflowX: 'auto', padding: '14px 20px 6px',
          flexShrink: 0,
          scrollbarWidth: 'none', msOverflowStyle: 'none',
        }}>
          {tabs.map(tb => {
            const active = tab === tb.key;
            const count = tb.key === 'all'
              ? quotes.length
              : tb.key.startsWith('status:')
                ? quotes.filter(q => q.status === tb.key.slice(7)).length
                : quotes.filter(q => q.folder === tb.key.slice(7)).length;
            return <TabChip key={tb.key} t={t} tab={tb} active={active} count={count}
              onClick={() => setTab(tb.key)} />;
          })}
        </div>

        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '8px 20px 110px', display: 'flex', flexDirection: 'column', gap: 10,
        }}>
          {filtered.length === 0 && (
            <div style={{
              textAlign: 'center', padding: '40px 20px', color: t.inkSoft,
              fontFamily: t.fontSans, fontSize: t.fz(14),
            }}>
              <div style={{ fontSize: t.fz(36), marginBottom: 8 }}>🔍</div>
              這個分頁還是空的
            </div>
          )}
          {filtered.map(q => <QuoteListRow key={q.id} t={t} q={q}
            onClick={() => onOpenQuote(q.id)}
            onOpenClient={onOpenClient} />)}
        </div>
      </div>

      <TabBar t={t} current="home" onHome={() => {}} onStats={onOpenStats} onSettings={onOpenSettings} />
    </div>
  );
}

function TabChip({ t, tab, active, count, onClick }) {
  if (t.id === 'blueprint') {
    return (
      <button onClick={onClick} style={{
        background: active ? t.accent : 'transparent',
        color: active ? t.bg : t.ink,
        border: `1px solid ${active ? t.accent : t.border}`,
        padding: '6px 12px', cursor: 'pointer', flexShrink: 0,
        fontFamily: t.fontMono, fontSize: t.fz(12),
        letterSpacing: '0.08em', textTransform: 'uppercase',
        display: 'flex', alignItems: 'center', gap: 6, whiteSpace: 'nowrap',
      }}>
        {tab.label}
        <span style={{ opacity: 0.7, fontSize: t.fz(10) }}>·{count}</span>
      </button>
    );
  }
  if (t.id === 'stamp') {
    return (
      <button onClick={onClick} style={{
        background: active ? t.ink : t.surface,
        color: active ? t.surface : t.ink,
        border: `1.5px solid ${t.ink}`, padding: '6px 12px',
        fontSize: t.fz(13), fontWeight: 700, fontFamily: t.fontDisplay,
        cursor: 'pointer', flexShrink: 0, borderRadius: 0,
        display: 'flex', alignItems: 'center', gap: 6, whiteSpace: 'nowrap',
        boxShadow: active ? `2px 2px 0 ${t.accent}` : 'none',
      }}>
        {tab.isFolder && <IconFolder size={12} stroke="currentColor" sw={2} />}
        {tab.label}
        <span style={{ opacity: 0.65, fontSize: t.fz(11), fontFamily: t.fontMono }}>{count}</span>
      </button>
    );
  }
  return (
    <button onClick={onClick} style={{
      background: active ? t.accent : t.surface,
      color: active ? '#fff' : t.ink,
      border: `1.5px solid ${active ? t.accent : t.border}`,
      padding: '7px 13px', borderRadius: 999,
      fontSize: t.fz(13), fontWeight: 600,
      cursor: 'pointer', flexShrink: 0, display: 'flex', alignItems: 'center', gap: 6,
      whiteSpace: 'nowrap', fontFamily: t.fontSans,
    }}>
      {tab.isFolder && <IconFolder size={11} stroke="currentColor" sw={2} />}
      {tab.label}
      <span style={{
        fontSize: t.fz(11), opacity: 0.85, padding: '1px 6px', borderRadius: 999,
        background: active ? 'rgba(255,255,255,0.22)' : t.bgSoft,
        color: active ? '#fff' : t.inkSoft,
      }}>{count}</span>
    </button>
  );
}

function QuoteListRow({ t, q, onClick }) {
  return (
    <Card t={t} onClick={onClick} style={{ display: 'flex', flexDirection: 'column' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 10, marginBottom: 6 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap', flex: 1, minWidth: 0 }}>
          <div style={{
            fontFamily: t.fontDisplay, fontSize: t.fz(16), fontWeight: 700, color: t.ink,
          }}>{q.client}</div>
          <StatusBadge t={t} status={q.status} />
        </div>
        <div style={{ fontSize: t.fz(12), color: t.inkSoft, fontFamily: t.fontMono, flexShrink: 0 }}>
          {q.date}
        </div>
      </div>
      <div style={{ fontSize: t.fz(13), color: t.inkSoft, marginBottom: 12, display: 'flex', alignItems: 'center', gap: 4 }}>
        <IconMapPin size={11} stroke={t.inkSoft} sw={2} />
        {q.location}
        {q.folder && (
          <>
            <span style={{ margin: '0 4px', opacity: 0.4 }}>·</span>
            <IconFolder size={11} stroke={t.inkSoft} sw={2} />
            {q.folder}
          </>
        )}
      </div>
      <Divider t={t} style={{ margin: '0 0 10px' }} />
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ fontSize: t.fz(12), color: t.inkSoft }}>
          {q.itemList?.length || 0} 個項目
        </div>
        <Money t={t} amount={q.total} size={18} />
      </div>
    </Card>
  );
}

// ────────────────────────────────────────────────────────────────────
// New Quote — step 1: basic info
// ────────────────────────────────────────────────────────────────────
function NewQuoteInfoScreen({ t, draft, setDraft, onBack, onNext, coaching, dismissCoach, initialMapOpen }) {
  const [mapOpen, setMapOpen] = scUS(!!initialMapOpen);
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: mapOpen ? '#000' : t.bg, overflow: 'hidden',
    }}>
      <div style={{
        width: '100%', height: '100%',
        background: t.bg, position: 'relative', overflow: 'hidden',
        transform: mapOpen ? 'scale(0.93)' : 'none',
        transformOrigin: 'top center',
        borderRadius: mapOpen ? 14 : 0,
        transition: 'transform 0.32s cubic-bezier(.2,.7,.3,1), border-radius 0.32s, opacity 0.32s',
        opacity: mapOpen ? 0.85 : 1,
      }}>
      <AppBackground t={t} />
      <div style={{
        position: 'relative', zIndex: 1, height: '100%',
        display: 'flex', flexDirection: 'column',
      }}>
        <AppHeader t={t} onBack={onBack}
          subtitle="新增報價單 · 1 / 3"
          title="基本資料" />

        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '16px 20px 160px',
          display: 'flex', flexDirection: 'column', gap: 16,
        }}>
          <FieldRow t={t} label="客戶稱呼"
            icon={<IconUser size={15} stroke={t.inkSoft} />}>
            <TextInput t={t} value={draft.client}
              onChange={e => setDraft({ ...draft, client: e.target.value })}
              placeholder="例:王先生、林太太" />
          </FieldRow>
          <FieldRow t={t} label="工程地點"
            icon={<IconMapPin size={15} stroke={t.inkSoft} />}>
            <div style={{ display: 'flex', gap: 8 }}>
              <div style={{ flex: 1 }}>
                <TextInput t={t} value={draft.location}
                  onChange={e => setDraft({ ...draft, location: e.target.value })}
                  placeholder="例:台北市信義區" />
              </div>
              <button onClick={() => setMapOpen(true)} aria-label="從地圖選"
                style={{
                  flexShrink: 0, padding: '0 12px',
                  background: t.surface, border: `1.5px solid ${t.border}`,
                  color: t.accent, borderRadius: t.radius, cursor: 'pointer',
                  display: 'flex', alignItems: 'center', gap: 5,
                  fontSize: t.fz(13), fontWeight: 600, fontFamily: t.fontSans,
                }}>
                <IconMapPin size={14} stroke="currentColor" sw={2.2} /> 地圖
              </button>
            </div>
          </FieldRow>
          <FieldRow t={t} label="報價日期"
            icon={<IconCalendar size={15} stroke={t.inkSoft} />}>
            <TextInput t={t} value={draft.date}
              onChange={e => setDraft({ ...draft, date: e.target.value })}
              placeholder="2026-05-20" />
          </FieldRow>
        </div>
      </div>
      </div>
      <BottomCTA t={t}>
        <PrimaryButton t={t} onClick={onNext}
          icon={<IconArrowRight size={18} stroke="currentColor" />}>
          下一步:加項目
        </PrimaryButton>
      </BottomCTA>
      {mapOpen && (
        <LocationPickerSheet t={t}
          initialValue={draft.location}
          onClose={() => setMapOpen(false)}
          onConfirm={(addr) => {
            setDraft({ ...draft, location: addr });
            setMapOpen(false);
          }} />
      )}
      {coaching && !mapOpen && (
        <CoachMark t={t} step={1} onDismiss={dismissCoach} position="top"
          text="先填客戶稱呼跟地點就好。日期已經幫你填好今天了 — 不夠的之後再補沒關係。" />
      )}
    </div>
  );
}

function FieldRow({ t, label, icon, children }) {
  return (
    <div>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8,
        fontSize: t.fz(13), color: t.inkSoft, fontWeight: 600,
        fontFamily: t.id === 'blueprint' ? t.fontMono : t.fontSans,
        letterSpacing: t.id === 'blueprint' ? '0.1em' : 'normal',
        textTransform: t.id === 'blueprint' ? 'uppercase' : 'none',
      }}>
        {icon} {label}
      </div>
      {children}
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// New Quote — step 2: pick items
// ────────────────────────────────────────────────────────────────────
function NewQuoteItemsScreen({ t, draft, setDraft, onBack, onNext, coaching, dismissCoach, initialPickerTab, categories }) {
  const [pickerTab, setPickerTab] = scUS(initialPickerTab || '常用');
  const [custom, setCustom] = scUS(
    initialPickerTab === '自訂'
      ? { name: '冷氣移機', unit: '式', price: '4500', qty: 2 }
      : { name: '', unit: '坪', price: '', qty: 1 }
  );
  const tabs = Object.keys(ITEM_LIBRARY);
  const allTabs = ['自訂', ...tabs];
  const itemsTotal = draft.items.reduce((s, it) => s + it.qty * it.price, 0);

  const addItem = (lib) => {
    const newItem = { id: Date.now() + Math.random(), name: lib.name, unit: lib.unit, qty: 1, price: lib.lastPrice };
    setDraft({ ...draft, items: [...draft.items, newItem] });
  };
  const addCustom = () => {
    if (!custom.name.trim() || !custom.price) return;
    const newItem = {
      id: Date.now() + Math.random(),
      name: custom.name.trim(),
      unit: custom.unit || '式',
      qty: Number(custom.qty) || 1,
      price: Number(custom.price) || 0,
    };
    setDraft({ ...draft, items: [...draft.items, newItem] });
    setCustom({ name: '', unit: '坪', price: '', qty: 1 });
  };
  const updateItem = (id, patch) => {
    setDraft({ ...draft, items: draft.items.map(it => it.id === id ? { ...it, ...patch } : it) });
  };
  const removeItem = (id) => {
    setDraft({ ...draft, items: draft.items.filter(it => it.id !== id) });
  };

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: t.bg, position: 'relative', overflow: 'hidden' }}>
      <AppBackground t={t} />
      <div style={{ position: 'relative', zIndex: 1, flex: 1, display: 'flex', flexDirection: 'column' }}>
        <AppHeader t={t} onBack={onBack}
          subtitle="新增報價單 · 2 / 3"
          title="加項目"
          right={<div style={{
            fontSize: t.fz(12), color: t.inkSoft, fontFamily: t.fontMono,
            display: 'flex', alignItems: 'flex-end', flexDirection: 'column',
          }}>
            <span>已加 {draft.items.length}</span>
          </div>}
        />

        {/* Current items */}
        <div style={{ padding: '14px 20px 0' }}>
          {draft.items.length > 0 && (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginBottom: 14 }}>
              {draft.items.map(it => (
                <Card key={it.id} t={t} padded={false} style={{ padding: '10px 12px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ fontSize: t.fz(14), fontWeight: 600, color: t.ink, marginBottom: 2 }}>{it.name}</div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: t.fz(12), color: t.inkSoft, fontFamily: t.fontMono }}>
                        <input type="number" value={it.qty}
                          onChange={e => updateItem(it.id, { qty: Number(e.target.value) || 0 })}
                          style={{
                            width: 38, padding: '2px 4px', fontSize: t.fz(12),
                            border: `1px solid ${t.border}`, background: t.surface, color: t.ink,
                            borderRadius: t.id === 'blueprint' ? 0 : 4,
                            fontFamily: t.fontMono, textAlign: 'right',
                          }} />
                        {it.unit} × $
                        <input type="number" value={it.price}
                          onChange={e => updateItem(it.id, { price: Number(e.target.value) || 0 })}
                          style={{
                            width: 64, padding: '2px 4px', fontSize: t.fz(12),
                            border: `1px solid ${t.border}`, background: t.surface, color: t.ink,
                            borderRadius: t.id === 'blueprint' ? 0 : 4,
                            fontFamily: t.fontMono, textAlign: 'right',
                          }} />
                      </div>
                    </div>
                    <Money t={t} amount={it.qty * it.price} size={15} color={t.ink} />
                    <button onClick={() => removeItem(it.id)} style={{
                      background: 'transparent', border: 'none', cursor: 'pointer',
                      color: t.inkFaint, padding: 4, display: 'flex',
                    }}>
                      <IconX size={14} stroke="currentColor" />
                    </button>
                  </div>
                </Card>
              ))}
            </div>
          )}
        </div>

        {/* Picker section */}
        <div style={{
          background: t.surface,
          borderTop: `1px solid ${t.border}`,
          borderRadius: t.id === 'blueprint' ? 0 : `${t.radiusBig}px ${t.radiusBig}px 0 0`,
          flex: 1, display: 'flex', flexDirection: 'column',
          padding: '14px 0 0',
        }}>
          <div style={{
            padding: '0 20px 8px', fontSize: t.fz(11), color: t.inkSoft,
            fontFamily: t.fontMono, letterSpacing: '0.15em', textTransform: 'uppercase',
            fontWeight: 700,
          }}>挑一個，或自己加一筆</div>
          <div style={{ display: 'flex', gap: 6, padding: '0 20px 10px', overflowX: 'auto', scrollbarWidth: 'none' }}>
            {allTabs.map(tb => {
              const isCustom = tb === '自訂';
              const active = pickerTab === tb;
              return (
                <button key={tb} onClick={() => setPickerTab(tb)} style={{
                  background: active ? (isCustom ? t.accent : t.ink) : 'transparent',
                  color: active ? '#fff' : (isCustom ? t.accent : t.ink),
                  border: `1px solid ${active ? (isCustom ? t.accent : t.ink) : (isCustom ? t.accent : t.border)}`,
                  padding: '4px 10px',
                  borderRadius: t.id === 'blueprint' ? 0 : 999,
                  fontSize: t.fz(12), fontWeight: 600, cursor: 'pointer', flexShrink: 0,
                  fontFamily: t.fontSans,
                  display: 'flex', alignItems: 'center', gap: 4,
                }}>
                  {isCustom && <IconPlus size={11} stroke="currentColor" sw={2.5} />}
                  {tb}
                </button>
              );
            })}
          </div>
          <div style={{ flex: 1, overflowY: 'auto', padding: '0 20px 150px' }}>
            {pickerTab === '自訂' ? (
              <CustomItemForm t={t} custom={custom} setCustom={setCustom} onAdd={addCustom} categories={categories} />
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                {ITEM_LIBRARY[pickerTab].map((lib, i) => (
                  <button key={i} onClick={() => addItem(lib)} style={{
                    display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px',
                    background: t.surfaceAlt,
                    border: `1px solid ${t.border}`,
                    borderRadius: t.id === 'blueprint' ? 0 : 8,
                    cursor: 'pointer', textAlign: 'left',
                  }}>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontSize: t.fz(14), fontWeight: 600, color: t.ink, marginBottom: 2 }}>{lib.name}</div>
                      <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono }}>
                        上次 ${lib.lastPrice.toLocaleString()} / {lib.unit}
                        {lib.usedCount && ` · 用過 ${lib.usedCount} 次`}
                      </div>
                    </div>
                    <div style={{
                      width: 28, height: 28, borderRadius: t.id === 'blueprint' ? 0 : '50%',
                      background: t.accent + '20', color: t.accent,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                    }}>
                      <IconPlus size={16} stroke="currentColor" sw={2.5} />
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Sticky bottom summary + next */}
      </div>
      <BottomCTA t={t} above={
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ fontSize: t.fz(13), color: t.inkSoft }}>目前小計</span>
          <Money t={t} amount={itemsTotal} size={20} />
        </div>
      }>
        <PrimaryButton t={t} onClick={onNext}
          icon={<IconArrowRight size={18} stroke="currentColor" />}
          style={draft.items.length === 0 ? { opacity: 0.5 } : {}}>
          下一步:算總價
        </PrimaryButton>
      </BottomCTA>
      {coaching && (
        <CoachMark t={t} step={2} onDismiss={dismissCoach} position="bottom"
          text="按下面的分類挑項目，上次價格我們都記著。沒有的點「+ 自訂」自己加一筆。" />
      )}
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// LocationPickerSheet — bottom sheet for choosing 工程地點 from map
// Mocked: a stylised map view + search + suggestions. Real impl would
// integrate Google Maps / Apple MapKit address autocomplete.
// ────────────────────────────────────────────────────────────────────
function LocationPickerSheet({ t, onClose, onConfirm, initialValue }) {
  const [query, setQuery] = scUS(initialValue || '');
  const [pinned, setPinned] = scUS(initialValue || '台北市信義區松仁路 100 號');
  const suggestions = [
    { addr: '台北市信義區松仁路 100 號', label: '附近最新工地' },
    { addr: '台北市信義區市府路 1 號', label: '台北市政府' },
    { addr: '新北市板橋區文化路二段 100 號', label: '上次去過' },
    { addr: '台北市大安區仁愛路四段 27 號', label: '張先生家（老客戶）' },
  ];
  const filtered = query
    ? suggestions.filter(s => s.addr.includes(query) || s.label.includes(query))
    : suggestions;

  return (
    <>
      <div onClick={onClose} style={{
        position: 'absolute', inset: 0, zIndex: 70,
        background: 'rgba(26,23,20,0.45)',
        backdropFilter: 'blur(3px)', WebkitBackdropFilter: 'blur(3px)',
      }} />
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 80,
        height: '78%', background: t.surface,
        borderTopLeftRadius: 24, borderTopRightRadius: 24,
        boxShadow: '0 -20px 60px rgba(0,0,0,0.25)',
        display: 'flex', flexDirection: 'column',
        animation: 'sheetUp 0.28s cubic-bezier(.2,.7,.3,1)',
      }}>
        <style>{`
          @keyframes sheetUp {
            from { transform: translateY(100%); }
            to { transform: translateY(0); }
          }
        `}</style>

        {/* drag handle */}
        <div style={{ padding: '10px 0 4px', display: 'flex', justifyContent: 'center', flexShrink: 0 }}>
          <div style={{ width: 38, height: 5, borderRadius: 3, background: t.borderStrong, opacity: 0.6 }} />
        </div>

        {/* header */}
        <div style={{
          padding: '4px 20px 12px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          flexShrink: 0,
        }}>
          <div style={{ fontFamily: t.fontDisplay, fontSize: t.fz(18), fontWeight: 700, color: t.ink }}>
            從地圖選地點
          </div>
          <button onClick={onClose} aria-label="關閉" style={{
            width: 32, height: 32, borderRadius: '50%',
            background: t.bgSoft, border: 'none', cursor: 'pointer',
            color: t.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <IconX size={16} stroke="currentColor" sw={2.4} />
          </button>
        </div>

        {/* faux map */}
        <FauxMap t={t} pinned={pinned} />

        {/* current location button overlay */}
        <div style={{ padding: '10px 20px 0', flexShrink: 0 }}>
          <button onClick={() => setPinned('台北市信義區松仁路 100 號（目前位置）')} style={{
            width: '100%', padding: '11px 14px',
            background: t.surfaceAlt, border: `1px solid ${t.border}`,
            borderRadius: t.radius, cursor: 'pointer', fontFamily: t.fontSans,
            color: t.ink, fontSize: t.fz(14), fontWeight: 600,
            display: 'flex', alignItems: 'center', gap: 8,
          }}>
            <span style={{
              width: 22, height: 22, borderRadius: '50%',
              background: t.cool, color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <IconMapPin size={13} stroke="#fff" sw={2.4} />
            </span>
            使用目前位置
            <span style={{ marginLeft: 'auto', fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono }}>
              GPS · ±10m
            </span>
          </button>
        </div>

        {/* search */}
        <div style={{ padding: '12px 20px 8px', flexShrink: 0 }}>
          <TextInput t={t} value={query}
            onChange={e => setQuery(e.target.value)}
            placeholder="搜尋地址、客戶名、或拖曳地圖"
            leadingIcon={<IconSearch size={15} stroke={t.inkSoft} />} />
        </div>

        {/* suggestion list */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '0 20px 24px' }}>
          {filtered.length === 0 && (
            <div style={{ padding: '20px 0', textAlign: 'center', color: t.inkSoft, fontSize: t.fz(13) }}>
              找不到符合「{query}」的地址
            </div>
          )}
          {filtered.map((s, i) => (
            <button key={i} onClick={() => setPinned(s.addr)} style={{
              width: '100%', display: 'flex', alignItems: 'flex-start', gap: 10,
              padding: '12px 0', borderTop: i > 0 ? `1px solid ${t.border}` : 'none',
              background: 'transparent', border: 'none', cursor: 'pointer', textAlign: 'left',
              borderBottom: 'none', borderLeft: 'none', borderRight: 'none',
              fontFamily: t.fontSans,
            }}>
              <IconMapPin size={16} stroke={pinned === s.addr ? t.accent : t.inkSoft} sw={2} style={{ marginTop: 2, flexShrink: 0 }} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: t.fz(14), color: t.ink, fontWeight: pinned === s.addr ? 700 : 500 }}>
                  {s.addr}
                </div>
                <div style={{ fontSize: t.fz(11), color: t.inkSoft, marginTop: 2 }}>{s.label}</div>
              </div>
              {pinned === s.addr && <IconCheck size={16} stroke={t.accent} sw={2.5} />}
            </button>
          ))}
        </div>

        {/* confirm */}
        <div style={{
          padding: '12px 20px 28px', borderTop: `1px solid ${t.border}`,
          background: t.surface, flexShrink: 0,
        }}>
          <PrimaryButton t={t} onClick={() => onConfirm(pinned)}
            icon={<IconCheck size={18} stroke="currentColor" sw={2.5} />}>
            確認此地點
          </PrimaryButton>
        </div>
      </div>
    </>
  );
}

// ────────────────────────────────────────────────────────────────────
// FauxMap — stylised map view used inside the location picker
// ────────────────────────────────────────────────────────────────────
function FauxMap({ t, pinned }) {
  return (
    <div style={{
      position: 'relative', height: 220, margin: '0 20px',
      background: t.bgSoft, borderRadius: t.radius, overflow: 'hidden',
      border: `1px solid ${t.border}`,
      flexShrink: 0,
    }}>
      {/* grid lines (faux roads) */}
      <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }} aria-hidden>
        <defs>
          <pattern id="mapGrid" x="0" y="0" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M40 0H0V40" fill="none" stroke={t.border} strokeWidth="1" />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#mapGrid)" />
        {/* major roads */}
        <line x1="0" y1="120" x2="100%" y2="120" stroke={t.borderStrong} strokeWidth="6" opacity="0.5" />
        <line x1="180" y1="0" x2="180" y2="100%" stroke={t.borderStrong} strokeWidth="6" opacity="0.5" />
        <line x1="0" y1="60" x2="100%" y2="60" stroke={t.border} strokeWidth="3" />
        {/* faux building blocks */}
        <rect x="40" y="20" width="80" height="30" fill={t.surfaceAlt} opacity="0.8" rx="2" />
        <rect x="220" y="20" width="50" height="30" fill={t.surfaceAlt} opacity="0.8" rx="2" />
        <rect x="40" y="140" width="60" height="60" fill={t.surfaceAlt} opacity="0.8" rx="2" />
        <rect x="220" y="140" width="120" height="60" fill={t.surfaceAlt} opacity="0.8" rx="2" />
        {/* park */}
        <circle cx="320" cy="40" r="20" fill={t.positive} opacity="0.18" />
      </svg>

      {/* center pin */}
      <div style={{
        position: 'absolute', top: '50%', left: '50%',
        transform: 'translate(-50%, -100%)',
        display: 'flex', flexDirection: 'column', alignItems: 'center',
      }}>
        <div style={{
          background: t.surface, color: t.ink, padding: '6px 10px',
          borderRadius: t.radius, fontSize: t.fz(11), fontWeight: 600,
          boxShadow: '0 4px 12px rgba(0,0,0,0.15)', whiteSpace: 'nowrap',
          maxWidth: 260, overflow: 'hidden', textOverflow: 'ellipsis',
          marginBottom: 6,
          border: `1px solid ${t.border}`,
        }}>
          {pinned}
        </div>
        <svg width="32" height="40" viewBox="0 0 32 40" style={{ filter: 'drop-shadow(0 3px 6px rgba(0,0,0,0.25))' }}>
          <path d="M16 0C7 0 0 7 0 16c0 12 16 24 16 24s16-12 16-24c0-9-7-16-16-16z" fill={t.accent} />
          <circle cx="16" cy="15" r="6" fill="#fff" />
        </svg>
      </div>

      {/* tap-to-place hint */}
      <div style={{
        position: 'absolute', bottom: 8, left: '50%', transform: 'translateX(-50%)',
        fontSize: t.fz(10), color: t.inkSoft, fontFamily: t.fontMono,
        background: t.surface, padding: '3px 8px', borderRadius: 999,
        border: `1px solid ${t.border}`,
        letterSpacing: '0.05em',
      }}>
        拖曳移動，雙擊放下圖釘
      </div>
    </div>
  );
}
// Accepts `categories` (list of tab names) so the user can pick
// which category the new item lives under. Default = 常用.
// ────────────────────────────────────────────────────────────────────
function CustomItemForm({ t, custom, setCustom, onAdd, categories }) {
  const units = ['坪', '式', '個', '組', '尺', '車', '人/日'];
  const cats = categories || ['常用', '拆除', '水電', '泥作', '木作'];
  const canSubmit = custom.name.trim() && Number(custom.price) > 0;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <div style={{
        fontSize: t.fz(12), color: t.inkSoft, lineHeight: 1.55,
        background: t.surfaceAlt, padding: '10px 12px',
        borderRadius: t.radius, border: `1px dashed ${t.border}`,
      }}>
        加進你的項目庫，下次直接挑就行。
      </div>
      <div>
        <FieldLabel t={t}>項目名稱</FieldLabel>
        <TextInput t={t} value={custom.name}
          onChange={e => setCustom({ ...custom, name: e.target.value })}
          placeholder="例：拆冷氣、磨地板、外牆貼磚" />
      </div>
      <div>
        <FieldLabel t={t}>歸到哪個分類</FieldLabel>
        <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
          {cats.filter(c => c !== '常用').map(c => {
            const on = custom.category === c;
            return (
              <button key={c} onClick={() => setCustom({ ...custom, category: c })} style={{
                padding: '6px 12px', fontSize: t.fz(13),
                background: on ? t.accent : t.surface,
                color: on ? '#fff' : t.ink,
                border: `1px solid ${on ? t.accent : t.border}`,
                borderRadius: 999, cursor: 'pointer', fontFamily: t.fontSans, fontWeight: 600,
              }}>{c}</button>
            );
          })}
          <button onClick={() => setCustom({ ...custom, category: '__new' })} style={{
            padding: '6px 12px', fontSize: t.fz(13),
            background: custom.category === '__new' ? t.accent : 'transparent',
            color: custom.category === '__new' ? '#fff' : t.accent,
            border: `1px dashed ${t.accent}`, borderRadius: 999,
            cursor: 'pointer', fontFamily: t.fontSans, fontWeight: 600,
            display: 'flex', alignItems: 'center', gap: 4,
          }}>
            <IconPlus size={11} stroke="currentColor" sw={2.5} /> 新分類
          </button>
        </div>
        {custom.category === '__new' && (
          <div style={{ marginTop: 8 }}>
            <TextInput t={t} value={custom.newCategoryName || ''}
              onChange={e => setCustom({ ...custom, newCategoryName: e.target.value })}
              placeholder="例：清潔、油漆、家具" />
          </div>
        )}
        <div style={{ fontSize: t.fz(11), color: t.inkFaint, marginTop: 6 }}>
          所有新項目都會自動進「常用」,加上分類後也會出現在那個分頁。
        </div>
      </div>
      <div style={{ display: 'flex', gap: 10 }}>
        <div style={{ flex: 1 }}>
          <FieldLabel t={t}>單位</FieldLabel>
          <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
            {units.map(u => {
              const on = custom.unit === u;
              return (
                <button key={u} onClick={() => setCustom({ ...custom, unit: u })} style={{
                  padding: '6px 10px', fontSize: t.fz(13),
                  background: on ? t.ink : t.surface,
                  color: on ? t.bg : t.ink,
                  border: `1px solid ${on ? t.ink : t.border}`,
                  borderRadius: 999, cursor: 'pointer', fontFamily: t.fontSans, fontWeight: 600,
                }}>{u}</button>
              );
            })}
          </div>
        </div>
      </div>
      <div style={{ display: 'flex', gap: 10 }}>
        <div style={{ flex: 1 }}>
          <FieldLabel t={t}>單價 (NT$)</FieldLabel>
          <TextInput t={t} value={custom.price}
            onChange={e => setCustom({ ...custom, price: e.target.value.replace(/[^\d]/g, '') })}
            placeholder="0" />
        </div>
        <div style={{ width: 110 }}>
          <FieldLabel t={t}>數量</FieldLabel>
          <TextInput t={t} value={custom.qty}
            onChange={e => setCustom({ ...custom, qty: e.target.value.replace(/[^\d.]/g, '') })}
            placeholder="1" />
        </div>
      </div>

      <div style={{
        padding: '10px 12px', borderRadius: t.radius,
        background: t.surface, border: `1.5px dashed ${t.accent}`,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: t.fz(14), fontWeight: 600, color: custom.name ? t.ink : t.inkFaint }}>
            {custom.name || '— 項目名稱 —'}
          </div>
          <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono, marginTop: 2 }}>
            {Number(custom.qty) || 1} {custom.unit} × ${Number(custom.price || 0).toLocaleString()}
            {custom.category && custom.category !== '__new' && (
              <span style={{ marginLeft: 8, color: t.accent }}>· {custom.category}</span>
            )}
            {custom.category === '__new' && custom.newCategoryName && (
              <span style={{ marginLeft: 8, color: t.accent }}>· {custom.newCategoryName}（新分類）</span>
            )}
          </div>
        </div>
        <Money t={t} amount={(Number(custom.qty) || 1) * Number(custom.price || 0)} size={15} color={canSubmit ? t.accent : t.inkFaint} />
      </div>

      <SecondaryButton t={t} onClick={onAdd}
        style={{ opacity: canSubmit ? 1 : 0.5, color: canSubmit ? t.accent : t.inkFaint, borderColor: canSubmit ? t.accent : t.border }}>
        <IconPlus size={16} stroke="currentColor" sw={2.5} /> 加進去
      </SecondaryButton>
    </div>
  );
}

function FieldLabel({ t, children }) {
  return (
    <div style={{
      fontSize: t.fz(12), color: t.inkSoft, marginBottom: 6,
      fontWeight: 600,
    }}>{children}</div>
  );
}

// ────────────────────────────────────────────────────────────────────
// New Quote — step 2 (variant): items as partial bottom sheet
// Same data + handlers as NewQuoteItemsScreen, but UX is restructured
// so the main view is just the already-added items, and the picker
// lives in a sheet you summon via a CTA. Cleaner on screens with many
// items, more iOS-native, and the user can drop the sheet to verify
// the running total before committing more.
// ────────────────────────────────────────────────────────────────────
function NewQuoteItemsScreenSheet({ t, draft, setDraft, onBack, onNext, coaching, dismissCoach, initialPickerTab, initialSheetOpen, categories }) {
  const [sheetOpen, setSheetOpen] = scUS(!!initialSheetOpen);
  const [pickerTab, setPickerTab] = scUS(initialPickerTab || '常用');
  const [custom, setCustom] = scUS(
    initialPickerTab === '自訂'
      ? { name: '冷氣移機', unit: '式', price: '4500', qty: 2 }
      : { name: '', unit: '坪', price: '', qty: 1 }
  );
  const [recent, setRecent] = scUS(null); // last-added item name (for toast)
  const tabs = Object.keys(ITEM_LIBRARY);
  const allTabs = ['自訂', ...tabs];
  const itemsTotal = draft.items.reduce((s, it) => s + it.qty * it.price, 0);

  const addItem = (lib) => {
    setDraft({ ...draft, items: [...draft.items, {
      id: Date.now() + Math.random(), name: lib.name, unit: lib.unit, qty: 1, price: lib.lastPrice,
    }] });
    setRecent(lib.name);
    setTimeout(() => setRecent(null), 1400);
  };
  const addCustom = () => {
    if (!custom.name.trim() || !custom.price) return;
    setDraft({ ...draft, items: [...draft.items, {
      id: Date.now() + Math.random(),
      name: custom.name.trim(), unit: custom.unit || '式',
      qty: Number(custom.qty) || 1, price: Number(custom.price) || 0,
    }] });
    setRecent(custom.name.trim());
    setTimeout(() => setRecent(null), 1400);
    setCustom({ name: '', unit: '坪', price: '', qty: 1 });
  };
  const updateItem = (id, patch) => {
    setDraft({ ...draft, items: draft.items.map(it => it.id === id ? { ...it, ...patch } : it) });
  };
  const removeItem = (id) => {
    setDraft({ ...draft, items: draft.items.filter(it => it.id !== id) });
  };

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: sheetOpen ? '#000' : t.bg, overflow: 'hidden',
    }}>
      <div style={{
        width: '100%', height: '100%',
        background: t.bg, position: 'relative', overflow: 'hidden',
        transform: sheetOpen ? 'scale(0.93)' : 'none',
        transformOrigin: 'top center',
        borderRadius: sheetOpen ? 14 : 0,
        transition: 'transform 0.32s cubic-bezier(.2,.7,.3,1), border-radius 0.32s, opacity 0.32s',
        opacity: sheetOpen ? 0.85 : 1,
      }}>
      <AppBackground t={t} />
      <div style={{
        position: 'relative', zIndex: 1, height: '100%',
        display: 'flex', flexDirection: 'column',
      }}>
        <AppHeader t={t} onBack={onBack}
          subtitle="新增報價單 · 2 / 3"
          title="加項目"
          right={<div style={{
            fontSize: t.fz(12), color: t.inkSoft, fontFamily: t.fontMono,
          }}>已加 {draft.items.length}</div>}
        />

        {/* Items list (main view) */}
        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '16px 20px 200px',
          display: 'flex', flexDirection: 'column', gap: 8,
        }}>
          {draft.items.length === 0 ? (
            <div style={{
              textAlign: 'center', padding: '60px 20px', color: t.inkSoft,
            }}>
              <div style={{
                width: 64, height: 64, borderRadius: '50%',
                background: t.surfaceAlt, color: t.accent,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                marginBottom: 14, border: `1.5px dashed ${t.accent}`,
              }}>
                <IconPlus size={28} stroke="currentColor" sw={2} />
              </div>
              <div style={{ fontSize: t.fz(16), fontWeight: 600, color: t.ink, marginBottom: 4 }}>
                還沒加項目
              </div>
              <div style={{ fontSize: t.fz(13), color: t.inkSoft }}>
                點下方的「+ 加項目」開始
              </div>
            </div>
          ) : (
            draft.items.map(it => (
              <Card key={it.id} t={t} padded={false} style={{ padding: '12px 14px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: t.fz(15), fontWeight: 600, color: t.ink, marginBottom: 4 }}>{it.name}</div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: t.fz(12), color: t.inkSoft, fontFamily: t.fontMono }}>
                      <input type="number" value={it.qty}
                        onChange={e => updateItem(it.id, { qty: Number(e.target.value) || 0 })}
                        style={{
                          width: 44, padding: '3px 6px', fontSize: t.fz(13),
                          border: `1px solid ${t.border}`, background: t.surface, color: t.ink,
                          borderRadius: 4, fontFamily: t.fontMono, textAlign: 'right',
                        }} />
                      <span>{it.unit} × $</span>
                      <input type="number" value={it.price}
                        onChange={e => updateItem(it.id, { price: Number(e.target.value) || 0 })}
                        style={{
                          width: 72, padding: '3px 6px', fontSize: t.fz(13),
                          border: `1px solid ${t.border}`, background: t.surface, color: t.ink,
                          borderRadius: 4, fontFamily: t.fontMono, textAlign: 'right',
                        }} />
                    </div>
                  </div>
                  <Money t={t} amount={it.qty * it.price} size={16} color={t.ink} />
                  <button onClick={() => removeItem(it.id)} aria-label="移除" style={{
                    background: 'transparent', border: 'none', cursor: 'pointer',
                    color: t.inkFaint, padding: 4, display: 'flex',
                  }}>
                    <IconX size={16} stroke="currentColor" />
                  </button>
                </div>
              </Card>
            ))
          )}
        </div>
      </div>

      {/* Toast "已加 ___" */}
      {recent && (
        <div style={{
          position: 'absolute', top: 130, left: '50%', transform: 'translateX(-50%)',
          background: t.ink, color: t.bg,
          padding: '8px 14px', borderRadius: 999,
          fontSize: t.fz(13), fontWeight: 600,
          boxShadow: '0 6px 20px rgba(0,0,0,0.25)',
          zIndex: 60, display: 'flex', alignItems: 'center', gap: 6,
          fontFamily: t.fontSans,
        }}>
          <IconCheck size={14} stroke={t.bg} sw={3} />
          已加 「{recent}」
        </div>
      )}

      {/* Bottom CTA: + 加項目 + 下一步 */}
      <BottomCTA t={t}
        above={
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: t.fz(13), color: t.inkSoft }}>目前小計</span>
            <Money t={t} amount={itemsTotal} size={20} />
          </div>
        }
      >
        <div style={{ display: 'flex', gap: 8 }}>
          <SecondaryButton t={t} onClick={() => setSheetOpen(true)}
            style={{ flex: '0 0 auto', width: 'auto', padding: '14px 16px' }}>
            <IconPlus size={18} stroke="currentColor" sw={2.5} /> 加項目
          </SecondaryButton>
          <div style={{ flex: 1 }}>
            <PrimaryButton t={t} onClick={onNext}
              icon={<IconArrowRight size={18} stroke="currentColor" />}
              style={draft.items.length === 0 ? { opacity: 0.5 } : {}}>
              下一步
            </PrimaryButton>
          </div>
        </div>
      </BottomCTA>

      {/* Sheet backdrop + sheet — outside the scaling shell */}
      </div>
      {sheetOpen && (
        <PickerSheet
          t={t}
          allTabs={allTabs}
          pickerTab={pickerTab}
          setPickerTab={setPickerTab}
          custom={custom}
          setCustom={setCustom}
          addItem={addItem}
          addCustom={addCustom}
          recent={recent}
          categories={categories}
          onClose={() => setSheetOpen(false)}
        />
      )}

      {coaching && !sheetOpen && (
        <CoachMark t={t} step={2} onDismiss={dismissCoach} position="bottom"
          text="按「+ 加項目」打開分類，從歷史挑或自己加一筆。可以一次加好幾筆再關掉。" />
      )}
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// PickerSheet — partial bottom sheet for selecting items
// ────────────────────────────────────────────────────────────────────
function PickerSheet({ t, allTabs, pickerTab, setPickerTab, custom, setCustom, addItem, addCustom, onClose, categories }) {
  return (
    <>
      {/* Dim layer behind the sheet — the parent screen is scaled down
          so a strip of it peeks above the sheet, like iOS pageSheet. */}
      <div onClick={onClose} style={{
        position: 'absolute', inset: 0, zIndex: 70,
        background: 'rgba(0,0,0,0.3)',
      }} />
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 80,
        height: 'calc(100% - 22px)', background: t.surface,
        borderTopLeftRadius: 12, borderTopRightRadius: 12,
        boxShadow: '0 -10px 40px rgba(0,0,0,0.25)',
        display: 'flex', flexDirection: 'column',
        animation: 'sheetUp 0.32s cubic-bezier(.2,.7,.3,1)',
      }}>
        <style>{`
          @keyframes sheetUp {
            from { transform: translateY(100%); }
            to { transform: translateY(0); }
          }
        `}</style>
        {/* drag handle */}
        <div style={{
          padding: '10px 0 6px', display: 'flex', justifyContent: 'center', flexShrink: 0,
        }}>
          <div style={{
            width: 38, height: 5, borderRadius: 3,
            background: t.borderStrong, opacity: 0.6,
          }} />
        </div>

        {/* header row */}
        <div style={{
          padding: '4px 20px 14px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          flexShrink: 0,
        }}>
          <div style={{
            fontFamily: t.fontDisplay, fontSize: t.fz(18), fontWeight: 700, color: t.ink,
          }}>挑項目，或自己加</div>
          <button onClick={onClose} aria-label="關閉" style={{
            width: 32, height: 32, borderRadius: '50%',
            background: t.bgSoft, border: 'none', cursor: 'pointer',
            color: t.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <IconX size={16} stroke="currentColor" sw={2.4} />
          </button>
        </div>

        {/* tabs */}
        <div style={{
          display: 'flex', gap: 6, padding: '0 20px 10px',
          overflowX: 'auto', scrollbarWidth: 'none', flexShrink: 0,
        }}>
          {allTabs.map(tb => {
            const isCustom = tb === '自訂';
            const active = pickerTab === tb;
            return (
              <button key={tb} onClick={() => setPickerTab(tb)} style={{
                background: active ? (isCustom ? t.accent : t.ink) : 'transparent',
                color: active ? '#fff' : (isCustom ? t.accent : t.ink),
                border: `1px solid ${active ? (isCustom ? t.accent : t.ink) : (isCustom ? t.accent : t.border)}`,
                padding: '5px 12px', borderRadius: 999,
                fontSize: t.fz(13), fontWeight: 600, cursor: 'pointer', flexShrink: 0,
                fontFamily: t.fontSans, display: 'flex', alignItems: 'center', gap: 4,
              }}>
                {isCustom && <IconPlus size={12} stroke="currentColor" sw={2.5} />}
                {tb}
              </button>
            );
          })}
        </div>

        {/* content */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 28px' }}>
          {pickerTab === '自訂' ? (
            <CustomItemForm t={t} custom={custom} setCustom={setCustom} onAdd={addCustom} categories={categories} />
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              {ITEM_LIBRARY[pickerTab].map((lib, i) => (
                <button key={i} onClick={() => addItem(lib)} style={{
                  display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
                  background: t.surfaceAlt,
                  border: `1px solid ${t.border}`,
                  borderRadius: 10,
                  cursor: 'pointer', textAlign: 'left',
                }}>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: t.fz(15), fontWeight: 600, color: t.ink, marginBottom: 2 }}>{lib.name}</div>
                    <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono }}>
                      上次 ${lib.lastPrice.toLocaleString()} / {lib.unit}
                      {lib.usedCount && ` · 用過 ${lib.usedCount} 次`}
                    </div>
                  </div>
                  <div style={{
                    width: 30, height: 30, borderRadius: '50%',
                    background: t.accent, color: '#fff',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>
                    <IconPlus size={17} stroke="currentColor" sw={2.5} />
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      </div>
    </>
  );
}

// ────────────────────────────────────────────────────────────────────
// New Quote — step 3: review + finalize
// ────────────────────────────────────────────────────────────────────
function NewQuoteReviewScreen({ t, draft, onBack, onFinish, coaching, dismissCoach, name, setName }) {
  const subtotal = draft.items.reduce((s, it) => s + it.qty * it.price, 0);
  const tax = Math.round(subtotal * 0.05);
  const total = subtotal + tax;
  const askName = !name;

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: t.bg, overflow: 'hidden',
    }}>
      <AppBackground t={t} />
      <div style={{
        position: 'relative', zIndex: 1, height: '100%',
        display: 'flex', flexDirection: 'column',
      }}>
        <AppHeader t={t} onBack={onBack}
          subtitle="新增報價單 · 3 / 3"
          title="確認出單" />

        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '16px 20px 160px',
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          {askName && (
            <Card t={t} style={{ background: t.surfaceAlt }}>
              <div style={{
                fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono,
                letterSpacing: '0.1em', marginBottom: 6, fontWeight: 600,
                display: 'flex', alignItems: 'center', gap: 6,
              }}>
                <IconStamp size={12} stroke={t.inkSoft} />
                報價單抬頭 · 第一次問，之後記著
              </div>
              <TextInput t={t} value={name || ''} onChange={e => setName(e.target.value)}
                placeholder="例：陳師傅 / 大發工程行" />
            </Card>
          )}
          <Card t={t}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
              <div>
                <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono, letterSpacing: '0.1em', marginBottom: 4 }}>客戶</div>
                <div style={{ fontSize: t.fz(18), fontWeight: 700, fontFamily: t.fontDisplay, color: t.ink }}>{draft.client || '未命名客戶'}</div>
              </div>
              <div style={{ fontSize: t.fz(12), color: t.inkSoft, fontFamily: t.fontMono }}>{draft.date}</div>
            </div>
            <div style={{ fontSize: t.fz(13), color: t.inkSoft, display: 'flex', alignItems: 'center', gap: 4 }}>
              <IconMapPin size={11} stroke={t.inkSoft} /> {draft.location || '— 未填地點 —'}
            </div>
          </Card>

          <Card t={t}>
            <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono, letterSpacing: '0.1em', marginBottom: 8 }}>
              項目明細
            </div>
            {draft.items.map((it, i) => (
              <div key={it.id}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', padding: '8px 0' }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: t.fz(14), fontWeight: 600, color: t.ink }}>{it.name}</div>
                    <div style={{ fontSize: t.fz(12), color: t.inkSoft, fontFamily: t.fontMono, marginTop: 2 }}>
                      {it.qty} {it.unit} × ${it.price.toLocaleString()}
                    </div>
                  </div>
                  <Money t={t} amount={it.qty * it.price} size={15} color={t.ink} />
                </div>
                {i < draft.items.length - 1 && <Divider t={t} style={{ margin: '0' }} />}
              </div>
            ))}
            {draft.items.length === 0 && (
              <div style={{ padding: '12px 0', color: t.inkFaint, fontSize: t.fz(13) }}>還沒有項目</div>
            )}
          </Card>

          <Card t={t} accent={t.id !== 'blueprint'}>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: t.fz(13), marginBottom: 6, color: t.id === 'blueprint' ? t.inkSoft : (t.accentSurfaceInkSoft || "rgba(245,242,236,0.7)") }}>
              <span>小計</span>
              <span style={{ fontFamily: t.fontMono }}>${subtotal.toLocaleString()}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: t.fz(13), marginBottom: 10, color: t.id === 'blueprint' ? t.inkSoft : (t.accentSurfaceInkSoft || "rgba(245,242,236,0.7)") }}>
              <span>稅金 5%</span>
              <span style={{ fontFamily: t.fontMono }}>${tax.toLocaleString()}</span>
            </div>
            <Divider t={t} style={{ margin: '0 0 10px', borderColor: t.id === 'blueprint' ? t.border : (t.accentSurfaceDivider || "rgba(245,242,236,0.2)"), background: t.id === 'blueprint' ? '' : (t.accentSurfaceDivider || "rgba(245,242,236,0.2)") }} />
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: t.fz(14), fontWeight: 700, color: t.id === 'blueprint' ? t.ink : (t.accentSurfaceInk || t.bg) }}>總計</span>
              <Money t={t} amount={total} size={26} color={t.id === 'blueprint' ? t.accent : t.accent2} />
            </div>
          </Card>
        </div>
      </div>
      <BottomCTA t={t}>
        <PrimaryButton t={t} onClick={onFinish}
          icon={<IconCheck size={18} stroke="currentColor" />}>
          出單，搞定!
        </PrimaryButton>
      </BottomCTA>
      {coaching && (
        <CoachMark t={t} step={3} onDismiss={dismissCoach} position="top"
          text="算好了！檢查一下總價。送出後可以從首頁分享 LINE / PDF 給客戶。" />
      )}
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// Exported — done screen
// ────────────────────────────────────────────────────────────────────
function ExportedScreen({ t, onHome, isFirstTime }) {
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: t.bg, position: 'relative',
    }}>
      <AppBackground t={t} />
      <div style={{
        position: 'relative', zIndex: 1, flex: 1,
        display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        padding: '60px 30px 200px', textAlign: 'center', width: '100%',
        boxSizing: 'border-box',
      }}>
        <DoneHero t={t} isFirstTime={isFirstTime} />
      </div>
      <BottomCTA t={t} withBackground={false} sub={
        <SecondaryButton t={t} onClick={onHome}
          style={{ background: 'transparent', borderColor: t.border }}>
          <IconShare size={16} stroke="currentColor" /> 傳給客戶
        </SecondaryButton>
      }>
        <PrimaryButton t={t} onClick={onHome}>
          {isFirstTime ? '太好了，看看主畫面' : '回到報價單列表'}
        </PrimaryButton>
      </BottomCTA>
    </div>
  );
}

function DoneHero({ t, isFirstTime }) {
  if (t.id === 'stamp') {
    return (
      <div>
        <div style={{
          display: 'inline-block', padding: '24px 28px',
          border: `4px double ${t.accent}`, color: t.accent,
          fontFamily: t.fontDisplay, fontSize: t.fz(28), fontWeight: 900,
          letterSpacing: '0.1em', transform: 'rotate(-5deg)',
          marginBottom: 24,
        }}>已出單</div>
        <div style={{
          fontFamily: t.fontDisplay, fontSize: t.fz(26), fontWeight: 800,
          color: t.ink, lineHeight: 1.2, marginBottom: 10,
        }}>{isFirstTime ? '第一張，蓋章！' : '出單完成'}</div>
        <div style={{
          fontFamily: t.fontHand, fontSize: t.fz(18), color: t.inkSoft,
          transform: 'rotate(-1deg)',
        }}>客戶資料已存進去，下次找他更快</div>
      </div>
    );
  }
  if (t.id === 'blueprint') {
    return (
      <div>
        <div style={{
          fontFamily: t.fontMono, fontSize: t.fz(11), color: t.accent,
          letterSpacing: '0.25em', marginBottom: 10,
        }}>// QUOTE_FINALIZED · OK</div>
        <div style={{
          fontFamily: t.fontDisplay, fontSize: t.fz(32), fontWeight: 600,
          color: t.ink, lineHeight: 1.15, marginBottom: 14,
        }}>{isFirstTime ? '第一張，搞定。' : '出單完成。'}</div>
        <div style={{
          fontFamily: t.fontMono, fontSize: t.fz(12), color: t.inkSoft,
          lineHeight: 1.7,
        }}>
          ✓ 報價單已建立<br/>
          ✓ 客戶已存入名單<br/>
          ✓ 待收款 = 1 張
        </div>
      </div>
    );
  }
  return (
    <div>
      <div style={{
        width: 76, height: 76, borderRadius: '50%', background: t.accent,
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        marginBottom: 22,
      }}>
        <IconCheck size={40} stroke="#fff" sw={3} />
      </div>
      <div style={{
        fontFamily: t.fontDisplay, fontSize: t.fz(28), fontWeight: 800,
        color: t.ink, lineHeight: 1.2, marginBottom: 10,
      }}>{isFirstTime ? '第一張完成！' : '出單完成'}</div>
      <div style={{ fontSize: t.fz(15), color: t.inkSoft, lineHeight: 1.55 }}>
        下次跟同個客戶報價時，<br/>
        我們會自動幫你填好資料。
      </div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// Detail — quote detail page
// ────────────────────────────────────────────────────────────────────
function DetailScreen({ t, quote, onBack, onShare, onCopy, onInvoice, onOpenClient, clients, shareOpen, setShareOpen, pdfPreviewOpen, setPdfPreviewOpen, template, isPro }) {
  if (!quote) return null;
  const subtotal = quote.itemList.reduce((s, it) => s + it.qty * it.price, 0);
  const tax = Math.round(subtotal * 0.05);
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: t.bg, overflow: 'hidden',
    }}>
      <AppBackground t={t} />
      <div style={{
        position: 'relative', zIndex: 1, height: '100%',
        display: 'flex', flexDirection: 'column',
      }}>
        <AppHeader t={t} onBack={onBack}
          subtitle={`報價單 · #${String(quote.id).slice(-4)}`}
          title={quote.client}
          right={<StatusBadge t={t} status={quote.status} large />}
        />
        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '16px 20px 40px',
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          {(() => {
            const contact = (clients || []).find(c => c.name === quote.client);
            return (
              <Card t={t} onClick={() => onOpenClient?.(quote.client)}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <Avatar t={t} name={quote.client} />
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: t.fz(15), fontWeight: 700, color: t.ink }}>{quote.client}</div>
                    <div style={{ fontSize: t.fz(12), color: t.inkSoft, marginTop: 2, fontFamily: t.fontMono }}>
                      {contact ? contact.phone : '尚未加入客戶簿'}
                    </div>
                  </div>
                  <span style={{
                    fontSize: t.fz(12), color: t.accent, fontWeight: 600,
                    display: 'flex', alignItems: 'center', gap: 2,
                  }}>
                    查看客戶 <IconChevronRight size={13} stroke="currentColor" sw={2.2} />
                  </span>
                </div>
              </Card>
            );
          })()}
          <Card t={t}>
            <div style={{ display: 'flex', gap: 18, flexWrap: 'wrap' }}>
              <DetailFact t={t} icon={<IconMapPin size={13} stroke={t.inkSoft} />} label="地點" value={quote.location} />
              <DetailFact t={t} icon={<IconCalendar size={13} stroke={t.inkSoft} />} label="日期" value={quote.date} />
              {quote.folder && <DetailFact t={t} icon={<IconFolder size={13} stroke={t.inkSoft} />} label="分類" value={quote.folder} />}
            </div>
          </Card>

          <Card t={t}>
            <div style={{
              fontFamily: t.fontMono, fontSize: t.fz(11), color: t.inkSoft,
              letterSpacing: '0.15em', textTransform: 'uppercase', marginBottom: 10,
            }}>項目明細</div>
            {quote.itemList.map((it, i) => (
              <div key={i}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', padding: '8px 0' }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: t.fz(14), fontWeight: 600, color: t.ink }}>{it.name}</div>
                    <div style={{ fontSize: t.fz(12), color: t.inkSoft, fontFamily: t.fontMono, marginTop: 2 }}>
                      {it.qty} {it.unit} × ${it.price.toLocaleString()}
                    </div>
                  </div>
                  <Money t={t} amount={it.qty * it.price} size={15} color={t.ink} />
                </div>
                {i < quote.itemList.length - 1 && <Divider t={t} style={{ margin: 0 }} />}
              </div>
            ))}
          </Card>

          <Card t={t} accent={t.id !== 'blueprint'}>
            {[['小計', subtotal], ['稅金 5%', tax]].map(([l, v]) => (
              <div key={l} style={{
                display: 'flex', justifyContent: 'space-between', marginBottom: 6,
                fontSize: t.fz(13),
                color: t.id === 'blueprint' ? t.inkSoft : (t.accentSurfaceInkSoft || "rgba(245,242,236,0.7)"),
              }}>
                <span>{l}</span>
                <span style={{ fontFamily: t.fontMono }}>${v.toLocaleString()}</span>
              </div>
            ))}
            <div style={{
              height: 1, margin: '10px 0',
              background: t.id === 'blueprint' ? t.border : (t.accentSurfaceDivider || "rgba(245,242,236,0.2)"),
            }} />
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{
                fontSize: t.fz(14), fontWeight: 700,
                color: t.id === 'blueprint' ? t.ink : (t.accentSurfaceInk || t.bg),
              }}>總計</span>
              <Money t={t} amount={quote.total} size={26} color={t.id === 'blueprint' ? t.accent : t.accent2} />
            </div>
          </Card>

          <div style={{ display: 'flex', gap: 10 }}>
            <SecondaryButton t={t} style={{ flex: 1 }} onClick={() => {
              // In production: trigger iOS UIActivityViewController (or
              // navigator.share on web). The prototype just no-ops here.
              if (navigator.share) {
                navigator.share({
                  title: `報價單 #${String(quote.id).slice(-4)} · ${quote.client}`,
                  text: `${quote.client} 報價：$${quote.total.toLocaleString()}`,
                }).catch(() => {});
              }
            }}>
              <IconShare size={15} stroke="currentColor" /> 傳給客戶
            </SecondaryButton>
            <SecondaryButton t={t} style={{ flex: 1 }} onClick={() => setPdfPreviewOpen?.(true)}>
              <IconFileText size={15} stroke="currentColor" /> 預覽 PDF
            </SecondaryButton>
          </div>
          {/* Secondary actions row */}
          <div style={{ display: 'flex', gap: 10 }}>
            <SecondaryButton t={t} style={{ flex: 1, padding: '11px 12px', fontSize: t.fz(13) }}
              onClick={() => onCopy?.()}>
              <IconPlus size={14} stroke="currentColor" sw={2.4} /> 複製這張
            </SecondaryButton>
            {quote.status === 'done' || quote.status === 'ongoing' ? (
              <SecondaryButton t={t} style={{ flex: 1, padding: '11px 12px', fontSize: t.fz(13), borderColor: t.accent, color: t.accent }}
                onClick={() => onInvoice?.()}>
                <IconCoins size={14} stroke="currentColor" sw={2} /> 轉請款單
              </SecondaryButton>
            ) : null}
          </div>
        </div>
      </div>
      {pdfPreviewOpen && (
        <PDFPreviewSheet t={t} quote={quote} template={template}
          watermarked={!isPro}
          onClose={() => setPdfPreviewOpen(false)} />
      )}
    </div>
  );
}

function DetailFact({ t, icon, label, value }) {
  return (
    <div style={{ minWidth: 100 }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 4,
        fontSize: t.fz(11), color: t.inkSoft,
        fontFamily: t.id === 'blueprint' ? t.fontMono : t.fontSans,
        letterSpacing: t.id === 'blueprint' ? '0.1em' : 'normal',
        textTransform: t.id === 'blueprint' ? 'uppercase' : 'none',
        marginBottom: 4,
      }}>{icon} {label}</div>
      <div style={{ fontSize: t.fz(14), color: t.ink, fontWeight: 500 }}>{value}</div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// Stats Screen
// ────────────────────────────────────────────────────────────────────
function StatsScreen({ t, quotes, name, onHome, onOpenClient, onOpenItem, onSettings }) {
  const [year, setYear] = scUS(2026);
  const allYears = [...new Set(quotes.map(q => parseInt(q.date.slice(0, 4))))].sort((a, b) => b - a);
  const s = useYearStats(quotes, year);

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: t.bg, overflow: 'hidden',
    }}>
      <AppBackground t={t} />
      <div style={{
        position: 'relative', zIndex: 1, height: '100%',
        display: 'flex', flexDirection: 'column',
      }}>
        <AppHeader t={t} subtitle={name || '陳師傅'} title="營運統計" accent={t.id === 'refined'} />

        {/* Year switcher */}
        <div style={{ display: 'flex', gap: 8, padding: '14px 20px 0', overflowX: 'auto', scrollbarWidth: 'none', flexShrink: 0 }}>
          {allYears.map(y => {
            const active = year === y;
            return (
              <button key={y} onClick={() => setYear(y)} style={{
                background: active ? t.accent : 'transparent',
                color: active ? '#fff' : t.ink,
                border: `1.5px solid ${active ? t.accent : t.border}`,
                padding: '6px 14px',
                borderRadius: t.id === 'blueprint' ? 0 : 999,
                fontSize: t.fz(13), fontWeight: 600, cursor: 'pointer',
                whiteSpace: 'nowrap', flexShrink: 0,
                fontFamily: t.id === 'blueprint' ? t.fontMono : t.fontSans,
              }}>{y} 年</button>
            );
          })}
        </div>

        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '14px 20px 110px',
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          {/* Hero card — paid total */}
          <Card t={t} accent={t.id !== 'blueprint'} style={{ padding: 20 }}>
            <div style={{
              fontSize: t.fz(12),
              color: t.id === 'blueprint' ? t.accent : (t.accentSurfaceInkSoft || "rgba(245,242,236,0.7)"),
              fontFamily: t.fontMono, letterSpacing: '0.15em', textTransform: 'uppercase',
              marginBottom: 8,
            }}>
              {year} 年已收款 · {s.paidCount} 張
            </div>
            <Money t={t} amount={s.paidTotal} size={36}
              color={t.id === 'blueprint' ? t.accent : t.accent2} />
            <div style={{
              fontSize: t.fz(13),
              color: t.id === 'blueprint' ? t.inkSoft : (t.accentSurfaceInkSoft || "rgba(245,242,236,0.55)"),
              marginTop: 8,
              fontFamily: t.id === 'blueprint' ? t.fontMono : t.fontSans,
            }}>
              比去年同期 ▲ 18.4%（去年 ${(s.paidTotal * 0.82).toFixed(0).toLocaleString()}）
            </div>
          </Card>

          {/* 2-col mini stats */}
          <div style={{ display: 'flex', gap: 10 }}>
            <MiniStat t={t} label="待收款" value={s.doneTotal} sub={`${s.doneCount} 張完工`} color={t.positive} />
            <MiniStat t={t} label="進行中" value={s.ongoingTotal} sub={`${s.ongoingCount} 張施工`} color={t.accent} />
          </div>

          {/* Monthly chart */}
          <SectionTitle t={t}>每月已收款</SectionTitle>
          <Card t={t} style={{ padding: 14 }}>
            {s.monthly.map((amt, i) => {
              const pct = (amt / s.maxMonthly) * 100;
              const isMax = amt === s.maxMonthly && amt > 0;
              return (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: i < 11 ? 5 : 0 }}>
                  <div style={{
                    width: 28, fontSize: t.fz(11), color: t.inkSoft,
                    fontFamily: t.fontMono, flexShrink: 0,
                  }}>{MONTHS_TC[i]}</div>
                  <div style={{
                    flex: 1, height: 16,
                    background: t.id === 'blueprint' ? 'transparent' : t.bgSoft,
                    border: t.id === 'blueprint' ? `1px solid ${t.border}` : 'none',
                    borderRadius: t.id === 'blueprint' ? 0 : 3,
                    position: 'relative', overflow: 'hidden',
                  }}>
                    <div style={{
                      width: `${pct}%`, height: '100%',
                      background: isMax ? t.accent : t.accent2,
                    }} />
                  </div>
                  <div style={{
                    width: 60, fontSize: t.fz(11), textAlign: 'right',
                    fontFamily: t.fontMono, color: amt > 0 ? t.ink : t.inkFaint,
                  }}>{amt > 0 ? `$${Math.round(amt / 1000)}k` : '—'}</div>
                </div>
              );
            })}
          </Card>

          {/* Top client */}
          {s.topClient && (
            <>
              <SectionTitle t={t}>最大客戶</SectionTitle>
              <Card t={t} onClick={() => onOpenClient && onOpenClient(s.topClient[0])}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div>
                    <div style={{
                      display: 'flex', alignItems: 'center', gap: 6,
                      fontSize: t.fz(16), fontWeight: 700, fontFamily: t.fontDisplay,
                      color: t.ink,
                    }}>
                      🏆 {s.topClient[0]}
                      <IconChevronRight size={14} stroke={t.inkFaint} />
                    </div>
                    <div style={{ fontSize: t.fz(12), color: t.inkSoft, marginTop: 4 }}>
                      {s.topClient[1].count} 次合作
                    </div>
                  </div>
                  <Money t={t} amount={s.topClient[1].total} size={18} />
                </div>
              </Card>
            </>
          )}

          {/* Top items */}
          <SectionTitle t={t}>最常做的項目</SectionTitle>
          <Card t={t} padded={false}>
            {s.topItems.map(([name, d], i) => (
              <div key={name}
                onClick={() => onOpenItem && onOpenItem(name)}
                style={{
                  display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
                  borderTop: i > 0 ? `1px solid ${t.border}` : 'none',
                  cursor: 'pointer',
                }}>
                <div style={{
                  width: 26, height: 26,
                  borderRadius: t.id === 'blueprint' ? 0 : '50%',
                  background: i === 0 ? t.accent : t.bgSoft,
                  color: i === 0 ? '#fff' : t.inkSoft,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: t.fz(12), fontWeight: 700, fontFamily: t.fontMono,
                  flexShrink: 0,
                }}>{i + 1}</div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: t.fz(14), fontWeight: 600, color: t.ink }}>{name}</div>
                  <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono, marginTop: 2 }}>
                    {d.count} 次 · 共 {d.totalQty} {d.unit}
                  </div>
                </div>
                <Money t={t} amount={d.totalRev} size={13} color={t.inkMid} />
                <IconChevronRight size={14} stroke={t.inkFaint} />
              </div>
            ))}
          </Card>
        </div>
      </div>
      <TabBar t={t} current="stats" onHome={onHome} onStats={() => {}} onSettings={onSettings} />
    </div>
  );
}

function MiniStat({ t, label, value, sub, color }) {
  return (
    <Card t={t} style={{ flex: 1, padding: 14 }}>
      <div style={{
        fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono,
        letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 6,
      }}>{label}</div>
      <Money t={t} amount={value} size={17} color={color} />
      <div style={{ fontSize: t.fz(11), color: t.inkSoft, marginTop: 4 }}>{sub}</div>
    </Card>
  );
}

function SectionTitle({ t, children }) {
  return (
    <div style={{
      fontSize: t.fz(11), color: t.inkSoft,
      fontFamily: t.fontMono, letterSpacing: '0.15em', textTransform: 'uppercase',
      fontWeight: 700, marginTop: 8, marginBottom: -4,
    }}>{children}</div>
  );
}

// ────────────────────────────────────────────────────────────────────
// ClientDetailScreen — drill-in from stats
// ────────────────────────────────────────────────────────────────────
function ClientDetailScreen({ t, quotes, clients, clientName, onBack, onOpenQuote }) {
  const list = quotes.filter(q => q.client === clientName).sort((a, b) => b.date.localeCompare(a.date));
  const contact = (clients || []).find(c => c.name === clientName);
  const paid = list.filter(q => q.status === 'paid');
  const done = list.filter(q => q.status === 'done');
  const totalPaid = paid.reduce((s, q) => s + q.total, 0);
  const totalDone = done.reduce((s, q) => s + q.total, 0);
  const firstDate = list[list.length - 1]?.date;

  const itemCount = {};
  list.forEach(q => q.itemList?.forEach(it => {
    itemCount[it.name] = (itemCount[it.name] || 0) + 1;
  }));
  const favItems = Object.entries(itemCount).sort((a, b) => b[1] - a[1]).slice(0, 4);

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: t.bg, overflow: 'hidden',
    }}>
      <AppBackground t={t} />
      <div style={{
        position: 'relative', zIndex: 1, height: '100%',
        display: 'flex', flexDirection: 'column',
      }}>
        <AppHeader t={t} onBack={onBack} subtitle="客戶詳情" title={clientName} />
        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '16px 20px 40px',
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          <Card t={t} accent style={{ padding: 20 }}>
            <div style={{ fontSize: t.fz(12), color: (t.accentSurfaceInkSoft || "rgba(245,242,236,0.7)"), marginBottom: 8, fontFamily: t.fontMono, letterSpacing: '0.1em' }}>
              累計營收
            </div>
            <Money t={t} amount={totalPaid} size={32} color={t.accent2} />
            <div style={{ fontSize: t.fz(13), color: (t.accentSurfaceInkSoft || "rgba(245,242,236,0.6)"), marginTop: 10 }}>
              合作 {list.length} 次{firstDate && ` · 自 ${firstDate.slice(0, 7)} 起`}
            </div>
          </Card>

          {contact && (
            <Card t={t} padded={false}>
              <div style={{ padding: 14, display: 'flex', alignItems: 'center', gap: 10 }}>
                <IconPhone size={14} stroke={t.cool} sw={2} />
                <div style={{ flex: 1, fontSize: t.fz(14), color: t.ink, fontFamily: t.fontMono, letterSpacing: '0.02em' }}>{contact.phone}</div>
                <button style={{
                  padding: '4px 10px', background: t.cool + '15', color: t.cool,
                  border: 'none', borderRadius: 999, cursor: 'pointer',
                  fontSize: t.fz(12), fontWeight: 700, fontFamily: t.fontSans,
                }}>撥打</button>
              </div>
              {contact.email && (
                <div style={{ padding: '0 14px 12px', display: 'flex', alignItems: 'center', gap: 10, borderTop: `1px solid ${t.border}`, paddingTop: 12 }}>
                  <IconBuilding size={14} stroke={t.inkSoft} sw={2} />
                  <div style={{ flex: 1, fontSize: t.fz(13), color: t.ink }}>{contact.email}</div>
                </div>
              )}
              {contact.address && (
                <div style={{
                  padding: '12px 14px', display: 'flex', alignItems: 'flex-start', gap: 10,
                  borderTop: `1px solid ${t.border}`,
                }}>
                  <IconMapPin size={14} stroke={t.accent} sw={2} style={{ marginTop: 2, flexShrink: 0 }} />
                  <div style={{ flex: 1, fontSize: t.fz(13), color: t.ink, lineHeight: 1.5 }}>{contact.address}</div>
                  <button style={{
                    padding: '4px 10px', background: t.accent + '15', color: t.accent,
                    border: 'none', borderRadius: 999, cursor: 'pointer',
                    fontSize: t.fz(12), fontWeight: 700, fontFamily: t.fontSans,
                    flexShrink: 0,
                  }}>導航</button>
                </div>
              )}
              {contact.notes && (
                <div style={{
                  padding: '10px 14px', borderTop: `1px solid ${t.border}`,
                  background: t.surfaceAlt,
                  fontSize: t.fz(12), color: t.inkSoft, lineHeight: 1.55,
                }}>
                  📝 {contact.notes}
                </div>
              )}
            </Card>
          )}

          {totalDone > 0 && (
            <Card t={t} style={{ borderLeft: `4px solid ${t.positive}` }}>
              <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono, letterSpacing: '0.1em', marginBottom: 4 }}>
                待收款
              </div>
              <Money t={t} amount={totalDone} size={20} color={t.positive} />
              <div style={{ fontSize: t.fz(12), color: t.inkSoft, marginTop: 2 }}>{done.length} 張已完工待收</div>
            </Card>
          )}

          {favItems.length > 0 && (
            <>
              <SectionTitle t={t}>常為他做</SectionTitle>
              <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                {favItems.map(([n, c]) => (
                  <span key={n} style={{
                    padding: '6px 12px', borderRadius: 999, background: t.surface,
                    border: `1px solid ${t.border}`, fontSize: t.fz(13), color: t.ink,
                  }}>
                    {n} <span style={{ color: t.inkFaint, marginLeft: 4 }}>×{c}</span>
                  </span>
                ))}
              </div>
            </>
          )}

          <SectionTitle t={t}>歷史報價單（{list.length} 張）</SectionTitle>
          {list.map(q => (
            <Card key={q.id} t={t} onClick={() => onOpenQuote(q.id)}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
                <div style={{ fontSize: t.fz(13), color: t.inkSoft, fontFamily: t.fontMono }}>{q.date}</div>
                <StatusBadge t={t} status={q.status} />
              </div>
              <div style={{ fontSize: t.fz(13), color: t.inkSoft, marginBottom: 8 }}>{q.location}</div>
              <Divider t={t} style={{ margin: '0 0 8px' }} />
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: t.fz(12), color: t.inkSoft }}>{q.itemList?.length || 0} 個項目</span>
                <Money t={t} amount={q.total} size={16} />
              </div>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// ItemDetailScreen — drill-in: price history for one item type
// ────────────────────────────────────────────────────────────────────
function ItemDetailScreen({ t, quotes, itemName, onBack }) {
  const records = [];
  quotes.forEach(q => q.itemList?.forEach(it => {
    if (it.name === itemName) records.push({
      date: q.date, client: q.client, qty: it.qty, unit: it.unit, price: it.price, status: q.status,
    });
  }));
  records.sort((a, b) => b.date.localeCompare(a.date));

  const prices = records.map(r => r.price);
  const minP = Math.min(...prices), maxP = Math.max(...prices);
  const latest = records[0]?.price;
  const oldest = records[records.length - 1]?.price;
  const trend = oldest && latest && oldest !== latest
    ? ((latest - oldest) / oldest) * 100 : 0;
  const totalQty = records.reduce((s, r) => s + r.qty, 0);
  const totalRev = records.reduce((s, r) => s + r.qty * r.price, 0);
  const unit = records[0]?.unit || '';

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: t.bg, overflow: 'hidden',
    }}>
      <AppBackground t={t} />
      <div style={{
        position: 'relative', zIndex: 1, height: '100%',
        display: 'flex', flexDirection: 'column',
      }}>
        <AppHeader t={t} onBack={onBack} subtitle="項目分析" title={itemName} />
        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '16px 20px 40px',
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          <Card t={t} accent style={{ padding: 20 }}>
            <div style={{ fontSize: t.fz(12), color: (t.accentSurfaceInkSoft || "rgba(245,242,236,0.7)"), marginBottom: 8, fontFamily: t.fontMono, letterSpacing: '0.1em' }}>
              累積營收（{records.length} 次）
            </div>
            <Money t={t} amount={totalRev} size={30} color={t.accent2} />
            <div style={{ fontSize: t.fz(13), color: (t.accentSurfaceInkSoft || "rgba(245,242,236,0.6)"), marginTop: 8 }}>
              共做了 {totalQty} {unit}
            </div>
          </Card>

          <div style={{ display: 'flex', gap: 10 }}>
            <Card t={t} style={{ flex: 1, padding: 14 }}>
              <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono, letterSpacing: '0.1em', marginBottom: 4 }}>最近單價</div>
              <Money t={t} amount={latest || 0} size={18} color={t.ink} />
              <div style={{ fontSize: t.fz(11), color: t.inkSoft, marginTop: 4 }}>/ {unit}</div>
            </Card>
            <Card t={t} style={{ flex: 1, padding: 14 }}>
              <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono, letterSpacing: '0.1em', marginBottom: 4 }}>價格趨勢</div>
              <div style={{ fontSize: t.fz(18), fontWeight: 700, color: trend > 0 ? t.accent : (trend < 0 ? t.positive : t.inkSoft), fontFamily: t.fontNumeric }}>
                {trend > 0 ? '▲' : trend < 0 ? '▼' : '—'} {Math.abs(trend).toFixed(1)}%
              </div>
              <div style={{ fontSize: t.fz(11), color: t.inkSoft, marginTop: 4 }}>
                範圍 ${minP.toLocaleString()}–${maxP.toLocaleString()}
              </div>
            </Card>
          </div>

          <SectionTitle t={t}>單價歷史</SectionTitle>
          <Card t={t} padded={false}>
            {records.map((r, i) => (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
                borderTop: i > 0 ? `1px solid ${t.border}` : 'none',
              }}>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: t.fz(14), fontWeight: 600, color: t.ink }}>{r.client}</div>
                  <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono, marginTop: 2 }}>
                    {r.date} · {r.qty} {r.unit}
                  </div>
                </div>
                <Money t={t} amount={r.price} size={14} color={t.ink} />
                <div style={{
                  fontSize: t.fz(10), padding: '2px 6px', borderRadius: 999,
                  color: r.price === maxP ? t.accent : (r.price === minP ? t.positive : t.inkFaint),
                  background: r.price === maxP ? t.accent + '15' : (r.price === minP ? t.positive + '15' : 'transparent'),
                  fontFamily: t.fontMono, fontWeight: 700,
                }}>
                  {r.price === maxP ? '最高' : r.price === minP ? '最低' : ''}
                </div>
              </div>
            ))}
          </Card>
        </div>
      </div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// Settings row + toggle + labels for international tokens
// ────────────────────────────────────────────────────────────────────
const CURRENCY_LABEL = {
  TWD: 'NT$ (新台幣)',
  VND: '₫ (越南盾)',
  IDR: 'Rp (印尼盾)',
  USD: '$ (US Dollar)',
  MYR: 'RM (馬來令吉)',
  PHP: '₱ (披索)',
};
const LANGUAGE_LABEL = {
  'zh-Hant': '繁體中文',
  'zh-Hans': '簡體中文',
  'en':      'English',
  'vi':      'Tiếng Việt',
  'id':      'Bahasa Indonesia',
};
const TAX_REGION = {
  TWD: '台灣營業稅',
  VND: '越南 VAT 10%',
  IDR: '印尼 PPN 11%',
  MYR: '馬來 SST 6%',
  PHP: '菲律賓 VAT 12%',
  USD: 'no tax',
};

function SettingsRow({ t, icon, label, hint, right, onClick, proLabel, isLast }) {
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
      borderTop: 'none',
      borderBottom: isLast ? 'none' : `1px solid ${t.border}`,
      cursor: onClick ? 'pointer' : 'default',
    }}>
      {icon && <div style={{
        width: 30, height: 30, borderRadius: 8,
        background: t.surfaceAlt, color: t.accent,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
      }}>{icon}</div>}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: t.fz(15), fontWeight: 600, color: t.ink, display: 'flex', alignItems: 'center', gap: 6 }}>
          {label}
          {proLabel && (
            <span style={{
              fontSize: t.fz(9), padding: '1px 5px', borderRadius: 3,
              background: t.accent, color: '#fff', fontFamily: t.fontMono,
              fontWeight: 700, letterSpacing: '0.05em',
            }}>{proLabel}</span>
          )}
        </div>
        {hint && <div style={{ fontSize: t.fz(11), color: t.inkSoft, marginTop: 2 }}>{hint}</div>}
      </div>
      {right || <IconChevronRight size={16} stroke={t.inkFaint} />}
    </div>
  );
}

function RowValue({ t, value }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
      <span style={{ fontSize: t.fz(13), color: t.inkSoft }}>{value}</span>
      <IconChevronRight size={14} stroke={t.inkFaint} />
    </div>
  );
}

function Toggle({ t, on, onChange }) {
  return (
    <button onClick={onChange} aria-pressed={on} style={{
      width: 44, height: 26, borderRadius: 13, padding: 3,
      background: on ? t.accent : t.border,
      transition: 'background 0.2s', cursor: 'pointer',
      display: 'flex', alignItems: 'center', border: 'none',
      flexShrink: 0,
    }}>
      <div style={{
        width: 20, height: 20, borderRadius: '50%', background: '#fff',
        transform: on ? 'translateX(18px)' : 'translateX(0)',
        transition: 'transform 0.2s',
        boxShadow: '0 1px 2px rgba(0,0,0,0.2)',
      }} />
    </button>
  );
}

// ────────────────────────────────────────────────────────────────────
// SettingsScreen — manage 抬頭, 分類, 自訂項目, 稅率
// ────────────────────────────────────────────────────────────────────
function SettingsScreen({ t, name, setName, categories, setCategories, customLibrary, setCustomLibrary, taxRate, setTaxRate, isPro, currency, setCurrency, language, setLanguage, onBack, onHome, onStats, onOpenContacts, onOpenPDFTemplate, onOpenPaywall }) {
  const [newCat, setNewCat] = scUS('');
  const [editingCat, setEditingCat] = scUS(null);
  const [editingItemIdx, setEditingItemIdx] = scUS(null);

  const cats = (categories || ['常用', '拆除', '水電', '泥作', '木作']).filter(c => c !== '常用');
  const fixedCats = new Set(['拆除', '水電', '泥作', '木作', '油漆']);

  const addCat = () => {
    if (!newCat.trim()) return;
    setCategories?.([...(categories || ['常用', '拆除', '水電', '泥作', '木作']), newCat.trim()]);
    setNewCat('');
  };
  const deleteCat = (c) => {
    setCategories?.((categories || []).filter(x => x !== c));
  };

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: t.bg, overflow: 'hidden',
    }}>
      <AppBackground t={t} />
      <div style={{
        position: 'relative', zIndex: 1, height: '100%',
        display: 'flex', flexDirection: 'column',
      }}>
        <AppHeader t={t} subtitle="師傅號 · v2.0" title="設定" accent={t.id === 'refined'} />
        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '16px 20px 110px',
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          {/* PRO upsell / status */}
          {isPro ? (
            <Card t={t} style={{ borderLeft: `4px solid ${t.positive}` }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <IconSparkle size={22} stroke={t.positive} sw={2} />
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: t.fz(15), fontWeight: 700, color: t.ink }}>師傅號 PRO · 已訂閱</div>
                  <div style={{ fontSize: t.fz(11), color: t.inkSoft, marginTop: 2 }}>下次扣款 2027-05-20 · 年費 $2,400</div>
                </div>
              </div>
            </Card>
          ) : (
            <Card t={t} onClick={onOpenPaywall}
              style={{ background: t.accentSurface || t.ink, color: t.accentSurfaceInk || t.bg, cursor: 'pointer' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <IconSparkle size={22} stroke={t.accent2} sw={2} />
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: t.fz(15), fontWeight: 700, color: t.accent2 }}>升級到師傅號 PRO</div>
                  <div style={{ fontSize: t.fz(11), color: (t.accentSurfaceInkSoft || 'rgba(245,242,236,0.7)'), marginTop: 2 }}>
                    無限報價單 · 自訂模板 · 移除浮水印 · iCloud 備份
                  </div>
                </div>
                <IconChevronRight size={16} stroke={t.accentSurfaceInk || t.bg} />
              </div>
            </Card>
          )}

          {/* iCloud sync */}
          <SectionTitle t={t}>同步與備份</SectionTitle>
          <Card t={t}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <div style={{
                width: 8, height: 8, borderRadius: '50%',
                background: isPro ? t.positive : t.inkFaint,
              }} />
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: t.fz(15), fontWeight: 600, color: t.ink }}>iCloud 自動備份</div>
                <div style={{ fontSize: t.fz(12), color: t.inkSoft, marginTop: 2 }}>
                  {isPro ? '已啟用 · 最後同步 12 秒前' : '需要 PRO · 換手機資料自動還原'}
                </div>
              </div>
              <Toggle t={t} on={isPro} onChange={() => { if (!isPro) onOpenPaywall?.(); }} />
            </div>
          </Card>

          {/* 個人 / 抬頭 */}
          <SectionTitle t={t}>個人</SectionTitle>
          <Card t={t}>
            <FieldLabel t={t}>報價單抬頭</FieldLabel>
            <TextInput t={t} value={name || ''} onChange={e => setName?.(e.target.value)}
              placeholder="例：陳師傅 / 大發工程行" />
            <div style={{ fontSize: t.fz(11), color: t.inkFaint, marginTop: 6 }}>
              出現在每張報價單的左上方
            </div>
          </Card>

          {/* 商務 */}
          <SectionTitle t={t}>商務</SectionTitle>
          <Card t={t} padded={false}>
            <SettingsRow t={t} icon={<IconUser size={16} stroke={t.accent} />} label="客戶簿"
              hint="所有客戶與聯絡資料" onClick={onOpenContacts} />
            <SettingsRow t={t} icon={<IconStamp size={16} stroke={t.accent} />} label="報價單模板（PDF）"
              hint="Logo、抬頭、付款條件、印章" onClick={onOpenPDFTemplate}
              proLabel={!isPro && 'PRO'} />
          </Card>

          {/* 項目分類 */}
          <SectionTitle t={t}>項目分類</SectionTitle>
          <Card t={t} padded={false}>
            {cats.map((c, i) => (
              <div key={c} style={{
                display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
                borderTop: i > 0 ? `1px solid ${t.border}` : 'none',
              }}>
                <div style={{
                  width: 6, height: 6, borderRadius: '50%', background: t.accent,
                }} />
                {editingCat === c ? (
                  <input autoFocus defaultValue={c}
                    onBlur={e => {
                      const v = e.target.value.trim();
                      if (v && v !== c) {
                        setCategories?.((categories || []).map(x => x === c ? v : x));
                      }
                      setEditingCat(null);
                    }}
                    onKeyDown={e => e.key === 'Enter' && e.target.blur()}
                    style={{
                      flex: 1, padding: '4px 8px',
                      fontSize: t.fz(15), background: t.surfaceAlt,
                      border: `1.5px solid ${t.accent}`, borderRadius: 6,
                      color: t.ink, fontFamily: t.fontSans,
                    }} />
                ) : (
                  <div style={{ flex: 1, fontSize: t.fz(15), color: t.ink, fontWeight: 500 }}>{c}</div>
                )}
                <button onClick={() => setEditingCat(c)} style={{
                  background: 'transparent', border: 'none', cursor: 'pointer',
                  color: t.inkSoft, padding: 4, display: 'flex', fontSize: t.fz(12), fontWeight: 600,
                }}>編輯</button>
                {!fixedCats.has(c) && (
                  <button onClick={() => deleteCat(c)} style={{
                    background: 'transparent', border: 'none', cursor: 'pointer',
                    color: t.accent, padding: 4, display: 'flex',
                  }}>
                    <IconTrash size={15} stroke="currentColor" />
                  </button>
                )}
              </div>
            ))}
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8, padding: '10px 14px',
              borderTop: `1px solid ${t.border}`, background: t.surfaceAlt,
            }}>
              <input value={newCat} onChange={e => setNewCat(e.target.value)}
                onKeyDown={e => e.key === 'Enter' && addCat()}
                placeholder="加新分類，例：清潔、家具"
                style={{
                  flex: 1, padding: '6px 8px', fontSize: t.fz(14),
                  background: t.surface, border: `1px solid ${t.border}`,
                  borderRadius: 6, color: t.ink, fontFamily: t.fontSans,
                }} />
              <button onClick={addCat} style={{
                padding: '6px 12px', background: newCat.trim() ? t.accent : t.bgSoft,
                color: newCat.trim() ? '#fff' : t.inkFaint,
                border: 'none', borderRadius: 6, cursor: 'pointer',
                fontSize: t.fz(13), fontWeight: 600, fontFamily: t.fontSans,
                display: 'flex', alignItems: 'center', gap: 4,
              }}>
                <IconPlus size={13} stroke="currentColor" sw={2.5} /> 加
              </button>
            </div>
          </Card>

          {/* 自訂項目 */}
          <SectionTitle t={t}>我的自訂項目（{(customLibrary || []).length}）</SectionTitle>
          {(customLibrary || []).length === 0 ? (
            <Card t={t}>
              <div style={{
                fontSize: t.fz(13), color: t.inkSoft, lineHeight: 1.55, textAlign: 'center',
                padding: '6px 0',
              }}>
                還沒加過自訂項目。
                <br />
                在「新增報價單 → 加項目 → + 自訂」就能加。
              </div>
            </Card>
          ) : (
            <Card t={t} padded={false}>
              {customLibrary.map((it, i) => (
                <CustomLibraryRow
                  key={i} t={t} item={it} isEditing={editingItemIdx === i}
                  categories={cats}
                  onStartEdit={() => setEditingItemIdx(i)}
                  onCancelEdit={() => setEditingItemIdx(null)}
                  onSave={(patch) => {
                    setCustomLibrary?.((customLibrary || []).map((x, j) => j === i ? { ...x, ...patch } : x));
                    setEditingItemIdx(null);
                  }}
                  onDelete={() => {
                    setCustomLibrary?.((customLibrary || []).filter((_, j) => j !== i));
                  }}
                  showDivider={i > 0}
                />
              ))}
            </Card>
          )}

          {/* 國際化 */}
          <SectionTitle t={t}>國際化</SectionTitle>
          <Card t={t} padded={false}>
            <SettingsRow t={t} icon={<IconCoins size={16} stroke={t.cool} />} label="貨幣"
              right={<RowValue t={t} value={CURRENCY_LABEL[currency] || 'NT$ (新台幣)'} />}
              onClick={() => {}} />
            <SettingsRow t={t} icon={<IconBuilding size={16} stroke={t.cool} />} label="語言"
              right={<RowValue t={t} value={LANGUAGE_LABEL[language] || '繁體中文'} />}
              onClick={() => {}} />
            <SettingsRow t={t} icon={<IconFileText size={16} stroke={t.cool} />} label="稅制"
              right={<RowValue t={t} value={`${taxRate}% · ${TAX_REGION[currency] || '台灣營業稅'}`} />}
              onClick={() => {}} isLast />
          </Card>

          {/* 其他 */}
          <SectionTitle t={t}>其他</SectionTitle>
          <Card t={t} padded={false}>
            <SettingsRow t={t} icon={<IconShare size={16} stroke={t.inkSoft} />} label="匯出全部資料"
              hint="備份成 Excel / CSV" onClick={() => {}} />
            <SettingsRow t={t} icon={<IconSettings size={16} stroke={t.inkSoft} />} label="App 設定"
              hint="通知、深色模式、字體大小" onClick={() => {}} isLast />
          </Card>

          <div style={{
            textAlign: 'center', padding: '20px 0 10px',
            fontSize: t.fz(11), color: t.inkFaint, fontFamily: t.fontMono,
          }}>
            師傅號 · v2.0 · build 2026.05.20
          </div>
        </div>
      </div>
      <TabBar t={t} current="settings" onHome={onHome} onStats={onStats} onSettings={() => {}} />
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// CustomLibraryRow — settings row for a custom item, inline editable
// ────────────────────────────────────────────────────────────────────
function CustomLibraryRow({ t, item, isEditing, categories, onStartEdit, onCancelEdit, onSave, onDelete, showDivider }) {
  const [draft, setDraftR] = scUS(item);
  const units = ['坪', '式', '個', '組', '尺', '車', '人/日'];

  React.useEffect(() => { setDraftR(item); }, [item, isEditing]);

  if (!isEditing) {
    return (
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
        borderTop: showDivider ? `1px solid ${t.border}` : 'none',
      }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: t.fz(15), fontWeight: 600, color: t.ink }}>{item.name}</div>
          <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono, marginTop: 2 }}>
            ${item.price.toLocaleString()} / {item.unit}
            <span style={{ color: t.accent, marginLeft: 6 }}>· {item.category}</span>
          </div>
        </div>
        <button onClick={onStartEdit} aria-label="編輯" style={{
          background: 'transparent', border: 'none', cursor: 'pointer',
          color: t.inkSoft, padding: 6, display: 'flex',
          fontSize: t.fz(12), fontWeight: 600,
        }}>編輯</button>
        <button onClick={onDelete} aria-label="刪除" style={{
          background: 'transparent', border: 'none', cursor: 'pointer',
          color: t.accent, padding: 6, display: 'flex',
        }}>
          <IconTrash size={14} stroke="currentColor" />
        </button>
      </div>
    );
  }

  return (
    <div style={{
      padding: '14px 14px',
      borderTop: showDivider ? `1px solid ${t.border}` : 'none',
      background: t.surfaceAlt,
      display: 'flex', flexDirection: 'column', gap: 10,
    }}>
      <FieldLabel t={t}>項目名稱</FieldLabel>
      <TextInput t={t} value={draft.name}
        onChange={e => setDraftR({ ...draft, name: e.target.value })} />

      <FieldLabel t={t}>分類</FieldLabel>
      <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
        {categories.map(c => {
          const on = draft.category === c;
          return (
            <button key={c} onClick={() => setDraftR({ ...draft, category: c })} style={{
              padding: '5px 11px', fontSize: t.fz(12),
              background: on ? t.accent : t.surface,
              color: on ? '#fff' : t.ink,
              border: `1px solid ${on ? t.accent : t.border}`,
              borderRadius: 999, cursor: 'pointer', fontFamily: t.fontSans, fontWeight: 600,
            }}>{c}</button>
          );
        })}
      </div>

      <div style={{ display: 'flex', gap: 10 }}>
        <div style={{ flex: 1 }}>
          <FieldLabel t={t}>單位</FieldLabel>
          <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
            {units.map(u => {
              const on = draft.unit === u;
              return (
                <button key={u} onClick={() => setDraftR({ ...draft, unit: u })} style={{
                  padding: '5px 9px', fontSize: t.fz(12),
                  background: on ? t.ink : t.surface,
                  color: on ? t.bg : t.ink,
                  border: `1px solid ${on ? t.ink : t.border}`,
                  borderRadius: 999, cursor: 'pointer', fontFamily: t.fontSans, fontWeight: 600,
                }}>{u}</button>
              );
            })}
          </div>
        </div>
        <div style={{ width: 110 }}>
          <FieldLabel t={t}>單價</FieldLabel>
          <TextInput t={t} value={draft.price}
            onChange={e => setDraftR({ ...draft, price: Number(e.target.value.replace(/[^\d]/g, '')) || 0 })} />
        </div>
      </div>

      <div style={{ display: 'flex', gap: 8, marginTop: 4 }}>
        <SecondaryButton t={t} onClick={onCancelEdit} style={{ flex: 1 }}>
          取消
        </SecondaryButton>
        <div style={{ flex: 1 }}>
          <PrimaryButton t={t} onClick={() => onSave(draft)}>
            <IconCheck size={16} stroke="currentColor" sw={2.5} /> 儲存
          </PrimaryButton>
        </div>
      </div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// TabBar
// ────────────────────────────────────────────────────────────────────
function TabBar({ t, current, onHome, onStats, onSettings }) {
  const items = [
    { key: 'home',     label: '報價單', icon: IconFileText, action: onHome },
    { key: 'stats',    label: '統計',   icon: IconChart,    action: onStats },
    { key: 'settings', label: '設定',   icon: IconSettings, action: onSettings },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 10,
      background: t.surface,
      borderTop: `1px solid ${t.border}`,
      padding: '6px 0 24px',
      display: 'flex',
    }}>
      {items.map(it => {
        const active = current === it.key;
        const I = it.icon;
        return (
          <button key={it.key} onClick={it.action} style={{
            flex: 1, background: 'transparent', border: 'none', cursor: 'pointer',
            padding: '6px 0', display: 'flex', flexDirection: 'column',
            alignItems: 'center', gap: 3,
            color: active ? t.accent : t.inkSoft,
            fontFamily: t.id === 'blueprint' ? t.fontMono : t.fontSans,
            fontSize: t.fz(11), fontWeight: 600,
            letterSpacing: t.id === 'blueprint' ? '0.1em' : 'normal',
            textTransform: t.id === 'blueprint' ? 'uppercase' : 'none',
          }}>
            <I size={20} stroke="currentColor" sw={active ? 2.4 : 2} />
            {it.label}
          </button>
        );
      })}
    </div>
  );
}

Object.assign(window, {
  HomeScreen, NewQuoteInfoScreen, NewQuoteItemsScreen, NewQuoteItemsScreenSheet,
  CustomItemForm, PickerSheet, LocationPickerSheet, FauxMap,
  NewQuoteReviewScreen, ExportedScreen, DetailScreen, StatsScreen,
  ClientDetailScreen, ItemDetailScreen, SettingsScreen,
  SettingsRow, RowValue, Toggle, CURRENCY_LABEL, LANGUAGE_LABEL, TAX_REGION,
  TabBar,
});
