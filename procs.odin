package cef

import "base:intrinsics"
import "base:runtime"
import "core:c/libc"
import "core:fmt"
import "core:sys/windows"

when ODIN_OS == .Windows {
	foreign import cef "lib/libcef.lib"
} else {
	#panic("Platform not supported")
}

@(link_prefix = "cef_")
foreign cef {

	///
	/// This function should be called on the main application thread to initialize
	/// the CEF browser process. The |application| parameter may be NULL. Returns
	/// true (1) if initialization succeeds. Returns false (0) if initialization
	/// fails or if early exit is desired (for example, due to process singleton
	/// relaunch behavior). If this function returns false (0) then the application
	/// should exit immediately without calling any other CEF functions except,
	/// optionally, CefGetErrorCode. The |windows_sandbox_info| parameter is only
	/// used on Windows and may be NULL (see cef_sandbox_win.h for details).
	///
	initialize :: proc(args: ^Main_Args, settings: ^Settings, application: ^App, windows_sandbox_info: rawptr) -> libc.int ---

	///
	/// This function should be called from the application entry point function to
	/// execute a secondary process. It can be used to run secondary processes from
	/// the browser client executable (default behavior) or from a separate
	/// executable specified by the cef_settings_t.browser_subprocess_path value. If
	/// called for the browser process (identified by no "type" command-line value)
	/// it will return immediately with a value of -1. If called for a recognized
	/// secondary process it will block until the process should exit and then
	/// return the process exit code. The |application| parameter may be NULL. The
	/// |windows_sandbox_info| parameter is only used on Windows and may be NULL
	/// (see cef_sandbox_win.h for details).
	///
	execute_process :: proc(args: ^Main_Args, application: ^App, windows_sandbox_info: rawptr) -> libc.int ---

	///
	/// Returns the CEF API version that was configured by the first call to
	/// cef_api_hash().
	///
	api_version :: proc() -> libc.int ---

	///
	/// Configures the CEF API version and returns API hashes for the libcef
	/// library. The returned string is owned by the library and should not be
	/// freed. The |version| parameter should be CEF_API_VERSION and any changes to
	/// this value will be ignored after the first call to this method. The |entry|
	/// parameter describes which hash value will be returned:
	///
	/// 0 - CEF_API_HASH_PLATFORM
	/// 1 - CEF_API_HASH_UNIVERSAL (deprecated, same as CEF_API_HASH_PLATFORM)
	/// 2 - CEF_COMMIT_HASH (from cef_version.h)
	///
	api_hash :: proc(version, entry: libc.int) -> cstring ---

	///
	/// This function can optionally be called on the main application thread after
	/// CefInitialize to retrieve the initialization exit code. When CefInitialize
	/// returns true (1) the exit code will be 0 (CEF_RESULT_CODE_NORMAL_EXIT).
	/// Otherwise, see cef_resultcode_t for possible exit code values including
	/// browser process initialization errors and normal early exit conditions (such
	/// as CEF_RESULT_CODE_NORMAL_EXIT_PROCESS_NOTIFIED for process singleton
	/// relaunch behavior).
	///
	get_exit_code :: proc() ---

	///
	/// Perform a single iteration of CEF message loop processing. This function is
	/// provided for cases where the CEF message loop must be integrated into an
	/// existing application message loop. Use of this function is not recommended
	/// for most users; use either the cef_run_message_loop() function or
	/// cef_settings_t.multi_threaded_message_loop if possible. When using this
	/// function care must be taken to balance performance against excessive CPU
	/// usage. It is recommended to enable the cef_settings_t.external_message_pump
	/// option when using this function so that
	/// cef_browser_process_handler_t::on_schedule_message_pump_work() callbacks can
	/// facilitate the scheduling process. This function should only be called on
	/// the main application thread and only if cef_initialize() is called with a
	/// cef_settings_t.multi_threaded_message_loop value of false (0). This function
	/// will not block.
	///
	do_message_loop_work :: proc() ---

	///
	/// Run the CEF message loop. Use this function instead of an application-
	/// provided message loop to get the best balance between performance and CPU
	/// usage. This function should only be called on the main application thread
	/// and only if cef_initialize() is called with a
	/// cef_settings_t.multi_threaded_message_loop value of false (0). This function
	/// will block until a quit message is received by the system.
	///
	run_message_loop :: proc() ---

	///
	/// Quit the CEF message loop that was started by calling
	/// cef_run_message_loop(). This function should only be called on the main
	/// application thread and only if cef_run_message_loop() was used.
	///
	quit_message_loop :: proc() ---

	///
	/// This function should be called on the main application thread to shut down
	/// the CEF browser process before the application exits. Do not call any other
	/// CEF functions after calling this function.
	///
	shutdown :: proc() ---

	command_line_create :: proc() -> ^Command_Line ---
	command_line_get_global :: proc() -> ^Command_Line ---

	string_wide_set :: proc(src: [^]libc.wchar_t, src_len: libc.size_t, output: ^String_Wide, copy: libc.int) -> libc.int ---
	string_utf8_set :: proc(src: [^]libc.char, src_len: libc.size_t, output: ^String_UTF8, copy: libc.int) -> libc.int ---
	string_utf16_set :: proc(src: [^]libc.char16_t, src_len: libc.size_t, output: ^String_UTF16, copy: libc.int) -> libc.int ---

	///
	/// Create a new cef_v8_value_t object of type undefined.
	///
	v8_value_create_undefined :: proc() -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type null.
	///
	v8_value_create_null :: proc() -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type bool.
	///
	v8_value_create_bool :: proc(value: libc.int) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type int.
	///
	v8_value_create_int :: proc(value: libc.int32_t) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type unsigned int.
	///
	v8_value_create_uint :: proc(value: libc.uint32_t) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type double.
	///
	v8_value_create_double :: proc(value: libc.double) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type Date. This function should only
	/// be called from within the scope of a cef_render_process_handler_t,
	/// cef_v8_handler_t or cef_v8_accessor_t callback, or in combination with
	/// calling enter() and exit() on a stored cef_v8_context_t reference.
	///
	v8_value_create_date :: proc(value: Basetime) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type string.
	///
	v8_value_create_string :: proc(value: ^String) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type object with optional accessor
	/// and/or interceptor. This function should only be called from within the
	/// scope of a cef_render_process_handler_t, cef_v8_handler_t or
	/// cef_v8_accessor_t callback, or in combination with calling enter() and
	/// exit() on a stored cef_v8_context_t reference.
	///
	v8_value_create_object :: proc(accessor: ^V8_Accessor, interceptor: ^V8_Interceptor) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type array with the specified
	/// |length|. If |length| is negative the returned array will have length 0.
	/// This function should only be called from within the scope of a
	/// cef_render_process_handler_t, cef_v8_handler_t or cef_v8_accessor_t
	/// callback, or in combination with calling enter() and exit() on a stored
	/// cef_v8_context_t reference.
	///
	v8_value_create_array :: proc(length: libc.int) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type ArrayBuffer which wraps the
	/// provided |buffer| of size |length| bytes. The ArrayBuffer is externalized,
	/// meaning that it does not own |buffer|. The caller is responsible for freeing
	/// |buffer| when requested via a call to
	/// cef_v8_array_buffer_release_callback_t::ReleaseBuffer. This function should
	/// only be called from within the scope of a cef_render_process_handler_t,
	/// cef_v8_handler_t or cef_v8_accessor_t callback, or in combination with
	/// calling enter() and exit() on a stored cef_v8_context_t reference.
	///
	/// NOTE: Always returns nullptr when V8 sandbox is enabled.
	///
	v8_value_create_array_buffer :: proc(buffer: rawptr, length: libc.size_t, release_callback: V8_Array_Buffer_Release_Callback) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type ArrayBuffer which copies the
	/// provided |buffer| of size |length| bytes. This function should only be
	/// called from within the scope of a cef_render_process_handler_t,
	/// cef_v8_handler_t or cef_v8_accessor_t callback, or in combination with
	/// calling enter() and exit() on a stored cef_v8_context_t reference.
	/// ^V8_Array_Buffer_Release_Callback) -> ^V8_Value ---
	v8_value_create_array_buffer_with_copy :: proc(buffer: rawptr, length: libc.size_t) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type function. This function should
	/// only be called from within the scope of a cef_render_process_handler_t,
	/// cef_v8_handler_t or cef_v8_accessor_t callback, or in combination with
	/// calling enter() and exit() on a stored cef_v8_context_t reference.
	///
	v8_value_create_function :: proc(name: ^String, handler: ^V8_Handler) -> ^V8_Value ---

	///
	/// Create a new cef_v8_value_t object of type Promise. This function should
	/// only be called from within the scope of a cef_render_process_handler_t,
	/// cef_v8_handler_t or cef_v8_accessor_t callback, or in combination with
	/// calling enter() and exit() on a stored cef_v8_context_t reference.
	///
	v8_value_create_promise :: proc() -> ^V8_Value ---

	request_context_get_global_context :: proc() -> ^Request_Context ---

	v8_context_get_current_context :: proc() -> ^V8_Context ---
	v8_context_get_entered_context :: proc() -> ^V8_Context ---
	v8_context_in_context :: proc() -> libc.int ---

	browser_host_create_browser :: proc(windowInfo: ^Window_Info, client: ^Client, url: ^String, settings: ^Browser_Settings, extra_info: ^Dictionary_Value, request_context: ^Request_Context) -> libc.int ---
	browser_host_create_browser_sync :: proc(windowInfo: ^Window_Info, client: ^Client, url: ^String, settings: ^Browser_Settings, extra_info: ^Dictionary_Value, request_context: ^Request_Context) -> libc.int ---
}

