// Shared helpers used by all three direction apps.
// Each direction provides its own theme + screen renderers; this file just
// supplies primitives that don't change much across directions.

const { useState, useEffect, useRef, useMemo, Fragment } = React;

// ─── currency formatting ────────────────────────────────────────────────
const fmt = (n) => '$' + Number(n).toLocaleString();
const fmtK = (n) => n >= 1000 ? '$' + Math.round(n / 1000) + 'k' : '$' + n;

// ─── SVG noise / grain pattern (reused) ─────────────────────────────────
function Grain({ opacity = 0.06, seed = 7 }) {
  return (
    <svg style={{
      position: 'absolute', inset: 0, width: '100%', height: '100%',
      pointerEvents: 'none', mixBlendMode: 'multiply', opacity,
    }} aria-hidden>
      <filter id={`g${seed}`}>
        <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" seed={seed} />
        <feColorMatrix values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0.6 0" />
      </filter>
      <rect width="100%" height="100%" filter={`url(#g${seed})`} />
    </svg>
  );
}

// ─── compute stats from quotes (shared between directions) ──────────────
function useYearStats(quotes, year) {
  return useMemo(() => {
    const ys = quotes.filter(q => q.date.startsWith(String(year)));
    const paid = ys.filter(q => q.status === 'paid');
    const done = ys.filter(q => q.status === 'done');
    const ongoing = ys.filter(q => q.status === 'ongoing');

    const paidTotal = paid.reduce((s, q) => s + q.total, 0);
    const doneTotal = done.reduce((s, q) => s + q.total, 0);
    const ongoingTotal = ongoing.reduce((s, q) => s + q.total, 0);

    const monthly = Array(12).fill(0);
    paid.forEach(q => {
      const m = parseInt(q.date.slice(5, 7)) - 1;
      monthly[m] += q.total;
    });
    const maxMonthly = Math.max(...monthly, 1);

    const clientMap = {};
    ys.forEach(q => {
      if (!clientMap[q.client]) clientMap[q.client] = { count: 0, total: 0 };
      clientMap[q.client].count += 1;
      if (q.status === 'paid') clientMap[q.client].total += q.total;
    });
    const topClient = Object.entries(clientMap).sort((a, b) => b[1].total - a[1].total)[0];

    const itemMap = {};
    ys.forEach(q => q.itemList?.forEach(it => {
      if (!itemMap[it.name]) itemMap[it.name] = { count: 0, totalQty: 0, totalRev: 0, unit: it.unit };
      itemMap[it.name].count += 1;
      itemMap[it.name].totalQty += it.qty;
      itemMap[it.name].totalRev += it.qty * it.price;
    }));
    const topItems = Object.entries(itemMap).sort((a, b) => b[1].count - a[1].count).slice(0, 5);

    return {
      total: ys.length, paidCount: paid.length, doneCount: done.length, ongoingCount: ongoing.length,
      paidTotal, doneTotal, ongoingTotal, monthly, maxMonthly,
      totalClients: Object.keys(clientMap).length,
      repeatClients: Object.values(clientMap).filter(c => c.count >= 2).length,
      topClient, topItems,
    };
  }, [quotes, year]);
}

// ─── onboarding state hook ──────────────────────────────────────────────
// Returns { screen, setScreen, coach, dismissCoach } and a sample first-time
// flow that each direction can drive. Coach hints fire on transitions.
function useAppNav(initial = 'splash') {
  const [screen, setScreen] = useState(initial);
  const [coach, setCoach] = useState(null);
  const dismissCoach = () => setCoach(null);
  return { screen, setScreen, coach, setCoach, dismissCoach };
}

// ─── month / status labels ──────────────────────────────────────────────
const MONTHS_TC = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];

const STATUS_LABEL = {
  ongoing: '進行中',
  done:    '已完工',
  paid:    '已收款',
  draft:   '草稿',
};

Object.assign(window, {
  fmt, fmtK, Grain, useYearStats, useAppNav, MONTHS_TC, STATUS_LABEL,
});
