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

Window_Handle :: windows.HWND

Color :: libc.uint32_t

State :: enum libc.int {
	Default,
	Enabled,
	Disabled,
}

Log_Severity :: enum libc.int {
	Default,
	Verbose,
	Debug = Verbose,
	Info,
	Warning,
	Error,
	Fatal,
	Disable = 99,
}

Log_Items :: enum libc.int {
	Default,
	None,
	Flag_Process_ID = 1 << 1,
	Flag_Thread_ID = 1 << 2,
	Flag_Time_Stamp = 1 << 3,
	Flag_Tick_Count = 1 << 4,
}

Runtime_Style :: enum libc.int {
	Default,
	Chrome,
	Alloy,
}

Rect :: struct {
	x:      libc.int,
	y:      libc.int,
	width:  libc.int,
	height: libc.int,
}

Size :: struct {
	width:  libc.int,
	height: libc.int,
}

Preferences_Type :: enum {
	Global,
	Request_Context,
}

Preference_Registrar :: struct {
	///
	/// Base structure.
	///
	base:           Base_Scoped,

	///
	/// Register a preference with the specified |name| and |default_value|. To
	/// avoid conflicts with built-in preferences the |name| value should contain
	/// an application-specific prefix followed by a period (e.g. "myapp.value").
	/// The contents of |default_value| will be copied. The data type for the
	/// preference will be inferred from |default_value|'s type and cannot be
	/// changed after registration. Returns true (1) on success. Returns false (0)
	/// if |name| is already registered or if |default_value| has an invalid type.
	/// This function must be called from within the scope of the
	/// cef_browser_process_handler_t::OnRegisterCustomPreferences callback.
	///
	add_preference: proc "c" (
		self: ^Preference_Registrar,
		name: ^String,
		default_value: ^Value,
	) -> libc.int,
}

Binary_Value :: struct {
	///
	/// Base structure.
	///
	base:         Base_Ref_Counted,

	///
	/// Returns true (1) if this object is valid. This object may become invalid
	/// if the underlying data is owned by another object (e.g. list or
	/// dictionary) and that other object is then modified or destroyed. Do not
	/// call any other functions if this function returns false (0).
	///
	is_valid:     proc "c" (self: ^Binary_Value) -> libc.int,

	///
	/// Returns true (1) if this object is currently owned by another object.
	///
	is_owned:     proc "c" (self: ^Binary_Value) -> libc.int,

	///
	/// Returns true (1) if this object and |that| object have the same underlying
	/// data.
	///
	is_same:      proc "c" (self: ^Binary_Value, that: ^Binary_Value) -> libc.int,

	///
	/// Returns true (1) if this object and |that| object have an equivalent
	/// underlying value but are not necessarily the same object.
	///
	is_equal:     proc "c" (self: ^Binary_Value, that: ^Binary_Value) -> libc.int,

	///
	/// Returns a copy of this object. The data in this object will also be
	/// copied.
	///
	copy:         proc "c" (self: ^Binary_Value) -> ^Binary_Value,

	///
	/// Returns a pointer to the beginning of the memory block. The returned
	/// pointer is valid as long as the cef_binary_value_t is alive.
	///
	get_raw_data: proc "c" (self: ^Binary_Value) -> rawptr,

	///
	/// Returns the data size.
	///
	get_size:     proc "c" (self: ^Binary_Value) -> libc.size_t,

	///
	/// Read up to |buffer_size| number of bytes into |buffer|. Reading begins at
	/// the specified byte |data_offset|. Returns the number of bytes read.
	///
	get_data:     proc "c" (
		self: ^Binary_Value,
		buffer: rawptr,
		buffer_size: libc.size_t,
		data_offset: libc.size_t,
	) -> libc.size_t,
}

