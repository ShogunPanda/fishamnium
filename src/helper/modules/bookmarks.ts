import {readFileSync, writeFileSync} from 'fs';
import {resolve} from 'path';
import * as yargs from 'yargs';
import chalk from 'chalk';

import {success, fail} from '../utils/console';
import {capitalize} from '../utils/string';

export interface Bookmark{
  name: string;
  bookmark: string;
  rootPath: string;
  paths: Array<string>;
  group: string;
}

type Bookmarks = Map<string, Bookmark>;

const FILE_PATH: string = resolve(process.env.HOME, '.fishamnium_bookmarks.json');
const ROOT_FORMATTER: RegExp = new RegExp(`^(?:${process.env.HOME})`);
const DESTINATION_FORMATTER: RegExp = new RegExp(`^(?:(?:\\$home)|(?:${process.env.HOME}))`);

const loadBookmarks = function(): Bookmarks{
  try{
    // Load raw bookmarks
    const raw: Array<Bookmark> = JSON.parse(readFileSync(FILE_PATH, 'utf8'))
      .sort((a: Bookmark, b: Bookmark) => a.bookmark.localeCompare(b.bookmark)); // Sort by name

    // Convert to a map
    const bookmarks = new Map<string, Bookmark>();

    for(const b of raw)
      bookmarks.set(b.bookmark, b);

    // Return them back
    return bookmarks;
  }catch(e){
    fail(`Cannot load bookmarks file ${FILE_PATH}.`);
  }
};

const storeBookmarks = function(bookmarks: Bookmarks): void{
  try{
    // Convert back to raw format
    const raw: Array<Bookmark> = [...bookmarks.values()]
      .sort((a: Bookmark, b: Bookmark) => a.bookmark.localeCompare(b.bookmark)); // Sort by name

    // Write to the file
    writeFileSync(FILE_PATH, JSON.stringify(raw, null, 2), 'utf8');
    success(`Bookmarks updated successfully!`);
  }catch(e){
    fail(`Cannot save bookmarks file ${FILE_PATH}.`);
  }
};

const resolveDestination = function(bookmark: Bookmark): string{
  return bookmark.rootPath.replace(/^\$home/, process.env.HOME);
};

const readBookmark = function(args: yargs.Arguments): void | string{
  const bookmark: Bookmark = loadBookmarks().get(args.name);

  if(!bookmark)
    return fail(chalk`The bookmark {bold ${args.name}} does not exists.`);

  console.log(resolveDestination(bookmark));
};

const saveBookmark = function(args: yargs.Arguments): void | string{
  const bookmarks: Bookmarks = loadBookmarks();
  const bookmarkName: string = args.name;
  const bookmark: Bookmark = bookmarks.get(bookmarkName);

  // Validate
  if(bookmark)
    return fail(chalk`The bookmark {bold ${args.name}} already exists and points to {bold ${resolveDestination(bookmark)}}.`);
  else if(!bookmarkName.match(/^(?:[a-z0-9-_.:@]+)$/i))
    return fail('Please use only letters, numbers, and "-", "_", ".", ":" and "@" only for the name.');

  // Adjust parameters
  const name: string = args.description ? args.description : capitalize(bookmarkName);
  const rootPath: string = process.cwd().replace(ROOT_FORMATTER, '$home');

  // Save the bookmark
  bookmarks.set(bookmarkName, {name, bookmark: bookmarkName, rootPath, paths: [], group: ''});
  storeBookmarks(bookmarks);
};

const deleteBookmark = function(args: yargs.Arguments): void | string{
  const bookmarks: Bookmarks = loadBookmarks();
  const bookmark: Bookmark = bookmarks.get(args.name);

  if(!bookmark)
    return fail(chalk`The bookmark {bold ${args.name}} does not exists.`);

  // Delete the bookmark
  bookmarks.delete(args.name);
  storeBookmarks(bookmarks);
};

const listBookmarks = function(args: yargs.Arguments): void{
  let bookmarks: Array<Bookmark> = Array.from(loadBookmarks().values());
  let response = '';

  if(args.query)
    bookmarks = bookmarks.filter((b: Bookmark) => b.bookmark.includes(args.query));

  if(!bookmarks.length) // No bookmarks, nothing to return here
    return;
  else if(args.namesOnly) // Only names
    response = bookmarks.map((b: Bookmark) => b.bookmark).join('\n');
  else if(args.autocomplete) // Autocomplete
    response = bookmarks.map((b: Bookmark) => `${b.bookmark}\t${b.name}`).join('\n');
  else{ // Pretty printing
    const maximumLength: number = Math.max(...bookmarks.map(b => b.bookmark.length));

    response = bookmarks.map((b: Bookmark) => {
      const destination: string = b.rootPath.replace(DESTINATION_FORMATTER, chalk`{yellow $HOME}`); // Replace home folder in destination

      return chalk`{green ${b.bookmark.padEnd(maximumLength)}} \u2192 ${destination}`;
    }).join('\n');
  }

  if(response)
    console.log(response);
};

export function buildBookmarksManager(y: yargs.Argv){
  return y
    .command({command: 'read <name>', aliases: ['get', 'show', 'load', 'r', 'g'], describe: 'Reads a bookmark', handler: readBookmark})
    .command({command: 'write <name> [description]', aliases: ['set', 'save', 'store', 'w', 's'], describe: 'Writes a bookmark', handler: saveBookmark})
    .command({command: 'delete <name>', aliases: ['erase', 'remove', 'd', 'e'], describe: 'Deletes a bookmark', handler: deleteBookmark})
    .command({command: 'list [query]', aliases: ['all', 'l', 'a'], describe: 'Lists all bookmarks', handler: listBookmarks, builder: (ly: yargs.Argv) => (
      ly
        .option('n', {alias: 'names-only', describe: 'Only list bookmarks names', type: 'boolean'})
        .option('a', {alias: 'autocomplete', describe: 'Only list bookmarks name and description for autocompletion', type: 'boolean'})
    )});
}
