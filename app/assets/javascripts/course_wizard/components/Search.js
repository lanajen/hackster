import React, { Component, PropTypes } from 'react';
import Select from 'react-select';
import Form from './Form';
import { getCSRFToken } from '../../utils/Utils';

export default class Search extends Component {
  constructor(props) {
    super(props);
    this.onChange = this.onChange.bind(this);
    this.getOptions = this.getOptions.bind(this);
    this.selectRenderer = this.selectRenderer.bind(this);
    this.handleViewState = this.handleViewState.bind(this);
    this.handlePostForm = this.handlePostForm.bind(this);
    this.handleContinueButton = this.handleContinueButton.bind(this);

    this.state = { isLoading: false, viewState: 'selection', value: null };
  }

  onChange(value) {
    this.setState({ value: value });
  }

  getOptions(input) {
    let { getOptionsHandler } = this.props.actions;

    this.setState({ isLoading: true });

    let query = {
      type: this.props.type,
      q: input
    };

    if (this.props.type === 'Course')
      query.parent_id = this.props.store['university'].id;

    return getOptionsHandler(query)
      .then(response => {
        return response.map(group => {
          return {
            value: group.id,
            label: group.full_name,
            ...group
          }
        });
      }).then(groups => {

        this.setState({ isLoading: false });

        return {
          options: groups,
          complete: true
        };

      });
  }

  handleViewState(state) {
    this.setState({ viewState: state });
  }

  handlePostForm(form, endpoint, imageData) {
    this.props.actions.postFormHandler(form, endpoint, getCSRFToken(), imageData);
  }

  handleContinueButton(e) {
    e.preventDefault();
    this.props.actions.setSelectionValue(this.state.value, this.props.name.toLowerCase());
  }

  render() {
    let { value, name, search, imageUploadData, type } = this.props;
    let createNew = this.state.value
               ? null
               : (<div className="create-new-form">
                    Not in the list?&nbsp;<a href="javascript:void(0);" onClick={this.handleViewState.bind(this, 'form')}>Create a new one</a>.
                  </div>);

   let continueBtn = this.state.value
                    ? (<div className="continue-btn">
                        <button className="btn btn-success btn-sm" onClick={this.handleContinueButton}>Continue</button>
                      </div>)
                    : null;

    let view = this.state.viewState === 'selection' && search
             ? (<div className="course-wizard-search">
                  {createNew}
                  <Select.Async value={this.state.value}
                                autoload={true}
                                isLoading={this.state.isLoading}
                                placeholder={`Search for a ${name}`}
                                loadOptions={this.getOptions}
                                onChange={this.onChange}
                                optionRenderer={this.selectRenderer} />
                  {continueBtn}
                </div>)
             : (<div className="course-wizard-search">
                  <Form { ...this.props.form }
                        type={type}
                        search={search}
                        imageUploadData={imageUploadData}
                        toggleToSearch={this.handleViewState.bind(this, 'selection')}
                        postForm={this.handlePostForm} />
                </div>);

    return view;
  }

  selectRenderer(group) {

    let detailsText = group.city ? group.city : '';
    detailsText += group.country ? `, ${group.country}` : '';
    let details = detailsText !== '' ? (<div className="result-details">{detailsText}</div>) : null;

    return (
      <div className="course-wizard-result">
        <div className="result-name">{group.full_name + ' '}</div>
        {details}
      </div>
    );
  }
}

Search.PropTypes = {
  actions: PropTypes.object.isRequired,
  form: PropTypes.object.isRequired,
  imageUploadData: PropTypes.object.isRequired,
  name: PropTypes.string.isRequired,
  search: PropTypes.bool.isRequired,
  value: PropTypes.object.isRequired,
  type: PropTypes.string.isRequired
};