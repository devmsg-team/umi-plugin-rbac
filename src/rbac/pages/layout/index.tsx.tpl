// @ts-nocheck
import { useEffect, useRef, useState } from 'react';
import { Link, Outlet, Navigate, useLocation, useAppData, RuntimeConfig, useModel } from 'umi';
import { ActionType, PageContainer, ProLayout } from '@ant-design/pro-components';
import { InfoCircleOutlined, MergeCellsOutlined, QuestionCircleOutlined, UserOutlined } from '@ant-design/icons';
import styles from './index.less';

export default function Layout() {
  const actionRef = useRef<ActionType>();
  const { pathname } = useLocation();
  const { pluginManager } = useAppData();
  const rbacConfig: RuntimeConfig['rbac'] = pluginManager.applyPlugins({
    key: 'rbac',
    type: 'modify',
  });
  const { initialState } = useModel('@@initialState');

  useEffect(() => {
    initialState?.events.on('reloadMenu', () => {
      actionRef.current?.reload();
    });
  }, []);

  return (
    <ProLayout
      className={styles.wrap}
      title={rbacConfig?.title || 'Ant Design Pro'}
      logo={rbacConfig?.logo || 'https://gw.alipayobjects.com/zos/antfincdn/PmY%24TNNDBI/logo.svg'}
      menu={{
        request: rbacConfig?.getMenuData!,
      }}
      location={{
        pathname,
      }}
      actionRef={actionRef}
      menuItemRender={(item, dom) => <Link to={item.path || '/'}>{dom}</Link>}
      menuFooterRender={false}
      avatarProps={{
        icon: <UserOutlined />,
        size: 'small',
        title: initialState?.username,
      }}
      breadcrumbRender={(routers) => {
        return routers?.map((v) => ({ breadcrumbName: v.breadcrumbName })) as [];
      }}
      fixSiderbar
      actionsRender={() => [<InfoCircleOutlined key="InfoCircleOutlined" />, <QuestionCircleOutlined key="QuestionCircleOutlined" />, <MergeCellsOutlined key="MergeCellsOutlined" />]}
    >
      <PageContainer title={false}>
        <Outlet />
      </PageContainer>
    </ProLayout>
  );
}
