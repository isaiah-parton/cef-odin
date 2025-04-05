package cef

import "core:c"
import "core:math"
import "core:sys/windows"

_String :: struct($T: typeid) {
	str:    [^]T,
	length: c.size_t,
	dtor:   proc "c" (_: [^]T),
}

String :: distinct _String(c.uint16_t)

String_Wide :: _String(c.wchar_t)
String_UTF8 :: _String(c.char)
String_UTF16 :: _String(c.uint16_t)

Errorcode :: enum c.int {
	None,
}

Window_Handle :: windows.HWND

Color :: c.uint32_t

State :: enum c.int {
	Default,
	Enabled,
	Disabled,
}

Log_Severity :: enum c.int {
	Default,
	Verbose,
	Debug = Verbose,
	Info,
	Warning,
	Error,
	Fatal,
	Disable = 99,
}

Log_Items :: enum c.int {
	Default,
	None,
	Flag_Process_ID = 1 << 1,
	Flag_Thread_ID = 1 << 2,
	Flag_Time_Stamp = 1 << 3,
	Flag_Tick_Count = 1 << 4,
}

Runtime_Style :: enum c.int {
	Default,
	Chrome,
	Alloy,
}

Rect :: struct {
	x:      c.int,
	y:      c.int,
	width:  c.int,
	height: c.int,
}

Size :: struct {
	width:  c.int,
	height: c.int,
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
	) -> c.int,
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
	is_valid:     proc "c" (self: ^Binary_Value) -> c.int,

	///
	/// Returns true (1) if this object is currently owned by another object.
	///
	is_owned:     proc "c" (self: ^Binary_Value) -> c.int,

	///
	/// Returns true (1) if this object and |that| object have the same underlying
	/// data.
	///
	is_same:      proc "c" (self: ^Binary_Value, that: ^Binary_Value) -> c.int,

	///
	/// Returns true (1) if this object and |that| object have an equivalent
	/// underlying value but are not necessarily the same object.
	///
	is_equal:     proc "c" (self: ^Binary_Value, that: ^Binary_Value) -> c.int,

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
	get_size:     proc "c" (self: ^Binary_Value) -> c.size_t,

	///
	/// Read up to |buffer_size| number of bytes into |buffer|. Reading begins at
	/// the specified byte |data_offset|. Returns the number of bytes read.
	///
	get_data:     proc "c" (
		self: ^Binary_Value,
		buffer: rawptr,
		buffer_size: c.size_t,
		data_offset: c.size_t,
	) -> c.size_t,
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
	is_valid:       proc "c" (self: ^List_Value) -> c.int,

	///
	/// Returns true (1) if this object is currently owned by another object.
	///
	is_owned:       proc "c" (self: ^List_Value) -> c.int,

	///
	/// Returns true (1) if the values of this object are read-only. Some APIs may
	/// expose read-only objects.
	///
	is_read_only:   proc "c" (self: ^List_Value) -> c.int,

	///
	/// Returns true (1) if this object and |that| object have the same underlying
	/// data. If true (1) modifications to this object will also affect |that|
	/// object and vice-versa.
	///
	is_same:        proc "c" (self: ^List_Value, that: ^List_Value) -> c.int,

	///
	/// Returns true (1) if this object and |that| object have an equivalent
	/// underlying value but are not necessarily the same object.
	///
	is_equal:       proc "c" (self: ^List_Value, that: ^List_Value) -> c.int,

	///
	/// Returns a writable copy of this object.
	///
	copy:           proc "c" (self: ^List_Value) -> ^List_Value,

	///
	/// Sets the number of values. If the number of values is expanded all new
	/// value slots will default to type null. Returns true (1) on success.
	///
	set_size:       proc "c" (self: ^List_Value, size: c.size_t) -> c.int,

	///
	/// Returns the number of values.
	///
	get_size:       proc "c" (self: ^List_Value) -> c.size_t,

	///
	/// Removes all values. Returns true (1) on success.
	///
	clear:          proc "c" (self: ^List_Value) -> c.int,

	///
	/// Removes the value at the specified index.
	///
	remove:         proc "c" (self: ^List_Value, index: c.size_t) -> c.int,

	///
	/// Returns the value type at the specified index.
	///
	get_type:       proc "c" (self: ^List_Value, index: c.size_t) -> Value_Type,

	///
	/// Returns the value at the specified index. For simple types the returned
	/// value will copy existing data and modifications to the value will not
	/// modify this object. For complex types (binary, dictionary and list) the
	/// returned value will reference existing data and modifications to the value
	/// will modify this object.
	///
	get_value:      proc "c" (self: ^List_Value, index: c.size_t) -> ^Value,

	///
	/// Returns the value at the specified index as type bool.
	///
	get_bool:       proc "c" (self: ^List_Value, index: c.size_t) -> c.int,

	///
	/// Returns the value at the specified index as type int.
	///
	get_int:        proc "c" (self: ^List_Value, index: c.size_t) -> c.int,

	///
	/// Returns the value at the specified index as type double.
	///
	get_double:     proc "c" (self: ^List_Value, index: c.size_t) -> c.double,

	///
	/// Returns the value at the specified index as type string.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_string:     proc "c" (self: ^List_Value, index: c.size_t) -> String_Userfree,

	///
	/// Returns the value at the specified index as type binary. The returned
	/// value will reference existing data.
	///
	get_binary:     proc "c" (self: ^List_Value, index: c.size_t) -> ^Binary_Value,

	///
	/// Returns the value at the specified index as type dictionary. The returned
	/// value will reference existing data and modifications to the value will
	/// modify this object.
	///
	get_dictionary: proc "c" (self: ^List_Value, index: c.size_t) -> ^Dictionary_Value,

	///
	/// Returns the value at the specified index as type list. The returned value
	/// will reference existing data and modifications to the value will modify
	/// this object.
	///
	get_list:       proc "c" (self: ^List_Value, index: c.size_t) -> ^List_Value,

	///
	/// Sets the value at the specified index. Returns true (1) if the value was
	/// set successfully. If |value| represents simple data then the underlying
	/// data will be copied and modifications to |value| will not modify this
	/// object. If |value| represents complex data (binary, dictionary or list)
	/// then the underlying data will be referenced and modifications to |value|
	/// will modify this object.
	///
	set_value:      proc "c" (self: ^List_Value, index: c.size_t, value: ^Value) -> c.int,

	///
	/// Sets the value at the specified index as type null. Returns true (1) if
	/// the value was set successfully.
	///
	set_null:       proc "c" (self: ^List_Value, index: c.size_t) -> c.int,

	///
	/// Sets the value at the specified index as type bool. Returns true (1) if
	/// the value was set successfully.
	///
	set_bool:       proc "c" (self: ^List_Value, index: c.size_t, value: c.int) -> c.int,

	///
	/// Sets the value at the specified index as type int. Returns true (1) if the
	/// value was set successfully.
	///
	set_int:        proc "c" (self: ^List_Value, index: c.size_t, value: c.int),

	///
	/// Sets the value at the specified index as type double. Returns true (1) if
	/// the value was set successfully.
	///
	set_double:     proc "c" (self: ^List_Value, index: c.size_t, value: c.double) -> c.int,

	///
	/// Sets the value at the specified index as type string. Returns true (1) if
	/// the value was set successfully.
	///
	set_string:     proc "c" (self: ^List_Value, index: c.size_t, value: ^String) -> c.int,

	///
	/// Sets the value at the specified index as type binary. Returns true (1) if
	/// the value was set successfully. If |value| is currently owned by another
	/// object then the value will be copied and the |value| reference will not
	/// change. Otherwise, ownership will be transferred to this object and the
	/// |value| reference will be invalidated.
	///
	set_binary:     proc "c" (self: ^List_Value, index: c.size_t, value: ^Binary_Value) -> c.int,

	///
	/// Sets the value at the specified index as type dict. Returns true (1) if
	/// the value was set successfully. If |value| is currently owned by another
	/// object then the value will be copied and the |value| reference will not
	/// change. Otherwise, ownership will be transferred to this object and the
	/// |value| reference will be invalidated.
	///
	set_dictionary: proc "c" (
		self: ^List_Value,
		index: c.size_t,
		value: ^Dictionary_Value,
	) -> c.int,

	///
	/// Sets the value at the specified index as type list. Returns true (1) if
	/// the value was set successfully. If |value| is currently owned by another
	/// object then the value will be copied and the |value| reference will not
	/// change. Otherwise, ownership will be transferred to this object and the
	/// |value| reference will be invalidated.
	///
	set_list:       proc "c" (self: ^List_Value, index: c.size_t, value: ^List_Value) -> c.int,
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
	is_valid:       proc "c" (self: ^Value) -> c.int,

	///
	/// Returns true (1) if the underlying data is owned by another object.
	///
	is_owned:       proc "c" (self: ^Value) -> c.int,

	///
	/// Returns true (1) if the underlying data is read-only. Some APIs may expose
	/// read-only objects.
	///
	is_read_only:   proc "c" (self: ^Value) -> c.int,

	///
	/// Returns true (1) if this object and |that| object have the same underlying
	/// data. If true (1) modifications to this object will also affect |that|
	/// object and vice-versa.
	///
	is_same:        proc "c" (self: ^Value, that: ^Value) -> c.int,

	///
	/// Returns true (1) if this object and |that| object have an equivalent
	/// underlying value but are not necessarily the same object.
	///
	is_equal:       proc "c" (self: ^Value, that: ^Value) -> c.int,

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
	get_bool:       proc "c" (self: ^Value) -> c.int,

	///
	/// Returns the underlying value as type int.
	///
	get_int:        proc "c" (self: ^Value) -> c.int,

	///
	/// Returns the underlying value as type double.
	///
	get_double:     proc "c" (self: ^Value) -> c.double,

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
	set_null:       proc "c" (self: ^Value) -> c.int,


	///
	/// Sets the underlying value as type bool. Returns true (1) if the value was
	/// set successfully.
	///
	set_bool:       proc "c" (self: ^Value, value: c.int) -> c.int,


	///
	/// Sets the underlying value as type int. Returns true (1) if the value was
	/// set successfully.
	///
	set_int:        proc "c" (self: ^Value, value: c.int) -> c.int,

	///
	/// Sets the underlying value as type double. Returns true (1) if the value
	/// was set successfully.
	///
	set_double:     proc "c" (self: ^Value, value: c.double) -> c.int,

	///
	/// Sets the underlying value as type string. Returns true (1) if the value
	/// was set successfully.
	///
	set_string:     proc "c" (self: ^Value, value: ^String) -> c.int,

	///
	/// Sets the underlying value as type binary. Returns true (1) if the value
	/// was set successfully. This object keeps a reference to |value| and
	/// ownership of the underlying data remains unchanged.
	///
	set_binary:     proc "c" (self: ^Value, value: ^Binary_Value) -> c.int,

	///
	/// Sets the underlying value as type dict. Returns true (1) if the value was
	/// set successfully. This object keeps a reference to |value| and ownership
	/// of the underlying data remains unchanged.
	///
	set_dictionary: proc "c" (self: ^Value, value: ^Dictionary_Value) -> c.int,

	///
	/// Sets the underlying value as type list. Returns true (1) if the value was
	/// set successfully. This object keeps a reference to |value| and ownership
	/// of the underlying data remains unchanged.
	///
	set_list:       proc "c" (self: ^Value, value: ^List_Value) -> c.int,
}

