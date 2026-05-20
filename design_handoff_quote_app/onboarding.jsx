// Onboarding screens — same flow, three visual treatments.
// Steps:
//   splash    → big greeting, name input
//   intro     → 3-point feature card carousel
//   tutorial0 → "let's build your first quote" CTA
// After tutorial0 the user enters new-quote flow with `coaching = true`,
// which lights up coach-marks on each step.

const { useState: obUS } = React;

function OnboardingFlow({ t, step, setStep, name, setName, onStart }) {
  if (step === 'splash')   return <SplashScreen t={t} name={name} setName={setName} onNext={() => setStep('intro')} />;
  if (step === 'intro')    return <IntroScreen t={t} onNext={() => setStep('tutorial0')} onBack={() => setStep('splash')} />;
  if (step === 'tutorial0') return <TutorialCTAScreen t={t} name={name} onStart={onStart} onBack={() => setStep('intro')} />;
  return null;
}

// ────────────────────────────────────────────────────────────────────
// Splash — direction-specific hero
// ────────────────────────────────────────────────────────────────────
function SplashScreen({ t, name, setName, onNext }) {
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: t.bg, position: 'relative', overflow: 'hidden',
      paddingTop: 60,
    }}>
      <AppBackground t={t} />
      <div style={{ position: 'relative', zIndex: 1, padding: '40px 24px 200px', flex: 1, display: 'flex', flexDirection: 'column' }}>
        <SplashHero t={t} />
      </div>
      <BottomCTA t={t} withBackground={false} sub={
        <div style={{ textAlign: 'center', fontSize: t.fz(12), color: t.inkFaint }}>
          不用先註冊，按下去就可以開始試。
        </div>
      }>
        <PrimaryButton t={t} onClick={onNext} icon={<IconArrowRight size={18} stroke="currentColor" />}>
          開工
        </PrimaryButton>
      </BottomCTA>
    </div>
  );
}

function SplashHero({ t }) {
  if (t.id === 'stamp') {
    return (
      <div style={{ textAlign: 'center', position: 'relative' }}>
        {/* Red rotated stamp */}
        <div style={{
          display: 'inline-block', padding: '14px 22px',
          border: `3px double ${t.accent}`, color: t.accent,
          fontFamily: t.fontDisplay, fontSize: t.fz(13), fontWeight: 800,
          letterSpacing: '0.2em', transform: 'rotate(-4deg)',
          marginBottom: 28,
        }}>師傅號 · 2026</div>
        <div style={{
          fontFamily: t.fontDisplay, fontSize: t.fz(48), fontWeight: 900,
          color: t.ink, lineHeight: 1.05, letterSpacing: '-0.02em',
          marginBottom: 14,
        }}>
          一張<br/>好報價單
        </div>
        <div style={{
          fontFamily: t.fontHand, fontSize: t.fz(22), color: t.accent,
          lineHeight: 1.2, transform: 'rotate(-1deg)',
        }}>工地老闆，幾步就上手</div>
      </div>
    );
  }
  if (t.id === 'blueprint') {
    return (
      <div>
        <div style={{
          fontFamily: t.fontMono, fontSize: t.fz(11), color: t.inkSoft,
          letterSpacing: '0.25em', marginBottom: 14,
        }}>SHEET 01 / 03 · 開工須知</div>
        <div style={{
          fontFamily: t.fontDisplay, fontSize: t.fz(42), fontWeight: 600,
          color: t.ink, lineHeight: 1.05, letterSpacing: '0.01em',
          marginBottom: 18,
        }}>
          報價單<br />
          <span style={{ color: t.accent }}>施工圖</span>
        </div>
        <div style={{
          fontFamily: t.fontMono, fontSize: t.fz(13), color: t.inkMid,
          lineHeight: 1.6, maxWidth: 280, letterSpacing: '0.02em',
        }}>
          工地老闆，幾步就上手。<br/>
          一張單、一筆帳、一目了然。
        </div>
        {/* corner crosshairs */}
        <div style={{ marginTop: 32, display: 'flex', gap: 4 }}>
          <DimMark t={t} label="01" />
          <DimMark t={t} label="02" muted />
          <DimMark t={t} label="03" muted />
        </div>
      </div>
    );
  }
  // refined default
  return (
    <div>
      <div style={{
        display: 'inline-block', padding: '4px 12px', borderRadius: 999,
        background: t.accent + '20', color: t.accent,
        fontSize: t.fz(12), fontWeight: 600, marginBottom: 22,
        letterSpacing: '0.05em',
      }}>師傅號 · v2.0</div>
      <div style={{
        fontFamily: t.fontDisplay, fontSize: t.fz(40), fontWeight: 800,
        color: t.ink, lineHeight: 1.1, letterSpacing: '-0.03em',
        marginBottom: 16,
      }}>
        報價收款，<br/>
        一支手機<br/>
        全包了。
      </div>
      <div style={{ fontSize: t.fz(16), color: t.inkSoft, lineHeight: 1.55, maxWidth: 280 }}>
        工地老闆，幾步就上手。算項目、看數字、追收款，
        都在這。
      </div>
    </div>
  );
}

