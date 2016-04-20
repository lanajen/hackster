import React, { Children, PropTypes } from 'react';

const TableFilter = props => {
  const { label, onChange, options, value } = props;

  const opts = options.reduce((acc, option, index) => {
    if(!acc.length) acc.push(<option value={'default'}>{'default'}</option>);
    acc.push(<option value={option}>{option}</option>);
    return acc;
  }, []);

  return (
    <span style={{ display: 'flex', flexDirection: 'column', padding: '0 20px' }}>
      <label style={{ fontSize: 12, fontWeight: 'bold' }}>{label}</label>
      <select style={{ margin: '0 auto' }} value={value} onChange={(e) => onChange(label.toLowerCase(), e.target.value)}>
        {Children.toArray(opts)}
      </select>
    </span>
  );
};

PropTypes.TableFilter = {
  label: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  options: PropTypes.array.isRequired,
  value: PropTypes.string.isRequired
};

export default TableFilter;