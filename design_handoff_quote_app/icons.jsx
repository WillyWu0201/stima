// Minimal SVG icons — kept inline so we don't ship lucide
const Icon = ({ d, size = 20, stroke = 'currentColor', sw = 2, fill = 'none', children, ...rest }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={stroke}
    strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" {...rest}>
    {d ? <path d={d} /> : children}
  </svg>
);

const IconPlus = (p) => <Icon {...p} d="M12 5v14M5 12h14" />;
const IconArrowLeft = (p) => <Icon {...p} d="M19 12H5M12 19l-7-7 7-7" />;
const IconArrowRight = (p) => <Icon {...p} d="M5 12h14M12 5l7 7-7 7" />;
const IconCheck = (p) => <Icon {...p} d="M20 6L9 17l-5-5" />;
const IconSearch = (p) => <Icon {...p}><circle cx="11" cy="11" r="7" /><path d="M21 21l-4.3-4.3" /></Icon>;
const IconHome = (p) => <Icon {...p} d="M3 12l9-9 9 9M5 10v10h14V10" />;
const IconChart = (p) => <Icon {...p} d="M3 3v18h18M7 14l4-4 4 4 5-5" />;
const IconUser = (p) => <Icon {...p}><circle cx="12" cy="8" r="4" /><path d="M4 21c0-4 4-7 8-7s8 3 8 7" /></Icon>;
const IconMapPin = (p) => <Icon {...p}><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 1118 0z" /><circle cx="12" cy="10" r="3" /></Icon>;
const IconCalendar = (p) => <Icon {...p}><rect x="3" y="5" width="18" height="16" rx="2" /><path d="M3 9h18M8 3v4M16 3v4" /></Icon>;
const IconFolder = (p) => <Icon {...p} d="M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V7z" />;
const IconChevronRight = (p) => <Icon {...p} d="M9 6l6 6-6 6" />;
const IconChevronDown = (p) => <Icon {...p} d="M6 9l6 6 6-6" />;
const IconSettings = (p) => <Icon {...p}><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.7 1.7 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.7 1.7 0 00-1.8-.3 1.7 1.7 0 00-1 1.5V21a2 2 0 11-4 0v-.1a1.7 1.7 0 00-1-1.5 1.7 1.7 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.7 1.7 0 00.3-1.8 1.7 1.7 0 00-1.5-1H3a2 2 0 110-4h.1a1.7 1.7 0 001.5-1 1.7 1.7 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.7 1.7 0 001.8.3H9a1.7 1.7 0 001-1.5V3a2 2 0 114 0v.1a1.7 1.7 0 001 1.5 1.7 1.7 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.7 1.7 0 00-.3 1.8V9a1.7 1.7 0 001.5 1H21a2 2 0 110 4h-.1a1.7 1.7 0 00-1.5 1z" /></Icon>;
const IconX = (p) => <Icon {...p} d="M18 6L6 18M6 6l12 12" />;
const IconTrash = (p) => <Icon {...p}><path d="M3 6h18M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6" /></Icon>;
const IconFileText = (p) => <Icon {...p}><path d="M14 3H6a2 2 0 00-2 2v14a2 2 0 002 2h12a2 2 0 002-2V9z" /><path d="M14 3v6h6M8 14h8M8 18h5" /></Icon>;
const IconShare = (p) => <Icon {...p}><circle cx="18" cy="5" r="3" /><circle cx="6" cy="12" r="3" /><circle cx="18" cy="19" r="3" /><path d="M8.6 13.5l6.8 4M15.4 6.5l-6.8 4" /></Icon>;
const IconHammer = (p) => <Icon {...p}><path d="M14 2l8 8-3 3-8-8z" /><path d="M11 5L3 13l3 3 8-8" /><path d="M5 19l3 3" /></Icon>;
const IconCoins = (p) => <Icon {...p}><circle cx="8" cy="8" r="6" /><path d="M18.1 10.4a6 6 0 11-7.6 7.6M7 6h1v4M16.7 13.6h1v4M5 14h6" /></Icon>;
const IconTrendUp = (p) => <Icon {...p} d="M3 17l6-6 4 4 8-8M14 7h7v7" />;
const IconSparkle = (p) => <Icon {...p} d="M12 3l1.5 4.5L18 9l-4.5 1.5L12 15l-1.5-4.5L6 9l4.5-1.5L12 3zM19 14l.8 2.2L22 17l-2.2.8L19 20l-.8-2.2L16 17l2.2-.8L19 14z" />;
const IconHardHat = (p) => <Icon {...p}><path d="M2 17h20v3H2zM5 17a7 7 0 0114 0M9 12V8a3 3 0 016 0v4" /></Icon>;
const IconRuler = (p) => <Icon {...p}><path d="M16 2L2 16l6 6L22 8z" /><path d="M7 17l-2-2M11 13l-2-2M15 9l-2-2M19 5l-2-2" /></Icon>;
const IconStamp = (p) => <Icon {...p}><path d="M9 3h6v6c0 1.7 1.3 3 3 3h0a2 2 0 012 2v2H4v-2a2 2 0 012-2h0c1.7 0 3-1.3 3-3V3zM4 21h16" /></Icon>;
const IconClock = (p) => <Icon {...p}><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></Icon>;
const IconBuilding = (p) => <Icon {...p}><path d="M4 21V5a2 2 0 012-2h12a2 2 0 012 2v16M9 7h1M9 11h1M9 15h1M14 7h1M14 11h1M14 15h1M9 21v-4h6v4" /></Icon>;
const IconPhone = (p) => <Icon {...p} d="M22 16.9v3a2 2 0 01-2.2 2 19.8 19.8 0 01-8.6-3 19.5 19.5 0 01-6-6 19.8 19.8 0 01-3-8.7A2 2 0 014.1 2h3a2 2 0 012 1.7c.1.9.3 1.8.6 2.7a2 2 0 01-.5 2.1L8 9.8a16 16 0 006 6l1.3-1.3a2 2 0 012.1-.4c.9.3 1.8.5 2.7.6a2 2 0 011.7 2z" />;

Object.assign(window, {
  IconPlus, IconArrowLeft, IconArrowRight, IconCheck, IconSearch, IconHome,
  IconChart, IconUser, IconMapPin, IconCalendar, IconFolder, IconChevronRight,
  IconChevronDown, IconSettings, IconX, IconTrash, IconFileText, IconShare,
  IconHammer, IconCoins, IconTrendUp, IconSparkle, IconHardHat, IconRuler,
  IconStamp, IconClock, IconBuilding, IconPhone,
});