function DimMark({ t, label, muted }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
      <div style={{
        width: 24, height: 3, background: muted ? t.border : t.accent,
      }} />
      <div style={{
        fontFamily: t.fontMono, fontSize: t.fz(10),
        color: muted ? t.inkFaint : t.ink, letterSpacing: '0.1em',
      }}>{label}</div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// Intro — 3 feature points
// ────────────────────────────────────────────────────────────────────
function IntroScreen({ t, onNext, onBack }) {
  const points = [
    {
      icon: <IconFileText size={26} stroke={t.accent} sw={1.8} />,
      title: '建立報價單',
      desc: '套用以前用過的項目，不用每次重新查價。',
    },
    {
      icon: <IconCoins size={26} stroke={t.cool} sw={1.8} />,
      title: '追收款進度',
      desc: '進行中、已完工、已收款，自動分類，一眼看清。',
    },
    {
      icon: <IconTrendUp size={26} stroke={t.positive} sw={1.8} />,
      title: '看自己賺多少',
      desc: '每月收入、最大客戶、最賺項目，都幫你算好。',
    },
  ];
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: t.bg, position: 'relative',
    }}>
      <AppBackground t={t} />
      <div style={{ padding: '60px 22px 200px', position: 'relative', zIndex: 1, flex: 1, display: 'flex', flexDirection: 'column' }}>
        <button onClick={onBack} style={{
          alignSelf: 'flex-start', background: 'transparent', border: 'none',
          padding: 6, marginLeft: -6, cursor: 'pointer', display: 'flex', color: t.inkSoft,
        }}>
          <IconArrowLeft size={20} stroke={t.inkSoft} sw={2} />
        </button>
        <div style={{
          fontFamily: t.fontDisplay,
          fontSize: t.fz(30), fontWeight: 700, color: t.ink,
          letterSpacing: '-0.02em', lineHeight: 1.15,
          margin: '20px 0 8px',
        }}>它能幫你做什麼？</div>
        <div style={{
          fontSize: t.fz(14), color: t.inkSoft, marginBottom: 24,
          fontFamily: t.id === 'blueprint' ? t.fontMono : t.fontSans,
        }}>
          {t.id === 'blueprint' ? '// 三件你不用再用紙筆做的事' : '三件不用再用紙筆做的事 ↓'}
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {points.map((p, i) => (
            <Card key={i} t={t} style={{ display: 'flex', gap: 14, alignItems: 'flex-start' }}>
              <div style={{
                width: 44, height: 44, flexShrink: 0,
                background: t.id === 'blueprint' ? 'transparent' : t.surfaceAlt,
                border: t.id === 'blueprint' ? `1px solid ${t.border}` : 'none',
                borderRadius: t.id === 'stamp' ? t.radius : (t.id === 'blueprint' ? 0 : 12),
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                position: 'relative',
              }}>
                {p.icon}
                {t.id === 'blueprint' && (
                  <div style={{
                    position: 'absolute', top: -8, left: -8,
                    fontFamily: t.fontMono, fontSize: t.fz(9), color: t.inkFaint,
                    background: t.bg, padding: '0 3px',
                  }}>0{i+1}</div>
                )}
              </div>
              <div style={{ flex: 1, paddingTop: 2 }}>
                <div style={{
                  fontFamily: t.fontDisplay, fontSize: t.fz(17), fontWeight: 700,
                  color: t.ink, marginBottom: 4,
                }}>{p.title}</div>
                <div style={{ fontSize: t.fz(13.5), color: t.inkSoft, lineHeight: 1.55 }}>{p.desc}</div>
              </div>
            </Card>
          ))}
        </div>
      </div>
      <BottomCTA t={t} withBackground={false}>
        <PrimaryButton t={t} onClick={onNext}
          icon={<IconArrowRight size={18} stroke="currentColor" />}>
          看起來不錯，繼續
        </PrimaryButton>
      </BottomCTA>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// TutorialCTA — "ready to build your first quote?"
