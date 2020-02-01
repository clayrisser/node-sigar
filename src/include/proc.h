#define NAPI_EXPERIMENTAL
#include <node_api.h>
#include <napi.h>

Napi::Array GetProcList(const Napi::CallbackInfo& info);
Napi::Value GetProcState(const Napi::CallbackInfo& info);