Settings :: struct {
	///
	/// Size of this structure.
	///
	size:                                c.size_t,
	///
	/// Set to true (1) to disable the sandbox for sub-processes. See
	/// cef_sandbox_win.h for requirements to enable the sandbox on Windows. Also
	/// configurable using the "no-sandbox" command-line switch.
	///
	no_sandbox:                          c.int,
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
	multi_threaded_message_loop:         c.int,
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
	external_message_pump:               c.int,
	///
	/// Set to true (1) to enable windowless (off-screen) rendering support. Do
	/// not enable this value if the application does not use windowless rendering
	/// as it may reduce rendering performance on some systems.
	///
	windowless_rendering_enabled:        c.int,
	///
	/// Set to true (1) to disable configuration of browser process features using
	/// standard CEF and Chromium command-line arguments. Configuration can still
	/// be specified using CEF data structures or via the
	/// CefApp::OnBeforeCommandLineProcessing() method.
	///
	command_line_args_disabled:          c.int,
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
	persist_session_cookies:             c.int,
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
	remote_debugging_port:               c.int,
	///
	/// The number of stack trace frames to capture for uncaught exceptions.
	/// Specify a positive value to enable the
	/// CefRenderProcessHandler::OnUncaughtException() callback. Specify 0
	/// (default value) and OnUncaughtException() will not be called. Also
	/// configurable using the "uncaught-exception-stack-size" command-line
	/// switch.
	///
	uncaught_exception_stack_size:       c.int,
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
	cookieable_schemes_exclude_defaults: c.int,
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
	chrome_app_icon_id:                  c.int,
	///
	/// Specify whether signal handlers must be disabled on POSIX systems.
	///
	disable_signal_handlers:             c.int,
}

Main_Args :: struct {
	instance: windows.HINSTANCE,
}

Base_Ref_Counted :: struct {
	size:                 c.size_t,
	add_ref:              proc "c" (_: ^Base_Ref_Counted),
	release:              proc "c" (_: ^Base_Ref_Counted) -> c.int,
	has_one_ref:          proc "c" (_: ^Base_Ref_Counted) -> c.int,
	has_at_least_one_ref: proc "c" (_: ^Base_Ref_Counted) -> c.int,
}

Base_Scoped :: struct {
	size: c.size_t,
	del:  proc "c" (self: ^Base_Scoped),
}

Scheme_Registrar :: struct {
	base:              Base_Scoped,
	add_custom_scheme: proc "c" (
		self: ^Scheme_Registrar,
		scheme_name: ^String,
		options: c.int,
	) -> c.int,
}

Resource_Bundle_Handler :: struct {
	base:                 Base_Ref_Counted,
	get_localized_string: proc "c" (_: ^Resource_Bundle_Handler, _: c.int, _: ^String),
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
	) -> c.int,

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
		delay_ms: c.int64_t,
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
		is_navigation: c.int,
		is_download: c.int,
		request_initiator: ^String,
		disable_default_handling: ^c.int,
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
	) -> c.int,

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
		received_content_length: c.int64_t,
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
		allow_os_execution: ^c.int,
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
		v8_context: ^V8_Context,
		exception: ^V8_Exception,
		stack_trace: ^V8_Stack_Trace,
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
	size:                         c.size_t,
	ex_style:                     windows.DWORD,
	window_name:                  String,
	style:                        windows.DWORD,
	bounds:                       Rect,
	parent_window:                Window_Handle,
	menu:                         windows.HMENU,
	windowless_rendering_enabled: c.int,
	shared_texture_enabled:       c.int,
	external_begin_frame_enabled: c.int,
	window:                       Window_Handle,
	runtime_style:                Runtime_Style,
}

Browser_Settings :: struct {
	///
	/// Size of this structure.
	///
	size:                           c.size_t,

	///
	/// The maximum rate in frames per second (fps) that CefRenderHandler::OnPaint
	/// will be called for a windowless browser. The actual fps may be lower if
	/// the browser cannot generate frames at the requested rate. The minimum
	/// value is 1 and the maximum value is 60 (default 30). This value can also
	/// be changed dynamically via CefBrowserHost::SetWindowlessFrameRate.
	///
	windowless_frame_rate:          c.int,

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
	default_font_size:              c.int,
	default_fixed_font_size:        c.int,
	minimum_font_size:              c.int,
	minimum_logical_font_size:      c.int,

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
	is_valid:                 proc "c" (self: ^Command_Line) -> c.int,
	is_read_only:             proc "c" (self: ^Command_Line) -> c.int,
	copy:                     proc "c" (self: ^Command_Line) -> ^Command_Line,
	init_from_argv:           proc "c" (self: ^Command_Line, argc: c.int, argv: [^]cstring),
	init_from_string:         proc "c" (self: ^Command_Line, command_line: ^String),
	reset:                    proc "c" (self: ^Command_Line),
	get_argv:                 proc "c" (self: ^Command_Line, argv: String_List),
	get_command_line_string:  proc "c" (self: ^Command_Line) -> String_Userfree,
	get_program:              proc "c" (self: ^Command_Line) -> String_Userfree,
	set_program:              proc "c" (self: ^Command_Line, program: ^String),
	has_switches:             proc "c" (self: ^Command_Line) -> c.int,
	has_switch:               proc "c" (self: ^Command_Line, name: ^String) -> c.int,
	get_switch_value:         proc "c" (self: ^Command_Line, name: ^String) -> String_Userfree,
	get_switches:             proc "c" (self: ^Command_Line, switches: String_Map),
	append_switch:            proc "c" (self: ^Command_Line, name: ^String),
	append_switch_with_value: proc "c" (self: ^Command_Line, name, value: ^String),
	has_arguments:            proc "c" (self: ^Command_Line) -> c.int,
	get_arguments:            proc "c" (self: ^Command_Line, arguments: String_List),
	append_argument:          proc "c" (self: ^Command_Line, argument: ^String),
	prepend_wrapper:          proc "c" (self: ^Command_Line, wrapper: ^String),
}

Dictionary_Value :: struct {
}

Request_Context :: struct {
	base: Base_Ref_Counted,
}

Transition_Type :: enum c.int {
	Link,
	Explicit,
	Auto_Bookmark,
	Auto_Subframe,
	Manual_Subframe,
	Generated,
	Auto_Toplevel,
	Form_Submit,
	Reload,
	Keyword,
	Keyword_Generated,
	Num_Values,
	Source_Mask,
	Blocked_Flag,
	Forward_Back_Flag,
	Direct_Load_Flag,
	Home_Page_Flag,
	From_API_Flag,
	Chain_Start_Flag,
}

PDF_Print_Margin_Type :: enum c.int {
	Default,
	None,
	Custom,
}

