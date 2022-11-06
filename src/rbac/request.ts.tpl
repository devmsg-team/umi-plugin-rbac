// @ts-nocheck
import { message } from 'antd';
import { history } from 'umi';
import request from 'umi-request';

request.interceptors.request.use((url, options) => {
  const token = localStorage.getItem('token');
  return {
    url: url,
    options: {
      ...options, interceptors: true, headers: {
        ...options.headers,
        ...token && { Authorization: `Bearer ${token}` },
      }
    },
  };
});

request.interceptors.response.use(async response => {
  const data = await response.json();
  if (data.code !== 200) {
    message.error(data.msg);
    if (data.code === 401) {
      history.replace('/login');
      localStorage.setItem('token', '');
    }
  }
  return data;
});


export default request;