List_Value :: struct {
	///
	/// Base structure.
	///
	base:           Base_Ref_Counted,

	///
	/// Returns true (1) if this object is valid. This object may become invalid
	/// if the underlying data is owned by another object (e.g. list or
	/// dictionary) and that other object is then modified or destroyed. Do not
	/// call any other functions if this function returns false (0).
	///
	is_valid:       proc "c" (self: ^List_Value) -> libc.int,

	///
	/// Returns true (1) if this object is currently owned by another object.
	///
	is_owned:       proc "c" (self: ^List_Value) -> libc.int,

	///
	/// Returns true (1) if the values of this object are read-only. Some APIs may
	/// expose read-only objects.
	///
	is_read_only:   proc "c" (self: ^List_Value) -> libc.int,

	///
	/// Returns true (1) if this object and |that| object have the same underlying
	/// data. If true (1) modifications to this object will also affect |that|
	/// object and vice-versa.
	///
	is_same:        proc "c" (self: ^List_Value, that: ^List_Value) -> libc.int,

	///
	/// Returns true (1) if this object and |that| object have an equivalent
	/// underlying value but are not necessarily the same object.
	///
	is_equal:       proc "c" (self: ^List_Value, that: ^List_Value) -> libc.int,

	///
	/// Returns a writable copy of this object.
	///
	copy:           proc "c" (self: ^List_Value) -> ^List_Value,

	///
	/// Sets the number of values. If the number of values is expanded all new
	/// value slots will default to type null. Returns true (1) on success.
	///
	set_size:       proc "c" (self: ^List_Value, size: libc.size_t) -> libc.int,

	///
	/// Returns the number of values.
	///
	get_size:       proc "c" (self: ^List_Value) -> libc.size_t,

	///
	/// Removes all values. Returns true (1) on success.
	///
	clear:          proc "c" (self: ^List_Value) -> libc.int,

	///
	/// Removes the value at the specified index.
	///
	remove:         proc "c" (self: ^List_Value, index: libc.size_t) -> libc.int,

	///
	/// Returns the value type at the specified index.
	///
	get_type:       proc "c" (self: ^List_Value, index: libc.size_t) -> Value_Type,

	///
	/// Returns the value at the specified index. For simple types the returned
	/// value will copy existing data and modifications to the value will not
	/// modify this object. For complex types (binary, dictionary and list) the
	/// returned value will reference existing data and modifications to the value
	/// will modify this object.
	///
	get_value:      proc "c" (self: ^List_Value, index: libc.size_t) -> ^Value,

	///
	/// Returns the value at the specified index as type bool.
	///
	get_bool:       proc "c" (self: ^List_Value, index: libc.size_t) -> libc.int,

	///
	/// Returns the value at the specified index as type int.
	///
	get_int:        proc "c" (self: ^List_Value, index: libc.size_t) -> libc.int,

	///
	/// Returns the value at the specified index as type double.
	///
	get_double:     proc "c" (self: ^List_Value, index: libc.size_t) -> libc.double,

	///
	/// Returns the value at the specified index as type string.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_string:     proc "c" (self: ^List_Value, index: libc.size_t) -> String_Userfree,

	///
	/// Returns the value at the specified index as type binary. The returned
	/// value will reference existing data.
	///
	get_binary:     proc "c" (self: ^List_Value, index: libc.size_t) -> ^Binary_Value,

	///
	/// Returns the value at the specified index as type dictionary. The returned
	/// value will reference existing data and modifications to the value will
	/// modify this object.
	///
	get_dictionary: proc "c" (self: ^List_Value, index: libc.size_t) -> ^Dictionary_Value,

	///
	/// Returns the value at the specified index as type list. The returned value
	/// will reference existing data and modifications to the value will modify
	/// this object.
	///
	get_list:       proc "c" (self: ^List_Value, index: libc.size_t) -> ^List_Value,

	///
	/// Sets the value at the specified index. Returns true (1) if the value was
	/// set successfully. If |value| represents simple data then the underlying
	/// data will be copied and modifications to |value| will not modify this
	/// object. If |value| represents complex data (binary, dictionary or list)
	/// then the underlying data will be referenced and modifications to |value|
	/// will modify this object.
	///
	set_value:      proc "c" (self: ^List_Value, index: libc.size_t, value: ^Value) -> libc.int,

	///
	/// Sets the value at the specified index as type null. Returns true (1) if
	/// the value was set successfully.
	///
	set_null:       proc "c" (self: ^List_Value, index: libc.size_t) -> libc.int,

	///
	/// Sets the value at the specified index as type bool. Returns true (1) if
	/// the value was set successfully.
	///
	set_bool:       proc "c" (self: ^List_Value, index: libc.size_t, value: libc.int) -> libc.int,

	///
	/// Sets the value at the specified index as type int. Returns true (1) if the
	/// value was set successfully.
	///
	set_int:        proc "c" (self: ^List_Value, index: libc.size_t, value: libc.int),

	///
	/// Sets the value at the specified index as type double. Returns true (1) if
	/// the value was set successfully.
	///
	set_double:     proc "c" (
		self: ^List_Value,
		index: libc.size_t,
		value: libc.double,
	) -> libc.int,

	///
	/// Sets the value at the specified index as type string. Returns true (1) if
	/// the value was set successfully.
	///
	set_string:     proc "c" (self: ^List_Value, index: libc.size_t, value: ^String) -> libc.int,

	///
	/// Sets the value at the specified index as type binary. Returns true (1) if
	/// the value was set successfully. If |value| is currently owned by another
	/// object then the value will be copied and the |value| reference will not
	/// change. Otherwise, ownership will be transferred to this object and the
	/// |value| reference will be invalidated.
	///
	set_binary:     proc "c" (
		self: ^List_Value,
		index: libc.size_t,
		value: ^Binary_Value,
	) -> libc.int,

	///
	/// Sets the value at the specified index as type dict. Returns true (1) if
	/// the value was set successfully. If |value| is currently owned by another
	/// object then the value will be copied and the |value| reference will not
	/// change. Otherwise, ownership will be transferred to this object and the
	/// |value| reference will be invalidated.
	///
	set_dictionary: proc "c" (
		self: ^List_Value,
		index: libc.size_t,
		value: ^Dictionary_Value,
	) -> libc.int,

	///
	/// Sets the value at the specified index as type list. Returns true (1) if
	/// the value was set successfully. If |value| is currently owned by another
	/// object then the value will be copied and the |value| reference will not
	/// change. Otherwise, ownership will be transferred to this object and the
	/// |value| reference will be invalidated.
	///
	set_list:       proc "c" (
		self: ^List_Value,
		index: libc.size_t,
		value: ^List_Value,
	) -> libc.int,
}

Value_Type :: enum {
	Invalid,
	Null,
	Bool,
	Int,
	Double,
	String,
	Binary,
	Dictionary,
	List,
}

Value :: struct {
	///
	/// Base structure.
	///
	base:           Base_Ref_Counted,

	///
	/// Returns true (1) if the underlying data is valid. This will always be true
	/// (1) for simple types. For complex types (binary, dictionary and list) the
	/// underlying data may become invalid if owned by another object (e.g. list
	/// or dictionary) and that other object is then modified or destroyed. This
	/// value object can be re-used by calling Set*() even if the underlying data
	/// is invalid.
	///
	is_valid:       proc "c" (self: ^Value) -> libc.int,

	///
	/// Returns true (1) if the underlying data is owned by another object.
	///
	is_owned:       proc "c" (self: ^Value) -> libc.int,

	///
	/// Returns true (1) if the underlying data is read-only. Some APIs may expose
	/// read-only objects.
	///
	is_read_only:   proc "c" (self: ^Value) -> libc.int,

	///
	/// Returns true (1) if this object and |that| object have the same underlying
	/// data. If true (1) modifications to this object will also affect |that|
	/// object and vice-versa.
	///
	is_same:        proc "c" (self: ^Value, that: ^Value) -> libc.int,

	///
	/// Returns true (1) if this object and |that| object have an equivalent
	/// underlying value but are not necessarily the same object.
	///
	is_equal:       proc "c" (self: ^Value, that: ^Value) -> libc.int,

	///
	/// Returns a copy of this object. The underlying data will also be copied.
	///
	copy:           proc "c" (self: ^Value) -> ^Value,

	///
	/// Returns the underlying value type.
	///
	get_type:       proc "c" (self: ^Value) -> Value_Type,

	///
	/// Returns the underlying value as type bool.
	///
	get_bool:       proc "c" (self: ^Value) -> libc.int,

	///
	/// Returns the underlying value as type int.
	///
	get_int:        proc "c" (self: ^Value) -> libc.int,

	///
	/// Returns the underlying value as type double.
	///
	get_double:     proc "c" (self: ^Value) -> libc.double,

	///
	/// Returns the underlying value as type string.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_string:     proc "c" (self: ^Value) -> String_Userfree,

	///
	/// Returns the underlying value as type binary. The returned reference may
	/// become invalid if the value is owned by another object or if ownership is
	/// transferred to another object in the future. To maintain a reference to
	/// the value after assigning ownership to a dictionary or list pass this
	/// object to the set_value() function instead of passing the returned
	/// reference to set_binary().
	///
	get_binary:     proc "c" (self: ^Value) -> ^Binary_Value,

	///
	/// Returns the underlying value as type dictionary. The returned reference
	/// may become invalid if the value is owned by another object or if ownership
	/// is transferred to another object in the future. To maintain a reference to
	/// the value after assigning ownership to a dictionary or list pass this
	/// object to the set_value() function instead of passing the returned
	/// reference to set_dictionary().
	///
	get_dictionary: proc "c" (self: ^Value) -> ^Dictionary_Value,

	///
	/// Returns the underlying value as type list. The returned reference may
	/// become invalid if the value is owned by another object or if ownership is
	/// transferred to another object in the future. To maintain a reference to
	/// the value after assigning ownership to a dictionary or list pass this
	/// object to the set_value() function instead of passing the returned
	/// reference to set_list().
	///
	get_list:       proc "c" (self: ^Value) -> ^List_Value,


	///
	/// Sets the underlying value as type null. Returns true (1) if the value was
	/// set successfully.
	///
	set_null:       proc "c" (self: ^Value) -> libc.int,


	///
	/// Sets the underlying value as type bool. Returns true (1) if the value was
	/// set successfully.
	///
	set_bool:       proc "c" (self: ^Value, value: libc.int) -> libc.int,


	///
	/// Sets the underlying value as type int. Returns true (1) if the value was
	/// set successfully.
	///
	set_int:        proc "c" (self: ^Value, value: libc.int) -> libc.int,

	///
	/// Sets the underlying value as type double. Returns true (1) if the value
	/// was set successfully.
	///
	set_double:     proc "c" (self: ^Value, value: libc.double) -> libc.int,

	///
	/// Sets the underlying value as type string. Returns true (1) if the value
	/// was set successfully.
	///
	set_string:     proc "c" (self: ^Value, value: ^String) -> libc.int,

	///
	/// Sets the underlying value as type binary. Returns true (1) if the value
	/// was set successfully. This object keeps a reference to |value| and
	/// ownership of the underlying data remains unchanged.
	///
	set_binary:     proc "c" (self: ^Value, value: ^Binary_Value) -> libc.int,

	///
	/// Sets the underlying value as type dict. Returns true (1) if the value was
	/// set successfully. This object keeps a reference to |value| and ownership
	/// of the underlying data remains unchanged.
	///
	set_dictionary: proc "c" (self: ^Value, value: ^Dictionary_Value) -> libc.int,

	///
	/// Sets the underlying value as type list. Returns true (1) if the value was
	/// set successfully. This object keeps a reference to |value| and ownership
	/// of the underlying data remains unchanged.
	///
	set_list:       proc "c" (self: ^Value, value: ^List_Value) -> libc.int,
}