// ────────────────────────────────────────────────────────────────────
function TutorialCTAScreen({ t, name, onStart, onBack }) {
  const displayName = (name || '師傅').replace(/師傅$/, '') + '師傅';
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      background: t.bg, position: 'relative',
    }}>
      <AppBackground t={t} />
      <div style={{ padding: '60px 22px 200px', position: 'relative', zIndex: 1, flex: 1, display: 'flex', flexDirection: 'column' }}>
        <button onClick={onBack} style={{
          alignSelf: 'flex-start', background: 'transparent', border: 'none',
          padding: 6, marginLeft: -6, cursor: 'pointer', display: 'flex',
        }}>
          <IconArrowLeft size={20} stroke={t.inkSoft} sw={2} />
        </button>
        <div style={{ flex: 1 }} />
        <TutorialCTAHero t={t} name={displayName} />
        <div style={{ flex: 1 }} />
      </div>
      <BottomCTA t={t} withBackground={false} sub={
        <button onClick={onStart} style={{
          background: 'transparent', border: 'none', color: t.inkSoft,
          padding: 8, fontSize: t.fz(13), cursor: 'pointer',
          fontFamily: t.fontSans, textAlign: 'center',
        }}>
          先跳過，等等再說 →
        </button>
      }>
        <PrimaryButton t={t} onClick={onStart}
          icon={<IconHammer size={18} stroke="currentColor" />}>
          來試一張看看
        </PrimaryButton>
      </BottomCTA>
    </div>
  );
}

