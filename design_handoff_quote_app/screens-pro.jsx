// Pro/premium feature screens — added on top of the core flow:
// contacts, PDF template, invoice conversion, share sheet, paywall.
// All themed via the shared `t` resolved theme.

const { useState: spUS } = React;

// ────────────────────────────────────────────────────────────────────
// ContactsScreen — 客戶簿. Lists every client with quick actions
// (call, navigate, new quote for this client).
// ────────────────────────────────────────────────────────────────────
function ContactsScreen({ t, clients, quotes, onBack, onOpenClient, initialAddOpen, onAddClient }) {
  const [search, setSearch] = spUS('');
  const [addOpen, setAddOpen] = spUS(!!initialAddOpen);
  // group by first-letter / pinyin for nicer browsing in real impl;
  // for the mock we just filter.
  const filtered = (clients || []).filter(c =>
    !search || c.name.includes(search) || c.phone.includes(search) || (c.address || '').includes(search)
  );

  // count quotes per client + paid total
  const stats = {};
  (quotes || []).forEach(q => {
    if (!stats[q.client]) stats[q.client] = { count: 0, paid: 0 };
    stats[q.client].count += 1;
    if (q.status === 'paid') stats[q.client].paid += q.total;
  });

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
        <AppHeader t={t} onBack={onBack} subtitle="師傅的人脈" title="客戶簿" accent={t.id === 'refined'}
          right={
            <button onClick={() => setAddOpen(true)} aria-label="新增客戶" style={{
              background: 'transparent', border: 'none', cursor: 'pointer',
              color: t.id === 'refined' ? t.accent2 : t.accent,
              padding: 8, marginRight: -8, display: 'flex',
            }}>
              <IconPlus size={26} stroke="currentColor" sw={2.2} />
            </button>
          }
        />
        <div style={{ padding: '14px 20px 8px', flexShrink: 0 }}>
          <TextInput t={t} value={search} onChange={e => setSearch(e.target.value)}
            placeholder="搜尋客戶名、電話、地址"
            leadingIcon={<IconSearch size={16} stroke={t.inkSoft} />} />
        </div>
        <div style={{
          flex: 1, overflowY: 'auto', padding: '6px 20px 40px',
          display: 'flex', flexDirection: 'column', gap: 8,
        }}>
          {filtered.map(c => {
            const s = stats[c.name] || { count: 0, paid: 0 };
            return (
              <Card key={c.id} t={t} onClick={() => onOpenClient(c.name)}>
                <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
                  <Avatar t={t} name={c.name} />
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{
                      fontFamily: t.fontDisplay, fontSize: t.fz(16), fontWeight: 700,
                      color: t.ink, marginBottom: 4,
                    }}>{c.name}</div>
                    <div style={{ fontSize: t.fz(12), color: t.inkSoft, display: 'flex', alignItems: 'center', gap: 4, marginBottom: 2 }}>
                      <IconPhone size={11} stroke={t.inkSoft} sw={2} /> {c.phone}
                    </div>
                    {c.address && (
                      <div style={{ fontSize: t.fz(12), color: t.inkSoft, display: 'flex', alignItems: 'center', gap: 4 }}>
                        <IconMapPin size={11} stroke={t.inkSoft} sw={2} />
                        <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{c.address}</span>
                      </div>
                    )}
                  </div>
                  <div style={{ textAlign: 'right', flexShrink: 0 }}>
                    <div style={{ fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono }}>{s.count} 案</div>
                    <Money t={t} amount={s.paid} size={13} color={t.ink} />
                  </div>
                </div>
                {/* Quick actions */}
                <div style={{ display: 'flex', gap: 6, marginTop: 12, paddingTop: 10, borderTop: `1px solid ${t.border}` }}>
                  <QuickActionButton t={t} icon={<IconPhone size={13} stroke="currentColor" sw={2.2} />} label="撥打" onClick={(e) => { e.stopPropagation(); }} />
                  <QuickActionButton t={t} icon={<IconMapPin size={13} stroke="currentColor" sw={2.2} />} label="導航" onClick={(e) => { e.stopPropagation(); }} />
                  <QuickActionButton t={t} icon={<IconPlus size={13} stroke="currentColor" sw={2.5} />} label="新報價" onClick={(e) => { e.stopPropagation(); }} primary />
                </div>
              </Card>
            );
          })}
          {filtered.length === 0 && (
            <div style={{ textAlign: 'center', padding: '50px 0', color: t.inkSoft, fontSize: t.fz(14) }}>
              找不到客戶
            </div>
          )}
        </div>
      </div>
      {addOpen && (
        <NewClientSheet t={t}
          onClose={() => setAddOpen(false)}
          onSave={(data) => { onAddClient?.(data); setAddOpen(false); }} />
      )}
    </div>
  );
}

function Avatar({ t, name }) {
  const ch = name?.slice(0, 1) || '?';
  return (
    <div style={{
      width: 40, height: 40, borderRadius: '50%',
      background: t.surfaceAlt, color: t.inkMid,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontFamily: t.fontDisplay, fontSize: t.fz(17), fontWeight: 700,
      flexShrink: 0, border: `1px solid ${t.border}`,
    }}>{ch}</div>
  );
}

function QuickActionButton({ t, icon, label, onClick, primary = false }) {
  return (
    <button onClick={onClick} style={{
      flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4,
      padding: '7px 0', background: primary ? t.accent : 'transparent',
      color: primary ? '#fff' : t.ink,
      border: primary ? 'none' : `1px solid ${t.border}`,
      borderRadius: t.radius, fontSize: t.fz(12), fontWeight: 600, cursor: 'pointer',
      fontFamily: t.fontSans,
    }}>
      {icon} {label}
    </button>
  );
}