Settings :: struct {
	///
	/// Size of this structure.
	///
	size:                                libc.size_t,
	///
	/// Set to true (1) to disable the sandbox for sub-processes. See
	/// cef_sandbox_win.h for requirements to enable the sandbox on Windows. Also
	/// configurable using the "no-sandbox" command-line switch.
	///
	no_sandbox:                          libc.int,
	///
	/// The path to a separate executable that will be launched for sub-processes.
	/// If this value is empty on Windows or Linux then the main process
	/// executable will be used. If this value is empty on macOS then a helper
	/// executable must exist at "Contents/Frameworks/<app>
	/// Helper.app/Contents/MacOS/<app> Helper" in the top-level app bundle. See
	/// the comments on CefExecuteProcess() for details. If this value is
	/// non-empty then it must be an absolute path. Also configurable using the
	/// "browser-subprocess-path" command-line switch.
	///
	browser_subprocess_path:             String,
	///
	/// The path to the CEF framework directory on macOS. If this value is empty
	/// then the framework must exist at "Contents/Frameworks/Chromium Embedded
	/// Framework.framework" in the top-level app bundle. If this value is
	/// non-empty then it must be an absolute path. Also configurable using the
	/// "framework-dir-path" command-line switch.
	///
	framework_dir_path:                  String,
	///
	/// The path to the main bundle on macOS. If this value is empty then it
	/// defaults to the top-level app bundle. If this value is non-empty then it
	/// must be an absolute path. Also configurable using the "main-bundle-path"
	/// command-line switch.
	///
	main_bundle_path:                    String,
	///
	/// Set to true (1) to have the browser process message loop run in a separate
	/// thread. If false (0) then the CefDoMessageLoopWork() function must be
	/// called from your application message loop. This option is only supported
	/// on Windows and Linux.
	///
	multi_threaded_message_loop:         libc.int,
	///
	/// Set to true (1) to control browser process main (UI) thread message pump
	/// scheduling via the CefBrowserProcessHandler::OnScheduleMessagePumpWork()
	/// callback. This option is recommended for use in combination with the
	/// CefDoMessageLoopWork() function in cases where the CEF message loop must
	/// be integrated into an existing application message loop (see additional
	/// comments and warnings on CefDoMessageLoopWork). Enabling this option is
	/// not recommended for most users; leave this option disabled and use either
	/// the CefRunMessageLoop() function or multi_threaded_message_loop if
	/// possible.
	///
	external_message_pump:               libc.int,
	///
	/// Set to true (1) to enable windowless (off-screen) rendering support. Do
	/// not enable this value if the application does not use windowless rendering
	/// as it may reduce rendering performance on some systems.
	///
	windowless_rendering_enabled:        libc.int,
	///
	/// Set to true (1) to disable configuration of browser process features using
	/// standard CEF and Chromium command-line arguments. Configuration can still
	/// be specified using CEF data structures or via the
	/// CefApp::OnBeforeCommandLineProcessing() method.
	///
	command_line_args_disabled:          libc.int,
	///
	/// The directory where data for the global browser cache will be stored on
	/// disk. If this value is non-empty then it must be an absolute path that is
	/// either equal to or a child directory of CefSettings.root_cache_path. If
	/// this value is empty then browsers will be created in "incognito mode"
	/// where in-memory caches are used for storage and no profile-specific data
	/// is persisted to disk (installation-specific data will still be persisted
	/// in root_cache_path). HTML5 databases such as localStorage will only
	/// persist across sessions if a cache path is specified. Can be overridden
	/// for individual CefRequestContext instances via the
	/// CefRequestContextSettings.cache_path value. Any child directory value will
	/// be ignored and the "default" profile (also a child directory) will be used
	/// instead.
	///
	cache_path:                          String,
	///
	/// The root directory for installation-specific data and the parent directory
	/// for profile-specific data. All CefSettings.cache_path and
	/// CefRequestContextSettings.cache_path values must have this parent
	/// directory in common. If this value is empty and CefSettings.cache_path is
	/// non-empty then it will default to the CefSettings.cache_path value. Any
	/// non-empty value must be an absolute path. If both values are empty then
	/// the default platform-specific directory will be used
	/// ("~/.config/cef_user_data" directory on Linux, "~/Library/Application
	/// Support/CEF/User Data" directory on MacOS, "AppData\Local\CEF\User Data"
	/// directory under the user profile directory on Windows). Use of the default
	/// directory is not recommended in production applications (see below).
	///
	/// Multiple application instances writing to the same root_cache_path
	/// directory could result in data corruption. A process singleton lock based
	/// on the root_cache_path value is therefore used to protect against this.
	/// This singleton behavior applies to all CEF-based applications using
	/// version 120 or newer. You should customize root_cache_path for your
	/// application and implement CefBrowserProcessHandler::
	/// OnAlreadyRunningAppRelaunch, which will then be called on any app relaunch
	/// with the same root_cache_path value.
	///
	/// Failure to set the root_cache_path value correctly may result in startup
	/// crashes or other unexpected behaviors (for example, the sandbox blocking
	/// read/write access to certain files).
	///
	root_cache_path:                     String,
	///
	/// To persist session cookies (cookies without an expiry date or validity
	/// interval) by default when using the global cookie manager set this value
	/// to true (1). Session cookies are generally intended to be transient and
	/// most Web browsers do not persist them. A |cache_path| value must also be
	/// specified to enable this feature. Also configurable using the
	/// "persist-session-cookies" command-line switch. Can be overridden for
	/// individual CefRequestContext instances via the
	/// CefRequestContextSettings.persist_session_cookies value.
	///
	persist_session_cookies:             libc.int,
	///
	/// Value that will be returned as the User-Agent HTTP header. If empty the
	/// default User-Agent string will be used. Also configurable using the
	/// "user-agent" command-line switch.
	///
	user_agent:                          String,
	///
	/// Value that will be inserted as the product portion of the default
	/// User-Agent string. If empty the Chromium product version will be used. If
	/// |userAgent| is specified this value will be ignored. Also configurable
	/// using the "user-agent-product" command-line switch.
	///
	user_agent_product:                  String,
	///
	/// The locale string that will be passed to WebKit. If empty the default
	/// locale of "en-US" will be used. This value is ignored on Linux where
	/// locale is determined using environment variable parsing with the
	/// precedence order: LANGUAGE, LC_ALL, LC_MESSAGES and LANG. Also
	/// configurable using the "lang" command-line switch.
	///
	locale:                              String,
	///
	/// The directory and file name to use for the debug log. If empty a default
	/// log file name and location will be used. On Windows and Linux a
	/// "debug.log" file will be written in the main executable directory. On
	/// MacOS a "~/Library/Logs/[app name]_debug.log" file will be written where
	/// [app name] is the name of the main app executable. Also configurable using
	/// the "log-file" command-line switch.
	///
	log_file:                            String,
	///
	/// The log severity. Only messages of this severity level or higher will be
	/// logged. When set to DISABLE no messages will be written to the log file,
	/// but FATAL messages will still be output to stderr. Also configurable using
	/// the "log-severity" command-line switch with a value of "verbose", "info",
	/// "warning", "error", "fatal" or "disable".
	///
	log_severity:                        Log_Severity,
	///
	/// The log items prepended to each log line. If not set the default log items
	/// will be used. Also configurable using the "log-items" command-line switch
	/// with a value of "none" for no log items, or a comma-delimited list of
	/// values "pid", "tid", "timestamp" or "tickcount" for custom log items.
	///
	log_items:                           Log_Items,
	///
	/// Custom flags that will be used when initializing the V8 JavaScript engine.
	/// The consequences of using custom flags may not be well tested. Also
	/// configurable using the "js-flags" command-line switch.
	///
	javascript_flags:                    String,
	///
	/// The fully qualified path for the resources directory. If this value is
	/// empty the *.pak files must be located in the module directory on
	/// Windows/Linux or the app bundle Resources directory on MacOS. If this
	/// value is non-empty then it must be an absolute path. Also configurable
	/// using the "resources-dir-path" command-line switch.
	///
	resources_dir_path:                  String,
	///
	/// The fully qualified path for the locales directory. If this value is empty
	/// the locales directory must be located in the module directory. If this
	/// value is non-empty then it must be an absolute path. This value is ignored
	/// on MacOS where pack files are always loaded from the app bundle Resources
	/// directory. Also configurable using the "locales-dir-path" command-line
	/// switch.
	///
	locales_dir_path:                    String,
	///
	/// Set to a value between 1024 and 65535 to enable remote debugging on the
	/// specified port. Also configurable using the "remote-debugging-port"
	/// command-line switch. Specifying 0 via the command-line switch will result
	/// in the selection of an ephemeral port and the port number will be printed
	/// as part of the WebSocket endpoint URL to stderr. If a cache directory path
	/// is provided the port will also be written to the
	/// <cache-dir>/DevToolsActivePort file. Remote debugging can be accessed by
	/// loading the chrome://inspect page in Google Chrome. Port numbers 9222 and
	/// 9229 are discoverable by default. Other port numbers may need to be
	/// configured via "Discover network targets" on the Devices tab.
	///
	remote_debugging_port:               libc.int,
	///
	/// The number of stack trace frames to capture for uncaught exceptions.
	/// Specify a positive value to enable the
	/// CefRenderProcessHandler::OnUncaughtException() callback. Specify 0
	/// (default value) and OnUncaughtException() will not be called. Also
	/// configurable using the "uncaught-exception-stack-size" command-line
	/// switch.
	///
	uncaught_exception_stack_size:       libc.int,
	///
	/// Background color used for the browser before a document is loaded and when
	/// no document color is specified. The alpha component must be either fully
	/// opaque (0xFF) or fully transparent (0x00). If the alpha component is fully
	/// opaque then the RGB components will be used as the background color. If
	/// the alpha component is fully transparent for a windowed browser then the
	/// default value of opaque white be used. If the alpha component is fully
	/// transparent for a windowless (off-screen) browser then transparent
	/// painting will be enabled.
	///
	background_color:                    Color,
	///
	/// Comma delimited ordered list of language codes without any whitespace that
	/// will be used in the "Accept-Language" HTTP request header and
	/// "navigator.language" JS attribute. Can be overridden for individual
	/// CefRequestContext instances via the
	/// CefRequestContextSettings.accept_language_list value.
	///
	accept_language_list:                String,
	///
	/// Comma delimited list of schemes supported by the associated
	/// CefCookieManager. If |cookieable_schemes_exclude_defaults| is false (0)
	/// the default schemes ("http", "https", "ws" and "wss") will also be
	/// supported. Not specifying a |cookieable_schemes_list| value and setting
	/// |cookieable_schemes_exclude_defaults| to true (1) will disable all loading
	/// and saving of cookies. These settings will only impact the global
	/// CefRequestContext. Individual CefRequestContext instances can be
	/// configured via the CefRequestContextSettings.cookieable_schemes_list and
	/// CefRequestContextSettings.cookieable_schemes_exclude_defaults values.
	///
	cookieable_schemes_list:             String,
	cookieable_schemes_exclude_defaults: libc.int,
	///
	/// Specify an ID to enable Chrome policy management via Platform and OS-user
	/// policies. On Windows, this is a registry key like
	/// "SOFTWARE\\Policies\\Google\\Chrome". On MacOS, this is a bundle ID like
	/// "com.google.Chrome". On Linux, this is an absolute directory path like
	/// "/etc/opt/chrome/policies". Only supported with Chrome style. See
	/// https://support.google.com/chrome/a/answer/9037717 for details.
	///
	/// Chrome Browser Cloud Management integration, when enabled via the
	/// "enable-chrome-browser-cloud-management" command-line flag, will also use
	/// the specified ID. See https://support.google.com/chrome/a/answer/9116814
	/// for details.
	///
	chrome_policy_id:                    String,
	///
	/// Specify an ID for an ICON resource that can be loaded from the main
	/// executable and used when creating default Chrome windows such as DevTools
	/// and Task Manager. If unspecified the default Chromium ICON (IDR_MAINFRAME
	/// [101]) will be loaded from libcef.dll. Only supported with Chrome style on
	/// Windows.
	///
	chrome_app_icon_id:                  libc.int,
	///
	/// Specify whether signal handlers must be disabled on POSIX systems.
	///
	disable_signal_handlers:             libc.int,
}

