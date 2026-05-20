// Shared sample data — mirrors the prototype's quotes, expanded with
// new fields for contacts, costs, photos, invoice status, etc.
const SAMPLE_CLIENTS = [
  { id: 'c1', name: '王先生', phone: '0912-345-678', email: '',                 address: '台北市信義區松仁路 100 號',     notes: '新案場主，喜歡簡潔風',         lastContact: '2026-05-15' },
  { id: 'c2', name: '林太太', phone: '0922-111-222', email: 'lin@example.com',  address: '新北市板橋區文化路二段 150 號', notes: '老客戶，付款乾脆',             lastContact: '2026-05-10' },
  { id: 'c3', name: '張先生', phone: '0933-456-789', email: '',                 address: '台北市大安區仁愛路四段 27 號',  notes: '介紹過 3 位朋友',              lastContact: '2026-04-28' },
  { id: 'c4', name: '李小姐', phone: '0955-789-123', email: '',                 address: '新北市中和區中山路一段 88 號', notes: '',                              lastContact: '2026-04-15' },
  { id: 'c5', name: '黃先生', phone: '0966-234-567', email: '',                 address: '桃園市中壢區中央西路 33 號',  notes: '林老闆介紹',                   lastContact: '2026-03-20' },
  { id: 'c6', name: '陳老闆', phone: '0988-098-123', email: 'chen@biz.tw',     address: '台北市內湖區瑞光路 188 號',    notes: '辦公室客戶，每年 2~3 案',     lastContact: '2026-02-12' },
];
const SAMPLE_QUOTES = [
  { id: 1, client: '王先生', location: '台北市信義區', date: '2026-05-15', total: 285000, status: 'ongoing', folder: '2026',
    itemList: [
      { name: '拆除磁磚', unit: '坪', qty: 10, price: 1800 },
      { name: '冷氣排水管', unit: '式', qty: 1, price: 3500 },
      { name: '油漆批土', unit: '坪', qty: 25, price: 850 },
    ] },
  { id: 2, client: '林太太', location: '新北市板橋區', date: '2026-05-10', total: 156000, status: 'paid', folder: '2026',
    itemList: [
      { name: '水電配管', unit: '式', qty: 1, price: 35000 },
      { name: '新增插座', unit: '個', qty: 8, price: 1200 },
    ] },
  { id: 3, client: '張先生', location: '台北市大安區', date: '2026-04-28', total: 420000, status: 'ongoing', folder: '老客戶',
    itemList: [
      { name: '木作天花板', unit: '坪', qty: 30, price: 3200 },
      { name: '系統櫃', unit: '尺', qty: 25, price: 4500 },
    ] },
  { id: 4, client: '李小姐', location: '新北市中和區', date: '2026-04-15', total: 98000, status: 'done', folder: '2026',
    itemList: [
      { name: '貼磁磚', unit: '坪', qty: 8, price: 2800 },
      { name: '防水工程', unit: '坪', qty: 8, price: 1800 },
    ] },
  { id: 5, client: '黃先生', location: '桃園市中壢區', date: '2026-03-20', total: 215000, status: 'draft', folder: '林老闆介紹',
    itemList: [
      { name: '冷氣排水管', unit: '式', qty: 2, price: 3500 },
      { name: '全室油漆', unit: '坪', qty: 35, price: 1200 },
    ] },
  { id: 6, client: '陳老闆', location: '台北市內湖區', date: '2026-02-12', total: 380000, status: 'paid', folder: '老客戶',
    itemList: [
      { name: '木作天花板', unit: '坪', qty: 25, price: 3200 },
      { name: '系統櫃', unit: '尺', qty: 18, price: 4500 },
      { name: '全室油漆', unit: '坪', qty: 18, price: 1200 },
    ] },
];

const ITEM_LIBRARY = {
  '常用': [
    { name: '拆除磁磚', unit: '坪', lastPrice: 1800, usedCount: 42 },
    { name: '泥作粉光', unit: '坪', lastPrice: 2500, usedCount: 38 },
    { name: '水電配管', unit: '式', lastPrice: 35000, usedCount: 35 },
    { name: '油漆批土', unit: '坪', lastPrice: 850, usedCount: 31 },
    { name: '木作天花板', unit: '坪', lastPrice: 3200, usedCount: 28 },
  ],
  '拆除': [
    { name: '拆除磁磚', unit: '坪', lastPrice: 1800 },
    { name: '拆除木作', unit: '坪', lastPrice: 1500 },
    { name: '拆除隔間牆', unit: '坪', lastPrice: 2200 },
  ],
  '水電': [
    { name: '水電配管', unit: '式', lastPrice: 35000 },
    { name: '新增插座', unit: '個', lastPrice: 1200 },
    { name: '燈具安裝', unit: '組', lastPrice: 800 },
    { name: '冷氣排水管', unit: '式', lastPrice: 3500 },
  ],
  '泥作': [
    { name: '泥作粉光', unit: '坪', lastPrice: 2500 },
    { name: '貼磁磚', unit: '坪', lastPrice: 2800 },
    { name: '防水工程', unit: '坪', lastPrice: 1800 },
  ],
  '木作': [
    { name: '木作天花板', unit: '坪', lastPrice: 3200 },
    { name: '系統櫃', unit: '尺', lastPrice: 4500 },
    { name: '木地板施作', unit: '坪', lastPrice: 4800 },
  ],
};

// Monthly income (paid only) for 2026 stats
const MONTHLY_2026 = [0, 142000, 0, 0, 156000, 0, 0, 0, 0, 0, 0, 0]; // just to show shape — will compute from data

Object.assign(window, { SAMPLE_QUOTES, ITEM_LIBRARY, SAMPLE_CLIENTS });
