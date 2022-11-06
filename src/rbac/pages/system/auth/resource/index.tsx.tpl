// @ts-nocheck
import { ActionType, ModalForm, ProColumns, ProForm, ProFormRadio, ProFormText, ProFormTextArea, ProFormTreeSelect, ProSkeleton, ProTable } from '@ant-design/pro-components';
import { Button, Form, Modal, Tag } from 'antd';
import { request, useModel } from 'umi';
import dayjs from 'dayjs';
import { Fragment, useRef, useState, useContext } from 'react';
import { LayoutContext } from '../../../layout';

export interface IRbacBaseProp {
  updateAt: string;
  remark?: string;
}
interface ISysResourceItemProp extends IRbacBaseProp {
  id: number;
  name: string;
  path: string;
  type: 0 | 1;
  icon?: string;
  sort?: number;
}

export default () => {
  const actionRef = useRef<ActionType>();
  const [form] = Form.useForm();
  const [modalOption, setModalOption] = useState<{ visible: boolean; title: string; isEdit?: boolean }>();
  const layoutAction = useContext(LayoutContext);

  const columns: ProColumns<ISysResourceItemProp>[] = [
    {
      dataIndex: 'name',
      title: '资源名称',
      width: 180,
    },
    {
      dataIndex: 'path',
      title: '资源路径',
      width: 240,
    },
    {
      dataIndex: 'type',
      title: '资源类型',
      valueEnum: {
        0: { text: '菜单' },
        1: { text: '权限' },
      },
      width: 80,
      render: (dom, entity) => {
        return <Tag color={entity.type === 0 ? 'green' : 'red'}>{dom}</Tag>;
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
              title: '编辑角色',
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
                await request.post('/api/system/resource/delete', {
                  method: 'POST',
                  data: {
                    id: record.id,
                  },
                });
                action?.reload();
                layoutAction.reload();
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
      <ProTable<ISysResourceItemProp>
        search={false}
        columns={columns}
        rowKey="id"
        actionRef={actionRef}
        bordered
        scroll={{ x: 1000 }}
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
        request={async (params) => {
          const result = await request.post('/api/system/resource/tree', {
            method: 'POST',
          });
          return {
            data: result.data?.list || [],
          };
        }}
      />
      <ModalForm<ISysResourceItemProp>
        title={modalOption?.title}
        form={form}
        visible={modalOption?.visible}
        grid
        rowProps={{
          gutter: 32,
        }}
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
        onFinish={async (values) => {
          await form.validateFields();
          await request.post(`/api/system/resource/${values.id ? 'update' : 'add'}`, {
            method: 'POST',
            data: values,
          });
          actionRef.current?.reload();
          layoutAction.reload();
          setModalOption({
            visible: false,
            title: modalOption?.title || '',
          });
        }}
      >
        <ProFormTreeSelect
          label="上级资源"
          colProps={{
            span: 12,
          }}
          name="parentId"
          fieldProps={{
            treeDefaultExpandAll: true,
            fieldNames: { label: 'name', value: 'id', children: 'children' },
          }}
          initialValue={0}
          rules={[
            {
              required: true,
            },
          ]}
          request={async () => {
            const result = await request.post('/api/system/resource/tree', {
              method: 'POST',
              data: { type: 0 },
            });
            return [
              {
                id: 0,
                name: '顶级资源',
              },
              ...result.data?.list,
            ];
          }}
        />
        <ProFormText
          rules={[
            {
              required: true,
            },
          ]}
          colProps={{
            span: 12,
          }}
          name="name"
          label="资源名称"
        />
        <ProFormText name="id" hidden />
        <ProFormText
          rules={[
            {
              required: true,
            },
          ]}
          colProps={{
            span: 12,
          }}
          name="path"
          label="资源路径"
        />
        <ProFormRadio.Group
          label="资源类型"
          name="type"
          initialValue={0}
          colProps={{
            span: 12,
          }}
          options={[
            {
              label: '菜单',
              value: 0,
            },
            {
              label: '权限',
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
        <ProFormText
          name="sort"
          label="排序"
          colProps={{
            span: 4,
          }}
        />
      </ModalForm>
    </Fragment>
  );
};
