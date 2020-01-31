import bindings from 'bindings';

const addon = bindings('sigar');

export default class Sigar {
  hello() {
    return addon.hello();
  }
}
