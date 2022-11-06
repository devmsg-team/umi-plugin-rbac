// @ts-nocheck
import { ActionType, ModalForm, ProColumns, ProFormRadio, ProFormSelect, ProFormText, ProFormTextArea, ProTable } from '@ant-design/pro-components';
import { Button, Form, Modal, Tag } from 'antd';
import { Fragment, useRef, useState } from 'react';
import { request } from 'umi';
import dayjs from 'dayjs';

export interface IRbacBaseProp {
  updateAt: string;
  remark?: string;
}
interface ISysUserItemProp extends IRbacBaseProp {
  id: number;
  username: string;
  status: number;
  role?: {
    id: number;
    name: string;
  };
}

export default () => {
  const actionRef = useRef<ActionType>();
  const [form] = Form.useForm();
  const [modalOption, setModalOption] = useState<{ visible: boolean; title: string; isEdit?: boolean }>();

  const columns: ProColumns<ISysUserItemProp>[] = [
    {
      dataIndex: 'id',
      title: 'ID',
      width: 60,
    },
    {
      dataIndex: 'username',
      title: '用户名',
      width: 120,
    },
    {
      dataIndex: 'status',
      title: '状态',
      width: 120,
      valueEnum: {
        0: { text: '正常' },
        1: { text: '禁用' },
      },
      render: (dom, entity) => {
        return <Tag color={entity.status === 0 ? 'blue' : 'magenta'}>{dom}</Tag>;
      },
    },
    {
      dataIndex: 'role',
      title: '角色',
      width: 120,
      render: (dom, entity) => {
        return entity.role?.name && <Tag color="green">{entity.role?.name}</Tag>;
      },
    },
    {
      dataIndex: 'remark',
      title: '备注',
      width: 120,
    },
    {
      dataIndex: 'updateAt',
      title: '更新时间',
      width: 180,
      render: (text, record) => {
        return dayjs(record.updateAt).format('YYYY-MM-DD HH:mm:ss');
      },
    },
    {
      dataIndex: 'action',
      title: '操作',
      valueType: 'option',
      fixed: 'right',
      width: 80,
      render: (text, record, _, action) => [
        <a
          key="edit"
          onClick={async () => {
            setModalOption({
              visible: true,
              title: '编辑用户',
              isEdit: true,
            });
            await Promise.resolve();
            form.setFieldsValue(record);
          }}
        >
          编辑
        </a>,
        <a
          key="del"
          onClick={() => {
            Modal.confirm({
              title: '删除',
              content: '确定删除吗？',
              onOk: async () => {
                await request.post('/api/system/user/delete', {
                  method: 'POST',
                  data: {
                    id: +record.id,
                  },
                });
                action?.reload();
              },
            });
          }}
        >
          删除
        </a>,
      ],
    },
  ];
  return (
    <Fragment>
      <ProTable<ISysUserItemProp>
        search={false}
        columns={columns}
        rowKey="id"
        bordered
        actionRef={actionRef}
        scroll={{ x: 1200 }}
        toolBarRender={() => [
          <Button
            key="add"
            type="primary"
            onClick={() => {
              setModalOption({
                visible: true,
                title: '新增用户',
              });
            }}
          >
            新增
          </Button>,
        ]}
        request={async (params) => {
          const result = await request.post('/api/system/user/list', {
            method: 'POST',
            data: params,
          });
          return {
            data: result.data?.list || [],
            total: result.data?.total || 0,
          };
        }}
      />
      <ModalForm<ISysUserItemProp>
        title={modalOption?.title}
        form={form}
        visible={modalOption?.visible}
        modalProps={{
          destroyOnClose: true,
          onCancel: () => {
            setModalOption({
              visible: false,
              isEdit: false,
              title: modalOption?.title || '',
            });
          },
        }}
        grid
        rowProps={{
          gutter: 32,
        }}
        onFinish={async (values) => {
          await form.validateFields();
          if (values.id) {
            values.id = parseInt(values.id.toString(), 10);
          }
          await request.post(`/api/system/user/${values.id ? 'update' : 'add'}`, {
            method: 'POST',
            data: values,
          });
          actionRef.current?.reload();
          setModalOption({
            visible: false,
            title: modalOption?.title || '',
          });
        }}
      >
        <ProFormText
          name="username"
          label="用户名"
          colProps={{ span: 12 }}
          rules={[
            {
              required: true,
              message: '请输入用户名',
            },
          ]}
        />
        <ProFormText.Password
          name="password"
          hidden={modalOption?.isEdit}
          label="密码"
          colProps={{ span: 12 }}
          rules={[
            {
              required: !modalOption?.isEdit,
              message: '请输入密码',
            },
          ]}
        />
        <ProFormSelect
          name={['role', 'id']}
          label="角色"
          colProps={{ span: 12 }}
          fieldProps={{
            fieldNames: { label: 'name', value: 'id' },
          }}
          request={async () => {
            const result = await request.post('/api/system/role/list', {
              method: 'POST',
              data: {
                page: 1,
                pageSize: 100,
              },
            });
            return result.data?.list;
          }}
        />
        <ProFormRadio.Group
          label="状态"
          name="status"
          initialValue={0}
          colProps={{
            span: 12,
          }}
          options={[
            {
              label: '正常',
              value: 0,
            },
            {
              label: '禁用',
              value: 1,
            },
          ]}
        />

        <ProFormTextArea
          name="remark"
          label="备注"
          fieldProps={{
            style: {
              height: 100,
            },
          }}
        />
        <ProFormText name="id" hidden />
      </ModalForm>
    </Fragment>
  );
};
