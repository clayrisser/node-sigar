#include "sigar.h"
#include <assert.h>
#include <stdio.h>
#define NAPI_EXPERIMENTAL
#include <node_api.h>

napi_value GetProcList(napi_env env, napi_callback_info info) {
  int sigar_status;
  napi_status n_status;
  napi_value n_proc_list;
  sigar_proc_list_t sigar_proc_list;
  sigar_t* sigar;
  sigar_open(&sigar);
  sigar_status = sigar_proc_list_get(sigar, &sigar_proc_list);
  assert(sigar_status == SIGAR_OK);
  n_status = napi_create_array_with_length(env, sigar_proc_list.number, &n_proc_list);
  assert(n_status == napi_ok);
  for (int i = 0; i < sigar_proc_list.number; i++) {
    napi_value n_pid;
    n_status = napi_create_bigint_uint64(env, sigar_proc_list.data[i], &n_pid);
    assert(n_status == napi_ok);
    n_status = napi_set_element(env, n_proc_list, i, n_pid);
    assert(n_status == napi_ok);
  }
  sigar_proc_list_destroy(sigar, &sigar_proc_list);
  sigar_close(sigar);
  return n_proc_list;
}

#define DECLARE_NAPI_METHOD(name, func)         \
  { name, 0, func, 0, 0, 0, napi_default, 0 }

napi_value Init(napi_env env, napi_value exports) {
  napi_status status;
  napi_property_descriptor desc = DECLARE_NAPI_METHOD("getProcList", GetProcList);
  status = napi_define_properties(env, exports, 1, &desc);
  assert(status == napi_ok);
  return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Init)
