import React from 'react';
import Select from 'react-select';
import request from 'superagent';

const UniversitySearch = React.createClass({
  getInitialState: function(){
    return {
      val: null
    }
  },

  onChange: function(val) {
    this.setState({
      val: val
    });
  },

  selectGetOptions: function(input, callback) {
    let promise = new Promise((resolve, reject) => {
      request
        .get('/api/v1/groups')
        .query({ type: 'University', q: input })
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
      });

    return promise
      .then(response => {
        return _.map(response.body, function(univ){
          return {
            value: univ.id,
            label: univ.full_name,
            ...univ
          }
        });
      }).then(universities => {
        return {
          options: universities
        }
      }).catch(function(err) { console.log('Request Error: ' + err); });
  },

  selectRenderer: function(univ) {
    return (
      <div>
        <div>{univ.full_name}</div>
        <div>{univ.city}, {univ.country}</div>
      </div>
    );
  },

  render: function() {
    const { } = this.props;

    return (
      <div className=''>
        <Select.Async name="form-field-name" value={this.state.val} loadOptions={this.selectGetOptions} autoload={false} onChange={this.onChange} optionRenderer={this.selectRenderer} valueRenderer={this.selectRenderer} />
      </div>
    );
  },

  fetchUniversities: function(query) {
    return new Promise((resolve, reject) => {
      request
        .get('/api/v1/groups')
        .send({ type: 'University', q: query })
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  }
});

export default UniversitySearch;