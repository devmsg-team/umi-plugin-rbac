import { IApi, RUNTIME_TYPE_FILE_NAME } from 'umi';
import { dirname, join } from 'path';
import withTmpPath from '../utils/withTmpPath';
import * as shelljs from 'shelljs'
import { readFileSync } from 'fs'


export default async (api: IApi) => {
  api.describe({
    key: 'rbac',
    config: {
      schema(joi) {
        return joi.boolean();
      },
      onChange: api.ConfigChangeType.regenerateTmpFiles,
    },
    enableBy: api.EnableBy.config,
  });

  const userRbacConfig = api.userConfig.rbac;
  if (!userRbacConfig) {
    api.logger.error('rbac plugin config is required');
    process.exit(1);
  }

  let pkgPath: string;
  let antdVersion = '';
  let proComponentsVersion = '';
  let umiVersion = '';
  let umiRequestVersion = '';
  try {
    umiVersion = require('umi/package.json').version;
    umiRequestVersion = require('umi-request/package.json').version;
    pkgPath = dirname(require.resolve('antd/package.json'));
    antdVersion = require(`${pkgPath}/package.json`).version;
    umiVersion
    const techUiPkgPath = dirname(
      require.resolve('@ant-design/pro-components/package.json'),
    );
    proComponentsVersion = require(`${techUiPkgPath}/package.json`).version;
  } catch (e) { }

  if (!antdVersion || !proComponentsVersion) {
    api.logger.error('antd or pro-components version is required, please install them');
    process.exit(1);
  }

  // add babel-plugin-import
  api.modifyBabelPresetOpts((opts) => {
    // antd5 采用css in js，不需要 babel-plugin-import
    if (antdVersion.startsWith('5')) return opts;
    const imps = [];
    imps.push({
      libraryName: 'antd',
      libraryDirectory: 'es',
      style: true,
    });
    return {
      ...opts,
      import: (opts.import || []).concat(imps),
    };
  });

  api.addEntryImportsAhead(() => {
    const isNewTechUI =
      antdVersion.startsWith('4') && proComponentsVersion.startsWith('2');

    if (isNewTechUI) {
      return [
        {
          source: 'antd/dist/antd.less',
        },
      ];
    }
    return []
  });

  api.modifyRoutes((memo) => {
    memo.login = {
      absPath: "/login",
      path: '/login',
      id: "login",
      file: withTmpPath({ api, path: 'plugin-rbac/modules/login/index.tsx' }),
    };

    ['system.auth.resource', 'system.auth.role', 'system.auth.user'].forEach((item) => {
      memo[item] = {
        absPath: `/${item.split('.').join('/')}`,
        path: `/${item.split('.').join('/')}`,
        id: item,
        parentId: 'rbac-layout',
        file: withTmpPath({ api, path: `plugin-rbac/modules/${item.split('.').join('/')}/index.tsx.tpl` }),
      };
    });

    memo['404'] = {
      absPath: '/404',
      path: '*',
      id: '404',
      parentId: 'rbac-layout',
      file: withTmpPath({ api, path: 'plugin-rbac/modules/404/index.tsx.tpl' }),
    };
    return memo;
  })


  api.addLayouts(() => {
    return {
      id: "rbac-layout",
      file: withTmpPath({ api, path: 'plugin-rbac/modules/layout/index.tsx.tpl' }),
    }
  })

  api.onGenerateFiles(() => {
    shelljs.rm('-rf', join(api.paths.absTmpPath!, 'plugin-rbac'));
    shelljs.mkdir('-p', join(api.paths.absTmpPath!, 'plugin-rbac'));
    shelljs.cp('-r', join(__dirname, 'modules'), join(api.paths.absTmpPath!, 'plugin-rbac'));
    // 注入request
    api.writeTmpFile({
      path: 'request.ts',
      content: readFileSync(join(__dirname, 'request.ts.tpl'), 'utf-8'),
    });


    // 导出rbac插件相关的类型
    api.writeTmpFile({
      path: 'index.ts',
      content: `
export { default as request } from './request';

export interface IMenuItemProp {
  children?: IMenuItemProp[];
  icon?: any;
  name: string;
  path: string;
}
`,
    })

    // 导出运行时rbac的类型
    api.writeTmpFile({
      path: RUNTIME_TYPE_FILE_NAME,
      content: `
import { IMenuItemProp } from './index';
export interface IRuntimeConfig {
  rbac?: {
    title: string;
    logo: string;
    getMenuData: () => Promise<IMenuItemProp[]>;
    logout: () => Promise<void>;
  }
}
      `,
    });
  });

  api.registerPlugins([
    require.resolve('@umijs/plugins/dist/initial-state'),
    require.resolve('@umijs/plugins/dist/model'),
  ]);
  api.modifyConfig((memo) => {
    return {
      ...memo,
      initialState: {},
      model: {},
    };
  })

  api.addRuntimePluginKey(() => ['rbac']);

  api.logger.info('antd-version', antdVersion);
  api.logger.info('proComponents-version', proComponentsVersion);
  api.logger.info('umi-version', umiVersion);
  api.logger.info('umi-request-version', umiRequestVersion);
};
