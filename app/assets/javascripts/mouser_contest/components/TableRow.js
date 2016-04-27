import React, { PropTypes } from 'react';
import moment from 'moment';

const TableRow = props => {
  const { isFetching, firstRow, header, lastRow, position, rowData } = props;
  const { id, vendor, project, author, date, status, buttons } = rowData;

  function handleClick(updatedStatus) {
    props.onActionClick({ id, status: updatedStatus });
  }

  function handleConfirm(status) {
    const message = {
      'approved': 'You\'re about to make this project THE CHAMPION OF THIS VENDOR.  Give it the crown?',
      'rejected': 'You\'re about to REJECT this project.  Cool Beans?'
    };
    window.confirm(message[status]) ? handleClick(status) : false;
  }

  let cellStyle = {
    display: 'flex',
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    textAlign: 'center',
    border: '1px solid black',
    borderTop: firstRow ? 'none' : '1px solid black',
    borderBottom: lastRow || header ? '1px solid black' : 'none',
    overflow: 'scroll',
    maxHeight: 60,
    height: 50,
    backgroundColor: position % 2 === 0  ? '#EDF9FD' : '#F9F9F9',
    fontSize: 14
  };
  cellStyle = header ? {...cellStyle, fontWeight: 'bold', backgroundColor: 'none' } : cellStyle;

  const buttonStyle = {
    borderRadius: 2,
    border: 'none',
    backgroundColor: '#E4E4E4',
    color: '#555',
    fontSize: 14
  };

  const actions = header
    ? 'Actions'
    : status !== 'new'
    ? <span style={{ color: status === 'approved' ? 'green' : 'red', marginRight: '3%', fontSize: 14 }}>{status}</span>
    : React.Children.toArray([
        <button style={{...buttonStyle, marginRight: '3%' }} onClick={() => handleConfirm('rejected')}>Reject</button>,
        <button style={buttonStyle} onClick={() => handleConfirm('approved')}>Make champion</button>
      ]);

  return (
    <div style={{ display: 'flex', alignItems: 'center' }}>
      <div style={{...cellStyle, borderRight: 'none' }}>{vendor}</div>
      <div style={{...cellStyle, borderRight: 'none' }}>
        { header ? <span>{project}</span> : <a href={project.url}>{project.name}</a> }
      </div>
      <div style={{...cellStyle, borderRight: 'none' }}>
        { header ? <span>{author}</span> : <a href={author.url}>{author.name}</a> }
      </div>
      <div style={{...cellStyle, borderRight: 'none', fontSize: header ? 18 : 14 }}>
        { header ? date : moment(date, 'YYYY MM DD').format('MMMM Do') }
      </div>
      <div style={cellStyle}>
        { isFetching.is && isFetching.id === id ? "Doing things" : actions }
      </div>
    </div>
  )
}

TableRow.PropTypes = {
  header: PropTypes.bool,
  firstRow: PropTypes.bool,
  isFetching: PropTypes.object,
  lastRow: PropTypes.bool,
  onActionClick: PropTypes.func,
  position: PropTypes.string,
  rowData: PropTypes.object.isRequired
};

TableRow.defaultProps = {
  isFetching: {},
  header: false
};

export default TableRow;