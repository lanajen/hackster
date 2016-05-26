import request from 'superagent';
import { getApiPath, getApiToken } from '../utils/Utils'

export default {
  getOptions: function(query) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .get(`${getApiPath()}/private/groups`)
          .set('Authorization', `Bearer ${token}`)
          .query(query)
          .end((err, res) => {
            err ? reject(err) : resolve(res.body);
          });
      });
    });
  },

  postForm: function(form, endpoint) {
    let newForm = Object.assign({}, form);
    newForm[newForm.model_key] = newForm.model_data;
    delete newForm.model_key;
    delete newForm.model_data;

    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .post(endpoint)
          .set('Authorization', `Bearer ${token}`)
          .send(newForm)
          .end((err, res) => {
            err ? reject(err) : resolve(res.body);
          });
      }, true);
    });
  }
};