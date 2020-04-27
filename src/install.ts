import fs from 'fs';
import path from 'path';

const rootPath = path.resolve(__dirname, '..');
const buildPath = path.resolve(
  rootPath,
  fs
    .readdirSync(rootPath)
    .filter(
      (fileName: string) => fileName.substr(0, 16) === 'build-tmp-napi-v'
    )?.[0]
);
fs.renameSync(buildPath, path.resolve(rootPath, 'build'));
