// Theme-aware building blocks. Each component branches on theme.id when
// the visual treatment is fundamentally different across directions.

const { useState: cmUS } = React;

// ────────────────────────────────────────────────────────────────────
// StatusBadge — pill / stamp / bracketed tag
// ────────────────────────────────────────────────────────────────────
function StatusBadge({ status, t, large = false }) {
  const label = STATUS_LABEL[status];
  const color = {
    ongoing: t.accent,
    done:    t.positive,
    paid:    t.cool,
    draft:   t.inkFaint,
  }[status] || t.inkSoft;

  if (t.id === 'stamp') {
    // Ink-stamp style: rotated square with double border
    return (
      <span style={{
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        padding: large ? '6px 10px' : '3px 7px',
        fontFamily: t.fontDisplay, fontWeight: 700,
        fontSize: t.fz(large ? 13 : 11),
        color, border: `1.5px solid ${color}`,
        boxShadow: `inset 0 0 0 2.5px ${t.surface}, inset 0 0 0 3.5px ${color}`,
        letterSpacing: '0.15em',
        transform: status === 'paid' ? 'rotate(-3deg)' : status === 'draft' ? 'rotate(2deg)' : 'rotate(-1.5deg)',
        background: 'transparent',
      }}>{label}</span>
    );
  }

  if (t.id === 'blueprint') {
    // Bracketed technical tag
    return (
      <span style={{
        display: 'inline-flex', alignItems: 'center', gap: 4,
        fontFamily: t.fontMono, fontWeight: 500,
        fontSize: t.fz(large ? 12 : 10),
        color, letterSpacing: '0.08em',
        textTransform: 'uppercase',
      }}>
        <span style={{ opacity: 0.6 }}>[</span>
        <span style={{
          width: 6, height: 6, borderRadius: '50%', background: color,
        }} />
        {label}
        <span style={{ opacity: 0.6 }}>]</span>
      </span>
    );
  }

  // Refined pill (default)
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      padding: large ? '5px 11px' : '3px 8px',
      fontSize: t.fz(large ? 12 : 11), fontWeight: 600,
      borderRadius: 999,
      background: color + '18', color,
      letterSpacing: '0.02em',
    }}>
      <span style={{ width: 6, height: 6, borderRadius: '50%', background: color }} />
      {label}
    </span>
  );
}

// ────────────────────────────────────────────────────────────────────
// Money — direction-specific numeric display
// ────────────────────────────────────────────────────────────────────
function Money({ amount, t, size = 18, color, prefix = '$', tabular = true, bold = true }) {
  const baseStyle = {
    fontSize: t.fz(size),
    fontWeight: bold ? 700 : 500,
    color: color || t.accent,
    fontFamily: t.fontNumeric,
    fontVariantNumeric: tabular ? 'tabular-nums' : 'normal',
    letterSpacing: t.id === 'blueprint' ? '0' : '-0.01em',
    lineHeight: 1.1,
  };

  if (t.id === 'stamp') {
    // Receipt-style: NT$ prefix, mono, slight underline
    return (
      <span style={baseStyle}>
        <span style={{ fontSize: t.fz(size * 0.55), marginRight: 3, opacity: 0.6, letterSpacing: '0.05em' }}>NT</span>
        {prefix}{Number(amount).toLocaleString()}
      </span>
    );
  }
  if (t.id === 'blueprint') {
    return (
      <span style={baseStyle}>
        <span style={{ fontSize: t.fz(size * 0.65), marginRight: 2, opacity: 0.7 }}>{prefix}</span>
        {Number(amount).toLocaleString()}
      </span>
    );
  }
  return (
    <span style={baseStyle}>{prefix}{Number(amount).toLocaleString()}</span>
  );
}