PDF_Print_Settings :: struct {
	///
	/// Size of this structure.
	///
	size:                      c.size_t,

	///
	/// Set to true (1) for landscape mode or false (0) for portrait mode.
	///
	landscape:                 c.int,

	///
	/// Set to true (1) to print background graphics.
	///
	print_background:          c.int,

	///
	/// The percentage to scale the PDF by before printing (e.g. .5 is 50%).
	/// If this value is less than or equal to zero the default value of 1.0
	/// will be used.
	///
	scale:                     c.double,

	///
	/// Output paper size in inches. If either of these values is less than or
	/// equal to zero then the default paper size (letter, 8.5 x 11 inches) will
	/// be used.
	///
	paper_width:               c.double,
	paper_height:              c.double,

	///
	/// Set to true (1) to prefer page size as defined by css. Defaults to false
	/// (0), in which case the content will be scaled to fit the paper size.
	///
	prefer_css_page_size:      c.int,

	///
	/// Margin type.
	///
	margin_type:               PDF_Print_Margin_Type,

	///
	/// Margins in inches. Only used if |margin_type| is set to
	/// PDF_PRINT_MARGIN_CUSTOM.
	///
	margin_top:                c.double,
	margin_right:              c.double,
	margin_bottom:             c.double,
	margin_left:               c.double,

	///
	/// Paper ranges to print, one based, e.g., '1-5, 8, 11-13'. Pages are printed
	/// in the document order, not in the order specified, and no more than once.
	/// Defaults to empty string, which implies the entire document is printed.
	/// The page numbers are quietly capped to actual page count of the document,
	/// and ranges beyond the end of the document are ignored. If this results in
	/// no pages to print, an error is reported. It is an error to specify a range
	/// with start greater than end.
	///
	page_ranges:               String,

	///
	/// Set to true (1) to display the header and/or footer. Modify
	/// |header_template| and/or |footer_template| to customize the display.
	///
	display_header_footer:     c.int,

	///
	/// HTML template for the print header. Only displayed if
	/// |display_header_footer| is true (1). Should be valid HTML markup with
	/// the following classes used to inject printing values into them:
	///
	/// - date: formatted print date
	/// - title: document title
	/// - url: document location
	/// - pageNumber: current page number
	/// - totalPages: total pages in the document
	///
	/// For example, "<span class=title></span>" would generate a span containing
	/// the title.
	///
	header_template:           String,

	///
	/// HTML template for the print footer. Only displayed if
	/// |display_header_footer| is true (1). Uses the same format as
	/// |header_template|.
	///
	footer_template:           String,

	///
	/// Set to true (1) to generate tagged (accessible) PDF.
	///
	generate_tagged_pdf:       c.int,

	///
	/// Set to true (1) to generate a document outline.
	///
	generate_document_outline: c.int,
}
Popup_Features :: struct {
	size:       c.size_t,
	x:          c.int,
	x_set:      c.int,
	y:          c.int,
	y_set:      c.int,
	width:      c.int,
	width_set:  c.int,
	height:     c.int,
	height_set: c.int,
	is_popup:   c.int,
}
Domnode :: struct {
}
Browser_Host :: struct {
	///
	/// Base structure.
	///
	base:                           Base_Ref_Counted,

	///
	/// Returns the hosted browser object.
	///
	get_browser:                    proc "c" (self: ^Browser_Host) -> ^Browser,

	///
	/// Request that the browser close. Closing a browser is a multi-stage process
	/// that may complete either synchronously or asynchronously, and involves
	/// callbacks such as cef_life_span_handler_t::DoClose (Alloy style only),
	/// cef_life_span_handler_t::OnBeforeClose, and a top-level window close
	/// handler such as cef_window_delegate_t::CanClose (or platform-specific
	/// equivalent). In some cases a close request may be delayed or canceled by
	/// the user. Using try_close_browser() instead of close_browser() is
	/// recommended for most use cases. See cef_life_span_handler_t::do_close()
	/// documentation for detailed usage and examples.
	///
	/// If |force_close| is false (0) then JavaScript unload handlers, if any, may
	/// be fired and the close may be delayed or canceled by the user. If
	/// |force_close| is true (1) then the user will not be prompted and the close
	/// will proceed immediately (possibly asynchronously). If browser close is
	/// delayed and not canceled the default behavior is to call the top-level
	/// window close handler once the browser is ready to be closed. This default
	/// behavior can be changed for Alloy style browsers by implementing
	/// cef_life_span_handler_t::do_close(). is_ready_to_be_closed() can be used
	/// to detect mandatory browser close events when customizing close behavior
	/// on the browser process UI thread.
	///
	close_browser:                  proc "c" (self: ^Browser_Host, force_close: c.int),

	///
	/// Helper for closing a browser. This is similar in behavior to
	/// CLoseBrowser(false (0)) but returns a boolean to reflect the immediate
	/// close status. Call this function from a top-level window close handler
	/// such as cef_window_delegate_t::CanClose (or platform-specific equivalent)
	/// to request that the browser close, and return the result to indicate if
	/// the window close should proceed. Returns false (0) if the close will be
	/// delayed (JavaScript unload handlers triggered but still pending) or true
	/// (1) if the close will proceed immediately (possibly asynchronously). See
	/// close_browser() documentation for additional usage information. This
	/// function must be called on the browser process UI thread.
	///
	try_close_browser:              proc "c" (self: ^Browser_Host) -> c.int,

	///
	/// Returns true (1) if the browser is ready to be closed, meaning that the
	/// close has already been initiated and that JavaScript unload handlers have
	/// already executed or should be ignored. This can be used from a top-level
	/// window close handler such as cef_window_delegate_t::CanClose (or platform-
	/// specific equivalent) to distringuish between potentially cancelable
	/// browser close events (like the user clicking the top-level window close
	/// button before browser close has started) and mandatory browser close
	/// events (like JavaScript `window.close()` or after browser close has
	/// started in response to [Try]close_browser()). Not completing the browser
	/// close for mandatory close events (when this function returns true (1))
	/// will leave the browser in a partially closed state that interferes with
	/// proper functioning. See close_browser() documentation for additional usage
	/// information. This function must be called on the browser process UI
	/// thread.
	///
	is_ready_to_be_closed:          proc "c" (self: ^Browser_Host) -> c.int,

	///
	/// Set whether the browser is focused.
	///
	set_focus:                      proc "c" (self: ^Browser_Host, focus: c.int),

	///
	/// Retrieve the window handle (if any) for this browser. If this browser is
	/// wrapped in a cef_browser_view_t this function should be called on the
	/// browser process UI thread and it will return the handle for the top-level
	/// native window.
	///
	get_window_handle:              proc "c" (self: ^Browser_Host) -> Window_Handle,

	///
	/// Retrieve the window handle (if any) of the browser that opened this
	/// browser. Will return NULL for non-popup browsers or if this browser is
	/// wrapped in a cef_browser_view_t. This function can be used in combination
	/// with custom handling of modal windows.
	///
	get_opener_window_handle:       proc "c" (self: ^Browser_Host) -> Window_Handle,

	///
	/// Retrieve the unique identifier of the browser that opened this browser.
	/// Will return 0 for non-popup browsers.
	///
	get_opener_identifier:          proc "c" (self: ^Browser_Host) -> c.int,

	///
	/// Returns true (1) if this browser is wrapped in a cef_browser_view_t.
	///
	has_view:                       proc "c" (self: ^Browser_Host) -> c.int,

	///
	/// Returns the client for this browser.
	///
	get_client:                     proc "c" (self: ^Browser_Host) -> ^Client,

	///
	/// Returns the request context for this browser.
	///
	get_request_context:            proc "c" (self: ^Browser_Host) -> ^Request_Context,

	///
	/// Returns true (1) if this browser can execute the specified zoom command.
	/// This function can only be called on the UI thread.
	///
	can_zoom:                       proc "c" (self: ^Browser_Host, command: Zoom_Command) -> c.int,

	///
	/// Execute a zoom command in this browser. If called on the UI thread the
	/// change will be applied immediately. Otherwise, the change will be applied
	/// asynchronously on the UI thread.
	///
	zoom:                           proc "c" (self: ^Browser_Host, command: Zoom_Command) -> c.int,

	///
	/// Get the default zoom level. This value will be 0.0 by default but can be
	/// configured. This function can only be called on the UI thread.
	///
	get_default_zoom_level:         proc "c" (self: ^Browser_Host) -> c.double,

	///
	/// Get the current zoom level. This function can only be called on the UI
	/// thread.
	///
	get_zoom_level:                 proc "c" (self: ^Browser_Host) -> c.double,

	///
	/// Change the zoom level to the specified value. Specify 0.0 to reset the
	/// zoom level to the default. If called on the UI thread the change will be
	/// applied immediately. Otherwise, the change will be applied asynchronously
	/// on the UI thread.
	///
	set_zoom_level:                 proc "c" (self: ^Browser_Host, zoom_level: c.double),

	///
	/// Call to run a file chooser dialog. Only a single file chooser dialog may
	/// be pending at any given time. |mode| represents the type of dialog to
	/// display. |title| to the title to be used for the dialog and may be NULL to
	/// show the default title ("Open" or "Save" depending on the mode).
	/// |default_file_path| is the path with optional directory and/or file name
	/// component that will be initially selected in the dialog. |accept_filters|
	/// are used to restrict the selectable file types and may any combination of
	/// (a) valid lower-cased MIME types (e.g. "text/*" or "image/*"), (b)
	/// individual file extensions (e.g. ".txt" or ".png"), or (c) combined
	/// description and file extension delimited using "|" and ";" (e.g. "Image
	/// Types|.png;.gif;.jpg"). |callback| will be executed after the dialog is
	/// dismissed or immediately if another dialog is already pending. The dialog
	/// will be initiated asynchronously on the UI thread.
	///
	run_file_dialog:                proc "c" (
		self: ^Browser_Host,
		mode: File_Dialog_Mode,
		title: ^String,
		default_file_path: ^String,
		accept_filters: String_List,
		callback: Run_File_Dialog_Callback,
	),

	///
	/// Download the file at |url| using cef_download_handler_t.
	///
	start_download:                 proc "c" (self: ^Browser_Host, url: ^String),

	///
	/// Download |image_url| and execute |callback| on completion with the images
	/// received from the renderer. If |is_favicon| is true (1) then cookies are
	/// not sent and not accepted during download. Images with density independent
	/// pixel (DIP) sizes larger than |max_image_size| are filtered out from the
	/// image results. Versions of the image at different scale factors may be
	/// downloaded up to the maximum scale factor supported by the system. If
	/// there are no image results <= |max_image_size| then the smallest image is
	/// resized to |max_image_size| and is the only result. A |max_image_size| of
	/// 0 means unlimited. If |bypass_cache| is true (1) then |image_url| is
	/// requested from the server even if it is present in the browser cache.
	///
	download_image:                 proc "c" (
		self: ^Browser_Host,
		image_url: ^String,
		is_favicon: c.int,
		max_image_size: c.uint32_t,
		bypass_cache: c.int,
		callback: Download_Image_Callback,
	),

	///
	/// Print the current browser contents.
	///
	print:                          proc "c" (self: ^Browser_Host),

	///
	/// Print the current browser contents to the PDF file specified by |path| and
	/// execute |callback| on completion. The caller is responsible for deleting
	/// |path| when done. For PDF printing to work on Linux you must implement the
	/// cef_print_handler_t::GetPdfPaperSize function.
	///
	print_to_pdf:                   proc "c" (
		self: ^Browser_Host,
		path: ^String,
		settings: ^PDF_Print_Settings,
		callback: ^PDF_Print_Callback,
	),

	///
	/// Search for |searchText|. |forward| indicates whether to search forward or
	/// backward within the page. |matchCase| indicates whether the search should
	/// be case-sensitive. |findNext| indicates whether this is the first request
	/// or a follow-up. The search will be restarted if |searchText| or
	/// |matchCase| change. The search will be stopped if |searchText| is NULL.
	/// The cef_find_handler_t instance, if any, returned via
	/// cef_client_t::GetFindHandler will be called to report find results.
	///
	find:                           proc "c" (
		self: ^Browser_Host,
		search_text: ^String,
		forward, match_case, find_next: c.int,
	),

	///
	/// Cancel all searches that are currently going on.
	///
	stop_finding:                   proc "c" (self: ^Browser_Host, clear_selection: c.int),

	///
	/// Open developer tools (DevTools) in its own browser. The DevTools browser
	/// will remain associated with this browser. If the DevTools browser is
	/// already open then it will be focused, in which case the |windowInfo|,
	/// |client| and |settings| parameters will be ignored. If
	/// |inspect_element_at| is non-NULL then the element at the specified (x,y)
	/// location will be inspected. The |windowInfo| parameter will be ignored if
	/// this browser is wrapped in a cef_browser_view_t.
	///
	show_dev_tools:                 proc "c" (
		self: ^Browser_Host,
		window_info: ^Window_Info,
		client: ^Client,
		settings: ^Browser_Settings,
		inspect_element_at: ^Point,
	),

	///
	/// Explicitly close the associated DevTools browser, if any.
	///
	close_dev_tools:                proc "c" (self: ^Browser_Host),

	///
	/// Returns true (1) if this browser currently has an associated DevTools
	/// browser. Must be called on the browser process UI thread.
	///
	has_dev_tools:                  proc "c" (self: ^Browser_Host) -> c.int,

	///
	/// Send a function call message over the DevTools protocol. |message| must be
	/// a UTF8-encoded JSON dictionary that contains "id" (int), "function"
	/// (string) and "params" (dictionary, optional) values. See the DevTools
	/// protocol documentation at https://chromedevtools.github.io/devtools-
	/// protocol/ for details of supported functions and the expected "params"
	/// dictionary contents. |message| will be copied if necessary. This function
	/// will return true (1) if called on the UI thread and the message was
	/// successfully submitted for validation, otherwise false (0). Validation
	/// will be applied asynchronously and any messages that fail due to
	/// formatting errors or missing parameters may be discarded without
	/// notification. Prefer ExecuteDevToolsMethod if a more structured approach
	/// to message formatting is desired.
	///
	/// Every valid function call will result in an asynchronous function result
	/// or error message that references the sent message "id". Event messages are
	/// received while notifications are enabled (for example, between function
	/// calls for "Page.enable" and "Page.disable"). All received messages will be
	/// delivered to the observer(s) registered with AddDevToolsMessageObserver.
	/// See cef_dev_tools_message_observer_t::OnDevToolsMessage documentation for
	/// details of received message contents.
	///
	/// Usage of the SendDevToolsMessage, ExecuteDevToolsMethod and
	/// AddDevToolsMessageObserver functions does not require an active DevTools
	/// front-end or remote-debugging session. Other active DevTools sessions will
	/// continue to function independently. However, any modification of global
	/// browser state by one session may not be reflected in the UI of other
	/// sessions.
	///
	/// Communication with the DevTools front-end (when displayed) can be logged
	/// for development purposes by passing the `--devtools-protocol-log-
	/// file=<path>` command-line flag.
	///
	send_dev_tools_message:         proc "c" (
		self: ^Browser_Host,
		message: rawptr,
		message_size: c.size_t,
	),

	///
	/// Execute a function call over the DevTools protocol. This is a more
	/// structured version of SendDevToolsMessage. |message_id| is an incremental
	/// number that uniquely identifies the message (pass 0 to have the next
	/// number assigned automatically based on previous values). |function| is the
	/// function name. |params| are the function parameters, which may be NULL.
	/// See the DevTools protocol documentation (linked above) for details of
	/// supported functions and the expected |params| dictionary contents. This
	/// function will return the assigned message ID if called on the UI thread
	/// and the message was successfully submitted for validation, otherwise 0.
	/// See the SendDevToolsMessage documentation for additional usage
	/// information.
	///
	execute_dev_tools_method:       proc "c" (
		self: ^Browser_Host,
		message_id: c.int,
		method: ^String,
		params: ^Dictionary_Value,
	) -> c.int,

	///
	/// Add an observer for DevTools protocol messages (function results and
	/// events). The observer will remain registered until the returned
	/// Registration object is destroyed. See the SendDevToolsMessage
	/// documentation for additional usage information.
	///
	add_dev_tools_message_observer: proc "c" (
		self: ^Browser_Host,
		observer: ^Dev_Tools_Message_Observer,
	) -> ^Registration,

	///
	/// Retrieve a snapshot of current navigation entries as values sent to the
	/// specified visitor. If |current_only| is true (1) only the current
	/// navigation entry will be sent, otherwise all navigation entries will be
	/// sent.
	///
	get_navigation_entries:         proc "c" (
		self: ^Browser_Host,
		visitor: Navigation_Entry_Visitor,
		current_only: c.int,
	),

	///
	/// If a misspelled word is currently selected in an editable node calling
	/// this function will replace it with the specified |word|.
	///
	replace_misspelled_word:        proc "c" (self: ^Browser_Host, word: ^String),

	///
	/// Add the specified |word| to the spelling dictionary.
	///
	add_word_to_dictionary:         proc "c" (self: ^Browser_Host, word: ^String),

	///
	/// Returns true (1) if window rendering is disabled.
	///
	is_window_rendering_disabled:   proc "c" (self: ^Browser_Host) -> c.int,

	///
	/// Notify the browser that the widget has been resized. The browser will
	/// first call cef_render_handler_t::GetViewRect to get the new size and then
	/// call cef_render_handler_t::OnPaint asynchronously with the updated
	/// regions. This function is only used when window rendering is disabled.
	///
	was_resized:                    proc "c" (self: ^Browser_Host),

	///
	/// Notify the browser that it has been hidden or shown. Layouting and
	/// cef_render_handler_t::OnPaint notification will stop when the browser is
	/// hidden. This function is only used when window rendering is disabled.
	///
	was_hidden:                     proc "c" (self: ^Browser_Host, hidden: c.int),

	///
	/// Send a notification to the browser that the screen info has changed. The
	/// browser will then call cef_render_handler_t::GetScreenInfo to update the
	/// screen information with the new values. This simulates moving the webview
	/// window from one display to another, or changing the properties of the
	/// current display. This function is only used when window rendering is
	/// disabled.
	///
	notify_screen_info_changed:     proc "c" (self: ^Browser_Host),

	///
	/// Invalidate the view. The browser will call cef_render_handler_t::OnPaint
	/// asynchronously. This function is only used when window rendering is
	/// disabled.
	///
	invalidate:                     proc "c" (self: ^Browser_Host, type: Paint_Element_Type),

	///
	/// Issue a BeginFrame request to Chromium.  Only valid when
	/// cef_window_tInfo::external_begin_frame_enabled is set to true (1).
	///
	send_external_begin_frame:      proc "c" (self: ^Browser_Host),

	///
	/// Send a key event to the browser.
	///
	send_key_event:                 proc "c" (self: ^Browser_Host, event: ^Key_Event),

	///
	/// Send a mouse click event to the browser. The |x| and |y| coordinates are
	/// relative to the upper-left corner of the view.
	///
	send_mouse_click_event:         proc "c" (
		self: ^Browser_Host,
		event: ^Mouse_Event,
		type: Mouse_Button_Type,
		mouse_up: c.int,
		click_count: c.int,
	),

	///
	/// Send a mouse move event to the browser. The |x| and |y| coordinates are
	/// relative to the upper-left corner of the view.
	///
	send_mouse_move_event:          proc "c" (
		self: ^Browser_Host,
		event: ^Mouse_Event,
		mouse_leave: c.int,
	),

	///
	/// Send a mouse wheel event to the browser. The |x| and |y| coordinates are
	/// relative to the upper-left corner of the view. The |deltaX| and |deltaY|
	/// values represent the movement delta in the X and Y directions
	/// respectively. In order to scroll inside select popups with window
	/// rendering disabled cef_render_handler_t::GetScreenPoint should be
	/// implemented properly.
	///
	send_mouse_wheel_event:         proc "c" (
		self: ^Browser_Host,
		event: ^Mouse_Event,
		delta_x, delta_y: c.int,
	),

	///
	/// Send a touch event to the browser for a windowless browser.
	///
	send_touch_event:               proc "c" (self: ^Browser_Host, event: ^Touch_Event),

	///
	/// Send a capture lost event to the browser.
	///
	send_capture_lost_event:        proc "c" (self: ^Browser_Host),

	///
	/// Notify the browser that the window hosting it is about to be moved or
	/// resized. This function is only used on Windows and Linux.
	///
	notify_move_or_resize_started:  proc "c" (self: ^Browser_Host),

	///
	/// Returns the maximum rate in frames per second (fps) that
	/// cef_render_handler_t::OnPaint will be called for a windowless browser. The
	/// actual fps may be lower if the browser cannot generate frames at the
	/// requested rate. The minimum value is 1 and the maximum value is 60
	/// (default 30). This function can only be called on the UI thread.
	///
	get_windowless_frame_rate:      proc "c" (self: ^Browser_Host) -> c.int,

	///
	/// Set the maximum rate in frames per second (fps) that
	/// cef_render_handler_t:: OnPaint will be called for a windowless browser.
	/// The actual fps may be lower if the browser cannot generate frames at the
	/// requested rate. The minimum value is 1 and the maximum value is 60
	/// (default 30). Can also be set at browser creation via
	/// cef_browser_tSettings.windowless_frame_rate.
	///
	set_windowless_frame_rate:      proc "c" (self: ^Browser_Host, frame_rate: c.int),
}
Run_File_Dialog_Callback :: struct {
	base:                        Base_Ref_Counted,
	on_run_file_dialog_finished: proc "c" (
		self: ^Run_File_Dialog_Callback,
		file_paths: String_List,
	),
}
File_Dialog_Mode :: enum {
	Open,
	Open_Multiple,
	Open_Folder,
	Save,
}
Zoom_Command :: enum {
	Out,
	Reset,
	In,
}
Download_Image_Callback :: struct {
	base:                       Base_Ref_Counted,
	on_download_image_finished: proc "c" (
		self: ^Download_Image_Callback,
		image_url: ^String,
		http_status_code: c.int,
		image: ^Image,
	),
}
Image :: struct {
	base: Base_Ref_Counted,
}
PDF_Print_Callback :: struct {
	base:                  Base_Ref_Counted,
	on_pdf_print_finished: proc "c" (self: ^PDF_Print_Callback, path: ^String, ok: c.int),
}
Process_ID :: enum c.int {
	Browser,
	Renderer,
}
Process_Message :: struct {
	base: Base_Ref_Counted,
}


