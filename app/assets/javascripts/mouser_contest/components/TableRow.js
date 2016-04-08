import React, { PropTypes } from 'react';

const TableRow = props => {
  //  Vendor | Project | Author | SubDate | Buttons
  const { vendor, project, author, date, status, buttons } = props.rowData;

  let cellStyle = {
    display: 'flex',
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    textAlign: 'center',
    border: '1px solid black',
    borderTop: props.firstRow ? 'none' : '1px solid black',
    borderBottom: props.lastRow || props.header ? '1px solid black' : 'none',
    overflow: 'scroll',
    maxHeight: 50,
    height: 35,
    backgroundColor: props.position === 'odd' ? '#F9F9F9' : '#EDF9FD'
  };
  cellStyle = props.header ? {...cellStyle, fontWeight: 'bold', backgroundColor: 'none' } : cellStyle;

  const actions = buttons
    ? React.Children.toArray([
        <button style={{ backgroundColor: status === 'rejected' ? 'red' : 'none' }}>reject</button>,
        <button style={{ backgroundColor: status === 'approved' ? 'green': 'none' }}>approve</button>
      ])
    : 'Actions';

  return (
    <div style={{ display: 'flex', alignItems: 'center' }}>
      <div style={{...cellStyle, borderRight: 'none' }}>{vendor}</div>
      <div style={{...cellStyle, borderRight: 'none' }}>{project}</div>
      <div style={{...cellStyle, borderRight: 'none' }}>{author}</div>
      <div style={{...cellStyle, borderRight: 'none', fontSize: props.header ? 18 : 12 }}>{date.toString()}</div>
      <div style={cellStyle}>
        {actions}
      </div>
    </div>
  )
}

TableRow.PropTypes = {
  header: PropTypes.bool,
  firstRow: PropTypes.bool,
  lastRow: PropTypes.bool,
  position: PropTypes.string,
  rowData: PropTypes.object.isRequired
};

export default TableRow;