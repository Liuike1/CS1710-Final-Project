const d3 = require('d3');

d3.selectAll('svg > *').remove();

const states = (typeof instances !== 'undefined' && instances.length > 0)
  ? instances
  : [instance];

// Interpret the model as a standard corner-cubie representation:
// `tOne` = solved orientation, `tTwo` = +1 twist, `tThree` = +2 twist.
const SLOT_ORDER = ['UFR', 'UFL', 'UBR', 'UBL', 'DFR', 'DFL', 'DBR', 'DBL'];

const FACE_NAMES = {
  U: 'Up',
  D: 'Down',
  F: 'Front',
  B: 'Back',
  L: 'Left',
  R: 'Right'
};

const FACE_COLORS = {
  U: '#f8f9fa',
  D: '#ffd43b',
  F: '#2f9e44',
  B: '#1971c2',
  L: '#f08c00',
  R: '#e03131'
};

const FACE_INK = {
  U: '#111111',
  D: '#111111',
  F: '#ffffff',
  B: '#ffffff',
  L: '#111111',
  R: '#ffffff'
};

const TWIST_INDEX = {
  tOne: 0,
  tTwo: 1,
  tThree: 2
};

const BLOCK_COLORS = {
  bUFR: ['U', 'R', 'F'],
  bUFL: ['U', 'F', 'L'],
  bUBR: ['U', 'B', 'R'],
  bUBL: ['U', 'L', 'B'],
  bDFR: ['D', 'F', 'R'],
  bDFL: ['D', 'L', 'F'],
  bDBR: ['D', 'R', 'B'],
  bDBL: ['D', 'B', 'L']
};

const POSITION_STICKERS = {
  UFR: [
    { face: 'U', row: 1, col: 1 },
    { face: 'R', row: 0, col: 0 },
    { face: 'F', row: 0, col: 1 }
  ],
  UFL: [
    { face: 'U', row: 1, col: 0 },
    { face: 'F', row: 0, col: 0 },
    { face: 'L', row: 0, col: 1 }
  ],
  UBR: [
    { face: 'U', row: 0, col: 1 },
    { face: 'B', row: 0, col: 0 },
    { face: 'R', row: 0, col: 1 }
  ],
  UBL: [
    { face: 'U', row: 0, col: 0 },
    { face: 'L', row: 0, col: 0 },
    { face: 'B', row: 0, col: 1 }
  ],
  DFR: [
    { face: 'D', row: 0, col: 1 },
    { face: 'F', row: 1, col: 1 },
    { face: 'R', row: 1, col: 0 }
  ],
  DFL: [
    { face: 'D', row: 0, col: 0 },
    { face: 'L', row: 1, col: 1 },
    { face: 'F', row: 1, col: 0 }
  ],
  DBR: [
    { face: 'D', row: 1, col: 1 },
    { face: 'R', row: 1, col: 1 },
    { face: 'B', row: 1, col: 0 }
  ],
  DBL: [
    { face: 'D', row: 1, col: 0 },
    { face: 'B', row: 1, col: 1 },
    { face: 'L', row: 1, col: 0 }
  ]
};

const STICKER = 34;
const STICKER_GAP = 4;
const FACE_PADDING = 8;
const FACE_GAP = 14;
const STATE_PADDING = 18;
const STATE_TITLE = 24;
const FACE_LABEL = 16;
const TABLE_GAP = 24;
const TABLE_WIDTH = 230;
const TABLE_HEADER = 18;
const TABLE_ROW = 18;
const STATE_GAP = 28;
const LEGEND_HEIGHT = 72;

const GRID = (STICKER * 2) + STICKER_GAP;
const FACE_CARD = GRID + (FACE_PADDING * 2);
const FACE_BLOCK = FACE_CARD + FACE_LABEL;
const NET_WIDTH = (FACE_BLOCK * 4) + (FACE_GAP * 3);
const NET_HEIGHT = (FACE_BLOCK * 3) + (FACE_GAP * 2);
const BODY_HEIGHT = Math.max(NET_HEIGHT, TABLE_HEADER + (SLOT_ORDER.length * TABLE_ROW) + 8);
const STATE_WIDTH = (STATE_PADDING * 2) + NET_WIDTH + TABLE_GAP + TABLE_WIDTH;
const STATE_HEIGHT = (STATE_PADDING * 2) + STATE_TITLE + BODY_HEIGHT;
const TOTAL_WIDTH = states.length === 0
  ? STATE_WIDTH
  : (STATE_WIDTH * states.length) + (STATE_GAP * Math.max(states.length - 1, 0));
const TOTAL_HEIGHT = STATE_HEIGHT + LEGEND_HEIGHT;

const svgNode = svg;
const scrollHost = svgNode && svgNode.parentElement ? svgNode.parentElement : null;

if (scrollHost) {
  scrollHost.style.overflowX = 'auto';
  scrollHost.style.overflowY = 'hidden';
  scrollHost.style.width = '100%';
}