// ────────────────────────────────────────────────────────────────────
// AppHeader — top bar treatment, varies most by direction
// ────────────────────────────────────────────────────────────────────
function AppHeader({ t, title, subtitle, onBack, right, accent = false }) {
  if (t.id === 'stamp') {
    return (
      <div style={{
        padding: '64px 22px 18px',
        background: t.surface,
        borderBottom: `2px solid ${t.ink}`,
        position: 'relative',
      }}>
        {/* perforated bottom edge for receipt effect */}
        <svg
          width="100%" height="6"
          style={{ position: 'absolute', bottom: -6, left: 0, display: 'block' }}
          aria-hidden
        >
          <defs>
            <pattern id={`teeth-${t.id}`} x="0" y="0" width="14" height="6" patternUnits="userSpaceOnUse">
              <path d="M0 0 L7 6 L14 0 Z" fill={t.ink} />
            </pattern>
          </defs>
          <rect width="100%" height="6" fill={`url(#teeth-${t.id})`} />
        </svg>
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
          {onBack && (
            <button onClick={onBack} aria-label="back" style={{
              background: 'transparent', border: `1.5px solid ${t.ink}`,
              padding: 6, cursor: 'pointer', color: t.ink, display: 'flex',
            }}>
              <IconArrowLeft size={14} stroke={t.ink} sw={2} />
            </button>
          )}
          <div style={{ flex: 1, minWidth: 0 }}>
            {subtitle && (
              <div style={{
                fontFamily: t.fontMono, fontSize: t.fz(10), color: t.inkSoft,
                letterSpacing: '0.15em', textTransform: 'uppercase', marginBottom: 4,
              }}>{subtitle}</div>
            )}
            <div style={{
              fontFamily: t.fontDisplay, fontSize: t.fz(26), fontWeight: 700,
              color: t.ink, letterSpacing: '-0.01em', lineHeight: 1.15,
            }}>{title}</div>
          </div>
          {right}
        </div>
      </div>
    );
  }

  if (t.id === 'blueprint') {
    return (
      <div style={{
        padding: '60px 20px 14px',
        background: t.bg, position: 'relative',
        borderBottom: `1px solid ${t.border}`,
      }}>
        {/* corner crosshair marks */}
        <CrossMark t={t} pos={{ top: 56, left: 6 }} />
        <CrossMark t={t} pos={{ top: 56, right: 6 }} />
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
          {onBack && (
            <button onClick={onBack} aria-label="back" style={{
              background: 'transparent', border: `1px solid ${t.border}`,
              padding: 6, cursor: 'pointer', color: t.ink, display: 'flex',
              borderRadius: 0,
            }}>
              <IconArrowLeft size={14} stroke={t.ink} sw={2} />
            </button>
          )}
          <div style={{ flex: 1, minWidth: 0 }}>
            {subtitle && (
              <div style={{
                fontFamily: t.fontMono, fontSize: t.fz(10), color: t.inkSoft,
                letterSpacing: '0.2em', textTransform: 'uppercase', marginBottom: 4,
              }}>— {subtitle}</div>
            )}
            <div style={{
              fontFamily: t.fontDisplay, fontSize: t.fz(22), fontWeight: 600,
              color: t.ink, letterSpacing: '0.01em', lineHeight: 1.2,
            }}>{title}</div>
          </div>
          {right}
        </div>
      </div>
    );
  }

  // Refined default
  return (
    <div style={{
      padding: '54px 22px 18px',
      background: accent ? (t.accentSurface || t.ink) : t.bg,
      color: accent ? (t.accentSurfaceInk || t.bg) : t.ink,
      position: 'relative',
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
        {onBack && (
          <button onClick={onBack} aria-label="back" style={{
            background: 'transparent', border: 'none',
            padding: 6, marginLeft: -6, cursor: 'pointer',
            color: accent ? (t.accentSurfaceInk || t.bg) : t.ink, display: 'flex',
          }}>
            <IconArrowLeft size={22} stroke={accent ? (t.accentSurfaceInk || t.bg) : t.ink} sw={2.4} />
          </button>
        )}
        <div style={{ flex: 1, minWidth: 0 }}>
          {subtitle && (
            <div style={{
              fontSize: t.fz(13),
              color: accent ? (t.accentSurfaceInkSoft || 'rgba(245,242,236,0.7)') : t.inkSoft,
              marginBottom: 4,
            }}>{subtitle}</div>
          )}
          <div style={{
            fontFamily: t.fontDisplay, fontSize: t.fz(24), fontWeight: 700,
            letterSpacing: '-0.02em', lineHeight: 1.15,
          }}>{title}</div>
        </div>
        {right}
      </div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// CrossMark — small + tick used by blueprint corners
// ────────────────────────────────────────────────────────────────────
function CrossMark({ t, pos, size = 10 }) {
  return (
    <div style={{ position: 'absolute', width: size, height: size, ...pos, pointerEvents: 'none' }}>
      <div style={{ position: 'absolute', top: size/2 - 0.5, left: 0, right: 0, height: 1, background: t.inkSoft, opacity: 0.6 }} />
      <div style={{ position: 'absolute', left: size/2 - 0.5, top: 0, bottom: 0, width: 1, background: t.inkSoft, opacity: 0.6 }} />
    </div>
  );
}

// ────────────────────────────────────────────────────────────────────
// Card — surface container, treatment varies by direction
// ────────────────────────────────────────────────────────────────────
function Card({ t, children, onClick, style = {}, padded = true, accent = false }) {
  const accentBg = t.accentSurface || t.ink;
  const accentFg = t.accentSurfaceInk || t.bg;
  const common = {
    background: accent ? accentBg : t.surface,
    color: accent ? accentFg : t.ink,
    padding: padded ? 16 : 0,
    cursor: onClick ? 'pointer' : 'default',
    position: 'relative',
    ...style,
  };
  if (t.id === 'stamp') {
    return (
      <div onClick={onClick} style={{
        ...common,
        border: `1.5px solid ${accent ? t.ink : t.borderStrong}`,
        boxShadow: `3px 3px 0 ${accent ? t.borderStrong : t.borderStrong}`,
        borderRadius: t.radius,
      }}>{children}</div>
    );
  }
  if (t.id === 'blueprint') {
    return (
      <div onClick={onClick} style={{
        ...common,
        background: accent ? t.accent : 'transparent',
        color: accent ? t.bg : t.ink,
        border: `1px solid ${t.border}`,
        borderRadius: 0,
      }}>{children}</div>
    );
  }
  return (
    <div onClick={onClick} style={{
      ...common,
      borderRadius: t.radius,
      border: `1px solid ${t.border}`,
    }}>{children}</div>
  );
}

// ────────────────────────────────────────────────────────────────────
// Divider — dashed / dotted / hatched
// ────────────────────────────────────────────────────────────────────
function Divider({ t, style = {} }) {
  if (t.id === 'stamp') {
    return (
      <div style={{
        height: 1, margin: '10px 0',
        backgroundImage: `radial-gradient(circle, ${t.borderStrong} 1px, transparent 1px)`,
        backgroundSize: '8px 1px', backgroundRepeat: 'repeat-x',
        ...style,
      }} />
    );
  }
  if (t.id === 'blueprint') {
    return (
      <div style={{
        height: 1, margin: '10px 0',
        background: `repeating-linear-gradient(to right, ${t.border} 0 6px, transparent 6px 10px)`,
        ...style,
      }} />
    );
  }
  return (
    <div style={{
      height: 1, margin: '10px 0',
      borderTop: `1px dashed ${t.border}`,
      ...style,
    }} />
  );
}

// ────────────────────────────────────────────────────────────────────
// PrimaryButton
// ────────────────────────────────────────────────────────────────────
function PrimaryButton({ t, children, onClick, style = {}, icon }) {
  if (t.id === 'stamp') {
    return (
      <button onClick={onClick} style={{
        background: t.ink, color: t.surface,
        border: 'none', padding: '14px 18px',
        fontSize: t.fz(16), fontWeight: 700, fontFamily: t.fontDisplay,
        width: '100%', cursor: 'pointer', display: 'flex',
        alignItems: 'center', justifyContent: 'center', gap: 8,
        boxShadow: `3px 3px 0 ${t.accent}`,
        letterSpacing: '0.05em',
        ...style,
      }}>
        {icon}{children}
      </button>
    );
  }
  if (t.id === 'blueprint') {
    return (
      <button onClick={onClick} style={{
        background: t.accent, color: t.bg,
        border: 'none', padding: '14px 18px',
        fontSize: t.fz(15), fontWeight: 600, fontFamily: t.fontDisplay,
        width: '100%', cursor: 'pointer', display: 'flex',
        alignItems: 'center', justifyContent: 'center', gap: 8,
        letterSpacing: '0.08em', textTransform: 'uppercase',
        ...style,
      }}>
        {icon}{children}
      </button>
    );
  }
  return (
    <button onClick={onClick} style={{
      background: t.accent, color: '#fff',
      border: 'none', padding: '15px 18px',
      fontSize: t.fz(16), fontWeight: 600, fontFamily: t.fontSans,
      borderRadius: t.radius, width: '100%', cursor: 'pointer',
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      ...style,
    }}>
      {icon}{children}
    </button>
  );
}

function SecondaryButton({ t, children, onClick, style = {} }) {
  const common = {
    width: '100%', padding: '12px 16px',
    fontSize: t.fz(15), fontFamily: t.fontSans, fontWeight: 600,
    cursor: 'pointer', display: 'flex', alignItems: 'center',
    justifyContent: 'center', gap: 8,
    ...style,
  };
  if (t.id === 'blueprint') {
    return (
      <button onClick={onClick} style={{
        ...common, background: 'transparent', color: t.ink,
        border: `1px solid ${t.border}`, borderRadius: 0,
      }}>{children}</button>
    );
  }
  if (t.id === 'stamp') {
    return (
      <button onClick={onClick} style={{
        ...common, background: t.surface, color: t.ink,
        border: `1.5px solid ${t.ink}`, borderRadius: t.radius,
        fontFamily: t.fontDisplay,
      }}>{children}</button>
    );
  }
  return (
    <button onClick={onClick} style={{
      ...common, background: t.surface, color: t.ink,
      border: `1.5px solid ${t.borderStrong}`, borderRadius: t.radius,
    }}>{children}</button>
  );
}

// ────────────────────────────────────────────────────────────────────
// Background — full-app paper / grid surface
// ────────────────────────────────────────────────────────────────────
function AppBackground({ t }) {
  if (t.id === 'blueprint') {
    return (
      <>
        {/* main grid */}
        <div style={{
          position: 'absolute', inset: 0, pointerEvents: 'none',
          backgroundImage: `
            linear-gradient(to right, ${t.border}22 1px, transparent 1px),
            linear-gradient(to bottom, ${t.border}22 1px, transparent 1px)`,
          backgroundSize: '20px 20px',
        }} />
        {/* major grid lines every 100px */}
        <div style={{
          position: 'absolute', inset: 0, pointerEvents: 'none',
          backgroundImage: `
            linear-gradient(to right, ${t.border}55 1px, transparent 1px),
            linear-gradient(to bottom, ${t.border}55 1px, transparent 1px)`,
          backgroundSize: '100px 100px',
        }} />
      </>
    );
  }
  if (t.id === 'stamp') {
    return <Grain opacity={t.paperGrain} seed={3} />;
  }
  return <Grain opacity={t.paperGrain} seed={5} />;
}

// ────────────────────────────────────────────────────────────────────
// TextInput — themed form input
// ────────────────────────────────────────────────────────────────────
function TextInput({ t, value, onChange, placeholder, leadingIcon, style = {} }) {
  const common = {
    width: '100%', padding: '13px 14px',
    fontSize: t.fz(16), color: t.ink, background: t.surface,
    fontFamily: t.fontSans, boxSizing: 'border-box',
    paddingLeft: leadingIcon ? 40 : 14,
  };
  let extra = {};
  if (t.id === 'blueprint') {
    extra = { border: `1px solid ${t.border}`, borderRadius: 0 };
  } else if (t.id === 'stamp') {
    extra = { border: `1.5px solid ${t.borderStrong}`, borderRadius: t.radius };
  } else {
    extra = { border: `1.5px solid ${t.border}`, borderRadius: t.radius };
  }
  return (
    <div style={{ position: 'relative' }}>
      {leadingIcon && (
        <div style={{
          position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)',
          color: t.inkSoft, display: 'flex',
        }}>{leadingIcon}</div>
      )}
      <input value={value} onChange={onChange} placeholder={placeholder}
        style={{ ...common, ...extra, ...style }} />
    </div>
  );
}

Object.assign(window, {
  StatusBadge, Money, AppHeader, Card, Divider, PrimaryButton,
  SecondaryButton, AppBackground, TextInput, CrossMark, BottomCTA,
});

// ────────────────────────────────────────────────────────────────────
// BottomCTA — fixed-position sticky bottom area shared across screens.
// Keeps the primary button at the same Y across every flow screen.
// Optional `above` slot for a summary row (e.g. "目前小計 $123").
// ────────────────────────────────────────────────────────────────────
function BottomCTA({ t, children, above, sub, withBackground = true }) {
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 30,
      padding: '14px 22px 36px',
      background: withBackground ? t.bg : 'transparent',
      borderTop: withBackground ? `1px solid ${t.border}` : 'none',
      display: 'flex', flexDirection: 'column', gap: 10,
    }}>
      {above}
      {sub}
      {children}
    </div>
  );
}