string_wide_copy :: proc(
	src: [^]libc.wchar_t,
	src_len: libc.size_t,
	output: ^String_Wide,
) -> libc.int {
	return string_wide_set(src, src_len, output, 1)
}

string_utf8_copy :: proc(
	src: [^]libc.char,
	src_len: libc.size_t,
	output: ^String_UTF8,
) -> libc.int {
	return string_utf8_set(src, src_len, output, 1)
}

string_utf16_copy :: proc(
	src: [^]libc.char16_t,
	src_len: libc.size_t,
	output: ^String_UTF16,
) -> libc.int {
	return string_utf16_set(src, src_len, output, 1)
}

add_ref :: proc "c" (self: ^Base_Ref_Counted) {
	context = runtime.default_context()
	// fmt.println(#location().procedure)
}

release :: proc "c" (self: ^Base_Ref_Counted) -> libc.int {
	context = runtime.default_context()
	// fmt.println(#location().procedure)
	return 1
}

has_one_ref :: proc "c" (self: ^Base_Ref_Counted) -> libc.int {
	context = runtime.default_context()
	// fmt.println(#location().procedure)
	return 1
}

base_ref_counted_init :: proc(base: ^Base_Ref_Counted) {
	// fmt.println(#location().procedure, base.size)
	assert(base.size >= 0)
	base.add_ref = add_ref
	base.release = release
	base.has_one_ref = has_one_ref
}