Main_Args :: struct {
	instance: windows.HINSTANCE,
}

Base_Ref_Counted :: struct {
	size:                 libc.size_t,
	add_ref:              proc "c" (_: ^Base_Ref_Counted),
	release:              proc "c" (_: ^Base_Ref_Counted) -> libc.int,
	has_one_ref:          proc "c" (_: ^Base_Ref_Counted) -> libc.int,
	has_at_least_one_ref: proc "c" (_: ^Base_Ref_Counted) -> libc.int,
}

Base_Scoped :: struct {
	size: libc.size_t,
	del:  proc "c" (self: ^Base_Scoped),
}

Scheme_Registrar :: struct {
	base:              Base_Scoped,
	add_custom_scheme: proc "c" (
		self: ^Scheme_Registrar,
		scheme_name: ^String,
		options: libc.int,
	) -> libc.int,
}

Resource_Bundle_Handler :: struct {
	base:                 Base_Ref_Counted,
	get_localized_string: proc "c" (_: ^Resource_Bundle_Handler, _: libc.int, _: ^String),
}

Browser_Process_Handler :: struct {
	///
	/// Base structure.
	///
	base:                                Base_Ref_Counted,

	///
	/// Provides an opportunity to register custom preferences prior to global and
	/// request context initialization.
	///
	/// If |type| is CEF_PREFERENCES_TYPE_GLOBAL the registered preferences can be
	/// accessed via cef_preference_manager_t::GetGlobalPreferences after
	/// OnContextInitialized is called. Global preferences are registered a single
	/// time at application startup. See related cef_settings_t.cache_path
	/// configuration.
	///
	/// If |type| is CEF_PREFERENCES_TYPE_REQUEST_CONTEXT the preferences can be
	/// accessed via the cef_request_context_t after
	/// cef_request_context_handler_t::OnRequestContextInitialized is called.
	/// Request context preferences are registered each time a new
	/// cef_request_context_t is created. It is intended but not required that all
	/// request contexts have the same registered preferences. See related
	/// cef_request_context_settings_t.cache_path configuration.
	///
	/// Do not keep a reference to the |registrar| object. This function is called
	/// on the browser process UI thread.
	///
	on_register_custom_preferences:      proc "c" (
		self: ^Browser_Process_Handler,
		type: Preferences_Type,
		registrar: ^Preference_Registrar,
	),

	///
	/// Called on the browser process UI thread immediately after the CEF context
	/// has been initialized.
	///
	on_context_initialized:              proc "c" (self: ^Browser_Process_Handler),

	///
	/// Called before a child process is launched. Will be called on the browser
	/// process UI thread when launching a render process and on the browser
	/// process IO thread when launching a GPU process. Provides an opportunity to
	/// modify the child process command line. Do not keep a reference to
	/// |command_line| outside of this function.
	///
	on_before_child_process_launch:      proc "c" (
		self: ^Browser_Process_Handler,
		command_line: ^Command_Line,
	),

	///
	/// Implement this function to provide app-specific behavior when an already
	/// running app is relaunched with the same CefSettings.root_cache_path value.
	/// For example, activate an existing app window or create a new app window.
	/// |command_line| will be read-only. Do not keep a reference to
	/// |command_line| outside of this function. Return true (1) if the relaunch
	/// is handled or false (0) for default relaunch behavior. Default behavior
	/// will create a new default styled Chrome window.
	///
	/// To avoid cache corruption only a single app instance is allowed to run for
	/// a given CefSettings.root_cache_path value. On relaunch the app checks a
	/// process singleton lock and then forwards the new launch arguments to the
	/// already running app process before exiting early. Client apps should
	/// therefore check the cef_initialize() return value for early exit before
	/// proceeding.
	///
	/// This function will be called on the browser process UI thread.
	///
	on_already_running_app_relaunch:     proc "c" (
		self: ^Browser_Process_Handler,
		command_line: ^Command_Line,
		current_directory: ^String,
	) -> libc.int,

	///
	/// Called from any thread when work has been scheduled for the browser
	/// process main (UI) thread. This callback is used in combination with
	/// cef_settings_t.external_message_pump and cef_do_message_loop_work() in
	/// cases where the CEF message loop must be integrated into an existing
	/// application message loop (see additional comments and warnings on
	/// CefDoMessageLoopWork). This callback should schedule a
	/// cef_do_message_loop_work() call to happen on the main (UI) thread.
	/// |delay_ms| is the requested delay in milliseconds. If |delay_ms| is <= 0
	/// then the call should happen reasonably soon. If |delay_ms| is > 0 then the
	/// call should be scheduled to happen after the specified delay and any
	/// currently pending scheduled call should be cancelled.
	///
	on_schedule_message_pump_work:       proc "c" (
		self: ^Browser_Process_Handler,
		delay_ms: libc.int64_t,
	),

	///
	/// Return the default client for use with a newly created browser window
	/// (cef_browser_t object). If null is returned the cef_browser_t will be
	/// unmanaged (no callbacks will be executed for that cef_browser_t) and
	/// application shutdown will be blocked until the browser window is closed
	/// manually. This function is currently only used with Chrome style when
	/// creating new browser windows via Chrome UI.
	///
	get_default_client:                  proc "c" (self: ^Browser_Process_Handler) -> ^Client,

	///
	/// Return the default handler for use with a new user or incognito profile
	/// (cef_request_context_t object). If null is returned the
	/// cef_request_context_t will be unmanaged (no callbacks will be executed for
	/// that cef_request_context_t). This function is currently only used with
	/// Chrome style when creating new browser windows via Chrome UI.
	///
	get_default_request_context_handler: proc "c" (
		self: ^Browser_Process_Handler,
	) -> ^Request_Context_Handler,
}

