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

    return getOptionsHandler({ type: this.props.name, q:input })
      .then(response => {
        return response.map(univ => {
          return {
            value: univ.id,
            label: univ.full_name,
            ...univ
          }
        });
      }).then(universities => {

        this.setState({ isLoading: false });

        return {
          options: universities,
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
    let { value, name, search, imageUploadData } = this.props;
    let action = this.state.value
               ? (<button className="btn btn-success" onClick={this.handleContinueButton}>Continue</button>)
               : (<span>
                    Not in the list?&nbsp;<a href="javascript:void(0);" onClick={this.handleViewState.bind(this, 'form')}>Create new</a>
                  </span>);

    let view = this.state.viewState === 'selection' && search
             ? (<div className="course-wizard-search">
                  <Select.Async value={this.state.value}
                                minimumInput={3}
                                autoload={false}
                                isLoading={this.state.isLoading}
                                placeholder={`Search for a ${name}`}
                                loadOptions={this.getOptions}
                                onChange={this.onChange}
                                optionRenderer={this.selectRenderer}
                                valueRenderer={this.selectRenderer} />
                  <div className="create-new-form">
                    {action}
                  </div>
                </div>)
             : (<div className="course-wizard-search">
                  <Form { ...this.props.form }
                        name={name}
                        search={search}
                        imageUploadData={imageUploadData}
                        toggleToSearch={this.handleViewState.bind(this, 'selection')}
                        postForm={this.handlePostForm} />
                </div>);

    return view;
  }

  selectRenderer(univ) {
    return (
      <div>
        <span>{univ.full_name + ' '}</span>
        <span>{univ.city ? univ.city : ''} {univ.country ? `, ${univ.country}` : ''}</span>
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
  value: PropTypes.object.isRequired
};