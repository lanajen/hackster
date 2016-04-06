import React, { PropTypes } from 'react';

const TableRow = props => {
  //  Vendor | Project | Author | SubDate | Buttons
  const { vendor, project, author, subDate, buttons } = props.rowData;
  const cellStyle = {
    flex: 1,
    textAlign: 'center',
    border: '1px solid black',
    overflow: 'scroll',
    maxHeight: 27
  };
  // Overflow x or y for each cell?
  const actions = buttons
    ? React.Children.toArray([<button>reject</button>,<button>approve</button>])
    : 'Actions';
  return (
    <div style={{ display: 'flex', alignItems: 'center' }}>
      <div style={cellStyle}>{vendor}</div>
      <div style={cellStyle}>{project}</div>
      <div style={cellStyle}>{author}</div>
      <div style={cellStyle}>{subDate}</div>
      <div style={cellStyle}>
        {actions}
      </div>
    </div>
  )
}

TableRow.PropTypes = {
  rowData: PropTypes.object.isRequired
};

export default TableRow;