Audio_Handler :: struct {
	base: Base_Ref_Counted,
}
Command_Handler :: struct {
	base: Base_Ref_Counted,
}
Context_Menu_Handler :: struct {
	base: Base_Ref_Counted,
}
Dialog_Handler :: struct {
	base: Base_Ref_Counted,
}
Display_Handler :: struct {
	base: Base_Ref_Counted,
}
Download_Handler :: struct {
	base: Base_Ref_Counted,
}
Drag_Handler :: struct {
	base: Base_Ref_Counted,
}
Find_Handler :: struct {
	base: Base_Ref_Counted,
}
Focus_Handler :: struct {
	base: Base_Ref_Counted,
}
Frame_Handler :: struct {
	base: Base_Ref_Counted,
}
Permission_Handler :: struct {
	base: Base_Ref_Counted,
}
JSDialog_Handler :: struct {
	base: Base_Ref_Counted,
}
Keyboard_Handler :: struct {
	base: Base_Ref_Counted,
}
Window_Open_Disposition :: enum {
	Unknown,
	Current_Tab,
	Singleton_Tab,
	Foreground_Tab,
	Background_Tab,
	New_Popup,
	New_Window,
	Save_To_Disk,
	Off_The_Record,
	Ignore_Action,
	Switch_To_Tab,
	New_Picture_In_Picture,
}
Life_Span_Handler :: struct {
	///
	/// Base structure.
	///
	base:                      Base_Ref_Counted,

	///
	/// Called on the UI thread before a new popup browser is created. The
	/// |browser| and |frame| values represent the source of the popup request
	/// (opener browser and frame). The |popup_id| value uniquely identifies the
	/// popup in the context of the opener browser. The |target_url| and
	/// |target_frame_name| values indicate where the popup browser should
	/// navigate and may be NULL if not specified with the request. The
	/// |target_disposition| value indicates where the user intended to open the
	/// popup (e.g. current tab, new tab, etc). The |user_gesture| value will be
	/// true (1) if the popup was opened via explicit user gesture (e.g. clicking
	/// a link) or false (0) if the popup opened automatically (e.g. via the
	/// DomContentLoaded event). The |popupFeatures| structure contains additional
	/// information about the requested popup window. To allow creation of the
	/// popup browser optionally modify |windowInfo|, |client|, |settings| and
	/// |no_javascript_access| and return false (0). To cancel creation of the
	/// popup browser return true (1). The |client| and |settings| values will
	/// default to the source browser's values. If the |no_javascript_access|
	/// value is set to false (0) the new browser will not be scriptable and may
	/// not be hosted in the same renderer process as the source browser. Any
	/// modifications to |windowInfo| will be ignored if the parent browser is
	/// wrapped in a cef_browser_view_t. The |extra_info| parameter provides an
	/// opportunity to specify extra information specific to the created popup
	/// browser that will be passed to
	/// cef_render_process_handler_t::on_browser_created() in the render process.
	///
	/// If popup browser creation succeeds then OnAfterCreated will be called for
	/// the new popup browser. If popup browser creation fails, and if the opener
	/// browser has not yet been destroyed, then OnBeforePopupAborted will be
	/// called for the opener browser. See OnBeforePopupAborted documentation for
	/// additional details.
	///
	on_before_popup:           proc "c" (
		self: ^Life_Span_Handler,
		browser: ^Browser,
		frame: ^Frame,
		popup_id: c.int,
		target_url: ^String,
		target_frame_name: ^String,
		target_disposition: Window_Open_Disposition,
		user_gesture: c.int,
		popup_features: ^Popup_Features,
		window_info: ^Window_Info,
		client: ^^Client,
		settings: ^Browser_Settings,
		extra_info: ^^Dictionary_Value,
		no_javascript_access: ^c.int,
	) -> c.int,

	///
	/// Called on the UI thread if a new popup browser is aborted. This only
	/// occurs if the popup is allowed in OnBeforePopup and creation fails before
	/// OnAfterCreated is called for the new popup browser. The |browser| value is
	/// the source of the popup request (opener browser). The |popup_id| value
	/// uniquely identifies the popup in the context of the opener browser, and is
	/// the same value that was passed to OnBeforePopup.
	///
	/// Any client state associated with pending popups should be cleared in
	/// OnBeforePopupAborted, OnAfterCreated of the popup browser, or
	/// OnBeforeClose of the opener browser. OnBeforeClose of the opener browser
	/// may be called before this function in cases where the opener is closing
	/// during popup creation, in which case cef_browser_host_t::IsValid will
	/// return false (0) in this function.
	///
	on_before_popup_aborted:   proc "c" (
		self: ^Life_Span_Handler,
		browser: ^Browser,
		popup_id: c.int,
	),

	///
	/// Called on the UI thread before a new DevTools popup browser is created.
	/// The |browser| value represents the source of the popup request. Optionally
	/// modify |windowInfo|, |client|, |settings| and |extra_info| values. The
	/// |client|, |settings| and |extra_info| values will default to the source
	/// browser's values. Any modifications to |windowInfo| will be ignored if the
	/// parent browser is Views-hosted (wrapped in a cef_browser_view_t).
	///
	/// The |extra_info| parameter provides an opportunity to specify extra
	/// information specific to the created popup browser that will be passed to
	/// cef_render_process_handler_t::on_browser_created() in the render process.
	/// The existing |extra_info| object, if any, will be read-only but may be
	/// replaced with a new object.
	///
	/// Views-hosted source browsers will create Views-hosted DevTools popups
	/// unless |use_default_window| is set to to true (1). DevTools popups can be
	/// blocked by returning true (1) from cef_command_handler_t::OnChromeCommand
	/// for IDC_DEV_TOOLS. Only used with Chrome style.
	///
	on_before_dev_tools_popup: proc "c" (
		self: ^Life_Span_Handler,
		browser: ^Browser,
		window_info: ^Window_Info,
		client: ^^Client,
		settings: ^Browser_Settings,
		extra_info: ^^Dictionary_Value,
		use_default_window: ^c.int,
	),

	///
	/// Called after a new browser is created. It is now safe to begin performing
	/// actions with |browser|. cef_frame_handler_t callbacks related to initial
	/// main frame creation will arrive before this callback. See
	/// cef_frame_handler_t documentation for additional usage information.
	///
	on_after_created:          proc "c" (self: ^Life_Span_Handler, browser: ^Browser),

	///
	/// Called when an Alloy style browser is ready to be closed, meaning that the
	/// close has already been initiated and that JavaScript unload handlers have
	/// already executed or should be ignored. This may result directly from a
	/// call to cef_browser_host_t::[Try]close_browser() or indirectly if the
	/// browser's top-level parent window was created by CEF and the user attempts
	/// to close that window (by clicking the 'X', for example). do_close() will
	/// not be called if the browser's host window/view has already been destroyed
	/// (via parent window/view hierarchy tear-down, for example), as it is no
	/// longer possible to customize the close behavior at that point.
	///
	/// An application should handle top-level parent window close notifications
	/// by calling cef_browser_host_t::try_close_browser() or
	/// cef_browser_host_t::CloseBrowser(false (0)) instead of allowing the window
	/// to close immediately (see the examples below). This gives CEF an
	/// opportunity to process JavaScript unload handlers and optionally cancel
	/// the close before do_close() is called.
	///
	/// When windowed rendering is enabled CEF will create an internal child
	/// window/view to host the browser. In that case returning false (0) from
	/// do_close() will send the standard close notification to the browser's top-
	/// level parent window (e.g. WM_CLOSE on Windows, performClose: on OS X,
	/// "delete_event" on Linux or cef_window_delegate_t::can_close() callback
	/// from Views).
	///
	/// When windowed rendering is disabled there is no internal window/view and
	/// returning false (0) from do_close() will cause the browser object to be
	/// destroyed immediately.
	///
	/// If the browser's top-level parent window requires a non-standard close
	/// notification then send that notification from do_close() and return true
	/// (1). You are still required to complete the browser close as soon as
	/// possible (either by calling [Try]close_browser() or by proceeding with
	/// window/view hierarchy tear-down), otherwise the browser will be left in a
	/// partially closed state that interferes with proper functioning. Top-level
	/// windows created on the browser process UI thread can alternately call
	/// cef_browser_host_t::is_ready_to_be_closed() in the close handler to check
	/// close status instead of relying on custom do_close() handling. See
	/// documentation on that function for additional details.
	///
	/// The cef_life_span_handler_t::on_before_close() function will be called
	/// after do_close() (if do_close() is called) and immediately before the
	/// browser object is destroyed. The application should only exit after
	/// on_before_close() has been called for all existing browsers.
	///
	/// The below examples describe what should happen during window close when
	/// the browser is parented to an application-provided top-level window.
	///
	/// Example 1: Using cef_browser_host_t::try_close_browser(). This is
	/// recommended for clients using standard close handling and windows created
	/// on the browser process UI thread. 1.  User clicks the window close button
	/// which sends a close notification
	///     to the application's top-level window.
	/// 2.  Application's top-level window receives the close notification and
	///     calls TryCloseBrowser() (similar to calling CloseBrowser(false)).
	///     TryCloseBrowser() returns false so the client cancels the window
	///     close.
	/// 3.  JavaScript 'onbeforeunload' handler executes and shows the close
	///     confirmation dialog (which can be overridden via
	///     CefJSDialogHandler::OnBeforeUnloadDialog()).
	/// 4.  User approves the close. 5.  JavaScript 'onunload' handler executes.
	/// 6.  Application's do_close() handler is called and returns false (0) by
	///     default.
	/// 7.  CEF sends a close notification to the application's top-level window
	///     (because DoClose() returned false).
	/// 8.  Application's top-level window receives the close notification and
	///     calls TryCloseBrowser(). TryCloseBrowser() returns true so the client
	///     allows the window close.
	/// 9.  Application's top-level window is destroyed, triggering destruction
	///     of the child browser window.
	/// 10. Application's on_before_close() handler is called and the browser
	/// object
	///     is destroyed.
	/// 11. Application exits by calling cef_quit_message_loop() if no other
	/// browsers
	///     exist.
	///
	/// Example 2: Using cef_browser_host_t::CloseBrowser(false (0)) and
	/// implementing the do_close() callback. This is recommended for clients
	/// using non-standard close handling or windows that were not created on the
	/// browser process UI thread. 1.  User clicks the window close button which
	/// sends a close notification
	///     to the application's top-level window.
	/// 2.  Application's top-level window receives the close notification and:
	///     A. Calls CefBrowserHost::CloseBrowser(false).
	///     B. Cancels the window close.
	/// 3.  JavaScript 'onbeforeunload' handler executes and shows the close
	///     confirmation dialog (which can be overridden via
	///     CefJSDialogHandler::OnBeforeUnloadDialog()).
	/// 4.  User approves the close. 5.  JavaScript 'onunload' handler executes.
	/// 6.  Application's do_close() handler is called. Application will:
	///     A. Set a flag to indicate that the next top-level window close attempt
	///        will be allowed.
	///     B. Return false.
	/// 7.  CEF sends a close notification to the application's top-level window
	///     (because DoClose() returned false).
	/// 8.  Application's top-level window receives the close notification and
	///     allows the window to close based on the flag from #6A.
	/// 9.  Application's top-level window is destroyed, triggering destruction
	///     of the child browser window.
	/// 10. Application's on_before_close() handler is called and the browser
	/// object
	///     is destroyed.
	/// 11. Application exits by calling cef_quit_message_loop() if no other
	/// browsers
	///     exist.
	///
	do_close:                  proc "c" (self: ^Life_Span_Handler, browser: ^Browser) -> c.int,

	///
	/// Called just before a browser is destroyed. Release all references to the
	/// browser object and do not attempt to execute any functions on the browser
	/// object (other than IsValid, GetIdentifier or IsSame) after this callback
	/// returns. cef_frame_handler_t callbacks related to final main frame
	/// destruction, and OnBeforePopupAborted callbacks for any pending popups,
	/// will arrive after this callback and cef_browser_t::IsValid will return
	/// false (0) at that time. Any in-progress network requests associated with
	/// |browser| will be aborted when the browser is destroyed, and
	/// cef_resource_request_handler_t callbacks related to those requests may
	/// still arrive on the IO thread after this callback. See cef_frame_handler_t
	/// and do_close() documentation for additional usage information.
	///
	on_before_close:           proc "c" (self: ^Life_Span_Handler, browser: ^Browser),
}