make_base_ref_counted :: proc(size: libc.size_t) -> Base_Ref_Counted {
	base := Base_Ref_Counted {
		size = size,
	}
	base_ref_counted_init(&base)
	return base
}

to_odin_string :: proc(s: ^String, allocator := context.temp_allocator) -> string {
	if s == nil {
		return {}
	}
	return(
		windows.utf16_to_utf8(s.str[:s.length], allocator = allocator) or_else panic(
			"String conversion error",
		) \
	)
}

to_cef_string :: proc(s: string, allocator := context.allocator) -> String {
	str := windows.utf8_to_utf16(s, allocator = allocator)
	return String{str = raw_data(str), length = len(str), dtor = proc "c" (s: [^]u16) {
			context = runtime.default_context()
			free(s)
		}}
}

to_cef_string_ptr :: proc(s: string, allocator := context.temp_allocator) -> ^String {
	return new_clone(to_cef_string(s, allocator), allocator = allocator)
}

delete_cef_string :: proc(s: ^String) {
	if s == nil {
		return
	}
	if s.dtor == nil {
		return
	}
	s.dtor(s.str)
}

app_init :: proc(app: ^App) {
	app.base.size = size_of(App)
	base_ref_counted_init(&app.base)
}

make_object :: proc($T: typeid/struct {
		base: Base_Ref_Counted,
	}) -> T {
	return T{base = {size = size_of(T)}}
}