function TutorialCTAHero({ t, name }) {
  if (t.id === 'stamp') {
    return (
      <div style={{ textAlign: 'center' }}>
        <div style={{
          fontFamily: t.fontHand, fontSize: t.fz(24), color: t.accent,
          transform: 'rotate(-2deg)', marginBottom: 8,
        }}>嗨，{name}！</div>
        <div style={{
          fontFamily: t.fontDisplay, fontSize: t.fz(34), fontWeight: 800,
          color: t.ink, letterSpacing: '-0.01em', lineHeight: 1.2,
          marginBottom: 14,
        }}>
          來蓋第一張<br/>正式報價單
        </div>
        <div style={{
          display: 'inline-block', padding: '6px 14px',
          background: t.accent + '15', color: t.accent,
          border: `1.5px solid ${t.accent}`,
          fontFamily: t.fontMono, fontSize: t.fz(11),
          letterSpacing: '0.2em', fontWeight: 700,
        }}>STEP 1 → 2 → 3 · 約 2 分鐘</div>
      </div>
    );
  }
  if (t.id === 'blueprint') {
    return (
      <div>
        <div style={{
          fontFamily: t.fontMono, fontSize: t.fz(11), color: t.accent,
          letterSpacing: '0.25em', marginBottom: 14,
        }}>// HELLO, {name.toUpperCase()}</div>
        <div style={{
          fontFamily: t.fontDisplay, fontSize: t.fz(30), fontWeight: 600,
          color: t.ink, lineHeight: 1.2, marginBottom: 18,
        }}>
          下一步：<br/>
          畫第一張<br/>
          施工報價
        </div>
        <div style={{
          display: 'flex', gap: 0, alignItems: 'center',
          fontFamily: t.fontMono, fontSize: t.fz(11), color: t.inkMid,
          letterSpacing: '0.1em',
        }}>
          <span style={{ color: t.accent }}>[01] 客戶</span>
          <span style={{ margin: '0 8px', color: t.inkFaint }}>→</span>
          <span>[02] 項目</span>
          <span style={{ margin: '0 8px', color: t.inkFaint }}>→</span>
          <span>[03] 出單</span>
        </div>
      </div>
    );
  }
  return (
    <div>
      <div style={{
        fontSize: t.fz(15), color: t.accent, marginBottom: 8, fontWeight: 600,
      }}>嗨，{name} 👋</div>
      <div style={{
        fontFamily: t.fontDisplay, fontSize: t.fz(32), fontWeight: 800,
        color: t.ink, letterSpacing: '-0.02em', lineHeight: 1.15,
        marginBottom: 14,
      }}>
        我們來試做<br/>
        第一張報價單。
      </div>
      <div style={{ fontSize: t.fz(15), color: t.inkSoft, lineHeight: 1.6, marginBottom: 20 }}>
        過程中我會在旁邊指一下重點。<br/>
        放心，假的，做壞了也沒事。
      </div>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10, padding: '10px 14px',
        background: t.surfaceAlt, borderRadius: t.radius,
        border: `1px solid ${t.border}`,
      }}>
        <span style={{
          width: 24, height: 24, borderRadius: '50%', background: t.accent,
          color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: t.fz(13), fontWeight: 700,
        }}>1</span>
        <span style={{ fontSize: t.fz(13), color: t.inkMid }}>客戶資料</span>
        <IconChevronRight size={12} stroke={t.inkFaint} />
        <span style={{ fontSize: t.fz(13), color: t.inkMid }}>選項目</span>
        <IconChevronRight size={12} stroke={t.inkFaint} />
        <span style={{ fontSize: t.fz(13), color: t.inkMid }}>出單</span>
      </div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// CoachMark — speech-bubble overlay for the tutorial mode
// ────────────────────────────────────────────────────────────────────
function CoachMark({ t, text, position = 'top', onDismiss, step }) {
  const arrow = position === 'top' ? '▼' : '▲';
  return (
    <div style={{
      position: 'absolute', left: 16, right: 16, zIndex: 100,
      ...(position === 'top' ? { top: 110 } : { bottom: 100 }),
    }}>
      <div style={{
        background: t.id === 'blueprint' ? t.accent : t.ink,
        color: t.id === 'blueprint' ? t.bg : t.bg,
        padding: '12px 14px',
        borderRadius: t.id === 'blueprint' ? 0 : t.radius,
        fontFamily: t.fontSans,
        fontSize: t.fz(13.5), lineHeight: 1.55,
        boxShadow: t.id === 'stamp'
          ? `3px 3px 0 ${t.accent}`
          : '0 8px 24px rgba(0,0,0,0.25)',
        position: 'relative',
        border: t.id === 'stamp' ? `1.5px solid ${t.ink}` : 'none',
      }}>
        {step && (
          <div style={{
            fontFamily: t.fontMono, fontSize: t.fz(10),
            opacity: 0.7, letterSpacing: '0.15em', marginBottom: 4,
          }}>STEP {step} / 3</div>
        )}
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
          <div style={{ flex: 1 }}>{text}</div>
          <button onClick={onDismiss} style={{
            background: 'transparent', border: 'none', color: 'inherit',
            cursor: 'pointer', padding: 0, opacity: 0.8, display: 'flex',
            fontFamily: t.fontMono, fontSize: t.fz(11), fontWeight: 700,
          }}>知道了</button>
        </div>
        {/* arrow */}
        <div style={{
          position: 'absolute',
          ...(position === 'top'
            ? { bottom: -7, left: 32 }
            : { top: -7, left: 32 }),
          color: t.id === 'blueprint' ? t.accent : t.ink,
          fontSize: 14, lineHeight: 1,
        }}>{arrow}</div>
      </div>
    </div>
  );
}

Object.assign(window, { OnboardingFlow, CoachMark });
