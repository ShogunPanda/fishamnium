#!/usr/bin/env node

import {writeFileSync} from 'fs';

import {Bookmark} from '../src/helper/modules/bookmarks';

const filePath: string = `${process.env.HOME}/.fishamnium_bookmarks.json`;
const source: {[key: string]: string} = require(filePath);

const capitalize = function(input: string): string{
  return input
    .split('_')
    .map((s: string) => `${s[0].toUpperCase()}${s.substring(1).toLowerCase()}`)
    .join(' ');
};

if(!Array.isArray(source)){
  const destination: Array<Bookmark> = Object.keys(source).sort().map((bookmark: string) => {
    const rootPath: string = source[bookmark].replace(/\//g, '/').replace('$HOME', '$home');

    return {name: capitalize(bookmark), bookmark, rootPath, paths: [], group: ''};
  });

  writeFileSync(filePath, JSON.stringify(destination, null, 2), 'utf8');
}else{
  console.error('File has already been converted.');
  process.exitCode = 1;
}