Request_Context_Handler :: struct {
	///
	/// Base structure.
	///
	base:                           Base_Ref_Counted,

	///
	/// Called on the browser process UI thread immediately after the request
	/// context has been initialized.
	///
	on_request_context_initialized: proc "c" (
		self: ^Request_Context_Handler,
		request_context: ^Request_Context,
	),

	///
	/// Called on the browser process IO thread before a resource request is
	/// initiated. The |browser| and |frame| values represent the source of the
	/// request, and may be NULL for requests originating from service workers or
	/// cef_urlrequest_t. |request| represents the request contents and cannot be
	/// modified in this callback. |is_navigation| will be true (1) if the
	/// resource request is a navigation. |is_download| will be true (1) if the
	/// resource request is a download. |request_initiator| is the origin (scheme
	/// + domain) of the page that initiated the request. Set
	/// |disable_default_handling| to true (1) to disable default handling of the
	/// request, in which case it will need to be handled via
	/// cef_resource_request_handler_t::GetResourceHandler or it will be canceled.
	/// To allow the resource load to proceed with default handling return NULL.
	/// To specify a handler for the resource return a
	/// cef_resource_request_handler_t object. This function will not be called if
	/// the client associated with |browser| returns a non-NULL value from
	/// cef_request_handler_t::GetResourceRequestHandler for the same request
	/// (identified by cef_request_t::GetIdentifier).
	///
	get_resource_request_handler:   proc "c" (
		self: ^Request_Context_Handler,
		browser: ^Browser,
		frame: ^Frame,
		request: ^Request,
		is_navigation: libc.int,
		is_download: libc.int,
		request_initiator: ^String,
		disable_default_handling: ^libc.int,
	) -> ^Resource_Request_Handler,
}

