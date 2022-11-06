// @ts-nocheck
import React from 'react';
import { Result } from 'antd';
import styles from './index.less';

type Props = {};

const Notfound = (props: Props) => {
  return (
    <div className={styles.wrap}>
      <Result status="404" title="404" subTitle="Sorry, the page you visited does not exist." />
    </div>
  );
};

export default Notfound;
