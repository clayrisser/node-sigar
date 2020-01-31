#include "sigar.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
#define NAPI_EXPERIMENTAL
#include <node_api.h>

napi_value GetProcList(napi_env env, napi_callback_info info) {
  int sigar_status;
  napi_status status;
  napi_value proc_list;
  sigar_proc_list_t sigar_proc_list;
  sigar_t* sigar;
  sigar_open(&sigar);
  sigar_status = sigar_proc_list_get(sigar, &sigar_proc_list);
  assert(sigar_status == SIGAR_OK);
  status = napi_create_array_with_length(env, sigar_proc_list.number, &proc_list);
  assert(status == napi_ok);
  for (int i = 0; i < sigar_proc_list.number; i++) {
    napi_value pid;
    status = napi_create_bigint_uint64(env, sigar_proc_list.data[i], &pid);
    assert(status == napi_ok);
    status = napi_set_element(env, proc_list, i, pid);
    assert(status == napi_ok);
  }
  sigar_proc_list_destroy(sigar, &sigar_proc_list);
  sigar_close(sigar);
  return proc_list;
}

napi_value GetProcState(napi_env env, napi_callback_info info) {
  bool lossless;
  char* s_key;
  int sigar_status;
  napi_status status;
  napi_value args[1];
  napi_value key;
  napi_value proc_state;
  napi_value value;
  napi_valuetype valuetype0;
  sigar_proc_state_t sigar_proc_state;
  sigar_t* sigar;
  size_t argc = 1;
  uint64_t value0;
  sigar_open(&sigar);
  status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
  assert(status == napi_ok);
  if (argc < 1) {
    napi_throw_type_error(env, nullptr, "Wrong number of arguments");
    return nullptr;
  }
  status = napi_typeof(env, args[0], &valuetype0);
  assert(status == napi_ok);
  if (valuetype0 != napi_bigint) {
    napi_throw_type_error(env, nullptr, "Wrong arguments");
    return nullptr;
  }
  status = napi_get_value_bigint_uint64(env, args[0], &value0, &lossless);
  assert(status == napi_ok);
  sigar_status = sigar_proc_state_get(sigar, value0, &sigar_proc_state);
  assert(sigar_status == SIGAR_OK);
  status = napi_create_object(env, &proc_state);
  assert(status == napi_ok);
 // name: string;
 // state: string;
  s_key = "ppid";
  status = napi_create_string_utf8(env, s_key, strlen(s_key), &key);
  assert(status == napi_ok);
  status = napi_create_bigint_uint64(env, sigar_proc_state.ppid, &value);
  status = napi_set_property(env, proc_state, key, value);
  assert(status == napi_ok);
  s_key = "nice";
  status = napi_create_string_utf8(env, s_key, strlen(s_key), &key);
  assert(status == napi_ok);
  status = napi_create_bigint_uint64(env, sigar_proc_state.nice, &value);
  status = napi_set_property(env, proc_state, key, value);
  assert(status == napi_ok);
  s_key = "priority";
  status = napi_create_string_utf8(env, s_key, strlen(s_key), &key);
  assert(status == napi_ok);
  status = napi_create_bigint_uint64(env, sigar_proc_state.priority, &value);
  status = napi_set_property(env, proc_state, key, value);
  assert(status == napi_ok);
  s_key = "processor";
  status = napi_create_string_utf8(env, s_key, strlen(s_key), &key);
  assert(status == napi_ok);
  status = napi_create_bigint_uint64(env, sigar_proc_state.processor, &value);
  status = napi_set_property(env, proc_state, key, value);
  assert(status == napi_ok);
  s_key = "tty";
  status = napi_create_string_utf8(env, s_key, strlen(s_key), &key);
  assert(status == napi_ok);
  status = napi_create_bigint_uint64(env, sigar_proc_state.tty, &value);
  status = napi_set_property(env, proc_state, key, value);
  assert(status == napi_ok);
  s_key = "threads";
  status = napi_create_string_utf8(env, s_key, strlen(s_key), &key);
  assert(status == napi_ok);
  status = napi_create_bigint_uint64(env, sigar_proc_state.threads, &value);
  status = napi_set_property(env, proc_state, key, value);
  assert(status == napi_ok);
  sigar_close(sigar);
  return proc_state;
}

#define DECLARE_NAPI_METHOD(name, func)         \
  { name, 0, func, 0, 0, 0, napi_default, 0 }

napi_value Init(napi_env env, napi_value exports) {
  napi_status status;
  napi_property_descriptor desc;
  desc = DECLARE_NAPI_METHOD("getProcList", GetProcList);
  status = napi_define_properties(env, exports, 1, &desc);
  assert(status == napi_ok);
  desc = DECLARE_NAPI_METHOD("getProcState", GetProcState);
  status = napi_define_properties(env, exports, 1, &desc);
  assert(status == napi_ok);
  return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Init)
