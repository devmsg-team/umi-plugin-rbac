# @devmsg/umi-plugin-rbac

rbac权限管理模块抽离, 包含用户、角色、资源基础三部分

运行时配置
```tsx | app.tsx
export const rbac: RuntimeConfig['rbac'] = {
  title: 'RBAC',
  logo: 'https://gw.alipayobjects.com/zos/rmsportal/KDpgvguMpGfqaHPjicRK.svg',
  getMenuData: async () => {
    const { success, data } = await request('/api/getMenus')
    return success ? data : [];
  },
  logout: async () => { },
}
```

后续只专注专注业务模块开发

server端在自建库中，后续单拎出来吧！
