import _ from 'lodash';

export default class PermissionReducer {
  reduce(json, state) {
    const data = _.get(json, 'permission-update', false);
    if (data) {
      this.initial(data, state);
      this.create(data, state);
      this.delete(data, state);
      this.add(data, state);
      this.remove(data, state);
    }
  }

  initial(json, state) {
    const data = _.get(json, 'initial', false);
    if (data) {
      for (const perm in data) {
        state.permissions[perm] = {
          who: new Set(data[perm].who),
          kind: data[perm].kind
        };
      }
    }
  }

  create(json, state) {
    const data = _.get(json, 'create', false);
    if (data) {
      state.permissions[data.path] = {
        kind: data.kind,
        who: new Set(data.who)
      };
    }
  }

  delete(json, state) {
    const data = _.get(json, 'delete', false);
    if (data) {
      delete state.permissions[data.path];
    }
  }

  add(json, state) {
    const data = _.get(json, 'add', false);
    if (data) {
      for (const member of data.who) {
        state.permissions[data.path].who.add(member);
      }
    }
  }

  remove(json, state) {
    const data = _.get(json, 'remove', false);
    if (data) {
      for (const member of data.who) {
        state.permissions[data.path].who.delete(member);
      }
    }
  }
}