Frame :: struct {
	///
	/// Base structure.
	///
	base:                  Base_Ref_Counted,

	///
	/// True if this object is currently attached to a valid frame.
	///
	is_valid:              proc "c" (self: ^Frame) -> c.int,

	///
	/// Execute undo in this frame.
	///
	undo:                  proc "c" (self: ^Frame),

	///
	/// Execute redo in this frame.
	///
	redo:                  proc "c" (self: ^Frame),

	///
	/// Execute cut in this frame.
	///
	cut:                   proc "c" (self: ^Frame),

	///
	/// Execute copy in this frame.
	///
	copy:                  proc "c" (self: ^Frame),

	///
	/// Execute paste in this frame.
	///
	paste:                 proc "c" (self: ^Frame),

	///
	/// Execute paste and match style in this frame.
	///
	paste_and_match_style: proc "c" (self: ^Frame),

	///
	/// Execute delete in this frame.
	///
	del:                   proc "c" (self: ^Frame),

	///
	/// Execute select all in this frame.
	///
	select_all:            proc "c" (self: ^Frame),

	///
	/// Save this frame's HTML source to a temporary file and open it in the
	/// default text viewing application. This function can only be called from
	/// the browser process.
	///
	view_source:           proc "c" (self: ^Frame),

	///
	/// Retrieve this frame's HTML source as a string sent to the specified
	/// visitor.
	///
	get_source:            proc "c" (self: ^Frame, visitor: ^String_Visitor),

	///
	/// Retrieve this frame's display text as a string sent to the specified
	/// visitor.
	///
	get_text:              proc "c" (self: ^Frame, visitor: ^String_Visitor),

	///
	/// Load the request represented by the |request| object.
	///
	/// WARNING: This function will fail with "bad IPC message" reason
	/// INVALID_INITIATOR_ORIGIN (213) unless you first navigate to the request
	/// origin using some other mechanism (LoadURL, link click, etc).
	///
	load_request:          proc "c" (self: ^Frame, request: ^Request),

	///
	/// Load the specified |url|.
	///
	load_url:              proc "c" (self: ^Frame, url: ^String),

	///
	/// Execute a string of JavaScript code in this frame. The |script_url|
	/// parameter is the URL where the script in question can be found, if any.
	/// The renderer may request this URL to show the developer the source of the
	/// error.  The |start_line| parameter is the base line number to use for
	/// error reporting.
	///
	execute_java_script:   proc "c" (
		self: ^Frame,
		code: ^String,
		script_url: ^String,
		start_line: c.int,
	),

	///
	/// Returns true (1) if this is the main (top-level) frame.
	///
	is_main:               proc "c" (self: ^Frame) -> c.int,

	///
	/// Returns true (1) if this is the focused frame.
	///
	is_focused:            proc "c" (self: ^Frame) -> c.int,

	///
	/// Returns the name for this frame. If the frame has an assigned name (for
	/// example, set via the iframe "name" attribute) then that value will be
	/// returned. Otherwise a unique name will be constructed based on the frame
	/// parent hierarchy. The main (top-level) frame will always have an NULL name
	/// value.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_name:              proc "c" (self: ^Frame) -> ^String_Userfree,

	///
	/// Returns the globally unique identifier for this frame or NULL if the
	/// underlying frame does not yet exist.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_identifier:        proc "c" (self: ^Frame) -> ^String_Userfree,

	///
	/// Returns the parent of this frame or NULL if this is the main (top-level)
	/// frame.
	///
	get_parent:            proc "c" (self: ^Frame) -> ^Frame,

	///
	/// Returns the URL currently loaded in this frame.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_url:               proc "c" (self: ^Frame) -> ^String_Userfree,

	///
	/// Returns the browser that this frame belongs to.
	///
	get_browser:           proc "c" (self: ^Frame) -> ^Browser,

	///
	/// Get the V8 context associated with the frame. This function can only be
	/// called from the render process.
	///
	get_v8_context:        proc "c" (self: ^Frame) -> ^V8_Context,
}

Point :: struct {
	x: c.int,
	y: c.int,
}

Registration :: struct {
	base: Base_Ref_Counted,
}

Dev_Tools_Message_Observer :: struct {
	base: Base_Ref_Counted,
}

Navigation_Entry_Visitor :: struct {
	base: Base_Ref_Counted,
}

Key_Event :: struct {
	base: Base_Ref_Counted,
}

Mouse_Event :: struct {
	base: Base_Ref_Counted,
}

