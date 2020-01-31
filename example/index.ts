import Sigar, { ProcState } from '../src';

interface PidsProcState {
  [key: number]: ProcState;
}

const sigar = new Sigar();

console.log(
  sigar.procList.reduce((pidsProcState: PidsProcState, pid: number) => {
    pidsProcState[pid] = sigar.getProcState(pid);
    return pidsProcState;
  }, {})
);
