// /js/utils.js

export function getRandom(max) {
  return Math.floor(Math.random() * max);
}

export function getRandomArbitrary(min, max) {
  return Math.random() * (max - min) + min;
}