Mouse_Button_Type :: struct {
	base: Base_Ref_Counted,
}

Touch_Event :: struct {
	base: Base_Ref_Counted,
}

String_Visitor :: struct {
	///
	/// Base structure.
	///
	base:  Base_Ref_Counted,

	///
	/// Method that will be executed.
	///
	visit: proc "c" (self: ^String_Visitor, text: ^String),
}

Load_Handler :: struct {
	base:                    Base_Ref_Counted,
	on_loading_state_change: proc "c" (
		self: ^Load_Handler,
		browser: ^Browser,
		is_loading: c.int,
		can_go_back: c.int,
		can_go_forward: c.int,
	),
	on_load_start:           proc "c" (
		self: ^Load_Handler,
		browser: ^Browser,
		frame: ^Frame,
		transition_type: Transition_Type,
	),
	on_load_end:             proc "c" (
		self: ^Load_Handler,
		browser: ^Browser,
		frame: ^Frame,
		http_status_code: c.int,
	),
	on_load_error:           proc "c" (
		self: ^Load_Handler,
		browser: ^Browser,
		frame: ^Frame,
		error_code: Errorcode,
		error_text: ^String,
		failed_url: ^String,
	),
}
Print_Handler :: struct {
	base: Base_Ref_Counted,
}


Render_Handler :: struct {
	///
	/// Base structure.
	///
	base:                             Base_Ref_Counted,

	///
	/// Return the handler for accessibility notifications. If no handler is
	/// provided the default implementation will be used.
	///
	get_accessibility_handler:        proc "c" (self: ^Render_Handler) -> ^Accessibility_Handler,

	///
	/// Called to retrieve the root window rectangle in screen DIP coordinates.
	/// Return true (1) if the rectangle was provided. If this function returns
	/// false (0) the rectangle from GetViewRect will be used.
	///
	get_root_screen_rect:             proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		rect: ^Rect,
	) -> c.int,

	///
	/// Called to retrieve the view rectangle in screen DIP coordinates. This
	/// function must always provide a non-NULL rectangle.
	///
	get_view_rect:                    proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		rect: ^Rect,
	),

	///
	/// Called to retrieve the translation from view DIP coordinates to screen
	/// coordinates. Windows/Linux should provide screen device (pixel)
	/// coordinates and MacOS should provide screen DIP coordinates. Return true
	/// (1) if the requested coordinates were provided.
	///
	get_screen_point:                 proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		view_x, view_y: c.int,
		screen_x, screen_y: ^c.int,
	) -> c.int,

	///
	/// Called to allow the client to fill in the CefScreenInfo object with
	/// appropriate values. Return true (1) if the |screen_info| structure has
	/// been modified.
	///
	/// If the screen info rectangle is left NULL the rectangle from GetViewRect
	/// will be used. If the rectangle is still NULL or invalid popups may not be
	/// drawn correctly.
	///
	get_screen_info:                  proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		screen_info: ^Screen_Info,
	) -> c.int,

	///
	/// Called when the browser wants to show or hide the popup widget. The popup
	/// should be shown if |show| is true (1) and hidden if |show| is false (0).
	///
	on_popup_show:                    proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		show: c.int,
	),

	///
	/// Called when the browser wants to move or resize the popup widget. |rect|
	/// contains the new location and size in view coordinates.
	///
	on_popup_size:                    proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		rect: ^Rect,
	),

	///
	/// Called when an element should be painted. Pixel values passed to this
	/// function are scaled relative to view coordinates based on the value of
	/// CefScreenInfo.device_scale_factor returned from GetScreenInfo. |type|
	/// indicates whether the element is the view or the popup widget. |buffer|
	/// contains the pixel data for the whole image. |dirtyRects| contains the set
	/// of rectangles in pixel coordinates that need to be repainted. |buffer|
	/// will be |width|*|height|*4 bytes in size and represents a BGRA image with
	/// an upper-left origin. This function is only called when
	/// cef_window_tInfo::shared_texture_enabled is set to false (0).
	///
	on_paint:                         proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		type: Paint_Element_Type,
		dirty_rects_count: c.size_t,
		dirty_rects: [^]Rect,
		buffer: rawptr,
		width, height: c.int,
	),

	///
	/// Called when an element has been rendered to the shared texture handle.
	/// |type| indicates whether the element is the view or the popup widget.
	/// |dirtyRects| contains the set of rectangles in pixel coordinates that need
	/// to be repainted. |info| contains the shared handle; on Windows it is a
	/// HANDLE to a texture that can be opened with D3D11 OpenSharedResource, on
	/// macOS it is an IOSurface pointer that can be opened with Metal or OpenGL,
	/// and on Linux it contains several planes, each with an fd to the underlying
	/// system native buffer.
	///
	/// The underlying implementation uses a pool to deliver frames. As a result,
	/// the handle may differ every frame depending on how many frames are in-
	/// progress. The handle's resource cannot be cached and cannot be accessed
	/// outside of this callback. It should be reopened each time this callback is
	/// executed and the contents should be copied to a texture owned by the
	/// client application. The contents of |info| will be released back to the
	/// pool after this callback returns.
	///
	on_accelerated_paint:             proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		type: Paint_Element_Type,
		dirty_rects_count: c.size_t,
		dirty_rects: [^]Rect,
		info: [^]Accelerated_Paint_Info,
	),

	///
	/// Called to retrieve the size of the touch handle for the specified
	/// |orientation|.
	///
	get_touch_handle_size:            proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		orientation: Horizontal_Alignment,
		size: ^Size,
	),

	///
	/// Called when touch handle state is updated. The client is responsible for
	/// rendering the touch handles.
	///
	on_touch_handle_state_changed:    proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		state: ^Touch_Handle_State,
	),

	///
	/// Called when the user starts dragging content in the web view. Contextual
	/// information about the dragged content is supplied by |drag_data|. (|x|,
	/// |y|) is the drag start location in screen coordinates. OS APIs that run a
	/// system message loop may be used within the StartDragging call.
	///
	/// Return false (0) to abort the drag operation. Don't call any of
	/// cef_browser_host_t::DragSource*Ended* functions after returning false (0).
	///
	/// Return true (1) to handle the drag operation. Call
	/// cef_browser_host_t::DragSourceEndedAt and DragSourceSystemDragEnded either
	/// synchronously or asynchronously to inform the web view that the drag
	/// operation has ended.
	///
	start_dragging:                   proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		drag_data: ^Drag_Data,
		allowed_ops: Drag_Operations_Mask,
		x, y: c.int,
	) -> c.int,

	///
	/// Called when the web view wants to update the mouse cursor during a drag &
	/// drop operation. |operation| describes the allowed operation (none, move,
	/// copy, link).
	///
	update_drag_cursor:               proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		operation: Drag_Operations_Mask,
	),

	///
	/// Called when the scroll offset has changed.
	///
	on_scroll_offset_changed:         proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		x, y: c.double,
	),

	///
	/// Called when the IME composition range has changed. |selected_range| is the
	/// range of characters that have been selected. |character_bounds| is the
	/// bounds of each character in view coordinates.
	///
	on_ime_composition_range_changed: proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		selected_range: ^Range,
		character_bounds_count: c.size_t,
		character_bounds: [^]Rect,
	),

	///
	/// Called when text selection has changed for the specified |browser|.
	/// |selected_text| is the currently selected text and |selected_range| is the
	/// character range.
	///
	on_text_selection_changed:        proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		selected_text: ^String,
		selected_range: ^Range,
	),

	///
	/// Called when an on-screen keyboard should be shown or hidden for the
	/// specified |browser|. |input_mode| specifies what kind of keyboard should
	/// be opened. If |input_mode| is CEF_TEXT_INPUT_MODE_NONE, any existing
	/// keyboard for this browser should be hidden.
	///
	on_virtual_keyboard_requested:    proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		input_mode: Text_Input_Mode,
	),
}

Drag_Data :: struct {
	base: Base_Ref_Counted,
}

Screen_Info :: struct {
	base: Base_Ref_Counted,
}

Accessibility_Handler :: struct {
	base: Base_Ref_Counted,
}

Paint_Element_Type :: enum {
	View,
	Popup,
}

Accelerated_Paint_Info :: struct {
	size: c.size_t,
}

Horizontal_Alignment :: enum {
	Left,
	Center,
	Right,
}

Touch_Handle_State :: struct {
	size: c.size_t,
}

Drag_Operations_Mask :: enum c.uint32_t {
	None    = 0,
	Copy    = 1,
	Link    = 2,
	Generic = 4,
	Private = 8,
	Move    = 16,
	Delete  = 32,
	Every   = c.UINT32_MAX,
}

Text_Input_Mode :: enum {
	Default,
	None,
	Text,
	Tel,
	URL,
	Email,
	Numeric,
	Decimal,
	Search,
}

Range :: struct {
	from, to: c.uint32_t,
}

Request_Handler :: struct {
	base: Base_Ref_Counted,
}

Client :: struct {
	///
	/// Base structure.
	///
	base:                        Base_Ref_Counted,

	///
	/// Return the handler for audio rendering events.
	///
	get_audio_handler:           proc "c" (self: ^Client) -> ^Audio_Handler,

	///
	/// Return the handler for commands. If no handler is provided the default
	/// implementation will be used.
	///
	get_command_handler:         proc "c" (self: ^Client) -> ^Command_Handler,

	///
	/// Return the handler for context menus. If no handler is provided the
	/// default implementation will be used.
	///
	get_context_menu_handler:    proc "c" (self: ^Client) -> ^Context_Menu_Handler,

	///
	/// Return the handler for dialogs. If no handler is provided the default
	/// implementation will be used.
	///
	get_dialog_handler:          proc "c" (self: ^Client) -> ^Dialog_Handler,

	///
	/// Return the handler for browser display state events.
	///
	get_display_handler:         proc "c" (self: ^Client) -> ^Display_Handler,

	///
	/// Return the handler for download events. If no handler is returned
	/// downloads will not be allowed.
	///
	get_download_handler:        proc "c" (self: ^Client) -> ^Download_Handler,

	///
	/// Return the handler for drag events.
	///
	get_drag_handler:            proc "c" (self: ^Client) -> ^Drag_Handler,

	///
	/// Return the handler for find result events.
	///
	get_find_handler:            proc "c" (self: ^Client) -> ^Find_Handler,

	///
	/// Return the handler for focus events.
	///
	get_focus_handler:           proc "c" (self: ^Client) -> ^Focus_Handler,

	///
	/// Return the handler for events related to cef_frame_t lifespan. This
	/// function will be called once during cef_browser_t creation and the result
	/// will be cached for performance reasons.
	///
	get_frame_handler:           proc "c" (self: ^Client) -> ^Frame_Handler,

	///
	/// Return the handler for permission requests.
	///
	get_permission_handler:      proc "c" (self: ^Client) -> ^Permission_Handler,

	///
	/// Return the handler for JavaScript dialogs. If no handler is provided the
	/// default implementation will be used.
	///
	get_jsdialog_handler:        proc "c" (self: ^Client) -> ^JSDialog_Handler,

	///
	/// Return the handler for keyboard events.
	///
	get_keyboard_handler:        proc "c" (self: ^Client) -> ^Keyboard_Handler,

	///
	/// Return the handler for browser life span events.
	///
	get_life_span_handler:       proc "c" (self: ^Client) -> ^Life_Span_Handler,

	///
	/// Return the handler for browser load status events.
	///
	get_load_handler:            proc "c" (self: ^Client) -> ^Load_Handler,

	///
	/// Return the handler for printing on Linux. If a print handler is not
	/// provided then printing will not be supported on the Linux platform.
	///
	get_print_handler:           proc "c" (self: ^Client) -> ^Print_Handler,

	///
	/// Return the handler for off-screen rendering events.
	///
	get_render_handler:          proc "c" (self: ^Client) -> ^Render_Handler,

	///
	/// Return the handler for browser request events.
	///
	get_request_handler:         proc "c" (self: ^Client) -> ^Request_Handler,

	///
	/// Called when a new message is received from a different process. Return
	/// true (1) if the message was handled or false (0) otherwise.  It is safe to
	/// keep a reference to |message| outside of this callback.
	///
	on_process_message_received: proc "c" (
		self: ^Client,
		browser: ^Browser,
		frame: ^Frame,
		source_process: Process_ID,
		message: ^Process_Message,
	),
}