Cookie_Access_Filter :: struct {
	base: Base_Ref_Counted,
}

Callback :: struct {
	base: Base_Ref_Counted,
}

Resource_Handler :: struct {
	base: Base_Ref_Counted,
}

Return_Value :: struct {
	base: Base_Ref_Counted,
}

Resource_Request_Handler :: struct {
	///
	/// Base structure.
	///
	base:                         Base_Ref_Counted,

	///
	/// Called on the IO thread before a resource request is loaded. The |browser|
	/// and |frame| values represent the source of the request, and may be NULL
	/// for requests originating from service workers or cef_urlrequest_t. To
	/// optionally filter cookies for the request return a
	/// cef_cookie_access_filter_t object. The |request| object cannot not be
	/// modified in this callback.
	///
	get_cookie_access_filter:     proc "c" (
		self: ^Resource_Request_Handler,
		browser: ^Browser,
		frame: ^Frame,
		request: ^Request,
	) -> ^Cookie_Access_Filter,

	///
	/// Called on the IO thread before a resource request is loaded. The |browser|
	/// and |frame| values represent the source of the request, and may be NULL
	/// for requests originating from service workers or cef_urlrequest_t. To
	/// redirect or change the resource load optionally modify |request|.
	/// Modification of the request URL will be treated as a redirect. Return
	/// RV_CONTINUE to continue the request immediately. Return RV_CONTINUE_ASYNC
	/// and call cef_callback_t functions at a later time to continue or cancel
	/// the request asynchronously. Return RV_CANCEL to cancel the request
	/// immediately.
	///
	on_before_resource_load:      proc "c" (
		self: ^Resource_Request_Handler,
		browser: ^Browser,
		frame: ^Frame,
		request: ^Request,
		callback: ^Callback,
	) -> Return_Value,

	///
	/// Called on the IO thread before a resource is loaded. The |browser| and
	/// |frame| values represent the source of the request, and may be NULL for
	/// requests originating from service workers or cef_urlrequest_t. To allow
	/// the resource to load using the default network loader return NULL. To
	/// specify a handler for the resource return a cef_resource_handler_t object.
	/// The |request| object cannot not be modified in this callback.
	///
	get_resource_handler:         proc "c" (
		self: ^Resource_Request_Handler,
		browser: ^Browser,
		frame: ^Frame,
		request: ^Request,
	) -> ^Resource_Handler,

	///
	/// Called on the IO thread when a resource load is redirected. The |browser|
	/// and |frame| values represent the source of the request, and may be NULL
	/// for requests originating from service workers or cef_urlrequest_t. The
	/// |request| parameter will contain the old URL and other request-related
	/// information. The |response| parameter will contain the response that
	/// resulted in the redirect. The |new_url| parameter will contain the new URL
	/// and can be changed if desired. The |request| and |response| objects cannot
	/// be modified in this callback.
	///
	on_resource_redirect:         proc "c" (
		self: ^Resource_Request_Handler,
		browser: ^Browser,
		frame: ^Frame,
		request: ^Request,
		response: ^Response,
		new_url: ^String,
	),

	///
	/// Called on the IO thread when a resource response is received. The
	/// |browser| and |frame| values represent the source of the request, and may
	/// be NULL for requests originating from service workers or cef_urlrequest_t.
	/// To allow the resource load to proceed without modification return false
	/// (0). To redirect or retry the resource load optionally modify |request|
	/// and return true (1). Modification of the request URL will be treated as a
	/// redirect. Requests handled using the default network loader cannot be
	/// redirected in this callback. The |response| object cannot be modified in
	/// this callback.
	///
	/// WARNING: Redirecting using this function is deprecated. Use
	/// OnBeforeResourceLoad or GetResourceHandler to perform redirects.
	///
	on_resource_response:         proc "c" (
		self: ^Resource_Request_Handler,
		browser: ^Browser,
		frame: ^Frame,
		request: ^Request,
		response: ^Response,
	) -> libc.int,

	///
	/// Called on the IO thread to optionally filter resource response content.
	/// The |browser| and |frame| values represent the source of the request, and
	/// may be NULL for requests originating from service workers or
	/// cef_urlrequest_t. |request| and |response| represent the request and
	/// response respectively and cannot be modified in this callback.
	///
	get_resource_response_filter: proc "c" (
		self: ^Resource_Request_Handler,
		browser: ^Browser,
		frame: ^Frame,
		request: ^Request,
		response: ^Response,
	) -> ^Response_Filter,

	///
	/// Called on the IO thread when a resource load has completed. The |browser|
	/// and |frame| values represent the source of the request, and may be NULL
	/// for requests originating from service workers or cef_urlrequest_t.
	/// |request| and |response| represent the request and response respectively
	/// and cannot be modified in this callback. |status| indicates the load
	/// completion status. |received_content_length| is the number of response
	/// bytes actually read. This function will be called for all requests,
	/// including requests that are aborted due to CEF shutdown or destruction of
	/// the associated browser. In cases where the associated browser is destroyed
	/// this callback may arrive after the cef_life_span_handler_t::OnBeforeClose
	/// callback for that browser. The cef_frame_t::IsValid function can be used
	/// to test for this situation, and care should be taken not to call |browser|
	/// or |frame| functions that modify state (like LoadURL, SendProcessMessage,
	/// etc.) if the frame is invalid.
	///
	on_resource_load_complete:    proc "c" (
		self: ^Render_Process_Handler,
		browser: ^Browser,
		frame: ^Frame,
		request: ^Request,
		response: ^Response,
		status: URLRequest_Status,
		received_content_length: libc.int64_t,
	),

	///
	/// Called on the IO thread to handle requests for URLs with an unknown
	/// protocol component. The |browser| and |frame| values represent the source
	/// of the request, and may be NULL for requests originating from service
	/// workers or cef_urlrequest_t. |request| cannot be modified in this
	/// callback. Set |allow_os_execution| to true (1) to attempt execution via
	/// the registered OS protocol handler, if any. SECURITY WARNING: YOU SHOULD
	/// USE THIS METHOD TO ENFORCE RESTRICTIONS BASED ON SCHEME, HOST OR OTHER URL
	/// ANALYSIS BEFORE ALLOWING OS EXECUTION.
	///
	on_protocol_execution:        proc "c" (
		self: ^Render_Process_Handler,
		browser: ^Browser,
		frame: ^Frame,
		request: ^Request,
		allow_os_execution: ^libc.int,
	),
}

