import React, { useRef, useState } from 'react';
import { LoginFormPage, ProFormInstance, ProFormText } from '@ant-design/pro-components';
import { Button, message } from 'antd';
import { LockOutlined, UserOutlined } from '@ant-design/icons';
import styles from './index.less';
import { request, history } from 'umi';

const Login = () => {
  const loginFormRef = useRef<ProFormInstance>();
  const [pendingLoading, setPendingLoading] = useState(false);
  return (
    <div className={styles.wrap}>
      <LoginFormPage
        formRef={loginFormRef}
        onFinish={async (values) => {
          setPendingLoading(true);
          try {
            const res = await request('/api/login', {
              method: 'post',
              data: values,
            });
            setPendingLoading(false);
            if (res.code === 200) {
              localStorage.setItem('token', res.data.token);
              history.replace('/');
            }
          } catch (error) {
            setPendingLoading(false);
          }
        }}
        backgroundImageUrl="https://gw.alipayobjects.com/zos/rmsportal/FfdJeJRQWjEeGTpqgBKj.png"
        logo="https://github.githubassets.com/images/modules/logos_page/Octocat.png"
        title="Github"
        subTitle="全球最大的代码托管平台"
        activityConfig={{
          style: {
            boxShadow: '0px 0px 8px rgba(0, 0, 0, 0.2)',
            color: '#fff',
            borderRadius: 8,
            backgroundColor: '#1677FF',
          },
          title: '活动标题，可配置图片',
          subTitle: '活动介绍说明文字',
          action: (
            <Button
              size="large"
              style={{
                borderRadius: 20,
                background: '#fff',
                color: '#1677FF',
                width: 120,
              }}
            >
              去看看
            </Button>
          ),
        }}
        submitter={{
          render: () => {
            return (
              <Button
                loading={pendingLoading}
                style={{
                  width: '328px',
                }}
                size="large"
                type="primary"
                onClick={() => {
                  loginFormRef.current?.submit();
                }}
              >
                Login
              </Button>
            );
          },
        }}
      >
        <ProFormText
          name="username"
          fieldProps={{
            size: 'large',
            prefix: <UserOutlined className={'prefixIcon'} />,
          }}
          placeholder={'用户名'}
          rules={[
            {
              required: true,
              message: '请输入用户名!',
            },
          ]}
        />
        <ProFormText.Password
          name="password"
          fieldProps={{
            size: 'large',
            prefix: <LockOutlined className={'prefixIcon'} />,
          }}
          placeholder={'密码'}
          rules={[
            {
              required: true,
              message: '请输入密码！',
            },
          ]}
        />
      </LoginFormPage>
    </div>
  );
};

export default Login;