const root = d3.select(svgNode)
  .attr('viewBox', `0 0 ${TOTAL_WIDTH} ${TOTAL_HEIGHT}`)
  .attr('width', TOTAL_WIDTH)
  .attr('height', TOTAL_HEIGHT)
  .attr('preserveAspectRatio', 'xMinYMin meet')
  .style('width', `${TOTAL_WIDTH}px`)
  .style('height', `${TOTAL_HEIGHT}px`)
  .style('max-width', 'none')
  .style('display', 'block')
  .style('background', '#fcfcfd');

if (states.length === 0) {
  root.append('text')
    .attr('x', 20)
    .attr('y', 40)
    .attr('fill', '#111111')
    .attr('font-size', 16)
    .attr('font-family', 'sans-serif')
    .text('No states to visualize.');
}

states.forEach((state, index) => {
  drawState(state, index);
});

drawLegend(TOTAL_HEIGHT - LEGEND_HEIGHT + 10);

function drawState(state, index) {
  const left = index * (STATE_WIDTH + STATE_GAP);
  const group = root.append('g')
    .attr('transform', `translate(${left}, 0)`);

  group.append('rect')
    .attr('x', 1)
    .attr('y', 1)
    .attr('width', STATE_WIDTH - 2)
    .attr('height', STATE_HEIGHT - 2)
    .attr('rx', 16)
    .attr('ry', 16)
    .attr('fill', '#f3f4f6')
    .attr('stroke', '#d0d7de')
    .attr('stroke-width', 1.5);

  group.append('text')
    .attr('x', STATE_PADDING)
    .attr('y', STATE_PADDING + 2)
    .attr('dominant-baseline', 'hanging')
    .attr('fill', '#111111')
    .attr('font-size', 18)
    .attr('font-weight', 700)
    .attr('font-family', 'sans-serif')
    .text(`State ${index}`);

  const snapshot = readState(state);
  const stickers = buildStickers(snapshot);
  const netTop = STATE_PADDING + STATE_TITLE;

  drawNet(group, STATE_PADDING, netTop, stickers);
  drawTable(group, STATE_PADDING + NET_WIDTH + TABLE_GAP, netTop, snapshot);
}

function drawNet(group, left, top, stickers) {
  const faceLayout = [
    { face: 'U', col: 1, row: 0 },
    { face: 'L', col: 0, row: 1 },
    { face: 'F', col: 1, row: 1 },
    { face: 'R', col: 2, row: 1 },
    { face: 'B', col: 3, row: 1 },
    { face: 'D', col: 1, row: 2 }
  ];

  faceLayout.forEach((entry) => {
    const x = left + (entry.col * (FACE_BLOCK + FACE_GAP));
    const y = top + (entry.row * (FACE_BLOCK + FACE_GAP));
    drawFace(group, x, y, entry.face, stickers[entry.face]);
  });
}

function drawFace(group, x, y, face, stickerRows) {
  group.append('text')
    .attr('x', x + (FACE_CARD / 2))
    .attr('y', y + 2)
    .attr('text-anchor', 'middle')
    .attr('dominant-baseline', 'hanging')
    .attr('fill', '#344054')
    .attr('font-size', 12)
    .attr('font-weight', 600)
    .attr('font-family', 'sans-serif')
    .text(FACE_NAMES[face]);

  const cardY = y + FACE_LABEL;

  group.append('rect')
    .attr('x', x)
    .attr('y', cardY)
    .attr('width', FACE_CARD)
    .attr('height', FACE_CARD)
    .attr('rx', 10)
    .attr('ry', 10)
    .attr('fill', '#20242b')
    .attr('stroke', '#111111')
    .attr('stroke-width', 1);

  for (let row = 0; row <= 1; row += 1) {
    for (let col = 0; col <= 1; col += 1) {
      const value = stickerRows[row][col];
      const knownFace = value && FACE_COLORS[value];
      const display = knownFace ? '' : (value || '?');
      const fill = FACE_COLORS[value] || '#ced4da';
      const textFill = FACE_INK[value] || '#111111';
      const cellX = x + FACE_PADDING + (col * (STICKER + STICKER_GAP));
      const cellY = cardY + FACE_PADDING + (row * (STICKER + STICKER_GAP));

      group.append('rect')
        .attr('x', cellX)
        .attr('y', cellY)
        .attr('width', STICKER)
        .attr('height', STICKER)
        .attr('rx', 5)
        .attr('ry', 5)
        .attr('fill', fill)
        .attr('stroke', '#0f172a')
        .attr('stroke-width', 1);

      if (display) {
        group.append('text')
          .attr('x', cellX + (STICKER / 2))
          .attr('y', cellY + (STICKER / 2))
          .attr('text-anchor', 'middle')
          .attr('dominant-baseline', 'central')
          .attr('fill', textFill)
          .attr('font-size', 15)
          .attr('font-weight', 700)
          .attr('font-family', 'sans-serif')
          .text(display);
      }
    }
  }
}

