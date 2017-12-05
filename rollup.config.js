import typescript from 'rollup-plugin-typescript2';
import uglify from 'rollup-plugin-uglify';
import { minify } from 'uglify-es';

const packageFile = require('./package');
const packageInfo = {version: packageFile.version};

const config = {
  input: './src/helper/index.ts',
  output: {
    file: './dist/bin/fishamnium',
    format: 'cjs'
  },
  plugins: [
    typescript({clean: true, cacheRoot: 'tmp/.rpt2_cache', tsconfig: 'tsconfig.json', useTsconfigDeclarationDir: true})
  ],
  external: [...Object.keys(require('./package.json').dependencies), 'child_process', 'fs', 'path', 'util', 'yargs', 'chalk'],
  banner: `#!/usr/bin/env node\nvar packageInfo = ${JSON.stringify(packageInfo)};`
};

if(process.env.production === 'true')
  config.plugins.push(uglify({}, minify));

export default config;
