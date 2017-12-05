import typescript from 'rollup-plugin-typescript2';
import uglify from 'rollup-plugin-uglify';
import { minify } from 'uglify-es';

const packageFile = require('./package');
const packageInfo = {version: packageFile.version};

const common = {
  plugins: [
    typescript({clean: true, cacheRoot: 'tmp/.rpt2_cache', tsconfig: 'tsconfig.json', useTsconfigDeclarationDir: true})
  ],
  external: [...Object.keys(require('./package.json').dependencies), 'child_process', 'fs', 'path', 'util', 'yargs', 'chalk'],
  banner: `#!/usr/bin/env node\nvar packageInfo = ${JSON.stringify(packageInfo)};`
}

if(process.env.production === 'true')
  common.plugins.push(uglify({}, minify));

const config = [
  Object.assign({input: './src/helpers/git.ts', output: {file: './dist/helpers/js/fishamnium_git', format: 'cjs'}}, common),
  Object.assign({input: './src/helpers/bookmarks.ts', output: {file: './dist/helpers/js/fishamnium_bookmarks', format: 'cjs'}}, common)
];

export default config;
