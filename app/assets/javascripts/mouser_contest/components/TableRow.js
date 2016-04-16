import React, { PropTypes } from 'react';

const TableRow = props => {
  const { id, vendor, project, author, date, status, buttons } = props.rowData;

  function handleClick(updatedStatus) {
    props.onActionClick({ id, vendor, project, author, date, status: updatedStatus });
  }

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

  const buttonStyle = {
    borderRadius: 2,
    border: 'none',
    backgroundColor: '#E4E4E4',
    color: '#555',
    fontSize: 14
  };

  const actions = props.header
    ? 'Actions'
    : status !== 'undecided'
    ? React.Children.toArray([
        <span style={{ color: status === 'approved' ? 'green' : 'red', marginRight: '3%', fontSize: 14 }}>{status}</span>,
        <button style={buttonStyle} onClick={() => handleClick('undecided')}>Undo</button>
      ])
    : React.Children.toArray([
        <button style={{...buttonStyle, marginRight: '3%' }} onClick={() => handleClick('rejected')}>Reject</button>,
        <button style={buttonStyle} onClick={() => handleClick('approved')}>Approve</button>
      ]);

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
  onActionClick: PropTypes.func,
  position: PropTypes.string,
  rowData: PropTypes.object.isRequired
};

export default TableRow;