///
/// Structure used to represent a browser. When used in the browser process the
/// functions of this structure may be called on any thread unless otherwise
/// indicated in the comments. When used in the render process the functions of
/// this structure may only be called on the main thread.
///
/// NOTE: This struct is allocated DLL-side.
///
Browser :: struct {
	///
	/// Base structure.
	///
	base:                    Base_Ref_Counted,

	///
	/// True if this object is currently valid. This will return false (0) after
	/// cef_life_span_handler_t::OnBeforeClose is called.
	///
	is_valid:                proc "c" (self: ^Browser) -> c.int,

	///
	/// Returns the browser host object. This function can only be called in the
	/// browser process.
	///
	get_host:                proc "c" (self: ^Browser) -> ^Browser_Host,

	///
	/// Returns true (1) if the browser can navigate backwards.
	///
	can_go_back:             proc "c" (self: ^Browser) -> c.int,

	///
	/// Navigate backwards.
	///
	go_back:                 proc "c" (self: ^Browser),

	///
	/// Returns true (1) if the browser can navigate forwards.
	///
	can_go_forward:          proc "c" (self: ^Browser) -> c.int,

	///
	/// Navigate forwards.
	///
	go_forward:              proc "c" (self: ^Browser),

	///
	/// Returns true (1) if the browser is currently loading.
	///
	is_loading:              proc "c" (self: ^Browser) -> c.int,

	///
	/// Reload the current page.
	///
	reload:                  proc "c" (self: ^Browser),

	///
	/// Reload the current page ignoring any cached data.
	///
	reload_ignore_cache:     proc "c" (self: ^Browser),

	///
	/// Stop loading the page.
	///
	stop_load:               proc "c" (self: ^Browser),

	///
	/// Returns the globally unique identifier for this browser. This value is
	/// also used as the tabId for extension APIs.
	///
	get_identifier:          proc "c" (self: ^Browser) -> c.int,

	///
	/// Returns true (1) if this object is pointing to the same handle as |that|
	/// object.
	///
	is_same:                 proc "c" (self: ^Browser, that: ^Browser) -> c.int,

	///
	/// Returns true (1) if the browser is a popup.
	///
	is_popup:                proc "c" (self: ^Browser) -> c.int,

	///
	/// Returns true (1) if a document has been loaded in the browser.
	///
	has_document:            proc "c" (self: ^Browser) -> c.int,

	///
	/// Returns the main (top-level) frame for the browser. In the browser process
	/// this will return a valid object until after
	/// cef_life_span_handler_t::OnBeforeClose is called. In the renderer process
	/// this will return NULL if the main frame is hosted in a different renderer
	/// process (e.g. for cross-origin sub-frames). The main frame object will
	/// change during cross-origin navigation or re-navigation after renderer
	/// process termination (due to crashes, etc).
	///
	get_main_frame:          proc "c" (self: ^Browser) -> ^Frame,

	///
	/// Returns the focused frame for the browser.
	///
	get_focused_frame:       proc "c" (self: ^Browser) -> ^Frame,

	///
	/// Returns the frame with the specified identifier, or NULL if not found.
	///
	get_frame_by_identifier: proc "c" (self: ^Browser, identifier: ^String) -> ^Frame,

	///
	/// Returns the frame with the specified name, or NULL if not found.
	///
	get_frame_by_name:       proc "c" (self: ^Browser, name: ^String) -> ^Frame,

	///
	/// Returns the number of frames that currently exist.
	///
	get_frame_count:         proc "c" (self: ^Browser) -> c.int,

	///
	/// Returns the identifiers of all existing frames.
	///
	get_frame_identifiers:   proc "c" (self: ^Browser, identifiers: String_List),

	///
	/// Returns the names of all existing frames.
	///
	get_frame_names:         proc "c" (self: ^Browser, names: String_List),
}

Basetime :: distinct c.int64_t

Task_Runner :: struct {
	base: Base_Ref_Counted,
}

V8_Property_Attribute :: enum {
	None,
	Read_Only,
	Dont_Enum,
	Dont_Delete,
}

///
/// Structure that should be implemented to handle V8 function calls. The
/// functions of this structure will be called on the thread associated with the
/// V8 function.
///
/// NOTE: This struct is allocated client-side.
///
V8_Handler :: struct {
	///
	/// Base structure.
	///
	base:    Base_Ref_Counted,

	///
	/// Handle execution of the function identified by |name|. |object| is the
	/// receiver ('this' object) of the function. |arguments| is the list of
	/// arguments passed to the function. If execution succeeds set |retval| to
	/// the function return value. If execution fails set |exception| to the
	/// exception that will be thrown. Return true (1) if execution was handled.
	///
	execute: proc "c" (
		self: ^V8_Handler,
		name: ^String,
		object: ^V8_Value,
		arguments_count: c.size_t,
		arguments: [^]V8_Value,
		retval: ^^V8_Value,
		exception: ^String,
	) -> c.int,
}

///
/// Structure representing a V8 context handle. V8 handles can only be accessed
/// from the thread on which they are created. Valid threads for creating a V8
/// handle include the render process main thread (TID_RENDERER) and WebWorker
/// threads. A task runner for posting tasks on the associated thread can be
/// retrieved via the cef_v8_context_t::get_task_runner() function.
///
/// NOTE: This struct is allocated DLL-side.
///
V8_Context :: struct {
	///
	/// Base structure.
	///
	base:            Base_Ref_Counted,

	///
	/// Returns the task runner associated with this context. V8 handles can only
	/// be accessed from the thread on which they are created. This function can
	/// be called on any render process thread.
	///
	get_task_runner: proc "c" (self: ^V8_Context) -> ^Task_Runner,

	///
	/// Returns true (1) if the underlying handle is valid and it can be accessed
	/// on the current thread. Do not call any other functions if this function
	/// returns false (0).
	///
	is_valid:        proc "c" (self: ^V8_Context) -> c.int,

	///
	/// Returns the browser for this context. This function will return an NULL
	/// reference for WebWorker contexts.
	///
	get_browser:     proc "c" (self: ^V8_Context) -> ^Browser,

	///
	/// Returns the frame for this context. This function will return an NULL
	/// reference for WebWorker contexts.
	///
	get_frame:       proc "c" (self: ^V8_Context) -> ^Frame,

	///
	/// Returns the global object for this context. The context must be entered
	/// before calling this function.
	///
	get_global:      proc "c" (self: ^V8_Context) -> ^Value,

	///
	/// Enter this context. A context must be explicitly entered before creating a
	/// V8 Object, Array, Function or Date asynchronously. exit() must be called
	/// the same number of times as enter() before releasing this context. V8
	/// objects belong to the context in which they are created. Returns true (1)
	/// if the scope was entered successfully.
	///
	enter:           proc "c" (self: ^V8_Context) -> c.int,

	///
	/// Exit this context. Call this function only after calling enter(). Returns
	/// true (1) if the scope was exited successfully.
	///
	exit:            proc "c" (self: ^V8_Context) -> c.int,

	///
	/// Returns true (1) if this object is pointing to the same handle as |that|
	/// object.
	///
	is_same:         proc "c" (self: ^V8_Context, that: ^V8_Context) -> c.int,

	///
	/// Execute a string of JavaScript code in this V8 context. The |script_url|
	/// parameter is the URL where the script in question can be found, if any.
	/// The |start_line| parameter is the base line number to use for error
	/// reporting. On success |retval| will be set to the return value, if any,
	/// and the function will return true (1). On failure |exception| will be set
	/// to the exception, if any, and the function will return false (0).
	///
	eval:            proc "c" (
		self: ^V8_Context,
		code: ^String,
		script_url: ^String,
		start_line: c.int,
		retval: ^^V8_Value,
		exception: ^^V8_Exception,
	) -> c.int,
}

