local ffi = require("ffi")

local format = string.format

local gc = ffi.gc
local cast = ffi.cast
local cdef = ffi.cdef
local load = ffi.load
local metatype = ffi.metatype
local new = ffi.new
local typeof = ffi.typeof
local sizeof = ffi.sizeof
local string = ffi.string

local libc = ffi.C
local libusb = load("libusb-1.0.dll")

cdef [[
typedef long int ssize_t;

/* libusb */

struct libusb_context;
struct libusb_device;
struct libusb_device_handle;

/** \ingroup libusb_lib
 * Structure providing the version of the libusb runtime
 */
struct libusb_version {
	/** Library major version. */
	const uint16_t major;

	/** Library minor version. */
	const uint16_t minor;

	/** Library micro version. */
	const uint16_t micro;

	/** Library nano version. */
	const uint16_t nano;

	/** Library release candidate suffix string, e.g. "-rc4". */
	const char *rc;

	/** For ABI compatibility only. */
	const char *describe;
};

/** \ingroup libusb_desc
 * A structure representing the standard USB device descriptor. This
 * descriptor is documented in section 9.6.1 of the USB 3.0 specification.
 * All multiple-byte fields are represented in host-endian format.
 */
struct libusb_device_descriptor {
	/** Size of this descriptor (in bytes) */
	uint8_t  bLength;

	/** Descriptor type. Will have value
	 * \ref libusb_descriptor_type::LIBUSB_DT_DEVICE LIBUSB_DT_DEVICE in this
	 * context. */
	uint8_t  bDescriptorType;

	/** USB specification release number in binary-coded decimal. A value of
	 * 0x0200 indicates USB 2.0, 0x0110 indicates USB 1.1, etc. */
	uint16_t bcdUSB;

	/** USB-IF class code for the device. See \ref libusb_class_code. */
	uint8_t  bDeviceClass;

	/** USB-IF subclass code for the device, qualified by the bDeviceClass
	 * value */
	uint8_t  bDeviceSubClass;

	/** USB-IF protocol code for the device, qualified by the bDeviceClass and
	 * bDeviceSubClass values */
	uint8_t  bDeviceProtocol;

	/** Maximum packet size for endpoint 0 */
	uint8_t  bMaxPacketSize0;

	/** USB-IF vendor ID */
	uint16_t idVendor;

	/** USB-IF product ID */
	uint16_t idProduct;

	/** Device release number in binary-coded decimal */
	uint16_t bcdDevice;

	/** Index of string descriptor describing manufacturer */
	uint8_t  iManufacturer;

	/** Index of string descriptor describing product */
	uint8_t  iProduct;

	/** Index of string descriptor containing device serial number */
	uint8_t  iSerialNumber;

	/** Number of possible configurations */
	uint8_t  bNumConfigurations;
};

typedef struct libusb_context libusb_context;
typedef struct libusb_device libusb_device;
typedef struct libusb_device_handle libusb_device_handle;

ssize_t libusb_get_device_list(libusb_context *ctx,
	libusb_device ***list);
void libusb_free_device_list(libusb_device **list,
	int unref_devices);
libusb_device * libusb_ref_device(libusb_device *dev);
void libusb_unref_device(libusb_device *dev);

int libusb_init(libusb_context **ctx);
void libusb_exit(libusb_context *ctx);

const struct libusb_version * libusb_get_version(void);
int libusb_has_capability(uint32_t capability);
const char * libusb_error_name(int errcode);
int libusb_setlocale(const char *locale);
const char * libusb_strerror(int errcode);

int libusb_get_configuration(libusb_device_handle *dev,
	int *config);
int libusb_get_device_descriptor(libusb_device *dev,
	struct libusb_device_descriptor *desc);
int libusb_get_active_config_descriptor(libusb_device *dev,
	struct libusb_config_descriptor **config);
int libusb_get_config_descriptor(libusb_device *dev,
	uint8_t config_index, struct libusb_config_descriptor **config);
int libusb_get_config_descriptor_by_value(libusb_device *dev,
	uint8_t bConfigurationValue, struct libusb_config_descriptor **config);
void libusb_free_config_descriptor(
	struct libusb_config_descriptor *config);
int libusb_get_ss_endpoint_companion_descriptor(
	libusb_context *ctx,
	const struct libusb_endpoint_descriptor *endpoint,
	struct libusb_ss_endpoint_companion_descriptor **ep_comp);
void libusb_free_ss_endpoint_companion_descriptor(
	struct libusb_ss_endpoint_companion_descriptor *ep_comp);
int libusb_get_bos_descriptor(libusb_device_handle *dev_handle,
	struct libusb_bos_descriptor **bos);
void libusb_free_bos_descriptor(struct libusb_bos_descriptor *bos);
int libusb_get_usb_2_0_extension_descriptor(
	libusb_context *ctx,
	struct libusb_bos_dev_capability_descriptor *dev_cap,
	struct libusb_usb_2_0_extension_descriptor **usb_2_0_extension);
void libusb_free_usb_2_0_extension_descriptor(
	struct libusb_usb_2_0_extension_descriptor *usb_2_0_extension);
int libusb_get_ss_usb_device_capability_descriptor(
	libusb_context *ctx,
	struct libusb_bos_dev_capability_descriptor *dev_cap,
	struct libusb_ss_usb_device_capability_descriptor **ss_usb_device_cap);
void libusb_free_ss_usb_device_capability_descriptor(
	struct libusb_ss_usb_device_capability_descriptor *ss_usb_device_cap);
int libusb_get_container_id_descriptor(libusb_context *ctx,
	struct libusb_bos_dev_capability_descriptor *dev_cap,
	struct libusb_container_id_descriptor **container_id);
void libusb_free_container_id_descriptor(
	struct libusb_container_id_descriptor *container_id);
uint8_t libusb_get_bus_number(libusb_device *dev);
uint8_t libusb_get_port_number(libusb_device *dev);
int libusb_get_port_numbers(libusb_device *dev, uint8_t *port_numbers, int port_numbers_len);
int libusb_get_port_path(libusb_context *ctx, libusb_device *dev, uint8_t *path, uint8_t path_length);
libusb_device * libusb_get_parent(libusb_device *dev);
uint8_t libusb_get_device_address(libusb_device *dev);
int libusb_get_device_speed(libusb_device *dev);
int libusb_get_max_packet_size(libusb_device *dev,
	unsigned char endpoint);
int libusb_get_max_iso_packet_size(libusb_device *dev,
	unsigned char endpoint);

int libusb_open(libusb_device *dev, libusb_device_handle **dev_handle);
void libusb_close(libusb_device_handle *dev_handle);
libusb_device * libusb_get_device(libusb_device_handle *dev_handle);
]]

