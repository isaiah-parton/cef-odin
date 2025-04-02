package cef

import "core:c/libc"
import "core:math"

_String :: struct($T: typeid) {
	str:    [^]T,
	length: libc.size_t,
	dtor:   proc "c" (_: [^]T),
}

String :: distinct _String(libc.char16_t)

String_Wide :: _String(libc.wchar_t)
String_UTF8 :: _String(libc.char)
String_UTF16 :: _String(libc.char16_t)

Errorcode :: enum libc.int {
	None,
}

Transition_Type :: enum libc.int {
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

PDF_Print_Margin_Type :: enum libc.int {
	Default,
	None,
	Custom,
}

PDF_Print_Settings :: struct {
	///
	/// Size of this structure.
	///
	size:                      libc.size_t,

	///
	/// Set to true (1) for landscape mode or false (0) for portrait mode.
	///
	landscape:                 libc.int,

	///
	/// Set to true (1) to print background graphics.
	///
	print_background:          libc.int,

	///
	/// The percentage to scale the PDF by before printing (e.g. .5 is 50%).
	/// If this value is less than or equal to zero the default value of 1.0
	/// will be used.
	///
	scale:                     libc.double,

	///
	/// Output paper size in inches. If either of these values is less than or
	/// equal to zero then the default paper size (letter, 8.5 x 11 inches) will
	/// be used.
	///
	paper_width:               libc.double,
	paper_height:              libc.double,

	///
	/// Set to true (1) to prefer page size as defined by css. Defaults to false
	/// (0), in which case the content will be scaled to fit the paper size.
	///
	prefer_css_page_size:      libc.int,

	///
	/// Margin type.
	///
	margin_type:               PDF_Print_Margin_Type,

	///
	/// Margins in inches. Only used if |margin_type| is set to
	/// PDF_PRINT_MARGIN_CUSTOM.
	///
	margin_top:                libc.double,
	margin_right:              libc.double,
	margin_bottom:             libc.double,
	margin_left:               libc.double,

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
	display_header_footer:     libc.int,

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
	generate_tagged_pdf:       libc.int,

	///
	/// Set to true (1) to generate a document outline.
	///
	generate_document_outline: libc.int,
}
Popup_Features :: struct {
	size:       libc.size_t,
	x:          libc.int,
	x_set:      libc.int,
	y:          libc.int,
	y_set:      libc.int,
	width:      libc.int,
	width_set:  libc.int,
	height:     libc.int,
	height_set: libc.int,
	is_popup:   libc.int,
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
	close_browser:                  proc "c" (self: ^Browser_Host, force_close: libc.int),

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
	try_close_browser:              proc "c" (self: ^Browser_Host) -> libc.int,

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
	is_ready_to_be_closed:          proc "c" (self: ^Browser_Host) -> libc.int,

	///
	/// Set whether the browser is focused.
	///
	set_focus:                      proc "c" (self: ^Browser_Host, focus: libc.int),

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
	get_opener_identifier:          proc "c" (self: ^Browser_Host) -> libc.int,

	///
	/// Returns true (1) if this browser is wrapped in a cef_browser_view_t.
	///
	has_view:                       proc "c" (self: ^Browser_Host) -> libc.int,

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
	can_zoom:                       proc "c" (
		self: ^Browser_Host,
		command: Zoom_Command,
	) -> libc.int,

	///
	/// Execute a zoom command in this browser. If called on the UI thread the
	/// change will be applied immediately. Otherwise, the change will be applied
	/// asynchronously on the UI thread.
	///
	zoom:                           proc "c" (
		self: ^Browser_Host,
		command: Zoom_Command,
	) -> libc.int,

	///
	/// Get the default zoom level. This value will be 0.0 by default but can be
	/// configured. This function can only be called on the UI thread.
	///
	get_default_zoom_level:         proc "c" (self: ^Browser_Host) -> libc.double,

	///
	/// Get the current zoom level. This function can only be called on the UI
	/// thread.
	///
	get_zoom_level:                 proc "c" (self: ^Browser_Host) -> libc.double,

	///
	/// Change the zoom level to the specified value. Specify 0.0 to reset the
	/// zoom level to the default. If called on the UI thread the change will be
	/// applied immediately. Otherwise, the change will be applied asynchronously
	/// on the UI thread.
	///
	set_zoom_level:                 proc "c" (self: ^Browser_Host, zoom_level: libc.double),

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
		is_favicon: libc.int,
		max_image_size: libc.uint32_t,
		bypass_cache: libc.int,
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
		forward, match_case, find_next: libc.int,
	),

	///
	/// Cancel all searches that are currently going on.
	///
	stop_finding:                   proc "c" (self: ^Browser_Host, clear_selection: libc.int),

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
	has_dev_tools:                  proc "c" (self: ^Browser_Host) -> libc.int,

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
		message_size: libc.size_t,
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
		message_id: libc.int,
		method: ^String,
		params: ^Dictionary_Value,
	) -> libc.int,

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
		current_only: libc.int,
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
	is_window_rendering_disabled:   proc "c" (self: ^Browser_Host) -> libc.int,

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
	was_hidden:                     proc "c" (self: ^Browser_Host, hidden: libc.int),

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
		mouse_up: libc.int,
		click_count: libc.int,
	),

	///
	/// Send a mouse move event to the browser. The |x| and |y| coordinates are
	/// relative to the upper-left corner of the view.
	///
	send_mouse_move_event:          proc "c" (
		self: ^Browser_Host,
		event: ^Mouse_Event,
		mouse_leave: libc.int,
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
		delta_x, delta_y: libc.int,
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
	get_windowless_frame_rate:      proc "c" (self: ^Browser_Host) -> libc.int,

	///
	/// Set the maximum rate in frames per second (fps) that
	/// cef_render_handler_t:: OnPaint will be called for a windowless browser.
	/// The actual fps may be lower if the browser cannot generate frames at the
	/// requested rate. The minimum value is 1 and the maximum value is 60
	/// (default 30). Can also be set at browser creation via
	/// cef_browser_tSettings.windowless_frame_rate.
	///
	set_windowless_frame_rate:      proc "c" (self: ^Browser_Host, frame_rate: libc.int),
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
		http_status_code: libc.int,
		image: ^Image,
	),
}
Image :: struct {
	base: Base_Ref_Counted,
}
PDF_Print_Callback :: struct {
	base:                  Base_Ref_Counted,
	on_pdf_print_finished: proc "c" (self: ^PDF_Print_Callback, path: ^String, ok: libc.int),
}
Process_ID :: enum libc.int {
	Browser,
	Renderer,
}
Process_Message :: struct {
	base: Base_Ref_Counted,
}
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
	is_valid:        proc "c" (self: ^V8_Context) -> libc.int,

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
	enter:           proc "c" (self: ^V8_Context) -> libc.int,

	///
	/// Exit this context. Call this function only after calling enter(). Returns
	/// true (1) if the scope was exited successfully.
	///
	exit:            proc "c" (self: ^V8_Context) -> libc.int,

	///
	/// Returns true (1) if this object is pointing to the same handle as |that|
	/// object.
	///
	is_same:         proc "c" (self: ^V8_Context, that: ^V8_Context) -> libc.int,

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
		start_line: libc.int,
		retval: ^^V8_Value,
		exception: ^^V8_Exception,
	) -> libc.int,
}
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
	is_valid:                proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is undefined.
	///
	is_undefined:            proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is null.
	///
	is_null:                 proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is bool.
	///
	is_bool:                 proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is int.
	///
	is_int:                  proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is unsigned int.
	///
	is_uint:                 proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is double.
	///
	is_double:               proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is Date.
	///
	is_date:                 proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is string.
	///
	is_string:               proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is object.
	///
	is_object:               proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is array.
	///
	is_array:                proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is an ArrayBuffer.
	///
	is_array_buffer:         proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is function.
	///
	is_function:             proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// True if the value type is a Promise.
	///
	is_promise:              proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// Returns true (1) if this object is pointing to the same handle as |that|
	/// object.
	///
	is_same:                 proc "c" (self: ^V8_Value, that: ^V8_Value) -> libc.int,

	///
	/// Return a bool value.
	///
	get_bool_value:          proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// Return an int value.
	///
	get_int_value:           proc "c" (self: ^V8_Value) -> libc.int32_t,

	///
	/// Return an unsigned int value.
	///
	get_uint_value:          proc "c" (self: ^V8_Value) -> libc.uint32_t,

	///
	/// Return a double value.
	///
	get_double_value:        proc "c" (self: ^V8_Value) -> libc.double,

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
	is_user_created:         proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// Returns true (1) if the last function call resulted in an exception. This
	/// attribute exists only in the scope of the current CEF value object.
	///
	has_exception:           proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// Returns the exception resulting from the last function call. This
	/// attribute exists only in the scope of the current CEF value object.
	///
	get_exception:           proc "c" (self: ^V8_Value) -> ^V8_Exception,

	///
	/// Clears the last exception and returns true (1) on success.
	///
	clear_exception:         proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// Returns true (1) if this object will re-throw future exceptions. This
	/// attribute exists only in the scope of the current CEF value object.
	///
	will_rethrow_exceptions: proc "c" (self: ^V8_Value) -> libc.int,

	///
	/// Set whether this object will re-throw future exceptions. By default
	/// exceptions are not re-thrown. If a exception is re-thrown the current
	/// context should not be accessed again until after the exception has been
	/// caught and not re-thrown. Returns true (1) on success. This attribute
	/// exists only in the scope of the current CEF value object.
	///
	set_rethrow_exceptions:  proc "c" (self: ^V8_Value, rethrow: libc.int) -> libc.int,

	///
	/// Returns true (1) if the object has a value with the specified identifier.
	///
	has_value_bykey:         proc "c" (self: ^V8_Value, key: ^String) -> libc.int,

	///
	/// Returns true (1) if the object has a value with the specified identifier.
	///
	has_value_byindex:       proc "c" (self: ^V8_Value, index: libc.int) -> libc.int,

	///
	/// Deletes the value with the specified identifier and returns true (1) on
	/// success. Returns false (0) if this function is called incorrectly or an
	/// exception is thrown. For read-only and don't-delete values this function
	/// will return true (1) even though deletion failed.
	///
	delete_value_bykey:      proc "c" (self: ^V8_Value, key: ^String) -> libc.int,

	///
	/// Deletes the value with the specified identifier and returns true (1) on
	/// success. Returns false (0) if this function is called incorrectly or an
	/// exception is thrown. For read-only and don't-delete values this function
	/// will return true (1) even though deletion failed.
	///
	delete_value_byindex:    proc "c" (self: ^V8_Value, index: libc.int) -> libc.int,

	///
	/// Returns the value with the specified identifier on success. Returns NULL
	/// if this function is called incorrectly or an exception is thrown.
	///
	get_value_bykey:         proc "c" (self: ^V8_Value, key: ^String) -> ^V8_Value,

	///
	/// Returns the value with the specified index on success. Returns NULL
	/// if this function is called incorrectly or an exception is thrown.
	///
	get_value_byindex:       proc "c" (self: ^V8_Value, index: libc.int) -> ^V8_Value,

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
	) -> libc.int,

	///
	/// Associates a value with the specified index and returns true (1) on
	/// success. Returns false (0) if this function is called incorrectly or an
	/// exception is thrown. For read-only values this function will return true
	/// (1) even though assignment failed.
	///
	set_value_byindex:       proc "c" (
		self: ^V8_Value,
		index: libc.int,
		value: ^V8_Value,
	) -> libc.int,
}
Task_Runner :: struct {
	base: Base_Ref_Counted,
}
Basetime :: distinct i64
V8_Property_Attribute :: enum {
	None,
	Read_Only,
	Dont_Enum,
	Dont_Delete,
}
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
V8_Stack_Trace :: struct {
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
		popup_id: libc.int,
		target_url: ^String,
		target_frame_name: ^String,
		target_disposition: Window_Open_Disposition,
		user_gesture: libc.int,
		popup_features: ^Popup_Features,
		window_info: ^Window_Info,
		client: ^^Client,
		settings: ^Browser_Settings,
		extra_info: ^^Dictionary_Value,
		no_javascript_access: ^libc.int,
	) -> libc.int,

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
		popup_id: libc.int,
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
		use_default_window: ^libc.int,
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
	do_close:                  proc "c" (self: ^Life_Span_Handler, browser: ^Browser) -> libc.int,

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
	is_valid:              proc "c" (self: ^Frame) -> libc.int,

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
		start_line: libc.int,
	),

	///
	/// Returns true (1) if this is the main (top-level) frame.
	///
	is_main:               proc "c" (self: ^Frame) -> libc.int,

	///
	/// Returns true (1) if this is the focused frame.
	///
	is_focused:            proc "c" (self: ^Frame) -> libc.int,

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
	x: libc.int,
	y: libc.int,
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
		is_loading: libc.int,
		can_go_back: libc.int,
		can_go_forward: libc.int,
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
		http_status_code: libc.int,
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
	) -> libc.int,

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
		view_x, view_y: libc.int,
		screen_x, screen_y: ^libc.int,
	) -> libc.int,

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
	) -> libc.int,

	///
	/// Called when the browser wants to show or hide the popup widget. The popup
	/// should be shown if |show| is true (1) and hidden if |show| is false (0).
	///
	on_popup_show:                    proc "c" (
		self: ^Render_Handler,
		browser: ^Browser,
		show: libc.int,
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
		dirty_rects_count: libc.size_t,
		dirty_rects: [^]Rect,
		buffer: rawptr,
		width, height: libc.int,
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
		dirty_rects_count: libc.size_t,
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
		x, y: libc.int,
	) -> libc.int,

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
		x, y: libc.double,
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
		character_bounds_count: libc.size_t,
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
	size: libc.size_t,
}