///
/// Structure representing a V8 value handle. V8 handles can only be accessed
/// from the thread on which they are created. Valid threads for creating a V8
/// handle include the render process main thread (TID_RENDERER) and WebWorker
/// threads. A task runner for posting tasks on the associated thread can be
/// retrieved via the cef_v8_context_t::get_task_runner() function.
///
/// NOTE: This struct is allocated DLL-side.
///
V8_Value :: struct {
	///
	/// Base structure.
	///
	base:                    Base_Ref_Counted,

	///
	/// Returns true (1) if the underlying handle is valid and it can be accessed
	/// on the current thread. Do not call any other functions if this function
	/// returns false (0).
	///
	is_valid:                proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is undefined.
	///
	is_undefined:            proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is null.
	///
	is_null:                 proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is bool.
	///
	is_bool:                 proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is int.
	///
	is_int:                  proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is unsigned int.
	///
	is_uint:                 proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is double.
	///
	is_double:               proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is Date.
	///
	is_date:                 proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is string.
	///
	is_string:               proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is object.
	///
	is_object:               proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is array.
	///
	is_array:                proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is an ArrayBuffer.
	///
	is_array_buffer:         proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is function.
	///
	is_function:             proc "c" (self: ^V8_Value) -> c.int,

	///
	/// True if the value type is a Promise.
	///
	is_promise:              proc "c" (self: ^V8_Value) -> c.int,

	///
	/// Returns true (1) if this object is pointing to the same handle as |that|
	/// object.
	///
	is_same:                 proc "c" (self: ^V8_Value, that: ^V8_Value) -> c.int,

	///
	/// Return a bool value.
	///
	get_bool_value:          proc "c" (self: ^V8_Value) -> c.int,

	///
	/// Return an int value.
	///
	get_int_value:           proc "c" (self: ^V8_Value) -> c.int32_t,

	///
	/// Return an unsigned int value.
	///
	get_uint_value:          proc "c" (self: ^V8_Value) -> c.uint32_t,

	///
	/// Return a double value.
	///
	get_double_value:        proc "c" (self: ^V8_Value) -> c.double,

	///
	/// Return a Date value.
	///
	get_date_value:          proc "c" (self: ^V8_Value) -> Basetime,

	///
	/// Return a string value.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_string_value:        proc "c" (self: ^V8_Value) -> String_Userfree,

	///
	/// Returns true (1) if this is a user created object.
	///
	is_user_created:         proc "c" (self: ^V8_Value) -> c.int,

	///
	/// Returns true (1) if the last function call resulted in an exception. This
	/// attribute exists only in the scope of the current CEF value object.
	///
	has_exception:           proc "c" (self: ^V8_Value) -> c.int,

	///
	/// Returns the exception resulting from the last function call. This
	/// attribute exists only in the scope of the current CEF value object.
	///
	get_exception:           proc "c" (self: ^V8_Value) -> ^V8_Exception,

	///
	/// Clears the last exception and returns true (1) on success.
	///
	clear_exception:         proc "c" (self: ^V8_Value) -> c.int,

	///
	/// Returns true (1) if this object will re-throw future exceptions. This
	/// attribute exists only in the scope of the current CEF value object.
	///
	will_rethrow_exceptions: proc "c" (self: ^V8_Value) -> c.int,

	///
	/// Set whether this object will re-throw future exceptions. By default
	/// exceptions are not re-thrown. If a exception is re-thrown the current
	/// context should not be accessed again until after the exception has been
	/// caught and not re-thrown. Returns true (1) on success. This attribute
	/// exists only in the scope of the current CEF value object.
	///
	set_rethrow_exceptions:  proc "c" (self: ^V8_Value, rethrow: c.int) -> c.int,

	///
	/// Returns true (1) if the object has a value with the specified identifier.
	///
	has_value_bykey:         proc "c" (self: ^V8_Value, key: ^String) -> c.int,

	///
	/// Returns true (1) if the object has a value with the specified identifier.
	///
	has_value_byindex:       proc "c" (self: ^V8_Value, index: c.int) -> c.int,

	///
	/// Deletes the value with the specified identifier and returns true (1) on
	/// success. Returns false (0) if this function is called incorrectly or an
	/// exception is thrown. For read-only and don't-delete values this function
	/// will return true (1) even though deletion failed.
	///
	delete_value_bykey:      proc "c" (self: ^V8_Value, key: ^String) -> c.int,

	///
	/// Deletes the value with the specified identifier and returns true (1) on
	/// success. Returns false (0) if this function is called incorrectly or an
	/// exception is thrown. For read-only and don't-delete values this function
	/// will return true (1) even though deletion failed.
	///
	delete_value_byindex:    proc "c" (self: ^V8_Value, index: c.int) -> c.int,

	///
	/// Returns the value with the specified identifier on success. Returns NULL
	/// if this function is called incorrectly or an exception is thrown.
	///
	get_value_bykey:         proc "c" (self: ^V8_Value, key: ^String) -> ^V8_Value,

	///
	/// Returns the value with the specified index on success. Returns NULL
	/// if this function is called incorrectly or an exception is thrown.
	///
	get_value_byindex:       proc "c" (self: ^V8_Value, index: c.int) -> ^V8_Value,

	///
	/// Associates a value with the specified identifier and returns true (1) on
	/// success. Returns false (0) if this function is called incorrectly or an
	/// exception is thrown. For read-only values this function will return true
	/// (1) even though assignment failed.
	///
	set_value_bykey:         proc "c" (
		self: ^V8_Value,
		key: ^String,
		value: ^V8_Value,
		attribute: V8_Property_Attribute,
	) -> c.int,

	///
	/// Associates a value with the specified index and returns true (1) on
	/// success. Returns false (0) if this function is called incorrectly or an
	/// exception is thrown. For read-only values this function will return true
	/// (1) even though assignment failed.
	///
	set_value_byindex:       proc "c" (self: ^V8_Value, index: c.int, value: ^V8_Value) -> c.int,
}

///
/// Structure representing a V8 exception. The functions of this structure may
/// be called on any render process thread.
///
/// NOTE: This struct is allocated DLL-side.
///
V8_Exception :: struct {
	///
	/// Base structure.
	///
	base:        Base_Ref_Counted,

	///
	/// Returns the exception message.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_message: proc "c" (self: ^V8_Exception) -> String_Userfree,
}

///
/// Structure representing a V8 stack trace handle. V8 handles can only be
/// accessed from the thread on which they are created. Valid threads for
/// creating a V8 handle include the render process main thread (TID_RENDERER)
/// and WebWorker threads. A task runner for posting tasks on the associated
/// thread can be retrieved via the cef_v8_context_t::get_task_runner()
/// function.
///
/// NOTE: This struct is allocated DLL-side.
///
V8_Stack_Trace :: struct {
	///
	/// Base structure.
	///
	base:            Base_Ref_Counted,

	///
	/// Returns true (1) if the underlying handle is valid and it can be accessed
	/// on the current thread. Do not call any other functions if this function
	/// returns false (0).
	///
	is_valid:        proc "c" (self: ^V8_Stack_Trace) -> c.int,

	///
	/// Returns the number of frames on the stack.
	///
	get_frame_count: proc "c" (self: ^V8_Stack_Trace) -> c.int,

	///
	/// Returns the stack frame at the specified 0-based index.
	///
	get_frame:       proc "c" (self: ^V8_Stack_Trace, index: c.int) -> ^V8_Stack_Frame,
}

///
/// Structure representing a V8 stack frame handle. V8 handles can only be
/// accessed from the thread on which they are created. Valid threads for
/// creating a V8 handle include the render process main thread (TID_RENDERER)
/// and WebWorker threads. A task runner for posting tasks on the associated
/// thread can be retrieved via the cef_v8_context_t::get_task_runner()
/// function.
///
/// NOTE: This struct is allocated DLL-side.
///
V8_Stack_Frame :: struct {
	///
	/// Base structure.
	///
	base:                          Base_Ref_Counted,

	///
	/// Returns true (1) if the underlying handle is valid and it can be accessed
	/// on the current thread. Do not call any other functions if this function
	/// returns false (0).
	///
	is_valid:                      proc "c" (self: ^V8_Stack_Frame) -> c.int,

	///
	/// Returns the name of the resource script that contains the function.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_script_name:               proc "c" (self: ^V8_Stack_Frame) -> ^String_Userfree,

	///
	/// Returns the name of the resource script that contains the function or the
	/// sourceURL value if the script name is undefined and its source ends with a
	/// "//@ sourceURL=..." string.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_script_name_or_source_url: proc "c" (self: ^V8_Stack_Frame) -> ^String_Userfree,

	///
	/// Returns the name of the function.
	///
	// The resulting string must be freed by calling cef_string_userfree_free().
	get_function_name:             proc "c" (self: ^V8_Stack_Frame) -> ^String_Userfree,

	///
	/// Returns the 1-based line number for the function call or 0 if unknown.
	///
	get_line_number:               proc "c" (self: ^V8_Stack_Frame) -> c.int,

	///
	/// Returns the 1-based column offset on the line for the function call or 0
	/// if unknown.
	///
	get_column:                    proc "c" (self: ^V8_Stack_Frame) -> c.int,

	///
	/// Returns true (1) if the function was compiled using eval().
	///
	is_eval:                       proc "c" (self: ^V8_Stack_Frame) -> c.int,

	///
	/// Returns true (1) if the function was called as a constructor via "new".
	///
	is_constructor:                proc "c" (self: ^V8_Stack_Frame) -> c.int,
}

///
/// Callback structure that is passed to cef_v8_value_t::CreateArrayBuffer.
///
/// NOTE: This struct is allocated client-side.
///
V8_Array_Buffer_Release_Callback :: struct {
	///
	/// Base structure.
	///
	base:           Base_Ref_Counted,

	///
	/// Called to release |buffer| when the ArrayBuffer JS object is garbage
	/// collected. |buffer| is the value that was passed to CreateArrayBuffer
	/// along with this object.
	///
	release_buffer: proc "c" (self: ^V8_Array_Buffer_Release_Callback, buffer: rawptr),
}

///
/// Structure that should be implemented to handle V8 accessor calls. Accessor
/// identifiers are registered by calling cef_v8_value_t::set_value(). The
/// functions of this structure will be called on the thread associated with the
/// V8 accessor.
///
/// NOTE: This struct is allocated client-side.
///
V8_Accessor :: struct {
	///
	/// Base structure.
	///
	base: Base_Ref_Counted,

	///
	/// Handle retrieval the accessor value identified by |name|. |object| is the
	/// receiver ('this' object) of the accessor. If retrieval succeeds set
	/// |retval| to the return value. If retrieval fails set |exception| to the
	/// exception that will be thrown. Return true (1) if accessor retrieval was
	/// handled.
	///
	get:  proc "c" (
		self: ^V8_Accessor,
		name: ^String,
		object: ^V8_Value,
		retval: ^^V8_Value,
		exception: ^String,
	) -> c.int,

	///
	/// Handle assignment of the accessor value identified by |name|. |object| is
	/// the receiver ('this' object) of the accessor. |value| is the new value
	/// being assigned to the accessor. If assignment fails set |exception| to the
	/// exception that will be thrown. Return true (1) if accessor assignment was
	/// handled.
	///
	set:  proc "c" (
		self: ^V8_Accessor,
		name: ^String,
		object: ^V8_Value,
		value: ^V8_Value,
		exception: ^String,
	) -> c.int,
}

///
/// Structure that should be implemented to handle V8 interceptor calls. The
/// functions of this structure will be called on the thread associated with the
/// V8 interceptor. Interceptor's named property handlers (with first argument
/// of type CefString) are called when object is indexed by string. Indexed
/// property handlers (with first argument of type int) are called when object
/// is indexed by integer.
///
/// NOTE: This struct is allocated client-side.
///
V8_Interceptor :: struct {
	///
	/// Base structure.
	///
	base:        Base_Ref_Counted,

	///
	/// Handle retrieval of the interceptor value identified by |name|. |object|
	/// is the receiver ('this' object) of the interceptor. If retrieval succeeds,
	/// set |retval| to the return value. If the requested value does not exist,
	/// don't set either |retval| or |exception|. If retrieval fails, set
	/// |exception| to the exception that will be thrown. If the property has an
	/// associated accessor, it will be called only if you don't set |retval|.
	/// Return true (1) if interceptor retrieval was handled, false (0) otherwise.
	///
	get_byname:  proc "c" (
		self: ^V8_Interceptor,
		name: ^String,
		object: ^V8_Value,
		retval: ^^V8_Value,
		exception: ^String,
	) -> c.int,

	///
	/// Handle retrieval of the interceptor value identified by |index|. |object|
	/// is the receiver ('this' object) of the interceptor. If retrieval succeeds,
	/// set |retval| to the return value. If the requested value does not exist,
	/// don't set either |retval| or |exception|. If retrieval fails, set
	/// |exception| to the exception that will be thrown. Return true (1) if
	/// interceptor retrieval was handled, false (0) otherwise.
	///
	get_byindex: proc "c" (
		self: ^V8_Interceptor,
		index: int,
		object: ^V8_Value,
		retval: ^^V8_Value,
		exception: ^String,
	) -> c.int,

	///
	/// Handle assignment of the interceptor value identified by |name|. |object|
	/// is the receiver ('this' object) of the interceptor. |value| is the new
	/// value being assigned to the interceptor. If assignment fails, set
	/// |exception| to the exception that will be thrown. This setter will always
	/// be called, even when the property has an associated accessor. Return true
	/// (1) if interceptor assignment was handled, false (0) otherwise.
	///
	set_byname:  proc "c" (
		self: ^V8_Interceptor,
		name: ^String,
		object: ^V8_Value,
		value: ^V8_Value,
		exception: ^String,
	) -> c.int,

	///
	/// Handle assignment of the interceptor value identified by |index|. |object|
	/// is the receiver ('this' object) of the interceptor. |value| is the new
	/// value being assigned to the interceptor. If assignment fails, set
	/// |exception| to the exception that will be thrown. Return true (1) if
	/// interceptor assignment was handled, false (0) otherwise.
	///
	set_byindex: proc "c" (
		self: ^V8_Interceptor,
		index: int,
		object: ^V8_Value,
		value: ^V8_Value,
		exception: ^String,
	) -> c.int,
}

