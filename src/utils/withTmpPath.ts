import { join } from 'path';
import { IApi } from 'umi';
import { winPath } from 'umi/plugin-utils';

export default (opts: { api: IApi; path: string; }) => (
  winPath(
    join(
      opts.api.paths.absTmpPath,
      opts.path,
    ),
  )
);