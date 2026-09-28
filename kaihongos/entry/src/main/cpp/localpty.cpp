// localpty.c — forkpty + /bin/sh 本地终端 NAPI 模块
// 导出: ptyOpen(cols,rows) / ptyWrite(str) / ptyClose() / ptyResize(cols,rows)
// 输出经 napi_threadsafe_function 异步回调 JS(onPtyData)
#include <napi/native_api.h>
#include <pty.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/wait.h>
#include <errno.h>

static int g_master = -1;
static pid_t g_child = -1;
static pthread_t g_thr;
static volatile int g_running = 0;
static napi_threadsafe_function g_tsfn = NULL;

static void call_js(napi_env env, napi_value js_cb, void* context, void* data) {
  if (data == NULL) return;
  char* text = (char*)data;  napi_value str;
  napi_create_string_utf8(env, text, NAPI_AUTO_LENGTH, &str);
  napi_value undef;
  napi_get_undefined(env, &undef);
  napi_call_function(env, undef, js_cb, 1, &str, &undef);
  free(text);
}

static void* read_loop(void* arg) {
  char buf[4096];
  while (g_running) {
    ssize_t n = read(g_master, buf, sizeof(buf) - 1);
    if (n <= 0) {
      if (n < 0 && (errno == EINTR)) continue;
      break;
    }
    buf[n] = '\0';
    char* copy = (char*)malloc(n + 1);
    memcpy(copy, buf, n + 1);
    napi_call_threadsafe_function(g_tsfn, copy, napi_tsfn_blocking);
  }
  return NULL;
}

static napi_value PtyOpen(napi_env env, napi_callback_info info) {
  size_t argc = 2;
  napi_value args[2];
  napi_get_cb_info(env, info, &argc, args, NULL, NULL);
  int cols = 80, rows = 24;
  napi_get_value_int32(env, args[0], &cols);
  napi_get_value_int32(env, args[1], &rows);
  napi_value js_cb = args[2];
  if (argc < 3) {
    napi_throw_error(env, NULL, "need (cols, rows, onData)");
    return NULL;
  }
  if (g_running) {
    napi_throw_error(env, NULL, "pty already open");
    return NULL;
  }
  struct winsize ws;
  ws.ws_col = cols; ws.ws_row = rows;
  ws.ws_xpixel = 0; ws.ws_ypixel = 0;
  pid_t pid = forkpty(&g_master, NULL, NULL, &ws);
  if (pid < 0) {
    napi_throw_error(env, NULL, "forkpty failed");
    return NULL;
  }
  if (pid == 0) {
    // child: /bin/sh interactive
    setenv("TERM", "xterm-256color", 1);
    execl("/bin/sh", "sh", NULL);
    _exit(127);
  }
  g_child = pid;
  // threadsafe function for output
  napi_value res_name;
  napi_create_string_utf8(env, "ptyData", NAPI_AUTO_LENGTH, &res_name);
  napi_create_threadsafe_function(env, js_cb, NULL, res_name, 0, 1, NULL, NULL, NULL, call_js, &g_tsfn);
  g_running = 1;
  pthread_create(&g_thr, NULL, read_loop, NULL);
  napi_value pid_val;
  napi_create_int32(env, pid, &pid_val);
  return pid_val;
}

static napi_value PtyWrite(napi_env env, napi_callback_info info) {
  size_t argc = 1;
  napi_value args[1];
  napi_get_cb_info(env, info, &argc, args, NULL, NULL);
  size_t len = 0;
  napi_get_value_string_utf8(env, args[0], NULL, 0, &len);
  char* buf = (char*)malloc(len + 1);
  napi_get_value_string_utf8(env, args[0], buf, len + 1, &len);
  ssize_t n = write(g_master, buf, len);
  free(buf);
  napi_value out;
  napi_create_int32(env, (int)n, &out);
  return out;
}

static napi_value PtyClose(napi_env env, napi_callback_info info) {
  (void)info;
  if (g_running) {
    g_running = 0;
    close(g_master);
    if (g_child > 0) {
      kill(g_child, SIGKILL);
      waitpid(g_child, NULL, 0);
    }
    pthread_join(g_thr, NULL);
    if (g_tsfn) {
      napi_release_threadsafe_function(g_tsfn, napi_tsfn_release);
      g_tsfn = NULL;
    }
    g_master = -1;
    g_child = -1;
  }
  napi_value undef;
  napi_get_undefined(env, &undef);
  return undef;
}

static napi_value PtyResize(napi_env env, napi_callback_info info) {
  size_t argc = 2;
  napi_value args[2];
  napi_get_cb_info(env, info, &argc, args, NULL, NULL);
  int cols = 80, rows = 24;
  napi_get_value_int32(env, args[0], &cols);
  napi_get_value_int32(env, args[1], &rows);
  struct winsize ws;
  ws.ws_col = cols; ws.ws_row = rows;
  ws.ws_xpixel = 0; ws.ws_ypixel = 0;
  ioctl(g_master, TIOCSWINSZ, &ws);
  napi_value undef;
  napi_get_undefined(env, &undef);
  return undef;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
  napi_property_descriptor desc[] = {
    { "ptyOpen", NULL, PtyOpen, NULL, NULL, NULL, napi_default, NULL },
    { "ptyWrite", NULL, PtyWrite, NULL, NULL, NULL, napi_default, NULL },
    { "ptyClose", NULL, PtyClose, NULL, NULL, NULL, napi_default, NULL },
    { "ptyResize", NULL, PtyResize, NULL, NULL, NULL, napi_default, NULL },
  };
  napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
  return exports;
}
EXTERN_C_END

static napi_module localptyModule = {
  .nm_version = 1,
  .nm_flags = 0,
  .nm_filename = NULL,
  .nm_register_func = Init,
  .nm_modname = "localpty",
  .nm_priv = NULL,
  .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterLocalptyModule(void) {
  napi_module_register(&localptyModule);
}