URLRequest_Status :: enum {
	Unknown,
	Success,
	IO_Pending,
	Canceled,
	Failed,
}

Response_Filter :: struct {
	base: Base_Ref_Counted,
}

Response :: struct {
	base: Base_Ref_Counted,
}

Request :: struct {
	base: Base_Ref_Counted,
}

Render_Process_Handler :: struct {
	///
	/// Base structure.
	///
	base:                        Base_Ref_Counted,

	///
	/// Called after WebKit has been initialized.
	///
	on_web_kit_initialized:      proc "c" (self: ^Render_Process_Handler),

	///
	/// Called after a browser has been created. When browsing cross-origin a new
	/// browser will be created before the old browser with the same identifier is
	/// destroyed. |extra_info| is an optional read-only value originating from
	/// cef_browser_host_t::cef_browser_host_create_browser(),
	/// cef_browser_host_t::cef_browser_host_create_browser_sync(),
	/// cef_life_span_handler_t::on_before_popup() or
	/// cef_browser_view_t::cef_browser_view_create().
	///
	on_browser_created:          proc "c" (
		self: ^Render_Process_Handler,
		browser: ^Browser,
		extra_info: ^Dictionary_Value,
	),

	///
	/// Called before a browser is destroyed.
	///
	on_browser_destroyed:        proc "c" (self: ^Render_Process_Handler, browser: ^Browser),

	///
	/// Return the handler for browser load status events.
	///
	get_load_handler:            proc "c" (self: ^Render_Process_Handler) -> ^Load_Handler,

	///
	/// Called immediately after the V8 context for a frame has been created. To
	/// retrieve the JavaScript 'window' object use the
	/// cef_v8_context_t::get_global() function. V8 handles can only be accessed
	/// from the thread on which they are created. A task runner for posting tasks
	/// on the associated thread can be retrieved via the
	/// cef_v8_context_t::get_task_runner() function.
	///
	on_context_created:          proc "c" (
		self: ^Render_Process_Handler,
		browser: ^Browser,
		frame: ^Frame,
		ctx: ^V8_Context,
	),

	///
	/// Called immediately before the V8 context for a frame is released. No
	/// references to the context should be kept after this function is called.
	///
	on_context_released:         proc "c" (
		self: ^Render_Process_Handler,
		browser: ^Browser,
		frame: ^Frame,
		ctx: ^V8_Context,
	),

	///
	/// Called for global uncaught exceptions in a frame. Execution of this
	/// callback is disabled by default. To enable set
	/// cef_settings_t.uncaught_exception_stack_size > 0.
	///
	on_uncaught_exception:       proc "c" (
		self: ^Render_Process_Handler,
		browser: ^Browser,
		frame: ^Frame,
		ctx: ^V8_Context,
		exception: ^V8_Exception,
		stackTrace: ^V8_Stack_Trace,
	),

	///
	/// Called when a new node in the the browser gets focus. The |node| value may
	/// be NULL if no specific node has gained focus. The node object passed to
	/// this function represents a snapshot of the DOM at the time this function
	/// is executed. DOM objects are only valid for the scope of this function. Do
	/// not keep references to or attempt to access any DOM objects outside the
	/// scope of this function.
	///
	on_focused_node_changed:     proc "c" (
		self: ^Render_Process_Handler,
		browser: ^Browser,
		frame: ^Frame,
		node: ^Domnode,
	),

	///
	/// Called when a new message is received from a different process. Return
	/// true (1) if the message was handled or false (0) otherwise. It is safe to
	/// keep a reference to |message| outside of this callback.
	///
	on_process_message_received: proc "c" (
		self: ^Render_Process_Handler,
		browser: ^Browser,
		frame: ^Frame,
		source_process: Process_ID,
		message: ^Process_Message,
	),
}

App :: struct {
	base:                              Base_Ref_Counted,
	on_before_command_line_processing: proc "c" (_: ^App, _: ^String, _: ^Command_Line),
	on_register_custom_schemes:        proc "c" (_: ^App, _: ^Scheme_Registrar),
	get_resource_bundle_handler:       proc "c" (_: ^App) -> ^Resource_Bundle_Handler,
	get_browser_process_handler:       proc "c" (_: ^App) -> ^Browser_Process_Handler,
	get_render_process_handler:        proc "c" (_: ^App) -> ^Render_Process_Handler,
}

Window_Info :: struct {
	size:                         libc.size_t,
	ex_style:                     windows.DWORD,
	window_name:                  String,
	style:                        windows.DWORD,
	bounds:                       Rect,
	parent_window:                Window_Handle,
	menu:                         windows.HMENU,
	windowless_rendering_enabled: libc.int,
	shared_texture_enabled:       libc.int,
	external_begin_frame_enabled: libc.int,
	window:                       Window_Handle,
	runtime_style:                Runtime_Style,
}