function drawTable(group, x, y, snapshot) {
  group.append('text')
    .attr('x', x)
    .attr('y', y + 2)
    .attr('dominant-baseline', 'hanging')
    .attr('fill', '#344054')
    .attr('font-size', 12)
    .attr('font-weight', 600)
    .attr('font-family', 'sans-serif')
    .text('Slot / block / twist');

  group.append('rect')
    .attr('x', x - 8)
    .attr('y', y + TABLE_HEADER)
    .attr('width', TABLE_WIDTH)
    .attr('height', (SLOT_ORDER.length * TABLE_ROW) + 12)
    .attr('rx', 10)
    .attr('ry', 10)
    .attr('fill', '#ffffff')
    .attr('stroke', '#d0d7de')
    .attr('stroke-width', 1);

  SLOT_ORDER.forEach((slot, index) => {
    const rowY = y + TABLE_HEADER + 8 + (index * TABLE_ROW);
    const block = snapshot.occupy[slot] || '?';
    const twist = snapshot.twist[slot] || '?';
    const line = `${slot.padEnd(3, ' ')}  ${block.padEnd(4, ' ')}  ${twist}`;

    if (index > 0) {
      group.append('line')
        .attr('x1', x - 4)
        .attr('y1', rowY - 4)
        .attr('x2', x + TABLE_WIDTH - 12)
        .attr('y2', rowY - 4)
        .attr('stroke', '#eef2f6')
        .attr('stroke-width', 1);
    }

    group.append('text')
      .attr('x', x)
      .attr('y', rowY)
      .attr('dominant-baseline', 'hanging')
      .attr('fill', '#111111')
      .attr('font-size', 12)
      .attr('font-family', 'Consolas, Menlo, monospace')
      .text(line);
  });
}

function readState(state) {
  return {
    occupy: readFieldPairs(state, 'occupy'),
    twist: readFieldPairs(state, 'tw')
  };
}

function buildStickers(snapshot) {
  const stickers = {
    U: [['?', '?'], ['?', '?']],
    D: [['?', '?'], ['?', '?']],
    F: [['?', '?'], ['?', '?']],
    B: [['?', '?'], ['?', '?']],
    L: [['?', '?'], ['?', '?']],
    R: [['?', '?'], ['?', '?']]
  };

  SLOT_ORDER.forEach((slot) => {
    const cubie = snapshot.occupy[slot];
    const twist = snapshot.twist[slot];
    const colors = BLOCK_COLORS[cubie];
    const orientation = TWIST_INDEX[twist];
    const destinations = POSITION_STICKERS[slot];

    if (!colors || orientation === undefined || !destinations) {
      return;
    }

    for (let index = 0; index < 3; index += 1) {
      const target = destinations[(index + orientation) % 3];
      stickers[target.face][target.row][target.col] = colors[index];
    }
  });

  return stickers;
}

function drawLegend(y) {
  const legend = root.append('g')
    .attr('transform', `translate(${STATE_PADDING}, ${y})`);

  legend.append('text')
    .attr('x', 0)
    .attr('y', 0)
    .attr('dominant-baseline', 'hanging')
    .attr('fill', '#344054')
    .attr('font-size', 12)
    .attr('font-weight', 600)
    .attr('font-family', 'sans-serif')
    .text('Face colors');

  ['U', 'D', 'F', 'B', 'L', 'R'].forEach((face, index) => {
    const x = index * 76;

    legend.append('rect')
      .attr('x', x)
      .attr('y', 18)
      .attr('width', 28)
      .attr('height', 28)
      .attr('rx', 5)
      .attr('ry', 5)
      .attr('fill', FACE_COLORS[face])
      .attr('stroke', '#0f172a')
      .attr('stroke-width', 1);

    legend.append('text')
      .attr('x', x + 36)
      .attr('y', 32)
      .attr('dominant-baseline', 'central')
      .attr('fill', '#344054')
      .attr('font-size', 12)
      .attr('font-weight', 600)
      .attr('font-family', 'sans-serif')
      .text(FACE_NAMES[face]);
  });

  legend.append('text')
    .attr('x', 500)
    .attr('y', 3)
    .attr('fill', '#5c6773')
    .attr('font-size', 11)
    .attr('font-family', 'sans-serif')
    .text('Twist convention: tOne = 0, tTwo = +1, tThree = +2');
}

function readFieldPairs(state, fieldName) {
  const entries = {};

  state.field(fieldName).tuples().forEach((tuple) => {
    const atoms = tuple.atoms();

    if (atoms.length < 2) {
      return;
    }

    // Sterling can expose field tuples either with the owning `Cube` atom
    // included or already joined away. The last two atoms are always key/value.
    const key = atomKey(atoms[atoms.length - 2]);
    const value = atomKey(atoms[atoms.length - 1]);
    entries[key] = value;
  });

  return entries;
}

function atomKey(atom) {
  const raw = atom && typeof atom.id === 'function'
    ? atom.id().split('/').pop()
    : String(atom).split('/').pop();

  // Forge surface-syntax atoms are serialized as names like `UFR0`, `bDFR0`,
  // and `tThree0`; normalize them back to their declared identifiers.
  return raw.replace(/\d+$/, '');
}
