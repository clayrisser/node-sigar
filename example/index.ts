import Sigar, { ProcState } from '../src';

const sigar = new Sigar();

interface PidsProcInfo {
  [key: number]: [string[], ProcState];
}

console.log(
  sigar.procList.reduce((pidsProcInfo: PidsProcInfo, pid: number) => {
    pidsProcInfo[pid] = [sigar.getProcArgs(pid), sigar.getProcState(pid)];
    return pidsProcInfo;
  }, {})
);
console.log(sigar.procStat);