Browser_Settings :: struct {
	///
	/// Size of this structure.
	///
	size:                           libc.size_t,

	///
	/// The maximum rate in frames per second (fps) that CefRenderHandler::OnPaint
	/// will be called for a windowless browser. The actual fps may be lower if
	/// the browser cannot generate frames at the requested rate. The minimum
	/// value is 1 and the maximum value is 60 (default 30). This value can also
	/// be changed dynamically via CefBrowserHost::SetWindowlessFrameRate.
	///
	windowless_frame_rate:          libc.int,

	/// BEGIN values that map to WebPreferences settings.

	///
	/// Font settings.
	///
	standard_font_family:           String,
	fixed_font_family:              String,
	serif_font_family:              String,
	sans_serif_font_family:         String,
	cursive_font_family:            String,
	fantasy_font_family:            String,
	default_font_size:              libc.int,
	default_fixed_font_size:        libc.int,
	minimum_font_size:              libc.int,
	minimum_logical_font_size:      libc.int,

	///
	/// Default encoding for Web content. If empty "ISO-8859-1" will be used. Also
	/// configurable using the "default-encoding" command-line switch.
	///
	default_encoding:               String,

	///
	/// Controls the loading of fonts from remote sources. Also configurable using
	/// the "disable-remote-fonts" command-line switch.
	///
	remote_fonts:                   State,

	///
	/// Controls whether JavaScript can be executed. Also configurable using the
	/// "disable-javascript" command-line switch.
	///
	javascript:                     State,

	///
	/// Controls whether JavaScript can be used to close windows that were not
	/// opened via JavaScript. JavaScript can still be used to close windows that
	/// were opened via JavaScript or that have no back/forward history. Also
	/// configurable using the "disable-javascript-close-windows" command-line
	/// switch.
	///
	javascript_close_windows:       State,

	///
	/// Controls whether JavaScript can access the clipboard. Also configurable
	/// using the "disable-javascript-access-clipboard" command-line switch.
	///
	javascript_access_clipboard:    State,

	///
	/// Controls whether DOM pasting is supported in the editor via
	/// execCommand("paste"). The |javascript_access_clipboard| setting must also
	/// be enabled. Also configurable using the "disable-javascript-dom-paste"
	/// command-line switch.
	///
	javascript_dom_paste:           State,

	///
	/// Controls whether image URLs will be loaded from the network. A cached
	/// image will still be rendered if requested. Also configurable using the
	/// "disable-image-loading" command-line switch.
	///
	image_loading:                  State,

	///
	/// Controls whether standalone images will be shrunk to fit the page. Also
	/// configurable using the "image-shrink-standalone-to-fit" command-line
	/// switch.
	///
	image_shrink_standalone_to_fit: State,

	///
	/// Controls whether text areas can be resized. Also configurable using the
	/// "disable-text-area-resize" command-line switch.
	///
	text_area_resize:               State,

	///
	/// Controls whether the tab key can advance focus to links. Also configurable
	/// using the "disable-tab-to-links" command-line switch.
	///
	tab_to_links:                   State,

	///
	/// Controls whether local storage can be used. Also configurable using the
	/// "disable-local-storage" command-line switch.
	///
	local_storage:                  State,

	///
	/// Controls whether databases can be used. Also configurable using the
	/// "disable-databases" command-line switch.
	///
	databases:                      State,

	///
	/// Controls whether WebGL can be used. Note that WebGL requires hardware
	/// support and may not work on all systems even when enabled. Also
	/// configurable using the "disable-webgl" command-line switch.
	///
	webgl:                          State,

	/// END values that map to WebPreferences settings.

	///
	/// Background color used for the browser before a document is loaded and when
	/// no document color is specified. The alpha component must be either fully
	/// opaque (0xFF) or fully transparent (0x00). If the alpha component is fully
	/// opaque then the RGB components will be used as the background color. If
	/// the alpha component is fully transparent for a windowed browser then the
	/// CefSettings.background_color value will be used. If the alpha component is
	/// fully transparent for a windowless (off-screen) browser then transparent
	/// painting will be enabled.
	///
	background_color:               Color,

	///
	/// Controls whether the Chrome status bubble will be used. Only supported
	/// with Chrome style. For details about the status bubble see
	/// https://www.chromium.org/user-experience/status-bubble/
	///
	chrome_status_bubble:           State,

	///
	/// Controls whether the Chrome zoom bubble will be shown when zooming. Only
	/// supported with Chrome style.
	///
	chrome_zoom_bubble:             State,
}

String_List :: rawptr
String_Map :: rawptr

String_Userfree :: ^String

Command_Line :: struct {
	base:                     Base_Ref_Counted,
	is_valid:                 proc "c" (self: ^Command_Line) -> libc.int,
	is_read_only:             proc "c" (self: ^Command_Line) -> libc.int,
	copy:                     proc "c" (self: ^Command_Line) -> ^Command_Line,
	init_from_argv:           proc "c" (self: ^Command_Line, argc: libc.int, argv: [^]cstring),
	init_from_string:         proc "c" (self: ^Command_Line, command_line: ^String),
	reset:                    proc "c" (self: ^Command_Line),
	get_argv:                 proc "c" (self: ^Command_Line, argv: String_List),
	get_command_line_string:  proc "c" (self: ^Command_Line) -> String_Userfree,
	get_program:              proc "c" (self: ^Command_Line) -> String_Userfree,
	set_program:              proc "c" (self: ^Command_Line, program: ^String),
	has_switches:             proc "c" (self: ^Command_Line) -> libc.int,
	has_switch:               proc "c" (self: ^Command_Line, name: ^String) -> libc.int,
	get_switch_value:         proc "c" (self: ^Command_Line, name: ^String) -> String_Userfree,
	get_switches:             proc "c" (self: ^Command_Line, switches: String_Map),
	append_switch:            proc "c" (self: ^Command_Line, name: ^String),
	append_switch_with_value: proc "c" (self: ^Command_Line, name, value: ^String),
	has_arguments:            proc "c" (self: ^Command_Line) -> libc.int,
	get_arguments:            proc "c" (self: ^Command_Line, arguments: String_List),
	append_argument:          proc "c" (self: ^Command_Line, argument: ^String),
	prepend_wrapper:          proc "c" (self: ^Command_Line, wrapper: ^String),
}

Dictionary_Value :: struct {
}

Request_Context :: struct {
	base: Base_Ref_Counted,
}

@(link_prefix = "cef_")
foreign cef {
	initialize :: proc(args: ^Main_Args, settings: ^Settings, application: ^App, windows_sandbox_info: rawptr) -> libc.int ---
	execute_process :: proc(args: ^Main_Args, application: ^App, windows_sandbox_info: rawptr) -> libc.int ---
	api_version :: proc() -> libc.int ---
	api_hash :: proc(version, entry: libc.int) -> cstring ---
	get_exit_code :: proc() ---
	do_message_loop_work :: proc() ---
	run_message_loop :: proc() ---
	quit_message_loop :: proc() ---
	shutdown :: proc() ---

	command_line_create :: proc() -> ^Command_Line ---
	command_line_get_global :: proc() -> ^Command_Line ---

	string_wide_set :: proc(src: [^]libc.wchar_t, src_len: libc.size_t, output: ^String_Wide, copy: libc.int) -> libc.int ---
	string_utf8_set :: proc(src: [^]libc.char, src_len: libc.size_t, output: ^String_UTF8, copy: libc.int) -> libc.int ---
	string_utf16_set :: proc(src: [^]libc.char16_t, src_len: libc.size_t, output: ^String_UTF16, copy: libc.int) -> libc.int ---

	// string_wide_to_utf8 :: proc(src: [^]libc.wchar_t, src_len: libc.size_t, output: ^String_UTF8) -> libc.int ---
	//
	v8_value_create_string :: proc(value: ^String) -> ^V8_Value ---
	v8_value_create_int :: proc(value: libc.int32_t) -> ^V8_Value ---
	v8_value_create_uint :: proc(value: libc.uint32_t) -> ^V8_Value ---
	v8_value_create_double :: proc(value: libc.double) -> ^V8_Value ---
	v8_value_create_date :: proc(value: Basetime) -> ^V8_Value ---

	request_context_get_global_context :: proc() -> ^Request_Context ---

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

to_odin_string :: proc(s: ^String, allocator := context.allocator) -> string {
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