Horizontal_Alignment :: enum {
	Left,
	Center,
	Right,
}

Touch_Handle_State :: struct {
	size: libc.size_t,
}

Drag_Operations_Mask :: enum libc.uint32_t {
	None    = 0,
	Copy    = 1,
	Link    = 2,
	Generic = 4,
	Private = 8,
	Move    = 16,
	Delete  = 32,
	Every   = libc.UINT32_MAX,
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
	from, to: libc.uint32_t,
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

Browser :: struct {
	base:                    Base_Ref_Counted,
	is_valid:                proc "c" (self: ^Browser) -> libc.int,
	get_host:                proc "c" (self: ^Browser) -> ^Browser_Host,
	can_go_back:             proc "c" (self: ^Browser) -> libc.int,
	go_back:                 proc "c" (self: ^Browser),
	can_go_forward:          proc "c" (self: ^Browser) -> libc.int,
	go_forward:              proc "c" (self: ^Browser),
	is_loading:              proc "c" (self: ^Browser) -> libc.int,
	reload:                  proc "c" (self: ^Browser),
	reload_ignore_cache:     proc "c" (self: ^Browser),
	stop_load:               proc "c" (self: ^Browser),
	get_identifier:          proc "c" (self: ^Browser) -> libc.int,
	is_same:                 proc "c" (self: ^Browser, that: ^Browser) -> libc.int,
	is_popup:                proc "c" (self: ^Browser) -> libc.int,
	has_document:            proc "c" (self: ^Browser) -> libc.int,
	get_main_frame:          proc "c" (self: ^Browser) -> ^Frame,
	get_focused_frame:       proc "c" (self: ^Browser) -> ^Frame,
	get_frame_by_identifier: proc "c" (self: ^Browser, identifier: ^String) -> ^Frame,
	get_frame_count:         proc "c" (self: ^Browser) -> libc.int,
	get_frame_identifiers:   proc "c" (self: ^Browser, identifiers: String_List),
	get_frame_names:         proc "c" (self: ^Browser, names: String_List),
}

