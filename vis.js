const d3 = require('d3');

d3.selectAll('svg > *').remove();

const states = (typeof instances !== 'undefined' && instances.length > 0)
  ? instances
  : [instance];

const faceAtoms = {
  Top,
  Left,
  Front,
  Right,
  Back,
  Bottom
};

const faceLayout = [
  { name: 'Top', col: 1, row: 0 },
  { name: 'Left', col: 0, row: 1 },
  { name: 'Front', col: 1, row: 1 },
  { name: 'Right', col: 2, row: 1 },
  { name: 'Back', col: 3, row: 1 },
  { name: 'Bottom', col: 1, row: 2 }
];

const palette = {
  1: '#f8f9fa',
  2: '#ffd43b',
  3: '#40c057',
  4: '#4dabf7',
  5: '#ff922b',
  6: '#fa5252'
};

const ink = {
  1: '#111111',
  2: '#111111',
  3: '#ffffff',
  4: '#ffffff',
  5: '#111111',
  6: '#ffffff'
};

const STICKER = 36;
const STICKER_GAP = 4;
const FACE_PADDING = 8;
const FACE_GAP = 18;
const STATE_PADDING = 20;
const STATE_TITLE = 24;
const FACE_LABEL = 16;
const STATE_GAP = 28;
const LEGEND_HEIGHT = 54;

const GRID = (STICKER * 2) + STICKER_GAP;
const FACE_CARD = GRID + (FACE_PADDING * 2);
const FACE_BLOCK = FACE_CARD + FACE_LABEL;
const NET_WIDTH = (FACE_BLOCK * 4) + (FACE_GAP * 3);
const NET_HEIGHT = (FACE_BLOCK * 3) + (FACE_GAP * 2);
const STATE_WIDTH = NET_WIDTH + (STATE_PADDING * 2);
const STATE_HEIGHT = NET_HEIGHT + STATE_TITLE + (STATE_PADDING * 2);
const TOTAL_WIDTH = states.length === 0
  ? STATE_WIDTH
  : (STATE_WIDTH * states.length) + (STATE_GAP * Math.max(states.length - 1, 0));
const TOTAL_HEIGHT = STATE_HEIGHT + LEGEND_HEIGHT;

const root = d3.select(svg)
  .attr('viewBox', `0 0 ${TOTAL_WIDTH} ${TOTAL_HEIGHT}`)
  .attr('preserveAspectRatio', 'xMinYMin meet')
  .style('background', '#fbfbfc');

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

drawLegend(TOTAL_HEIGHT - LEGEND_HEIGHT + 8);

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

  const boards = {};
  faceLayout.forEach((face) => {
    boards[face.name] = readBoard(state, faceAtoms[face.name]);
  });

  faceLayout.forEach((face) => {
    const blockX = STATE_PADDING + (face.col * (FACE_BLOCK + FACE_GAP));
    const blockY = STATE_PADDING + STATE_TITLE + (face.row * (FACE_BLOCK + FACE_GAP));
    drawFace(group, blockX, blockY, face.name, boards[face.name]);
  });
}

function drawFace(group, x, y, name, board) {
  group.append('text')
    .attr('x', x + (FACE_CARD / 2))
    .attr('y', y + 2)
    .attr('text-anchor', 'middle')
    .attr('dominant-baseline', 'hanging')
    .attr('fill', '#344054')
    .attr('font-size', 12)
    .attr('font-weight', 600)
    .attr('font-family', 'sans-serif')
    .text(name);

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
      const key = `${col},${row}`;
      const value = board.get(key);
      const fill = palette[value] || '#ced4da';
      const textFill = ink[value] || '#111111';
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

      group.append('text')
        .attr('x', cellX + (STICKER / 2))
        .attr('y', cellY + (STICKER / 2))
        .attr('text-anchor', 'middle')
        .attr('dominant-baseline', 'central')
        .attr('fill', textFill)
        .attr('font-size', 15)
        .attr('font-weight', 700)
        .attr('font-family', 'sans-serif')
        .text(value === undefined ? '?' : value);
    }
  }
}

function readBoard(state, faceAtom) {
  const cells = new Map();
  const tuples = faceAtom.join(state.field('board')).tuples();

  tuples.forEach((tuple) => {
    const atoms = tuple.atoms();
    const x = Number(atoms[0].toString());
    const y = Number(atoms[1].toString());
    const value = Number(atoms[2].toString());

    if (!Number.isNaN(x) && !Number.isNaN(y)) {
      cells.set(`${x},${y}`, value);
    }
  });

  return cells;
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
    .text('Sticker values');

  for (let value = 1; value <= 6; value += 1) {
    const x = (value - 1) * 58;

    legend.append('rect')
      .attr('x', x)
      .attr('y', 18)
      .attr('width', 28)
      .attr('height', 28)
      .attr('rx', 5)
      .attr('ry', 5)
      .attr('fill', palette[value])
      .attr('stroke', '#0f172a')
      .attr('stroke-width', 1);

    legend.append('text')
      .attr('x', x + 14)
      .attr('y', 32)
      .attr('text-anchor', 'middle')
      .attr('dominant-baseline', 'central')
      .attr('fill', ink[value])
      .attr('font-size', 13)
      .attr('font-weight', 700)
      .attr('font-family', 'sans-serif')
      .text(value);
  }
}