// ────────────────────────────────────────────────────────────────────
// NewClientSheet — add a new client (name / phone / email / address / notes)
// Presented as iOS page-sheet from the Contacts screen.
// ────────────────────────────────────────────────────────────────────
function NewClientSheet({ t, onClose, onSave }) {
  const [draft, setDraft] = spUS({ name: '', phone: '', email: '', address: '', notes: '' });
  const [mapOpen, setMapOpen] = spUS(false);
  const canSave = draft.name.trim();

  return (
    <>
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
          @keyframes sheetUp { from { transform: translateY(100%); } to { transform: translateY(0); } }
        `}</style>

        {/* drag handle */}
        <div style={{ padding: '10px 0 4px', display: 'flex', justifyContent: 'center', flexShrink: 0 }}>
          <div style={{ width: 38, height: 5, borderRadius: 3, background: t.borderStrong, opacity: 0.6 }} />
        </div>

        {/* header */}
        <div style={{
          padding: '4px 16px 14px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          flexShrink: 0, borderBottom: `1px solid ${t.border}`,
        }}>
          <button onClick={onClose} style={{
            background: 'transparent', border: 'none', cursor: 'pointer',
            padding: 4, color: t.inkSoft, fontSize: t.fz(15), fontFamily: t.fontSans,
          }}>取消</button>
          <div style={{ fontFamily: t.fontDisplay, fontSize: t.fz(17), fontWeight: 700, color: t.ink }}>
            新增客戶
          </div>
          <button onClick={() => canSave && onSave({ ...draft, id: 'c' + Date.now(), lastContact: new Date().toISOString().slice(0, 10) })} style={{
            background: 'transparent', border: 'none', cursor: canSave ? 'pointer' : 'default',
            padding: 4, color: canSave ? t.accent : t.inkFaint,
            fontSize: t.fz(15), fontFamily: t.fontSans, fontWeight: 700,
          }}>儲存</button>
        </div>

        {/* form */}
        <div style={{
          flex: 1, overflowY: 'auto', padding: '18px 20px 24px',
          display: 'flex', flexDirection: 'column', gap: 14,
        }}>
          {/* big avatar preview */}
          <div style={{
            display: 'flex', justifyContent: 'center', padding: '8px 0 4px',
          }}>
            <div style={{
              width: 72, height: 72, borderRadius: '50%',
              background: draft.name ? t.accent + '22' : t.surfaceAlt,
              color: draft.name ? t.accent : t.inkFaint,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontFamily: t.fontDisplay, fontSize: t.fz(28), fontWeight: 700,
              border: `1.5px ${draft.name ? 'solid' : 'dashed'} ${draft.name ? t.accent : t.borderStrong}`,
              transition: 'all 0.2s',
            }}>
              {draft.name ? draft.name.slice(0, 1) : '+'}
            </div>
          </div>

          <FieldRow t={t} label="客戶稱呼  ＊"
            icon={<IconUser size={15} stroke={t.inkSoft} />}>
            <TextInput t={t} value={draft.name}
              onChange={e => setDraft({ ...draft, name: e.target.value })}
              placeholder="例：王先生、林太太、陳老闆" />
          </FieldRow>

          <FieldRow t={t} label="電話"
            icon={<IconPhone size={15} stroke={t.inkSoft} />}>
            <TextInput t={t} value={draft.phone}
              onChange={e => setDraft({ ...draft, phone: e.target.value })}
              placeholder="0912-345-678" />
          </FieldRow>

          <FieldRow t={t} label="Email（可省略）"
            icon={<IconBuilding size={15} stroke={t.inkSoft} />}>
            <TextInput t={t} value={draft.email}
              onChange={e => setDraft({ ...draft, email: e.target.value })}
              placeholder="example@email.com" />
          </FieldRow>

          <FieldRow t={t} label="工程地址"
            icon={<IconMapPin size={15} stroke={t.inkSoft} />}>
            <div style={{ display: 'flex', gap: 8 }}>
              <div style={{ flex: 1 }}>
                <TextInput t={t} value={draft.address}
                  onChange={e => setDraft({ ...draft, address: e.target.value })}
                  placeholder="例：台北市信義區松仁路" />
              </div>
              <button onClick={() => setMapOpen(true)} style={{
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

          <FieldRow t={t} label="備註（可省略）"
            icon={<IconFileText size={15} stroke={t.inkSoft} />}>
            <textarea value={draft.notes}
              onChange={e => setDraft({ ...draft, notes: e.target.value })}
              placeholder="例：張先生介紹、喜歡北歐風、付款乾脆⋯"
              rows={3}
              style={{
                width: '100%', boxSizing: 'border-box', padding: 12,
                border: `1.5px solid ${t.border}`, borderRadius: t.radius,
                background: t.surface, color: t.ink, fontSize: t.fz(14),
                fontFamily: t.fontSans, lineHeight: 1.55, resize: 'none',
              }} />
          </FieldRow>

          <div style={{
            padding: '10px 12px', background: t.surfaceAlt,
            borderRadius: t.radius, border: `1px dashed ${t.border}`,
            fontSize: t.fz(12), color: t.inkSoft, lineHeight: 1.55,
            display: 'flex', alignItems: 'flex-start', gap: 8,
          }}>
            <IconSparkle size={14} stroke={t.accent} sw={2} style={{ flexShrink: 0, marginTop: 2 }} />
            <div>
              加進來後，未來的報價單只要輸入名字，地址跟電話會自動帶入。<br/>
              統計頁也會自動歸戶這位客戶的累計營收。
            </div>
          </div>
        </div>
      </div>
      {mapOpen && (
        <LocationPickerSheet t={t}
          initialValue={draft.address}
          onClose={() => setMapOpen(false)}
          onConfirm={(addr) => { setDraft({ ...draft, address: addr }); setMapOpen(false); }} />
      )}
    </>
  );
}

function PDFTemplateScreen({ t, template, setTemplate, onBack, onPreview }) {
  const tpl = template || DEFAULT_TEMPLATE;
  const upd = (patch) => setTemplate?.({ ...tpl, ...patch });

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
        <AppHeader t={t} onBack={onBack} subtitle="設定" title="報價單模板" accent={t.id === 'refined'}
          right={
            <button onClick={onPreview} aria-label="預覽" style={{
              background: 'transparent', border: 'none', cursor: 'pointer',
              color: t.id === 'refined' ? t.accent2 : t.accent,
              padding: 6, marginRight: -6, fontSize: t.fz(15), fontWeight: 600,
              fontFamily: t.fontSans,
            }}>預覽</button>
          }
        />
        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '14px 20px 40px',
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          <SectionTitle t={t}>商號識別</SectionTitle>
          <Card t={t}>
            <FieldLabel t={t}>公司／工作室名稱（抬頭）</FieldLabel>
            <TextInput t={t} value={tpl.businessName}
              onChange={e => upd({ businessName: e.target.value })}
              placeholder="例：大發工程行" />
            <div style={{ marginTop: 12 }}>
              <FieldLabel t={t}>標語／slogan（可空白）</FieldLabel>
              <TextInput t={t} value={tpl.slogan}
                onChange={e => upd({ slogan: e.target.value })}
                placeholder="例：交期不拖、價錢實在" />
            </div>
          </Card>

          <SectionTitle t={t}>Logo 與印章</SectionTitle>
          <Card t={t}>
            <div style={{ display: 'flex', gap: 12 }}>
              <UploadSlot t={t} kind="logo" label="商號 Logo" hint="左上角" hasFile={tpl.logoUploaded} />
              <UploadSlot t={t} kind="stamp" label="印章" hint="右下簽章" hasFile={tpl.stampUploaded} />
            </div>
            <div style={{ fontSize: t.fz(11), color: t.inkFaint, marginTop: 10 }}>
              支援 PNG（建議透明背景）、JPG。最大 2MB / 邊長 1200px。
            </div>
          </Card>

          <SectionTitle t={t}>聯絡資訊</SectionTitle>
          <Card t={t}>
            <FieldLabel t={t}><IconPhone size={12} stroke={t.inkSoft} sw={2} /> 電話</FieldLabel>
            <TextInput t={t} value={tpl.phone}
              onChange={e => upd({ phone: e.target.value })}
              placeholder="0912-345-678" />
            <div style={{ marginTop: 12 }}>
              <FieldLabel t={t}>Email</FieldLabel>
              <TextInput t={t} value={tpl.email}
                onChange={e => upd({ email: e.target.value })}
                placeholder="chen@example.com" />
            </div>
            <div style={{ marginTop: 12 }}>
              <FieldLabel t={t}>統編／營業地址</FieldLabel>
              <TextInput t={t} value={tpl.address}
                onChange={e => upd({ address: e.target.value })}
                placeholder="例：統編 12345678 / 台北市信義區⋯" />
            </div>
          </Card>

          <SectionTitle t={t}>付款條件 & 簽名</SectionTitle>
          <Card t={t}>
            <FieldLabel t={t}>付款條件</FieldLabel>
            <textarea value={tpl.paymentTerms}
              onChange={e => upd({ paymentTerms: e.target.value })}
              placeholder="例：簽約付 30%，完工驗收付 60%，保固期滿付 10%"
              rows={3}
              style={{
                width: '100%', boxSizing: 'border-box', padding: 12,
                border: `1.5px solid ${t.border}`, borderRadius: t.radius,
                background: t.surface, color: t.ink, fontSize: t.fz(14),
                fontFamily: t.fontSans, lineHeight: 1.55, resize: 'none',
              }} />
            <div style={{ marginTop: 12 }}>
              <FieldLabel t={t}>有效期限（天）</FieldLabel>
              <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
                {[7, 14, 30, 60, 90].map(d => {
                  const on = tpl.validDays === d;
                  return (
                    <button key={d} onClick={() => upd({ validDays: d })} style={{
                      padding: '6px 12px', fontSize: t.fz(13),
                      background: on ? t.ink : t.surface,
                      color: on ? t.bg : t.ink,
                      border: `1px solid ${on ? t.ink : t.border}`,
                      borderRadius: 999, cursor: 'pointer', fontFamily: t.fontSans, fontWeight: 600,
                    }}>{d} 天</button>
                  );
                })}
              </div>
            </div>
            <div style={{
              marginTop: 14, padding: 12,
              background: t.surfaceAlt, borderRadius: t.radius,
              border: `1px dashed ${t.border}`,
              display: 'flex', alignItems: 'center', gap: 10,
            }}>
              <input id="sig-line" type="checkbox" checked={tpl.signatureLine}
                onChange={e => upd({ signatureLine: e.target.checked })}
                style={{ width: 18, height: 18, accentColor: t.accent }} />
              <label htmlFor="sig-line" style={{ flex: 1, fontSize: t.fz(13), color: t.ink, cursor: 'pointer' }}>
                顯示甲乙方簽名欄（給客戶簽名用）
              </label>
            </div>
          </Card>

          <SectionTitle t={t}>外觀</SectionTitle>
          <Card t={t}>
            <FieldLabel t={t}>主色（PDF 上的強調色）</FieldLabel>
            <div style={{ display: 'flex', gap: 8 }}>
              {['#C9522A', '#1A1A1A', '#2A6FDB', '#1F8A5B', '#7A5AE0'].map(c => {
                const on = tpl.brandColor === c;
                return (
                  <button key={c} onClick={() => upd({ brandColor: c })} style={{
                    width: 36, height: 36, borderRadius: '50%',
                    background: c, border: `2px solid ${on ? t.ink : 'transparent'}`,
                    cursor: 'pointer', boxShadow: on ? `0 0 0 3px ${t.bg}, 0 0 0 5px ${t.ink}` : 'none',
                    transition: 'box-shadow 0.15s',
                  }} aria-label={c} />
                );
              })}
            </div>
            <div style={{ marginTop: 14 }}>
              <FieldLabel t={t}>字體</FieldLabel>
              <div style={{ display: 'flex', gap: 6 }}>
                {['黑體', '明體', '楷體'].map(f => {
                  const on = tpl.fontStyle === f;
                  return (
                    <button key={f} onClick={() => upd({ fontStyle: f })} style={{
                      flex: 1, padding: '8px 10px', fontSize: t.fz(13),
                      background: on ? t.ink : t.surface,
                      color: on ? t.bg : t.ink,
                      border: `1px solid ${on ? t.ink : t.border}`,
                      borderRadius: t.radius, cursor: 'pointer', fontFamily: t.fontSans, fontWeight: 600,
                    }}>{f}</button>
                  );
                })}
              </div>
            </div>
          </Card>

          {!tpl.isPro && (
            <Card t={t} style={{ background: t.surfaceAlt, border: `1.5px dashed ${t.accent}` }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
                <IconSparkle size={20} stroke={t.accent} sw={2} />
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: t.fz(14), fontWeight: 700, color: t.ink, marginBottom: 4 }}>
                    免費版限制
                  </div>
                  <div style={{ fontSize: t.fz(12), color: t.inkSoft, lineHeight: 1.55 }}>
                    每月 3 張報價單，PDF 含浮水印。升級 Pro 解鎖無限張、自訂模板、移除浮水印。
                  </div>
                </div>
              </div>
            </Card>
          )}

          <div style={{ height: 12 }} />
        </div>
      </div>
    </div>
  );
}

const DEFAULT_TEMPLATE = {
  businessName: '陳師傅 / 大發工程行',
  slogan: '交期不拖、價錢實在',
  logoUploaded: false,
  stampUploaded: false,
  phone: '0912-345-678',
  email: '',
  address: '統編 12345678 · 台北市信義區松仁路 100 號',
  paymentTerms: '簽約付 30%，完工驗收付 60%，保固期滿付 10%。',
  validDays: 30,
  signatureLine: true,
  brandColor: '#C9522A',
  fontStyle: '黑體',
  isPro: false,
};

function UploadSlot({ t, kind, label, hint, hasFile }) {
  return (
    <div style={{
      flex: 1, padding: 14,
      background: t.surface, borderRadius: t.radius,
      border: `1.5px dashed ${hasFile ? t.accent : t.borderStrong}`,
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
      cursor: 'pointer',
    }}>
      <div style={{
        width: 48, height: 48, borderRadius: '50%',
        background: hasFile ? t.accent + '20' : t.surfaceAlt,
        color: hasFile ? t.accent : t.inkFaint,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        {kind === 'stamp'
          ? <IconStamp size={22} stroke="currentColor" sw={2} />
          : <IconBuilding size={22} stroke="currentColor" sw={2} />}
      </div>
      <div style={{ fontSize: t.fz(13), color: t.ink, fontWeight: 600 }}>{label}</div>
      <div style={{ fontSize: t.fz(10), color: t.inkSoft }}>{hint}</div>
      <div style={{
        fontSize: t.fz(11), color: hasFile ? t.positive : t.accent,
        fontWeight: 600, marginTop: 4,
      }}>{hasFile ? '✓ 已上傳' : '+ 點此上傳'}</div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// PDFPreviewSheet — partial sheet showing how the quote will print
// ────────────────────────────────────────────────────────────────────
function PDFPreviewSheet({ t, quote, template, watermarked, onClose }) {
  const tpl = template || DEFAULT_TEMPLATE;
  return (
    <>
      <div onClick={onClose} style={{
        position: 'absolute', inset: 0, zIndex: 70,
        background: 'rgba(0,0,0,0.4)',
      }} />
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 80,
        height: 'calc(100% - 22px)', background: '#E5E2DC',
        borderTopLeftRadius: 12, borderTopRightRadius: 12,
        boxShadow: '0 -10px 40px rgba(0,0,0,0.25)',
        display: 'flex', flexDirection: 'column',
        animation: 'sheetUp 0.32s cubic-bezier(.2,.7,.3,1)',
      }}>
        {/* Sheet handle + header */}
        <div style={{ padding: '10px 0 4px', display: 'flex', justifyContent: 'center', flexShrink: 0 }}>
          <div style={{ width: 38, height: 5, borderRadius: 3, background: 'rgba(0,0,0,0.2)' }} />
        </div>
        <div style={{
          padding: '4px 20px 12px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          flexShrink: 0,
        }}>
          <div style={{
            fontFamily: t.fontDisplay, fontSize: t.fz(16), fontWeight: 700, color: '#1A1A1A',
          }}>PDF 預覽</div>
          <button onClick={onClose} aria-label="關閉" style={{
            width: 30, height: 30, borderRadius: '50%',
            background: 'rgba(0,0,0,0.08)', border: 'none', cursor: 'pointer',
            color: '#1A1A1A', display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <IconX size={14} stroke="currentColor" sw={2.4} />
          </button>
        </div>

        {/* A4-ish paper preview */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 16px' }}>
          <div style={{
            background: '#FFF', boxShadow: '0 4px 16px rgba(0,0,0,0.12)',
            padding: '24px 22px', minHeight: 540, position: 'relative',
            color: '#1A1A1A',
            fontFamily: tpl.fontStyle === '明體' ? '"Noto Serif TC", serif' : '"Noto Sans TC", sans-serif',
          }}>
            {watermarked && (
              <div style={{
                position: 'absolute', inset: 0, pointerEvents: 'none',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: 'rgba(0,0,0,0.06)', fontSize: 44, fontWeight: 700,
                transform: 'rotate(-30deg)', letterSpacing: '0.1em',
              }}>師傅號 · 免費版</div>
            )}

            {/* Letterhead */}
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12, paddingBottom: 14, borderBottom: `3px solid ${tpl.brandColor}` }}>
              <div style={{
                width: 50, height: 50, background: '#F0EEE9',
                border: '1px dashed #C0B8A8', borderRadius: 6,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: '#888', fontSize: 9, textAlign: 'center', flexShrink: 0,
              }}>{tpl.logoUploaded ? '★ LOGO' : 'LOGO'}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 16, fontWeight: 700, color: tpl.brandColor }}>{tpl.businessName}</div>
                {tpl.slogan && <div style={{ fontSize: 10, color: '#666', marginTop: 1 }}>{tpl.slogan}</div>}
                <div style={{ fontSize: 9, color: '#666', marginTop: 4, lineHeight: 1.55 }}>
                  {tpl.phone} {tpl.email && `· ${tpl.email}`}<br />
                  {tpl.address}
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: 9, color: '#666' }}>報價單 #{String(quote?.id || '20260520').slice(-4)}</div>
                <div style={{ fontSize: 18, fontWeight: 700, color: '#1A1A1A', marginTop: 2 }}>報 價 單</div>
                <div style={{ fontSize: 9, color: '#666', marginTop: 2 }}>有效期限 {tpl.validDays} 天</div>
              </div>
            </div>

            {/* Client / project */}
            <div style={{ display: 'flex', gap: 24, paddingTop: 14, paddingBottom: 14 }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 9, color: '#888', textTransform: 'uppercase', letterSpacing: 1 }}>致 / TO</div>
                <div style={{ fontSize: 13, fontWeight: 600, marginTop: 4 }}>{quote?.client || '客戶'}</div>
                <div style={{ fontSize: 10, color: '#666', marginTop: 2 }}>{quote?.location || ''}</div>
              </div>
              <div style={{ flex: 1, textAlign: 'right' }}>
                <div style={{ fontSize: 9, color: '#888', textTransform: 'uppercase', letterSpacing: 1 }}>日期 / DATE</div>
                <div style={{ fontSize: 13, fontWeight: 600, marginTop: 4 }}>{quote?.date || '2026-05-20'}</div>
              </div>
            </div>

            {/* Items table */}
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 10 }}>
              <thead>
                <tr style={{ borderTop: '1px solid #1A1A1A', borderBottom: '1px solid #1A1A1A' }}>
                  <th style={{ textAlign: 'left', padding: '6px 4px', fontWeight: 700 }}>項目</th>
                  <th style={{ textAlign: 'center', padding: '6px 4px', fontWeight: 700, width: 36 }}>單位</th>
                  <th style={{ textAlign: 'right', padding: '6px 4px', fontWeight: 700, width: 30 }}>數量</th>
                  <th style={{ textAlign: 'right', padding: '6px 4px', fontWeight: 700, width: 56 }}>單價</th>
                  <th style={{ textAlign: 'right', padding: '6px 4px', fontWeight: 700, width: 60 }}>小計</th>
                </tr>
              </thead>
              <tbody>
                {(quote?.itemList || [
                  { name: '拆除磁磚', unit: '坪', qty: 10, price: 1800 },
                  { name: '冷氣排水管', unit: '式', qty: 1, price: 3500 },
                  { name: '油漆批土', unit: '坪', qty: 25, price: 850 },
                ]).map((it, i) => (
                  <tr key={i} style={{ borderBottom: '1px dotted #ccc' }}>
                    <td style={{ padding: '6px 4px' }}>{it.name}</td>
                    <td style={{ padding: '6px 4px', textAlign: 'center', color: '#666' }}>{it.unit}</td>
                    <td style={{ padding: '6px 4px', textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>{it.qty}</td>
                    <td style={{ padding: '6px 4px', textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>${it.price.toLocaleString()}</td>
                    <td style={{ padding: '6px 4px', textAlign: 'right', fontVariantNumeric: 'tabular-nums', fontWeight: 600 }}>${(it.qty * it.price).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>

            {/* Totals */}
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 8 }}>
              <table style={{ fontSize: 10 }}>
                <tbody>
                  <tr><td style={{ textAlign: 'right', padding: '2px 8px', color: '#666' }}>小計</td><td style={{ textAlign: 'right', padding: '2px 0', fontVariantNumeric: 'tabular-nums', minWidth: 70 }}>${(quote?.total ? Math.round(quote.total / 1.05) : 25500).toLocaleString()}</td></tr>
                  <tr><td style={{ textAlign: 'right', padding: '2px 8px', color: '#666' }}>稅金 5%</td><td style={{ textAlign: 'right', padding: '2px 0', fontVariantNumeric: 'tabular-nums' }}>${Math.round((quote?.total || 26775) * 0.05 / 1.05).toLocaleString()}</td></tr>
                  <tr style={{ borderTop: `2px solid ${tpl.brandColor}` }}><td style={{ textAlign: 'right', padding: '4px 8px', fontWeight: 700, fontSize: 11 }}>總計 NT$</td><td style={{ textAlign: 'right', padding: '4px 0', fontVariantNumeric: 'tabular-nums', fontWeight: 700, fontSize: 14, color: tpl.brandColor }}>${(quote?.total || 26775).toLocaleString()}</td></tr>
                </tbody>
              </table>
            </div>

            {/* Payment terms */}
            <div style={{ marginTop: 18, fontSize: 9, color: '#666', lineHeight: 1.55 }}>
              <div style={{ fontWeight: 700, color: '#1A1A1A', fontSize: 10, marginBottom: 3 }}>付款條件</div>
              {tpl.paymentTerms}
            </div>

            {/* Signatures + stamp */}
            {tpl.signatureLine && (
              <div style={{ display: 'flex', gap: 24, marginTop: 28 }}>
                <div style={{ flex: 1, borderTop: '1px solid #888', paddingTop: 4 }}>
                  <div style={{ fontSize: 9, color: '#888' }}>甲方（客戶）簽名</div>
                </div>
                <div style={{ flex: 1, borderTop: '1px solid #888', paddingTop: 4, position: 'relative' }}>
                  <div style={{ fontSize: 9, color: '#888' }}>乙方（{tpl.businessName.split(/[ /]/)[0]}）簽章</div>
                  {tpl.stampUploaded && (
                    <div style={{
                      position: 'absolute', right: 0, top: -20,
                      width: 44, height: 44, borderRadius: '50%',
                      background: 'rgba(178,40,40,0.8)', color: '#fff',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      fontSize: 12, fontWeight: 800,
                      transform: 'rotate(-8deg)',
                      border: '2px solid #b32828',
                    }}>師傅號</div>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Actions */}
        <div style={{
          padding: '12px 20px 28px', borderTop: `1px solid ${t.border}`,
          background: t.surface, flexShrink: 0,
          display: 'flex', gap: 8,
        }}>
          <SecondaryButton t={t} style={{ flex: 1 }}>
            <IconShare size={15} stroke="currentColor" /> 分享
          </SecondaryButton>
          <div style={{ flex: 1 }}>
            <PrimaryButton t={t}>
              <IconFileText size={16} stroke="currentColor" /> 儲存 PDF
            </PrimaryButton>
          </div>
        </div>
      </div>
    </>
  );
}

// ────────────────────────────────────────────────────────────────────
// ShareSheet — share quote via PDF / Image / LINE / WhatsApp / link
// ────────────────────────────────────────────────────────────────────
function ShareSheet({ t, quote, onClose, onOpenPDF }) {
  const targets = [
    { key: 'line',   icon: '💬', label: 'LINE',     hint: '傳訊息給客戶',  color: '#06C755' },
    { key: 'wa',     icon: '📱', label: 'WhatsApp', hint: '海外客戶',      color: '#25D366' },
    { key: 'mail',   icon: '✉️', label: 'Email',    hint: '郵件附件',       color: '#3E6B9B' },
    { key: 'sms',    icon: '💬', label: '簡訊 / iMessage', hint: '純文字 + 連結', color: '#7B68EE' },
    { key: 'copy',   icon: '🔗', label: '複製連結', hint: '7 天有效',       color: '#6B6660' },
  ];
  const formats = [
    { key: 'pdf',   icon: <IconFileText size={20} stroke="currentColor" />, label: 'PDF',     hint: '正式報價單', accent: true, onClick: onOpenPDF },
    { key: 'image', icon: <IconBuilding size={20} stroke="currentColor" />, label: '圖片',     hint: '給只看圖的客戶' },
    { key: 'text',  icon: <IconClock size={20} stroke="currentColor" />,    label: '純文字明細', hint: 'LINE/簡訊直接貼' },
  ];

  return (
    <>
      <div onClick={onClose} style={{
        position: 'absolute', inset: 0, zIndex: 70,
        background: 'rgba(0,0,0,0.4)',
      }} />
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 80,
        background: t.surface,
        borderTopLeftRadius: 16, borderTopRightRadius: 16,
        boxShadow: '0 -10px 40px rgba(0,0,0,0.25)',
        animation: 'sheetUp 0.28s cubic-bezier(.2,.7,.3,1)',
        paddingBottom: 28,
      }}>
        <div style={{ padding: '10px 0 4px', display: 'flex', justifyContent: 'center' }}>
          <div style={{ width: 38, height: 5, borderRadius: 3, background: t.borderStrong, opacity: 0.6 }} />
        </div>
        <div style={{
          padding: '4px 20px 14px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <div>
            <div style={{ fontFamily: t.fontDisplay, fontSize: t.fz(17), fontWeight: 700, color: t.ink }}>
              傳給 {quote?.client || '客戶'}
            </div>
            <div style={{ fontSize: t.fz(12), color: t.inkSoft, marginTop: 2 }}>
              ${(quote?.total || 0).toLocaleString()} · {quote?.itemList?.length || 0} 個項目
            </div>
          </div>
          <button onClick={onClose} aria-label="關閉" style={{
            width: 30, height: 30, borderRadius: '50%',
            background: t.bgSoft, border: 'none', cursor: 'pointer',
            color: t.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <IconX size={14} stroke="currentColor" sw={2.4} />
          </button>
        </div>

        <div style={{ padding: '0 20px' }}>
          <div style={{
            fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono,
            letterSpacing: '0.15em', marginBottom: 8, fontWeight: 700,
          }}>FORMAT 格式</div>
          <div style={{ display: 'flex', gap: 8, marginBottom: 18 }}>
            {formats.map(f => (
              <button key={f.key} onClick={f.onClick} style={{
                flex: 1, padding: '14px 8px',
                background: f.accent ? t.accent + '12' : t.surfaceAlt,
                border: f.accent ? `1.5px solid ${t.accent}` : `1px solid ${t.border}`,
                borderRadius: t.radius, cursor: 'pointer',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
                color: f.accent ? t.accent : t.ink, fontFamily: t.fontSans,
              }}>
                {f.icon}
                <div style={{ fontSize: t.fz(13), fontWeight: 700, marginTop: 2 }}>{f.label}</div>
                <div style={{ fontSize: t.fz(10), color: t.inkSoft }}>{f.hint}</div>
              </button>
            ))}
          </div>

          <div style={{
            fontSize: t.fz(11), color: t.inkSoft, fontFamily: t.fontMono,
            letterSpacing: '0.15em', marginBottom: 8, fontWeight: 700,
          }}>傳到</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {targets.map(tg => (
              <button key={tg.key} style={{
                display: 'flex', alignItems: 'center', gap: 12,
                padding: '12px 14px', background: t.surfaceAlt,
                border: `1px solid ${t.border}`, borderRadius: t.radius,
                cursor: 'pointer', textAlign: 'left', fontFamily: t.fontSans,
              }}>
                <div style={{
                  width: 36, height: 36, borderRadius: 10,
                  background: tg.color + '20', color: tg.color,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 18, flexShrink: 0,
                }}>{tg.icon}</div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: t.fz(14), fontWeight: 600, color: t.ink }}>{tg.label}</div>
                  <div style={{ fontSize: t.fz(11), color: t.inkSoft, marginTop: 1 }}>{tg.hint}</div>
                </div>
                <IconChevronRight size={14} stroke={t.inkFaint} />
              </button>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

// ────────────────────────────────────────────────────────────────────
// InvoiceScreen — 請款單（convert from a quote, similar layout but
// flags this as a billing doc)
// ────────────────────────────────────────────────────────────────────
function InvoiceScreen({ t, quote, onBack }) {
  if (!quote) return null;
  const subtotal = quote.itemList.reduce((s, it) => s + it.qty * it.price, 0);
  const tax = Math.round(subtotal * 0.05);
  const dueDate = '2026-06-19';

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
          subtitle={`請款單 · INV-${String(quote.id).slice(-4)}`}
          title={quote.client}
          right={
            <span style={{
              padding: '3px 8px', borderRadius: 999,
              background: t.accent + '18', color: t.accent,
              fontSize: t.fz(11), fontWeight: 700, fontFamily: t.fontMono,
              letterSpacing: '0.05em',
            }}>請款中</span>
          }
        />
        <div style={{
          flex: 1, overflowY: 'auto',
          padding: '14px 20px 40px',
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          <Card t={t} style={{ background: t.surfaceAlt, borderLeft: `4px solid ${t.accent}` }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <IconClock size={20} stroke={t.accent} sw={2} />
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: t.fz(13), fontWeight: 700, color: t.ink }}>付款到期日：{dueDate}</div>
                <div style={{ fontSize: t.fz(11), color: t.inkSoft, marginTop: 2 }}>
                  從報價單 #{String(quote.id).slice(-4)} 轉成請款單 · 工程已完工
                </div>
              </div>
            </div>
          </Card>

          <Card t={t}>
            <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
              <DetailFact t={t} icon={<IconMapPin size={11} stroke={t.inkSoft} />} label="工程地點" value={quote.location} />
              <DetailFact t={t} icon={<IconCalendar size={11} stroke={t.inkSoft} />} label="完工日" value={quote.date} />
            </div>
          </Card>

          <Card t={t}>
            <div style={{
              fontFamily: t.fontMono, fontSize: t.fz(11), color: t.inkSoft,
              letterSpacing: '0.15em', textTransform: 'uppercase', marginBottom: 10,
            }}>請款明細</div>
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

          <Card t={t} accent>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: t.fz(13), marginBottom: 6, color: (t.accentSurfaceInkSoft || 'rgba(245,242,236,0.7)') }}>
              <span>小計</span><span style={{ fontFamily: t.fontMono }}>${subtotal.toLocaleString()}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: t.fz(13), marginBottom: 10, color: (t.accentSurfaceInkSoft || 'rgba(245,242,236,0.7)') }}>
              <span>稅金 5%</span><span style={{ fontFamily: t.fontMono }}>${tax.toLocaleString()}</span>
            </div>
            <Divider t={t} style={{ margin: '0 0 10px', background: 'rgba(245,242,236,0.2)' }} />
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: t.fz(14), fontWeight: 700, color: (t.accentSurfaceInk || t.bg) }}>請款金額</span>
              <Money t={t} amount={quote.total} size={28} color={t.accent2} />
            </div>
          </Card>

          <Card t={t}>
            <div style={{
              fontFamily: t.fontMono, fontSize: t.fz(11), color: t.inkSoft,
              letterSpacing: '0.15em', textTransform: 'uppercase', marginBottom: 8,
            }}>付款方式</div>
            <div style={{ fontSize: t.fz(13), color: t.inkMid, lineHeight: 1.6 }}>
              · 匯款：玉山銀行（808）123-4567-890-1<br/>
              · LINE Pay / 街口：掃描下方 QR Code<br/>
              · 現金：請聯絡 0912-345-678 約時間
            </div>
          </Card>

          <div style={{ display: 'flex', gap: 10 }}>
            <SecondaryButton t={t} style={{ flex: 1 }}>
              <IconCheck size={15} stroke="currentColor" /> 標記已收款
            </SecondaryButton>
            <SecondaryButton t={t} style={{ flex: 1 }}>
              <IconShare size={15} stroke="currentColor" /> 傳給客戶
            </SecondaryButton>
          </div>
        </div>
      </div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// PaywallScreen — Pro subscription
// ────────────────────────────────────────────────────────────────────
function PaywallScreen({ t, onBack, onSubscribe }) {
  const [plan, setPlan] = spUS('yearly');
  const features = [
    { icon: <IconFileText size={18} stroke={t.accent} sw={2} />, text: '無限張報價單', sub: '免費版每月只能 3 張' },
    { icon: <IconStamp size={18} stroke={t.accent} sw={2} />, text: '自訂 PDF 模板', sub: 'Logo、抬頭、付款條件、簽名欄、印章' },
    { icon: <IconSparkle size={18} stroke={t.accent} sw={2} />, text: '移除浮水印', sub: '客戶不會看到「免費版」字樣' },
    { icon: <IconCoins size={18} stroke={t.accent} sw={2} />, text: '請款單 & 收款追蹤', sub: '報價→施工→請款一條龍' },
    { icon: <IconChart size={18} stroke={t.accent} sw={2} />, text: '進階統計與成本記錄', sub: '看每案淨利、年度趨勢' },
    { icon: <IconBuilding size={18} stroke={t.accent} sw={2} />, text: 'iCloud 自動備份', sub: '換手機也不怕資料不見' },
  ];

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
        {/* Custom hero header */}
        <div style={{
          padding: '54px 22px 24px',
          background: t.accentSurface || t.ink,
          color: t.accentSurfaceInk || t.bg,
          position: 'relative',
        }}>
          <button onClick={onBack} style={{
            background: 'transparent', border: 'none', cursor: 'pointer',
            padding: 4, marginLeft: -4, color: t.accentSurfaceInk || t.bg, display: 'flex',
          }}>
            <IconX size={22} stroke="currentColor" sw={2} />
          </button>
          <div style={{
            display: 'inline-block', padding: '4px 12px', borderRadius: 999,
            background: t.accent + '30', color: t.accent2,
            fontSize: t.fz(11), fontWeight: 700, letterSpacing: '0.15em',
            marginTop: 14, marginBottom: 12,
          }}>師傅號 PRO</div>
          <div style={{
            fontFamily: t.fontDisplay, fontSize: t.fz(28), fontWeight: 800,
            letterSpacing: '-0.02em', lineHeight: 1.15,
          }}>
            報得快、收得回，<br/>
            師傅的生意更穩。
          </div>
        </div>

        <div style={{
          flex: 1, overflowY: 'auto', padding: '20px 22px 220px',
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          {features.map((f, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
              <div style={{
                width: 38, height: 38, flexShrink: 0,
                background: t.accent + '15', borderRadius: 10,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {f.icon}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: t.fz(15), fontWeight: 700, color: t.ink }}>{f.text}</div>
                <div style={{ fontSize: t.fz(12), color: t.inkSoft, marginTop: 2, lineHeight: 1.5 }}>{f.sub}</div>
              </div>
            </div>
          ))}

          <div style={{ height: 8 }} />

          {/* Plan picker */}
          <button onClick={() => setPlan('yearly')} style={{
            padding: '14px 16px', textAlign: 'left', background: t.surface,
            border: `2px solid ${plan === 'yearly' ? t.accent : t.border}`,
            borderRadius: t.radiusBig, cursor: 'pointer', position: 'relative',
            fontFamily: t.fontSans,
          }}>
            <div style={{
              position: 'absolute', top: -8, right: 12,
              padding: '2px 8px', borderRadius: 999, background: t.accent, color: '#fff',
              fontSize: t.fz(10), fontWeight: 700, letterSpacing: '0.1em',
            }}>省 33%</div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontSize: t.fz(16), fontWeight: 700, color: t.ink }}>年訂閱</div>
                <div style={{ fontSize: t.fz(12), color: t.inkSoft, marginTop: 2 }}>每月只要 $200，年付便宜兩個月</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <Money t={t} amount={2400} size={20} />
                <div style={{ fontSize: t.fz(11), color: t.inkSoft }}>/ 年</div>
              </div>
            </div>
          </button>

          <button onClick={() => setPlan('monthly')} style={{
            padding: '14px 16px', textAlign: 'left', background: t.surface,
            border: `2px solid ${plan === 'monthly' ? t.accent : t.border}`,
            borderRadius: t.radiusBig, cursor: 'pointer', fontFamily: t.fontSans,
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontSize: t.fz(16), fontWeight: 700, color: t.ink }}>月訂閱</div>
                <div style={{ fontSize: t.fz(12), color: t.inkSoft, marginTop: 2 }}>先試一個月看看</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <Money t={t} amount={299} size={20} />
                <div style={{ fontSize: t.fz(11), color: t.inkSoft }}>/ 月</div>
              </div>
            </div>
          </button>

          <div style={{
            fontSize: t.fz(11), color: t.inkSoft, textAlign: 'center',
            marginTop: 10, lineHeight: 1.6,
          }}>
            7 天免費試用，隨時可取消<br/>
            訂閱透過 App Store 收費，可在「設定 → Apple ID」隨時關閉
          </div>
        </div>

        <BottomCTA t={t}>
          <PrimaryButton t={t} onClick={onSubscribe}
            icon={<IconSparkle size={18} stroke="currentColor" sw={2.2} />}>
            {plan === 'yearly' ? '訂閱 PRO · 年付 $2,400' : '訂閱 PRO · 月付 $299'}
          </PrimaryButton>
        </BottomCTA>
      </div>
    </div>
  );
}

Object.assign(window, {
  ContactsScreen, NewClientSheet, Avatar, QuickActionButton,
  PDFTemplateScreen, UploadSlot, DEFAULT_TEMPLATE,
  PDFPreviewSheet, ShareSheet,
  InvoiceScreen, PaywallScreen,
});
