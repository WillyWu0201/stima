// Three design directions, expressed as theme objects.
// Each theme provides tokens + custom render functions for the
// visual moments where directions truly diverge (status badges,
// money displays, paper textures, header treatments).

const { useState: rsUS, useMemo: rsUM } = React;

// ────────────────────────────────────────────────────────────────────
// Direction A — 踏實版 / Refined Warm
// Stays close to the existing palette but introduces subtle paper
// grain, generous spacing, and a friendlier handwritten greeting.
// ────────────────────────────────────────────────────────────────────
const THEME_A = {
  id: 'refined',
  name: '踏實版',
  tagline: '把現有設計打磨成完成品',
  // colors — light
  bg: '#F5F2EC',
  bgSoft: '#EFEAE0',
  surface: '#FFFFFF',
  surfaceAlt: '#FAF7F1',
  ink: '#1A1A1A',
  inkMid: '#3D3833',
  inkSoft: '#6B6660',
  inkFaint: '#9B8E7A',
  border: '#E5E0D5',
  borderStrong: '#C9BFB0',
  accent: '#C9522A',
  accent2: '#E89B5C',
  positive: '#5C8A6B',
  cool: '#3E6B9B',
  warn: '#A37B2E',
  // "accent surface" — used for the dark hero card / header bg. Stays
  // dark in BOTH modes so it reads as an emphasised dark cap, not as
  // a light slab on a dark canvas.
  accentSurface: '#1A1A1A',
  accentSurfaceInk: '#F5F2EC',
  accentSurfaceInkSoft: 'rgba(245,242,236,0.7)',
  // typography
  fontSans: '"Noto Sans TC", "PingFang TC", -apple-system, sans-serif',
  fontDisplay: '"Noto Sans TC", "PingFang TC", sans-serif',
  fontHand: '"Caveat", "Noto Sans TC", cursive',
  fontMono: '"IBM Plex Mono", "Menlo", monospace',
  fontNumeric: '"Noto Sans TC"',
  // dark mode overrides
  dark: {
    bg: '#17140F',
    bgSoft: '#1F1B16',
    surface: '#26221C',
    surfaceAlt: '#2E2923',
    ink: '#F2EDE3',
    inkMid: '#CFC7BB',
    inkSoft: '#9A9085',
    inkFaint: '#6E6459',
    border: '#3A332C',
    borderStrong: '#52473A',
    accent: '#E89B5C',
    accent2: '#C9522A',
    positive: '#7FB890',
    cool: '#7FA8D6',
    // In dark mode the "accent surface" stays a deeper-than-bg charcoal —
    // a *darker* cap, not a *lighter* one, so it never inverts to cream.
    accentSurface: '#0E0B07',
    accentSurfaceInk: '#F2EDE3',
    accentSurfaceInkSoft: 'rgba(242,237,227,0.65)',
  },
  // tokens
  radius: 14,
  radiusBig: 22,
  // texture
  paperGrain: 0.05,
};

// ────────────────────────────────────────────────────────────────────
// Direction B — 印章工坊 / Kraft + Stamp
// Kraft paper, ink stamps, serif headers, mono receipt numerals.
// More tactile and crafty.
// ────────────────────────────────────────────────────────────────────
const THEME_B = {
  id: 'stamp',
  name: '印章工坊',
  tagline: '紙感、印章、收據感的手作風',
  bg: '#E8DCC0',
  bgSoft: '#DCCFB0',
  surface: '#F2EAD5',
  surfaceAlt: '#EBE0C2',
  ink: '#211913',
  inkMid: '#3F3225',
  inkSoft: '#6E5D43',
  inkFaint: '#9C8865',
  border: '#C6B286',
  borderStrong: '#A89260',
  accent: '#B33A2A',
  accent2: '#D88A3F',
  positive: '#4F7152',
  cool: '#385876',
  warn: '#92682B',
  fontSans: '"Noto Sans TC", "PingFang TC", sans-serif',
  fontDisplay: '"Noto Serif TC", "PingFang TC", serif',
  fontHand: '"Caveat", "Noto Serif TC", cursive',
  fontMono: '"JetBrains Mono", "Courier New", monospace',
  fontNumeric: '"JetBrains Mono", monospace',
  dark: {
    bg: '#1E1812',
    bgSoft: '#28201A',
    surface: '#2E2620',
    surfaceAlt: '#352C24',
    ink: '#F2EAD5',
    inkMid: '#D9CCAE',
    inkSoft: '#A89060',
    inkFaint: '#7A6A4A',
    border: '#3D3527',
    borderStrong: '#52472F',
    accent: '#D88A3F',
    accent2: '#B33A2A',
  },
  radius: 6,
  radiusBig: 8,
  paperGrain: 0.13,
};

// ────────────────────────────────────────────────────────────────────
// Direction C — 工程藍圖 / Blueprint
// Cyan-navy ground with white technical strokes. Caution-yellow
// accents. Tabular mono numerals. Most editorial / avant-garde.
// ────────────────────────────────────────────────────────────────────
const THEME_C = {
  id: 'blueprint',
  name: '工程藍圖',
  tagline: '工地老闆的施工圖介面',
  bg: '#0E2F50',
  bgSoft: '#143C63',
  surface: '#0E2F50',
  surfaceAlt: '#143C63',
  ink: '#F4F1E8',
  inkMid: '#D4DAE6',
  inkSoft: '#A8B6CC',
  inkFaint: '#6E84A8',
  border: '#3A6090',
  borderStrong: '#5A7CB0',
  accent: '#F5C24F',
  accent2: '#FF8B5C',
  positive: '#7FD89B',
  cool: '#9ECBFF',
  warn: '#F5C24F',
  fontSans: '"Inter", "Noto Sans TC", sans-serif',
  fontDisplay: '"IBM Plex Mono", "Noto Sans TC", monospace',
  fontHand: '"Caveat", cursive',
  fontMono: '"IBM Plex Mono", "JetBrains Mono", monospace',
  fontNumeric: '"IBM Plex Mono", monospace',
  dark: {
    // For blueprint, "dark" mode flips to a daytime blueprint: pale
    // cyan paper on white-ish ground. Same engineering vibe, lighter.
    bg: '#E8EEF3',
    bgSoft: '#D6E0EA',
    surface: '#F1F5F9',
    surfaceAlt: '#E2EAF2',
    ink: '#0E2F50',
    inkMid: '#1F4775',
    inkSoft: '#4A6A92',
    inkFaint: '#7A92B0',
    border: '#A0B5CE',
    borderStrong: '#6A85A8',
    accent: '#1F4775',
    accent2: '#C9522A',
  },
  radius: 0,
  radiusBig: 2,
  paperGrain: 0.04,
};

// ────────────────────────────────────────────────────────────────────
// Resolve a theme + dark flag into a flat token map.
// (Plus a font-size scale.)
// ────────────────────────────────────────────────────────────────────
function resolveTheme(theme, { dark, scale = 1 }) {
  const base = { ...theme };
  if (dark) Object.assign(base, theme.dark);
  base.scale = scale;
  base.fz = (n) => Math.round(n * scale * 10) / 10;
  return base;
}

const ALL_THEMES = [THEME_A, THEME_B, THEME_C];
Object.assign(window, { THEME_A, THEME_B, THEME_C, ALL_THEMES, resolveTheme });