local function getVersion()
	local version = libusb.libusb_get_version()
	return format("%d.%d.%d.%d%s", version.major, version.minor, version.micro, version.nano, string(version.rc))
end

local function throw(code)
	local version = libusb.libusb_get_version()
	local message = string(libusb.libusb_strerror(code))
	return error(format("[%s] %s", getVersion(), message))
end

local USB_CONTEXT = {}
USB_CONTEXT.__index = USB_CONTEXT

local new_libusb_context_ptr = typeof("libusb_context*[1]")
local new_libusb_device_ptr = typeof("libusb_device**[1]")

function USB_CONTEXT:__new()
	local libusb_context = new_libusb_context_ptr()

	err = libusb.libusb_init(libusb_context)
	if err < 0 then return throw(err) end

	gc(libusb_context[0], libusb.libusb_exit)

	return libusb_context[0]
end

function USB_CONTEXT:get_device_list()
	local list = new_libusb_device_ptr()
	local size = libusb.libusb_get_device_list(self, list)
	if size < 0 then return throw(size) end

	local desc = new("struct libusb_device_descriptor")

	for i=0, size-1 do
		local device = list[0][i]

		local ret = libusb.libusb_get_device_descriptor(device, desc)

		if desc.idVendor == 0x057e and desc.idProduct == 0x0337 then
			print(i, desc.idVendor, desc.idProduct)

			local bus  = libusb.libusb_get_bus_number(device)
			local port = libusb.libusb_get_device_address(device)

			local handle = new("struct libusb_device_handle*[1]")

			ret = libusb.libusb_open(device, handle)

			print(ret, bus, port, handle)
		end
	end

	libusb.libusb_free_device_list(list[0], 1)

	return list
end

function USB_CONTEXT:free_device_list(list, unref_devices)
	libusb.libusb_free_device_list(list[0], unref_devices)
end

return metatype("libusb_context", USB_CONTEXT)