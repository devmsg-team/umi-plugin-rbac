// @ts-nocheck
import { ActionType, ModalForm, ProColumns, ProFormRadio, ProFormSelect, ProFormText, ProFormTextArea, ProFormTreeSelect, ProTable } from '@ant-design/pro-components';
import { Button, Form, Modal, Tag, TreeSelect } from 'antd';
import { Fragment, ReactNode, useEffect, useRef, useState } from 'react';
import { request } from 'umi';
import dayjs from 'dayjs';

export interface IRbacBaseProp {
  updateAt: string;
  remark?: string;
}
interface ISysRoleItemProp extends IRbacBaseProp {
  id: number;
  name: string;
  resources: { value?: string; label?: string; id?: number; name?: string }[];
}

export default () => {
  const actionRef = useRef<ActionType>();
  const [form] = Form.useForm();
  const [modalOption, setModalOption] = useState<{ visible: boolean; title: string; isEdit?: boolean }>();

  const columns: ProColumns<ISysRoleItemProp>[] = [
    {
      dataIndex: 'id',
      title: 'ID',
      width: 60,
    },
    {
      dataIndex: 'name',
      title: '角色名',
      width: 120,
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
              title: '编辑角色',
              isEdit: true,
            });
            await Promise.resolve();
            form.setFieldsValue({
              ...record,
              resources: record.resources.map((item) => ({
                value: item.id,
                label: item.name,
              })),
            });
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
                await request.post('/api/system/role/delete', {
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
      <ProTable<ISysRoleItemProp>
        search={false}
        columns={columns}
        rowKey="id"
        actionRef={actionRef}
        bordered
        request={async (params) => {
          const result = await request.post('/api/system/role/list', {
            method: 'POST',
            data: params,
          });
          return {
            data: result.data?.list || [],
            total: result.data?.total || 0,
          };
        }}
        toolBarRender={() => [
          <Button
            key="add"
            type="primary"
            onClick={() => {
              setModalOption({
                visible: true,
                title: '新增角色',
              });
            }}
          >
            新增
          </Button>,
        ]}
      />
      <ModalForm<ISysRoleItemProp>
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
          if (values.resources) {
            values.resources = values.resources.map((item) => {
              return {
                id: parseInt(item?.value!, 10),
              };
            });
          }
          await request.post(`/api/system/role/${values.id ? 'update' : 'add'}`, {
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
          name="name"
          label="角色名"
          colProps={{ span: 12 }}
          rules={[
            {
              required: true,
              message: '请输入用户名',
            },
          ]}
        />
        <ProFormTreeSelect
          label="功能权限"
          name="resources"
          colProps={{ span: 12 }}
          fieldProps={{
            labelInValue: true,
            maxTagCount: 3,
            showCheckedStrategy: TreeSelect.SHOW_ALL,
            treeCheckable: true,
            treeDefaultExpandAll: true,
            treeCheckStrictly: true,
            fieldNames: { label: 'name', value: 'id', children: 'children' },
          }}
          request={async () => {
            const result = await request.post('/api/system/resource/tree', {
              method: 'POST',
            });
            return result.data?.list || [];
          }}
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
